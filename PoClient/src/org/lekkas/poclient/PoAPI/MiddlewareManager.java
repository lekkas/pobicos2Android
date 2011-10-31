package org.lekkas.poclient.PoAPI;

import java.util.concurrent.LinkedBlockingQueue;

import org.lekkas.poclient.PoCommMgrWriteTask;
import org.lekkas.poclient.PoConnMgrReadTask;
import org.lekkas.poclient.PoEvents.PoEvent;
import android.util.Log;

public final class MiddlewareManager implements MiddlewareManagerI {
	/*
	 * JNI Calls used
	 */
	private native String stringFromJNI();
	private native int nativeMain();
	private native int nativeInit();
	private native int nativeCompleteTasks();
	
	private static final String TAG = "MiddlewareManager";
	private static final MiddlewareManager INSTANCE = new MiddlewareManager();
	
	private LinkedBlockingQueue<PoEvent> EventQueue;	
	private static NetworkService net;
	private static TimerService timer;
	private static UARTService uart;
	private static NGResources ng;
	private static String msg;
	
	private static long startMillis, stopMillis;
	/*
	 * Initializes Middleware Services.
	 */
	private MiddlewareManager() {
		Log.w(TAG, "MiddlewareManager started");
		
		/*
		 * We need to ensure that all service classes are loaded
		 * by the same classloader, as native libraries are associated
		 * with classloaders. So if, for example, TimerService
		 * was loaded by a different classloader, the middleware library
		 * would not be available to that object.
		 */
		ClassLoader loader =  this.getClass().getClassLoader();
		try {
			loader.loadClass("org.lekkas.poclient.PoAPI.NetworkService");
			loader.loadClass("org.lekkas.poclient.PoAPI.TimerService");
			loader.loadClass("org.lekkas.poclient.PoAPI.UARTService");
			loader.loadClass("org.lekkas.poclient.PoAPI.NGResources");

		} catch(ClassNotFoundException e) {
			Log.w(TAG, "Class not found: "+e.getMessage());
		}
		Log.w(TAG, "Services loaded successfuly.");
		
		net = NetworkService.getInstance();
		timer = TimerService.getInstance();
		uart = UARTService.getInstance();
		ng = NGResources.getInstance();
		
		if (this.getClass().getClassLoader() == net.getClass().getClassLoader() )
			Log.w(TAG, "net ok");
		if (this.getClass().getClassLoader() == timer.getClass().getClassLoader() )
			Log.w(TAG, "timer ok");
		if (this.getClass().getClassLoader() == uart.getClass().getClassLoader() )
			Log.w(TAG, "uart ok");
		if (this.getClass().getClassLoader() == ng.getClass().getClassLoader() )
			Log.w(TAG, "ng ok");
		
		EventQueue = PoAPI.getEventQueue();	
	}
	
	public void JNICall_InitMiddleware() {
		int ret = nativeInit();
		Log.w(TAG, "nativeInit() returned: "+ret);
		
		ret = nativeMain();
		Log.w(TAG, "nativeMain() returned: "+ret);
	}
    
	
	public void JNICall_completeTasks() {
		nativeCompleteTasks(); 
	}
	
	public static MiddlewareManager getInstance() {
		return INSTANCE;
	}
	
	int cnt=0;
	public void JNICallback_dbg(String dbg) {
    	Log.w(TAG,"DEBUG: "+ dbg);
    	if(dbg.contains("__BYTE__START__")) {
    		startMillis = System.currentTimeMillis();
    		PoCommMgrWriteTask.logBytes = true;
    		PoConnMgrReadTask.logBytes = true;
    		Log.e(TAG, "Start: "+startMillis);
    	}
    	if(dbg.contains("__BYTE__STOP__")) {
    		cnt++;
    		stopMillis = System.currentTimeMillis();
    		long diff = stopMillis - startMillis;
    		Log.e(TAG, "Diff in millis: "+diff);
    		if(cnt == 2) {
    			PoCommMgrWriteTask.logBytes = false;
    			PoConnMgrReadTask.logBytes = false;
    		
    			Log.e(TAG, "Bytes sent: "+PoCommMgrWriteTask.sentBytes+" .Packets: " + 
    			PoCommMgrWriteTask.cntTxPkts);
    			
    			Log.e(TAG, "Bytes received: "+PoConnMgrReadTask.receivedBytes+" .Packets: " +
    			PoConnMgrReadTask.cntRxPkts);
    			PoCommMgrWriteTask.sentBytes = 0;
    			PoConnMgrReadTask.receivedBytes = 0;
    			PoCommMgrWriteTask.cntTxPkts = 0;
    			PoConnMgrReadTask.cntRxPkts = 0;
    			
    			cnt = 0;
    		}
    	}
    	
	}
	
	public static String getMsg() {
		return msg;
	}
	
    static 
    {
    	System.loadLibrary("middleware");
		Log.w(TAG, "Library is loaded.");
    } 

    public void finalize() {
    	Log.w(TAG, "Finalizer function()");
    }
}
