package org.lekkas.poclient.PoEvents;

public class PoDialogInputReceived extends PoNGEvent {
	public static final byte RESULT_YES = 1;
	public static final byte RESULT_NO = 0;
	
	private byte result;
	
	public PoDialogInputReceived(byte r) {
		result = r;
	}
	
	public byte getResult() {
		return result;
	}
}
