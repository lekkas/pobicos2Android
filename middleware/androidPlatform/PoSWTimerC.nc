#include "PoSWTimer.h"

generic configuration PoSWTimerC()
{
	provides interface Timer < TMilli > as Timer;
}

implementation
{


	/*
	 * This is commented out as Android timers are not yet available.
	 */

	 components PoSWTimerP;
	 Timer = PoSWTimerP.TimerMilli[unique(PO_SW_TIMERS)];


	/*
	 * This implementation uses the default tinyOS timers (Not real time)
	 */
	//components new TimerMilliC() as TimerMilliC;
	//Timer=TimerMilliC;
}
