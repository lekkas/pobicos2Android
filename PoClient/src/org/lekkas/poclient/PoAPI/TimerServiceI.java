package org.lekkas.poclient.PoAPI;

public interface TimerServiceI {
	public void JNICall_fireTimer(byte tid);
	public void JNICallback_startTimer(byte unsigned_id, int unsigned_t0, 
	int unsigned_dt, boolean isoneshot);
	public int JNICallback_getNow(byte tid);
	public int JNICallback_gett0(byte tid);
	public int JNICallback_getdt(byte tid);
	public boolean JNICallback_isRunning(byte tid);
	public boolean JNICallback_isOneShot(byte tid);
	public void JNICallback_stop(byte tid);
}
