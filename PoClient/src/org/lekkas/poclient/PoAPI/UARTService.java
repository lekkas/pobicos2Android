package org.lekkas.poclient.PoAPI;

import java.util.concurrent.LinkedBlockingQueue;

import android.util.Log;

public final class UARTService implements UARTServiceI {
	/*
	 * JNI Calls used
	 */
	private native void nativeRxByte(byte b);
	
	private static final String TAG = "UARTService";
	private static final UARTService INSTANCE = new UARTService();
	private static final LinkedBlockingQueue<Byte> UARTByteTxQ = new LinkedBlockingQueue<Byte>();

	
	private UARTService(){ 
		Log.w(TAG, "Started!");
	}
	
	public LinkedBlockingQueue<Byte> getUARTTxQueue() {
		return UARTByteTxQ;
	}
	
	public static UARTService getInstance() {
		return INSTANCE;
	}
	
	public void JNICall_RxByteReady(byte data) {
		nativeRxByte(data);
	}
	
	public void JNICallback_TxByte(byte data) {
		UARTByteTxQ.offer(new Byte(data));
	}
}
