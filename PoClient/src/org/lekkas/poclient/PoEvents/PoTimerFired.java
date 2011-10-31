package org.lekkas.poclient.PoEvents;

public class PoTimerFired extends PoEvent {
	private byte unsigned_tid;
	
	public PoTimerFired(byte id) {
		unsigned_tid = id;
	}
	
	public byte getuTID() {
		return unsigned_tid;
	}
}
