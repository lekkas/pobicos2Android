package org.lekkas.poclient.PoAPI;

import java.util.concurrent.LinkedBlockingQueue;

public interface UARTServiceI {
	public void JNICall_RxByteReady(byte data);
	public void JNICallback_TxByte(byte data);
	public LinkedBlockingQueue<Byte> getUARTTxQueue();
}
