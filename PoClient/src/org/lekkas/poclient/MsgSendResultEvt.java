/*
 * Author: Kwstas Lekkas , kwstasl@gmail.com
 */
package org.lekkas.poclient;

public class MsgSendResultEvt {
	public static final int SUCCESS = 0;
	public static final int FAIL = 1;
	
	private int ID;
	private int Result;
	
	public MsgSendResultEvt(int id, int res) {
		ID = id;
		Result = res;
	}
	
	public int getID() {
		return ID;
	}
	public int getResult() {
		return Result;
	}
	
}
