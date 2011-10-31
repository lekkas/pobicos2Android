package org.lekkas.poclient.PoAPI;

import org.lekkas.poclient.Network_Msg;

public interface NetworkServiceI {
	public void JNICall_ReceivedPacket(Network_Msg msg);
	public void JNICallback_SendPacket(byte[] payload, byte len, char source, char dest);
	public char JNICallback_JoinNetwork();
}
