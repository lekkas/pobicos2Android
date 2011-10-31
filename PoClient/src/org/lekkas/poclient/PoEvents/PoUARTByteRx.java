package org.lekkas.poclient.PoEvents;

public class PoUARTByteRx extends PoEvent {
	private byte RxB;
	
	public PoUARTByteRx(byte b) {
		RxB = b;
	}
	public byte getRxByte() {
		return RxB;
	}

}
