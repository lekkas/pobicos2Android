/*
 * Author: Kwstas Lekkas , kwstasl@gmail.com
 */
package org.lekkas.poclient;

public class Network_Msg {
	
	public static final byte POBICOS_MSG		= 0x01;
	public static final byte REGISTRY_REQ 		= 0x02;
	
	public static final byte REG_REPLY_FAIL		= 0x03;
	public static final byte REG_REPLY_WELCOME	= 0x04;
	public static final byte REG_REPLY_PONG		= 0x05;
	
	public static final byte CLASS_MOBILE		= 0x01;
	
	public byte 	msg_type; 		
	public byte 	payload_len;	// length of 256 is enough for current pobicos implementation
									// as MAX_MSG_DATA < 200
	
	public static final int HEADER_LEN = 2;	// {MSG_TYPE, PAYLOAD_LEN}
	
	public byte[] 	payload;
	
	
	public Network_Msg(byte msg_type, byte len, byte[] p) {
		this.msg_type = msg_type;
		payload_len = len;
		payload = p.clone();
	}
	
}
