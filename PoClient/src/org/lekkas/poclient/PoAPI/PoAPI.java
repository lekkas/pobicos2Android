package org.lekkas.poclient.PoAPI;
import java.util.concurrent.LinkedBlockingQueue;

import org.lekkas.poclient.PoEvents.PoEvent;
import android.util.Log;

/*
 * The PoAPI Class:
 * 	1) Initializes the Event thread.
 * 	2) Initializes the Event Queue.
 *  3) Provides start() and stop() methods to kill the Event handler thread and
 *  	eventually unload the middleware library.
 */
public final class PoAPI implements PoAPIInterface {
	private static final String TAG = "PoAPI";
	private static EventHandlerThread handler_thread;
	private static final LinkedBlockingQueue<PoEvent> EventQueue = new LinkedBlockingQueue<PoEvent>();
	private static final PoAPI INSTANCE = new PoAPI();
	private static STATE status; 
	private static boolean hostsRootAgent;
	
	enum STATE {
		RUNNING,
		STOPPED
	};
	
	public static boolean hostsRootAgent() {
		return hostsRootAgent;
	}
	public static void setHostsRootAgent(boolean b) {
		hostsRootAgent = b;
	}
	
	private PoAPI() {
		ClassLoader loader =  this.getClass().getClassLoader();
		try {
			loader.loadClass("org.lekkas.poclient.PoAPI.EventHandlerThread");
		} catch(ClassNotFoundException e) {
			Log.w(TAG, "Class not found: "+e.getMessage());
		}
	}
	
	public static PoAPI getInstance() {
		return INSTANCE;
	}
	
	public static boolean isRunning() {
		return status == STATE.RUNNING ? true : false;
	}
	public void start() {
		handler_thread = new EventHandlerThread(EventQueue);
		if (PoAPI.class.getClassLoader() == handler_thread.getClass().getClassLoader())
			Log.w(TAG, "Classloader of POAPI is the same with evt handler thread");
		handler_thread.start();
		status = STATE.RUNNING;
	}
	
	/*
	 * Cancels Event thread.
	 */
	public void stop() {
		handler_thread.cancel();
		try {
			handler_thread.join();
			Log.w(TAG, "Main thread join(): Event handler thread is killed");
			status = STATE.STOPPED;
			handler_thread = null;
			EventQueue.clear();
		} catch(InterruptedException e) {
			Log.w(TAG, "PoAPI interrupted while join()'ing evt handler thread.");
		}
	}
	
	public static LinkedBlockingQueue<PoEvent> getEventQueue() {
		return EventQueue;
	}

	public void finalize() {
		
	}
	static {
		
	}
}
