#include <Timer.h>
#include <sys/time.h>
#include <time.h>

#if !defined(__CYGWIN__)
  #include <errno.h>
#endif
#include <semaphore.h>
#include <pthread.h>

module PoHWAsyncTimerM
{
	provides interface Init;
	provides interface Timer < TMilli > as TimerMilli;
}
implementation
{
	#define DBG_PO_HW_ASYNC_TIMER "PoHWAsyncTimerM"

	typedef struct tossim_timer
	{
		uint32_t t0;
		uint32_t dt;
		bool isPeriodic;
		bool isActive;
		sim_event_t *evt;
	} tossim_timer_t;

	tossim_timer_t timer;

	uint32_t initTime;
	struct timeval initTv;
	sem_t sem;

	void initializeEvent(sim_event_t * evt, uint8_t timerID);

	void tossim_timer_handle(sim_event_t * evt);

	void post_sim_queue()
	{
                sim_event_t * temp_evt;
		while (1)
		{
			sem_wait(&sem);
			timer.evt = sim_queue_allocate_event();
            temp_evt = timer.evt;
			assert(temp_evt != NULL, ASSERT_OUT_OF_MEMORY_FOR_EVENTS, "PoHWAsyncTimerM: Out of memory for event allocation");
			
			initializeEvent(temp_evt, 0);
			temp_evt->time = sim_time();
			
			sync_sim_queue_insert(temp_evt);
			//sim_queue_insert(timer.evt);
		}
	}

	void alarm_handler(int signo)
	{
		if (signo != SIGALRM)
		{
			fprintf(stderr, "alarm handler signalled by wrong signal no: %d\n", signo);
			return;
		}
		sem_post(&sem);
	}
	
	command error_t Init.init()
	{
		pthread_t t;

		memset(&timer, 0, sizeof(timer));
		gettimeofday(&initTv, NULL);
		initTime = 0;
		if (sem_init(&sem, 0, 0) != 0)
		{
#if !defined(__CYGWIN__)
			fprintf(stderr, "PoHWAsyncTimerM.nc: line %d: sem_init: %s \n", __LINE__, strerror(errno));
#else
			fprintf(stderr, "PoHWAsyncTimerM.nc: line %d\n", __LINE__);
#endif
			exit(1);

		}

		if (pthread_create(&t, NULL, (void *(*)(void *)) post_sim_queue, NULL) != 0)
		{
			fprintf(stderr, "PoHWAsyncTimerM.nc: line %d: pthread_create failed\n", __LINE__);
			exit(1);
		}
		dbg("INIT", "PoHWAsyncTimerM init\n");
		return SUCCESS;
	}

	command void TimerMilli.startPeriodic (uint32_t dt)
	{
		call TimerMilli.startPeriodicAt (call TimerMilli.getNow(), dt);
	}
	command void TimerMilli.startOneShot (uint32_t dt)
	{
		call TimerMilli.startOneShotAt (call TimerMilli.getNow(), dt);
	}

	command void TimerMilli.stop()
	{
		struct itimerval val;

		val.it_interval.tv_sec = 0;
		val.it_interval.tv_usec = 0;
		val.it_value.tv_sec = 0;
		val.it_value.tv_usec = 0;

		if (setitimer(ITIMER_REAL, &val, NULL) != 0)
		{
#if !defined(__CYGWIN__)
			perror("setitimer");
			exit(errno);
#else
			printf("ERROR: setitimer\n");
			exit(1);
#endif
		}

		//dbg(DBG_PO_HW_ASYNC_TIMER,"TIMER STOPPED\n");

		timer.isActive = 0;
/*
// tp-20110210 - after analyze with Giorgis, it seems that this block is not needed at all
		if (timer.evt != NULL)
		{
			timer.evt->cancelled = 1;
			// tp-20110207 - possible cause of concurrent modification?
			//timer.evt->cleanup = sim_queue_cleanup_total;
                        // tp-20110210 - commenting this out breaks comm, why?
			timer.evt = NULL;
		}
*/		
	}

	// extended interface
	command bool TimerMilli.isRunning()
	{
		return timer.isActive;
	}
	command bool TimerMilli.isOneShot()
	{
		return !timer.isActive;
	}

	command void TimerMilli.startPeriodicAt(uint32_t t0, uint32_t dt)
	{
		call TimerMilli.startOneShotAt(t0, dt);

		timer.isPeriodic = 1;
	}
	command void TimerMilli.startOneShotAt(uint32_t t0, uint32_t dt)
	{

		struct itimerval val;
		struct sigaction act;
		struct timeval tv;

		val.it_interval.tv_sec = 0;
		val.it_interval.tv_usec = 0;
		val.it_value.tv_sec = dt / 1000;
		val.it_value.tv_usec = (dt % 1000) * 1000;

		memset(&act, 0, sizeof(struct sigaction));
		act.sa_handler = alarm_handler;

		if (sigaction(SIGALRM, &act, NULL) != 0)
		{
#if !defined(__CYGWIN__)
			perror("sigaction");
			exit(errno);
#else
			printf("ERROR: sigaction\n");
			exit(1);
#endif
		}

		if (setitimer(ITIMER_REAL, &val, NULL) != 0)
		{
#if !defined(__CYGWIN__)
			perror("setitimer");
			exit(errno);
#else
			printf("ERROR: setitimer\n");
			exit(1);
#endif
		}

		timer.isPeriodic = 0;
		timer.isActive = 1;
		gettimeofday(&tv, NULL);
		timer.t0 = (tv.tv_sec * 1000 + tv.tv_usec / 1000) - (initTv.tv_sec * 1000 + initTv.tv_usec / 1000);
		timer.dt = dt;
	}

	command uint32_t TimerMilli.getNow()
	{
		struct timeval tv;
		uint32_t now;

		gettimeofday(&tv, NULL);
		now = (tv.tv_sec * 1000 + tv.tv_usec / 1000) - (initTv.tv_sec * 1000 + initTv.tv_usec / 1000);
		return now;
	}

	command uint32_t TimerMilli.gett0()
	{
		return timer.t0;
	}
	command uint32_t TimerMilli.getdt()
	{
		return timer.dt;
	}
	
	void tossim_timer_handle(struct sim_event* evt)
	{
		//uint8_t *datum = (uint8_t *) evt->data;
		//uint8_t id = *datum;
		signal TimerMilli.fired();

		// We should only re-enqueue the event if it is a follow-up firing
		// of the same timer.  If the timer is stopped, it's a one shot,
		// or someone has started a new timer, don't re-enqueue it.
		if (timer.isActive && timer.isPeriodic && timer.evt == evt)
		{
			call TimerMilli.startOneShot(timer.dt);
		}
		// If we aren't enqueueing it, and nobody has done something that
		// would cause the event to have been garbage collected, then do
		// so.
		else if (timer.evt == evt)
		{
			call TimerMilli.stop();
		}
	}

	void initializeEvent(sim_event_t * evt, uint8_t timerID)
	{
		uint8_t *data = (uint8_t *) malloc(sizeof(uint8_t));

		*data = timerID;

		evt->handle = tossim_timer_handle;
		evt->cleanup = sim_queue_cleanup_total;
		evt->data = data;
		evt->cancelled = 0;
	}

	default event void TimerMilli.fired()
	{
	}
}
