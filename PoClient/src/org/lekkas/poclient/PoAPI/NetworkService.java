package org.lekkas.poclient.PoAPI;

import org.lekkas.poclient.Network_Msg;
import org.lekkas.poclient.PoConnectionManager;
import org.lekkas.poclient.PoRegistryService;
import org.lekkas.poclient.Serialization;

import android.util.Log;

public final class NetworkService implements NetworkServiceI {	
	/*
	 * JNI Call used
	 */
	/*
	 * payload -> uint8_t*
	 * len -> uint8_t
	 * src -> uint16_t
	 * dst -> uint16_t
	 */
	private native void nativeReceivedPacket(byte[] payload, byte len, char src, char dst);
	private static final String TAG = "NetworkService";
	private static final NetworkService INSTANCE = new NetworkService();
	
	private NetworkService(){ 
		Log.w(TAG, "Started!");
	}
	
	public static NetworkService getInstance() {
		return INSTANCE;
	}
	public void JNICall_ReceivedPacket(Network_Msg msg) { 
		//char src = (char) ( (msg.payload[0] & 0x00FF) | (msg.payload[1] & 0xFF00) );
		//char dst = (char) ( (msg.payload[2] & 0x00FF) | (msg.payload[3] & 0xFF00) );
		char src = Serialization.byteArrayToChar(msg.payload, 0);
		char dst = Serialization.byteArrayToChar(msg.payload, 2);
		
		byte len = (byte) msg.payload[4];
		byte[] pomsg = new byte[len];
		for(int i = 0; i < Serialization.uint8ToInt(len); i++)
			pomsg[i] = msg.payload[i+5];
			
		nativeReceivedPacket(pomsg, len, src, dst);
	}
	
	public void JNICallback_SendPacket(byte[] payload, byte len, char source, char dest) {
		Log.w(TAG, "SendPacket CB: payload.length = "+payload.length);
		Log.w(TAG, "SendPacket CB: len = "+(int)len);
		// JNI Callback ; offer packet to queue
		byte[] buf = new byte[2 + 2 + 1 + len];
		buf[0] = (byte) ((source >> 8) & 0xff);
		buf[1] = (byte) (source & 0xff);
		
		buf[2] = (byte) ((dest >> 8) & 0xff);
		buf[3] = (byte) (dest & 0xff);
		// Log.w(TAG, "Src: buf[0]="+buf[0]+", buf[1]="+buf[1]);
		// Log.w(TAG, "Dst: buf[2]="+buf[2]+", buf[3]="+buf[3]);
		Log.w(TAG, "Src: "+byteArrayToAscii(buf, 0, 1));
		Log.w(TAG, "Dst: "+byteArrayToAscii(buf, 2, 3));
		
		buf[4] = len;
		
		for(int i=0; i<len; i++)
			buf[i+5] = payload[i];
		
		Network_Msg msg = new Network_Msg(Network_Msg.POBICOS_MSG, (byte)(buf.length & 0xFF), buf);
		PoConnectionManager.getInstance().getOutMsgQ().offer(msg);
	}
	
	public char JNICallback_JoinNetwork() {
		char c = PoRegistryService.getInstance().getMyAddr();
		Log.w(TAG, "Returning local myAddr: "+(int)c);
		return c;
	}

	private String byteArrayToAscii(byte[] b, int start, int end) {
		String result = "";
		if(b == null)
			return result;

		for (int i = start; i <= end; i++) {
		    result +=
		    Integer.toString( ( b[i] & 0xff ) + 0x100, 16).substring( 1 );
		}
		return result;

	}
	public void JNICallback_LeaveNetwork() {
		// unimplemented
	}
}
