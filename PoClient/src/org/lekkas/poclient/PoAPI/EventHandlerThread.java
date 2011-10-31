package org.lekkas.poclient.PoAPI;

import java.util.concurrent.LinkedBlockingQueue;

import org.lekkas.poclient.PoEvents.PoDialogInputReceived;
import org.lekkas.poclient.PoEvents.PoEvent;
import org.lekkas.poclient.PoEvents.PoNGEvent;
import org.lekkas.poclient.PoEvents.PoNetworkEvent;
import org.lekkas.poclient.PoEvents.PoNetworkPacketRx;
import org.lekkas.poclient.PoEvents.PoTimerFired;
import org.lekkas.poclient.PoEvents.PoUARTByteRx;

import android.util.Log;


public class EventHandlerThread extends Thread implements Runnable {
	private final String TAG = "PoEventHandlerThread";
	private boolean Running;
	LinkedBlockingQueue<PoEvent> EventQueue;
	
	private MiddlewareManager mgr;
	private NetworkService net;
	private TimerService timer;
	private UARTService uart;
	private NGResources ng;

	public EventHandlerThread(LinkedBlockingQueue<PoEvent> q) {
		Running = false;
		EventQueue = q;
	}
	
	public void run() {
		Log.w(TAG, "Event Handler Thread started!");
		Running = true;
		
		
		/* It is very important that we initialize the MiddlewareManager
		 * class FIRST.
		 * We want the same classloader to load manager & services.
		 * (library visibility, as each classloader has its own libraries.)
		 */
		ClassLoader loader =  this.getClass().getClassLoader();
		try {
			loader.loadClass("org.lekkas.poclient.PoAPI.MiddlewareManager");
		} catch(ClassNotFoundException e) {
			Log.w(TAG, "Class not found: "+e.getMessage());
		}
		Log.w(TAG, "MiddlewareManager class loaded successfuly.");
		
		mgr = MiddlewareManager.getInstance();
		if (this.getClass().getClassLoader() == mgr.getClass().getClassLoader() )
			Log.w(TAG, "Classloader of evt handler thread is the same with MiddlewareManager");
		
		mgr.JNICall_InitMiddleware();
		
		net = NetworkService.getInstance();
		timer = TimerService.getInstance();
		uart = UARTService.getInstance();
		ng = NGResources.getInstance();
		
		//LinkedBlockingQueue<PoEvent> EventQueue = PoAPI.getInstance().getEventQueue();
		PoEvent evt;
		while(!Thread.currentThread().isInterrupted()) {
			try {
				evt = EventQueue.take();	// BLOCKS when queue is empty
				DispatchEvt(evt);	// dispatch Event
			} catch (InterruptedException e) {
				Log.w(TAG, "Event Handler Thread Interrupted.Queue Exception"+e.toString());
				cleanup();
				return;
			}	
		} 
		Log.w(TAG, "Event Handler Thread Interrupted.");
		cleanup();
	}
	
	private void cleanup() {
		Running = false;
		mgr = null;
		net = null;
		timer = null;
		uart = null;
		ng = null;
		System.gc();
	}
	public boolean isRunning() {
		return Running;
	}
	
	public void DispatchEvt(PoEvent evt) {
		
		if(evt instanceof PoTimerFired) {
			timer.JNICall_fireTimer(((PoTimerFired) evt).getuTID());
		}
		
		else if (evt instanceof PoUARTByteRx) {
			uart.JNICall_RxByteReady( ((PoUARTByteRx) evt).getRxByte() );
		}
		
		else if(evt instanceof PoNetworkEvent) {
			if(evt instanceof PoNetworkPacketRx) {
				net.JNICall_ReceivedPacket( ((PoNetworkPacketRx) evt).getRxPacket() );
			}
			else { // PoPhLayerStatChanged
				// net.dosth()
			}
		}
		
		else if(evt instanceof PoNGEvent) {
			if(evt instanceof PoDialogInputReceived) {
				ng.JNICall_DialogInputReceived(((PoDialogInputReceived) evt).getResult());
			}
			else { // PoDialogTimeout
				ng.JNICall_DialogTimeout();
			}
		}
		else
			Log.w(TAG,"Unknown event.");
		
		/*
		 * Call completeTasks() to complete all submitted 
		 * middleware tasks.
		 */
		mgr.JNICall_completeTasks();
	}
	
	public void cancel(){
		interrupt();
	}
}
