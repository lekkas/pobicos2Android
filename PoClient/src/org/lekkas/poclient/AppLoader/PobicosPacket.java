package org.lekkas.poclient.AppLoader;

class PobicosPacket {
	private byte counter;
	private byte buffer[];
	
	public PobicosPacket() {
		//System.out.println("PobicosPacket()");
		counter = 0;
		buffer = new byte[PoUART.MAX_MESSAGE_LEN];		
	}
	public PobicosPacket(int channel) {
		//System.out.println("PobicosPacket(channel)");
		counter = 0;
		buffer = new byte[PoUART.MAX_MESSAGE_LEN];
		buffer[0] = (byte) channel;
	}
	public PobicosPacket(byte[] packet) {
		//System.out.println("PobicosPacket(packet)");
		buffer = new byte[PoUART.MAX_MESSAGE_LEN];
		for (int i = 0; i < packet.length; i++) {
			buffer[i] = packet[i];
		}
		counter = buffer[1];		
	}
	byte[] getBuffer() {
		byte copy[] = new byte[2 + counter];
		for (int i = 0; i < 2 + counter; i++) {
			copy[i] = buffer[i];
		}
		copy[1] = counter;
		return copy;
	}
	byte getChannel() {
		return buffer[0];
	}
	byte[] getContents() {
		byte copy[] = new byte[counter];
		for (int i = 0; i < counter; i++) {
			copy[i] = buffer[2 + i];
		}
		return copy;
	}
	void append(byte b) {
		buffer[2 + counter++] = b;
	}
	void append(byte b[]) {
		for (int i = 0; i < b.length; i++)
			append(b[i]);
	}
}

