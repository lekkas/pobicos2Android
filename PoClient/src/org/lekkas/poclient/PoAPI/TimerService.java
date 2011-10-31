package org.lekkas.poclient.PoAPI;

import java.util.Vector;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

import org.lekkas.poclient.Serialization;
import org.lekkas.poclient.PoEvents.PoTimerFired;

import android.util.Log;

public class TimerService implements TimerServiceI {
	/*
	 * JNI Calls used
	 */
	private native int nativeTimerFired(byte tid);
	
	private static final String TAG = "TimerService";
	private static final TimerService INSTANCE = new TimerService();
	
	// Log starting time, so our internal clock starts from 0
	private static final long Init_Time = System.currentTimeMillis();
	private static ScheduledThreadPoolExecutor timer_sched;
	private Vector<TimerService.TimerDescriptor> timer_list;
	
	
	private class TimerTask implements Runnable {
		byte unsigned_tid;
		public TimerTask(byte id) {
			unsigned_tid = id;
		}
		public void run() {
			PoTimerFired evt = new PoTimerFired(unsigned_tid);
			PoAPI.getEventQueue().offer(evt);	
		}
	}
	private class TimerDescriptor {
		private byte unsigned_tid;
		private int unsigned_t0;
		private int unsigned_dt;
		private boolean isOneShot;
		private boolean isRunning;
		ScheduledFuture<?> task;
		
		public TimerDescriptor(byte id, int t0, int dt, boolean oneshot, 
				boolean running, ScheduledFuture<?> t) {
		
			unsigned_tid = id;
			unsigned_t0 = t0;
			unsigned_dt = dt;
			isOneShot = oneshot;
			isRunning = running;
			task = t;
		}
		
		byte getID() {
			return unsigned_tid;
		}
		int gett0() {
			return unsigned_t0;
		}
		int getdt() {
			return unsigned_dt;
		}
		boolean isRunning() {
			return isRunning;
		}
		boolean isOneShot() {
			return isOneShot;
		}
		ScheduledFuture<?> getTask() {
			return task;
		}
		void sett0(int t0) {
			unsigned_t0 = t0;
		}
		void setdt(int dt) {
			unsigned_dt = dt;
		}
		void setRunning(boolean r) {
			isRunning = r;
		}
		void setOneShot(boolean o) {
			isOneShot = o;
		}
		void setTask(ScheduledFuture<?> t) {
			task = t;
		}
	}
	

	private TimerService() { 
		Log.w(TAG, "Started!");
		timer_sched = new ScheduledThreadPoolExecutor(1);
		timer_list = new Vector<TimerService.TimerDescriptor>();
	}
	
	private TimerService.TimerDescriptor findTimer(byte unsigned_tid) {
		for(TimerService.TimerDescriptor tmp_td : timer_list) {
			if(tmp_td.getID() == unsigned_tid) 
				return tmp_td;
		}
		return null;
	}
	public void JNICall_fireTimer(byte tid) {
		TimerService.TimerDescriptor td;
		td = findTimer(tid);
		if(!td.isOneShot()) {
			td.sett0(getIntNow());
		}
		else {
			td.setRunning(false);
		}

		nativeTimerFired(tid);
	}
	
	/*
	 * dt is passed from tinyOS as an unsigned little-endian
	 * 32bit jnit.
	 */
	public void JNICallback_startTimer(byte unsigned_id, int unsigned_t0, 
			int unsigned_dt, boolean isoneshot) {
			TimerService.TimerDescriptor td = null;
			ScheduledFuture<?> t;
			
			long now = System.currentTimeMillis() - Init_Time;
			long t1 = Serialization.uint32ToLong(unsigned_t0) + Serialization.uint32ToLong(unsigned_dt);			
			long initial_delay;
			
			if(now <= t1)
				initial_delay = t1 - now;
			else { // timer already expired
				initial_delay = 0;
				// Log.w(TAG, "WARNING: T0 > NOW()");
			}
			
			td = findTimer(unsigned_id);
			
			if(td != null) {	// found timer
				td.getTask().cancel(false);		// cancel pending task
				td.sett0(unsigned_t0);
				td.setdt(unsigned_dt);
				td.setOneShot(isoneshot);
				td.setRunning(true);
			}
			else {	// new instance
				td = new TimerDescriptor(unsigned_id, unsigned_t0, unsigned_dt, 
						isoneshot, true, null);
				timer_list.add(td);
			}
			
			/*
			 * Timer info is created/updated. Now, fire it.
			 */
			if(isoneshot)
				t = timer_sched.schedule(new TimerTask(unsigned_id), initial_delay, 
						TimeUnit.MILLISECONDS);
			else 
				t = timer_sched.scheduleAtFixedRate(new TimerTask(unsigned_id), 
						initial_delay, Serialization.uint32ToLong(unsigned_dt), TimeUnit.MILLISECONDS);
						
			td.setTask(t);
			
	}
	public int JNICallback_getNow(byte tid) {
		return getIntNow();
	}
	
	public int JNICallback_gett0(byte tid) {
		TimerService.TimerDescriptor t = findTimer(tid);
		if(t != null)
			return t.gett0();
		
		return 0;
	}
	
	public int JNICallback_getdt(byte tid) {
		TimerService.TimerDescriptor t = findTimer(tid);
		if(t != null)
			return t.getdt();
		
		return 0;
	}
	public boolean JNICallback_isRunning(byte tid) {
		TimerService.TimerDescriptor t = findTimer(tid);
		if(t != null)
			return t.isRunning();
		
		return false;
	}
	public boolean JNICallback_isOneShot(byte tid) {
		TimerService.TimerDescriptor t = findTimer(tid);
		if(t != null)
			return t.isOneShot();
		
		return false;
	}
	public void JNICallback_stop(byte tid) {
		TimerService.TimerDescriptor t = findTimer(tid);
		if(t != null) {
			t.getTask().cancel(false);
			t.setRunning(false);
		}
	}
	
	private int getIntNow() {
		/*
		 * We only want the least-significant 32 bits of system time.
		 * The timer functions support time 'wrap around'
		 */
		long now = ( (System.currentTimeMillis()-Init_Time) & 0x00000000FFFFFFFFL );
		//Log.w(TAG, "Android: now = "+now);
		return (int) now;
	}
	
	public static TimerService getInstance() {
		return INSTANCE;
	}
	
}
