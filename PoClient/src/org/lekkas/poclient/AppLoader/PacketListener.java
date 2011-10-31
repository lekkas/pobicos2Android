package org.lekkas.poclient.AppLoader;

public interface PacketListener {
	public void packetReceived(byte channel, byte[] payload);
}
