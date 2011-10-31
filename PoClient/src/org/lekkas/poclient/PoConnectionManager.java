/*
 * Author: Kwstas Lekkas , kwstasl@gmail.com
 */
package org.lekkas.poclient;

import java.util.concurrent.*;
import java.io.*;
import java.net.*;
import java.nio.channels.*;

import android.util.*;

public class PoConnectionManager {
	
	private static final PoConnectionManager INSTANCE = new PoConnectionManager();
	private static LinkedBlockingQueue<Network_Msg> OutMsgQ ;
	private final String TAG = "PoConnectionManager";
	private static boolean isConnected;
	private PoCommMgrWriteTask writer_thread;
	private PoConnMgrReadTask reader_thread;
	private RegistryUpdateTask update_thread;
	private static Selector selector;
	private static boolean disconnect_req_flag;
	private boolean update_thread_running = false;
	
	private static SocketChannel sockch;
	
	/*
	 * Called when disconnected from network. Kills reader/writer threads and empties queues.
	 * The threads should, by now, be already be stopped or blocked, waiting in a 
	 * Blocking queue. The interrupt() Method will (should?) unblock them by throwing an Interrupted
	 * exception.
	 */
	public boolean disconnect() {
		disconnect_req_flag = true;	// set so the read thread does not try to reconnect.
		if( (sockch == null) || (!isConnected()) )
			return true;
		
		try {
			sockch.close();
			selector.close();
			sockch = null;
		} catch(IOException e) {
			Log.w(TAG, "IOException while closing socket.");
		}
		writer_thread.cancel();
		reader_thread.cancel();
		killUpdateThread();
		
		try {
			reader_thread.join();
			writer_thread.join();
		} catch (InterruptedException e) {
			Log.w(TAG, "Interrupted while join()'ing read/write threads.");
			return false;
		}
		//OutMsgQ.clear();
		Log.w(TAG, "Both read/write threads Join()'ed.");
		Log.w(TAG, "disconnect() was successful.");
		isConnected = false;
		return true;
	}
	public boolean connect() {
		disconnect_req_flag = false;
		String addr = "178.79.136.46";
		int port = 55555;
		
		if(sockch != null)
			if(sockch.isConnected()) {
				isConnected = true;
				return true;
			}
		try {
			selector = Selector.open();
			sockch = SocketChannel.open();
			sockch.configureBlocking(false);		// true for blocking, false for non-blocking
			//sockch.socket().setSoTimeout(1000);
			sockch.register(selector,  SelectionKey.OP_READ);
			//SelectionKey k = sockch.register(selector, SelectionKey.OP_CONNECT);
			sockch.connect(new InetSocketAddress(addr, port));
			
			while(!sockch.finishConnect()) { }	// for non-blocking mode
			
			if(sockch.isConnected()) {
				isConnected = true;
				Log.w(TAG, "Socket is connected.");
			}
			else {
				Log.w(TAG, "Called connect() but socket neither connected nor threw exception.");
				return false;
			}
		} catch (IOException e) {
			Log.w(TAG, "Failed to connect to the directory: "+e.toString());
			isConnected = false;
			return false;
		}
		
		if(!writer_thread.isRunning()) {
			try {
				writer_thread = new PoCommMgrWriteTask(sockch);
				writer_thread.start();
			} catch(Exception e) {
				Log.w(TAG, "writer thread caught exc: "+e.toString());
			}
		}
		if(!reader_thread.isRunning()) {
			reader_thread = new PoConnMgrReadTask(selector, sockch);
			reader_thread.start();
		}
		return true;
	}

	private PoConnectionManager() {
		disconnect_req_flag = false;
		OutMsgQ = new LinkedBlockingQueue<Network_Msg>();		
		writer_thread = new PoCommMgrWriteTask(sockch);
		reader_thread = new PoConnMgrReadTask(selector, sockch);
	}
	
	public static PoConnectionManager getInstance() {
		return INSTANCE;
	}
	
	public LinkedBlockingQueue<Network_Msg> getOutMsgQ() {
		return OutMsgQ;
	}
	public static boolean isConnected() {
		return isConnected;
	}
	
	public static boolean disconnectCalled() {
		return disconnect_req_flag;
	}
	
	public void startUpdateThread() {
		Log.w(TAG, "Starting update thread.");
		killUpdateThread();
		update_thread = new RegistryUpdateTask(PoRegistryService.getInstance().getMyAddr(), 
				PoRegistryService.getInstance().getSeed());
		update_thread.start();
		update_thread_running = true;
	}
	
	public void killUpdateThread() {
		if(update_thread != null) {
			if(update_thread.isRunning()) {
				update_thread.cancel();
			}
		}
		update_thread_running = false;
	}
	public boolean isRegistryUpdateThreadRunning() {
		return update_thread_running;
	}

}
