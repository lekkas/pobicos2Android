/*
 * Author: Kwstas Lekkas , kwstasl@gmail.com
 */
package org.lekkas.poclient;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.channels.*;

import org.lekkas.poclient.PoAPI.PoAPI;
import org.lekkas.poclient.PoEvents.PoNetworkPacketRx;

import android.content.Intent;
import android.util.*;

public class PoConnMgrReadTask extends Thread implements Runnable {

	private final String TAG = "PoCommMgrReadTask";
	private SocketChannel sockch;
	private ByteBuffer network_msg_header, payload;
	private boolean Running;
	
	public static boolean logBytes = false;
	public static int receivedBytes, cntRxPkts;
	
	
	private Selector selector;
	
	public static int uByteToInt(byte b) {
		return (int) (b & 0xFF);
	}
	public PoConnMgrReadTask(Selector sel, SocketChannel sock) {
		Running = false;
		sockch = sock;
		selector = sel;
	}
	
	public void run() {
		int ret, bytes_read;
		
		Log.w(TAG, "Thread started!");
		network_msg_header = ByteBuffer.allocate(Network_Msg.HEADER_LEN);	// Allocate space 
																			// for Msg_type(1), Seq(1) + Len(1) fields
		payload = null;
		Running = true;
		while(!Thread.currentThread().isInterrupted()) {
			try {
				/*
				 * MSG Reply format:
				 * 
				 * Msg Type:	byte:	1 byte
				 * Len:			byte:	1 byte
		 		 * Payload:		byte[]:	{Len} bytes
		 		 * 
		 		 * Where Payload:
		 		 * 
		 		 * 1) For POBICOS messages:
				 * Src addr		: char	: 2 bytes
				 * Dest addr	: char	: 2 bytes
				 * Msg Len		: byte	: 1 byte
				 * Msg			: byte[]: {Msg Len} bytes;
				 * 
				 * 2) For registration messages:
				 *  a)2 bytes, (Registered node address) + 4 bytes(seed) for welcome messages
				 *  b)no payload for pong messages
				 */
				Log.w(TAG, "Read()'ing");
				/*
				 * Reading network message header.
				 */
				selector.select();
				ret = sockch.read(network_msg_header);
				if(ret == -1) throw new IOException("sockch.read() returned -1. Server has probably " +
													"closed the connection");
				if(ret == 0)
					continue;
				
				bytes_read = ret;
				while(bytes_read < Network_Msg.HEADER_LEN) {
					ret = sockch.read(network_msg_header);
					if(ret == -1) throw new IOException("sockch.read() returned -1");
					bytes_read += ret;
				}
				
				/*
				 * Reading message payload
				 */
				int len = uByteToInt(network_msg_header.get(1));
				Log.w(TAG, "read() Header: "+ret+" bytes. Length of payload = "+len);
				if(len != 0) {
					payload = ByteBuffer.allocate(len);
					ret = sockch.read(payload);
					if(ret == -1) throw new IOException("sockch.read() returned -1");
					bytes_read = ret;
					while(bytes_read < len) {
						ret = sockch.read(payload);
						if(ret == -1) throw new IOException("sockch.read() returned -1");
						bytes_read += ret;
					}
				}
				
				byte flag = network_msg_header.get(0);
				if(flag == Network_Msg.REG_REPLY_WELCOME) {
					Log.w(TAG, "GOT REG_REPLY_WELCOME! addr:"+byteArrayToAscii(payload.array()));
					byte[] addr = { payload.get(0), payload.get(1) };
					byte[] seed = { payload.get(2), payload.get(3), payload.get(4), payload.get(5) };
					Log.w(TAG, "addr: "+byteArrayToAscii(addr));
					Log.w(TAG, "seed: "+byteArrayToAscii(seed));
					
					char a = Serialization.byteArrayToChar(addr);
					int s = Serialization.byteArrayToInt(seed);
					PoRegistryService.getInstance().setMyAddr(a, s);
					PoRegistryService.getInstance().setState(PoRegistryService.STATE.REGISTERED);
					sendRegistryIntent();	// first time connection; start registry update thread.
				}
				if(flag == Network_Msg.REG_REPLY_FAIL) {
					Log.w(TAG, "Registration failed!");
					PoRegistryService.getInstance().setState(PoRegistryService.STATE.REJECTED);
					sendRegistryIntent();	// restart service
					cancel();
				}
				if(flag == Network_Msg.REG_REPLY_PONG) {
					Log.w(TAG, "GOT REG_REPLY_PONG!");
					PoRegistryService.getInstance().setState(PoRegistryService.STATE.REGISTERED);
					if(!PoConnectionManager.getInstance().isRegistryUpdateThreadRunning())
						sendRegistryIntent();	// needed to restart update thread in case we have
												// just reconnected.
				}
				if(flag == Network_Msg.POBICOS_MSG) {
					Log.w(TAG, "GOT POBICOS MESSAGE!");
					if(logBytes) {
						receivedBytes += (payload.capacity()+2);
						cntRxPkts++;
					}
					PoAPI.getEventQueue().offer(new PoNetworkPacketRx(flag, (byte)len, payload.array()));
				}
				
				if(payload != null)
					payload.clear();
				network_msg_header.clear();
			} catch(ClosedByInterruptException e) {
				Log.w(TAG, "ClosedByInterruptException: "+e.toString());
				cleanup();
				//if(!PoConnectionManager.disconnectCalled())
					//sendReconnectIntent();
				return;
			} catch (ClosedChannelException e) {	// by socket	
				Log.w(TAG, "ClosedChannelException: "+e.toString());
				cleanup();
				//if(!PoConnectionManager.disconnectCalled())
					//sendReconnectIntent();
				return;
			} catch (NotYetConnectedException e) {	// by socket
				Log.w(TAG, "NotYetConnectedException: "+e.toString());
				cleanup();
				//if(!PoConnectionManager.disconnectCalled())
				//	sendReconnectIntent();
				return;
			} catch(IOException e) {
				Log.w(TAG, "IOException: "+e.toString());
				cleanup();
				//if(!PoConnectionManager.disconnectCalled())
					//sendReconnectIntent();
				return;
			} /*catch(Exception e) {
				Log.w(TAG, "Exception: "+e.toString());
				cleanup();
				sendReconnectIntent();
				return; 
			} */
		}
	}

	public boolean isRunning() {
		return Running;
	}
	private String byteArrayToAscii(byte[] b) {
		String result = "";
		if(b == null)
			return result;

		for (int i=0; i < b.length; i++) {
		    result +=
		    Integer.toString( ( b[i] & 0xff ) + 0x100, 16).substring( 1 );
		}
		return result;
	}
	private void cleanup() {
		Running = false;
		sockch = null;
		network_msg_header = null;
		payload = null;
	}
	/*
	private void sendReconnectIntent() {
		Intent myIntent = new Intent(PoApp.getMiddlewareService(), PoConnStatusBR.class);
    	myIntent.putExtra("reconnect", "");
    	PoApp.getMiddlewareService().getApplicationContext().sendBroadcast(myIntent);
	} */
	private void sendRegistryIntent() {
		Intent myIntent = new Intent(PoApp.getMiddlewareService(), PoConnStatusBR.class);
    	myIntent.putExtra("registry_event", "");
    	PoApp.getMiddlewareService().getApplicationContext().sendBroadcast(myIntent);
	}
	public void cancel() {
		interrupt();
	}
}
