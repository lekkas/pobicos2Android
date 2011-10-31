configuration PoSWTimerP
{
	provides interface Timer < TMilli > as TimerMilli[uint8_t id];
}

implementation
{
	components MainC, new PoSWTimerM() as PoSWTimerM;

	// MainC.SoftwareInit->PoHWAndroidTimerM.Init;
	// PoSWTimerM.TimerFrom->PoHWAandroidTimerM.TimerMilli;
	
	TimerMilli = PoSWTimerM.Timer;
}
