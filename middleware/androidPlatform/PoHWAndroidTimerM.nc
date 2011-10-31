module PoHWAndroidTimerM
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

	command error_t Init.init()
	{
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
		// inactivate timer
	}
	
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
		/* JNI CALLBACK */
	}

	command uint32_t TimerMilli.getNow()
	{
		// Get time 'now'
	}

	command uint32_t TimerMilli.gett0()
	{
		return timer.t0;
	}

	command uint32_t TimerMilli.getdt()
	{
		return timer.dt;
	}

	default event void TimerMilli.fired()
	{
	}
	
	void Timer_handler() {
		signal TimerMilli.fired();
			
	}

}
