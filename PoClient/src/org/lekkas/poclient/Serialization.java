package org.lekkas.poclient;

public class Serialization {
	
	public static final long uint32ToLong(byte[] b) { 
		
		return (long) ((b[0] & 0xFF) << 24) | 
				((b[1] & 0xFF) << 16) | 
				((b[2] & 0xFF) << 8) | 
				b[3] & 0xFF;
	}
	
	public static final long uint32ToLong(int unsigned_uint32) {
		//long l = (long) (unsigned_uint32 & 0x00000000FFFFFFFF);
		long l = (long) (unsigned_uint32 & 0x00000000FFFFFFFFL);
		return l;
	}
	
	public static final int le_uint16ToInt(byte b[]) {
		return (int) ((b[0] & 0xFF) << 8) | 
					((b[1] & 0XFF));
	}
	
	public static final int uint8ToInt(byte b) {
		return (int) (b & 0xFF);
	}
	public static final char byteArrayToChar(byte[] b) {
		return (char)  ( ((b[0] & 0xFF) << 8) | (b[1] & 0xFF) );
	}
	public static final int byteArrayToInt(byte[] b) {
		return (int)  ( ((b[0] & 0xFF) << 24)
						| ((b[1] & 0xFF) << 16) 
						| ((b[2] & 0xFF) << 8) 
						| (b[3] & 0xFF) );
	}
	public static final char byteArrayToChar(byte[] b, int start) {
		return (char) ( (b[start] << 8) | b[start+1] );
	}
}
