configuration PoRuntimeSWTimersC
{
	provides interface PoRuntimeSWTimersI;
}

implementation
{
	components PoRuntimeSWTimersM, MainC, new PoSWTimerC() as PoSWTimer;

	MainC.SoftwareInit->PoRuntimeSWTimersM.Init;
	PoRuntimeSWTimersM.TimerMilli->PoSWTimer;
	PoRuntimeSWTimersI = PoRuntimeSWTimersM.PoRuntimeSWTimersI;
}
