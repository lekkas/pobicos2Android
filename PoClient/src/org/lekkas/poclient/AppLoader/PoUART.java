package org.lekkas.poclient.AppLoader;

import java.util.concurrent.LinkedBlockingQueue;

import org.lekkas.poclient.PoAPI.PoAPI;
import org.lekkas.poclient.PoAPI.UARTService;
import org.lekkas.poclient.PoEvents.PoEvent;
import org.lekkas.poclient.PoEvents.PoUARTByteRx;

import android.util.Log;

public class PoUART extends Thread /*implements Runnable*/{
	
	private static final String TAG = "POUARTTHREAD";
	static LinkedBlockingQueue<Byte> RxQ;
	static LinkedBlockingQueue<PoEvent> TxQ;
	
	
	static final int MAX_PAYLOAD_LEN = 27;
	static final int MAX_MESSAGE_LEN = MAX_PAYLOAD_LEN+2;
	/* configuration */	
	static int NODE_PORT = 55500;
	static int cmdMAC = 0xFFFF;

	boolean started = false;
	PacketListener listener;
	
	public PoUART(PacketListener listener) {
		RxQ = UARTService.getInstance().getUARTTxQueue();
		TxQ = PoAPI.getEventQueue();
		
		this.listener = listener;
		this.start();	
		
	}
	
	public void run() {
		started = true;
		byte buffer[] = new byte[PoUART.MAX_MESSAGE_LEN];
		int i;
		while(!Thread.currentThread().isInterrupted()) {
		try {
			for(i = 0; i < 2; i++) {
				byte b = RxQ.take().byteValue();
				buffer[i] = b;
			}
			int offset = 2;
			int count = buffer[1];
			
			for(i = 0; i < count; i++) {
				byte b = RxQ.take().byteValue();
				buffer[i+offset] = b;
			}
			PobicosPacket pkt = new PobicosPacket(buffer);
			this.listener.packetReceived(pkt.getChannel(), pkt.getContents());
		
		} catch (InterruptedException e) {
			Log.w(TAG, "Event Handler Thread Interrupted.Queue Exception"+e.toString());
			return;
		}
		}
	}
	public void sendPacket(byte channel, byte[] payload) {
		//System.out.println("PoUART.send()");
		PobicosPacket pkt = new PobicosPacket(channel);		
		
		pkt.append(payload);		
		
		sendUARTBytes(pkt.getBuffer());
	}

	private void sendUARTBytes(byte[] pkt) {
		int size = pkt.length;
		
		for(int i = 0; i < size; i++) {
			TxQ.offer(new PoUARTByteRx(pkt[i]));
		}
	}
	public int getMaxPayloadLen() {
		return PoUART.MAX_MESSAGE_LEN-2;
	}
	public void cancel(){
		interrupt();
	}
}
