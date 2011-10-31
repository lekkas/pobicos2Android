#include "PoSWTimer.h"

generic module PoSWTimerM() @ safe()
{
	provides interface Timer < TMilli > as Timer[uint8_t num];
}

implementation
{

	
	jint Java_org_lekkas_poclient_PoAPI_TimerService_nativeTimerFired(JNIEnv *env, 
		jobject obj, jbyte num) __attribute__ ((C, spontaneous)) {

		signal Timer.fired[num] ();
		return 99;
	}

	command void Timer.startPeriodic[uint8_t num] (uint32_t dt)
	{
		call Timer.startOneShotAt[num](call Timer.getNow[num](),  dt);
	}

	command void Timer.startOneShot[uint8_t num] (uint32_t dt)
	{
		call Timer.startOneShotAt[num](call Timer.getNow[num](),  dt);
	}

	command void Timer.stop[uint8_t num] ()
	{
		(*cached_JNIEnv)->CallVoidMethod(cached_JNIEnv, cached_timer_obj, cached_TimerStop_mid, num);
	}

	command bool Timer.isRunning[uint8_t num] ()
	{
		return (*cached_JNIEnv)->CallBooleanMethod(cached_JNIEnv, cached_timer_obj, cached_TimerIsRunning_mid, num);
	}

	command bool Timer.isOneShot[uint8_t num] ()
	{
		return (*cached_JNIEnv)->CallBooleanMethod(cached_JNIEnv, cached_timer_obj, cached_TimerIsOneShot_mid, num);
	}

	command void Timer.startPeriodicAt[uint8_t num] (uint32_t t0, uint32_t dt)
	{
		jboolean isOneShot = FALSE;
		(*cached_JNIEnv)->CallVoidMethod(cached_JNIEnv, cached_timer_obj, cached_StartTimer_mid, num, t0, dt, isOneShot);
	}

	command void Timer.startOneShotAt[uint8_t num] (uint32_t t0, uint32_t dt)
	{
		jboolean isOneShot = TRUE;
		(*cached_JNIEnv)->CallVoidMethod(cached_JNIEnv, cached_timer_obj, cached_StartTimer_mid, num, t0, dt, isOneShot);
	}

	command uint32_t Timer.getNow[uint8_t num] ()
	{
		return (*cached_JNIEnv)->CallIntMethod(cached_JNIEnv, cached_timer_obj, cached_TimerGetNow_mid, num);
	}

	command uint32_t Timer.gett0[uint8_t num] ()
	{
		return (*cached_JNIEnv)->CallIntMethod(cached_JNIEnv, cached_timer_obj, cached_TimerGett0_mid, num);
	}

	command uint32_t Timer.getdt[uint8_t num] ()
	{
		return (*cached_JNIEnv)->CallIntMethod(cached_JNIEnv, cached_timer_obj, cached_TimerGetdt_mid, num);
	}

	default event void Timer.fired[uint8_t num] ()
	{
	}
}
