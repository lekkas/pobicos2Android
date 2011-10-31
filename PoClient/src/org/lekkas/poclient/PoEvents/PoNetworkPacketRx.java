package org.lekkas.poclient.PoEvents;

import org.lekkas.poclient.Network_Msg;

public class PoNetworkPacketRx extends PoNetworkEvent{
	private Network_Msg msg;
	
	public PoNetworkPacketRx(byte msg_type, byte payload_len, byte[] payload) {
		msg = new Network_Msg(msg_type, payload_len, payload);
	}
	public Network_Msg getRxPacket() {
		return msg;
	}
}
