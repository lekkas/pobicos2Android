module PoRuntimeSWTimersM
{
	provides interface Init;
	provides interface PoRuntimeSWTimersI;
	uses interface Timer < TMilli > as TimerMilli;
}

implementation
{
	enum
	{
		NUM_TIMERS = 128
	};

	typedef struct
	{
		uint32_t t0;
		uint32_t dt;
		bool iscreated:1;
		bool isoneshot:1;
		bool isrunning:1;
	} RTimer_t;

	RTimer_t timers[NUM_TIMERS];

	task void updateFromTimer();

	void fireTimers(uint32_t now)
	{
		uint8_t num;

		for (num = 0; num < NUM_TIMERS; num++)
		{
			RTimer_t *timer = &timers[num];

			if (timer->isrunning)
			{
				uint32_t elapsed = now - timer->t0;

				if (elapsed >= timer->dt)
				{
					if (timer->isoneshot)
					{
						timer->isrunning = FALSE;
					}
					else									// Update timer for next event
					{
						timer->t0 += timer->dt;
					}

					signal PoRuntimeSWTimersI.fired(num);

					break;
				}
			}
		}
		post updateFromTimer();
	}

	task void updateFromTimer()
	{
		/* This code supports a maximum dt of MAXINT. If min_remaining and
		   remaining were switched to uint32_t, and the logic changed a
		   little, dt's up to 2^32-1 should work (but at a slightly higher
		   runtime cost). */
		uint32_t now = call TimerMilli.getNow();
		int32_t min_remaining = (1UL << 31) - 1;	/* max int32_t */
		bool min_remaining_isset = FALSE;
		uint8_t num;

		call TimerMilli.stop();

		for (num = 0; num < NUM_TIMERS; num++)
		{
			RTimer_t *timer = &timers[num];
			//dbg("test","timer %d\nt0:%u\ndt:%u\nisoneshot:%d\nisrunning:%d\n============\n",num,timer->t0,timer->dt,timer->isoneshot,timer->isrunning);

			if (timer->isrunning)
			{
				uint32_t elapsed = now - timer->t0;
				int32_t remaining = timer->dt - elapsed;

				//dbg("test","num:%d,remaining:%d,min_remaining:%d\n",num,remaining,min_remaining);
				if (remaining < min_remaining)
				{
					min_remaining = remaining;
					min_remaining_isset = TRUE;
				}
			}
		}

		if (min_remaining_isset)
		{
			if (min_remaining <= 0)
			{
				fireTimers(now);
			}
			else
			{
				call TimerMilli.startOneShotAt(now, min_remaining);
			}
		}
	}

	command error_t Init.init()
	{
		int num;
		for (num = 0; num < NUM_TIMERS; num++)
		{
			timers[num].iscreated = 0;
			timers[num].isrunning=0;
		}
		dbg("INIT","PoRuntimeSWTimersM\n");

		return SUCCESS;
	}

	command uint32_t PoRuntimeSWTimersI.getNow()
	{
		return call TimerMilli.getNow();
	}

	command error_t PoRuntimeSWTimersI.createTimer(uint8_t * id)
	{
		int num;
		for (num = 0; num < NUM_TIMERS; num++)
		{
			if (!timers[num].iscreated)
			{
				*id = num;
				timers[num].iscreated = 1;
				return SUCCESS;
			}
		}

		return FAIL;
	}

	command error_t PoRuntimeSWTimersI.destroyTimer(uint8_t id)
	{
		if (id > NUM_TIMERS - 1)
		{
			return FAIL;
		}

		if (!timers[id].iscreated)
		{
			return FAIL;
		}

		timers[id].iscreated=0;
		timers[id].isrunning = 0;

		return SUCCESS;
	}

	void startTimer(uint8_t id, uint32_t t0, uint32_t timeout, bool isoneshot)
	{
		timers[id].t0 = t0;
		timers[id].dt = timeout;
		timers[id].isoneshot = isoneshot;
		post updateFromTimer();
	}

	command error_t PoRuntimeSWTimersI.startOneShot(uint8_t id, uint32_t timeout)
	{
		if (!timers[id].iscreated)
		{
			return FAIL;
		}

		timers[id].isrunning=1;
		startTimer(id, call TimerMilli.getNow(), timeout, 1);

		return SUCCESS;
	}

	command error_t PoRuntimeSWTimersI.startPeriodic(uint8_t id, uint32_t timeout)
	{
		if (!timers[id].iscreated)
		{
			return FAIL;
		}

		timers[id].isrunning=1;
		startTimer(id, call TimerMilli.getNow(), timeout, 0);

		return SUCCESS;
	}
	
	command error_t PoRuntimeSWTimersI.getTimeLeft(uint8_t id,uint32_t *remaining)
	{
		uint32_t elapsed;
		int32_t rem_time;
		
		if (id > NUM_TIMERS - 1)
		{
			return FAIL;
		}

		if (!timers[id].isrunning)
		{
			return FAIL;
		}
		
		elapsed = call TimerMilli.getNow() - timers[id].t0;
		rem_time = timers[id].dt - elapsed;
		
		if(rem_time<0)
		{
			*remaining=0;
		}
		else
		{
			*remaining=rem_time;
		}
		
		return SUCCESS;
	}

	event void TimerMilli.fired()
	{
		fireTimers(call TimerMilli.getNow());
	}
}
