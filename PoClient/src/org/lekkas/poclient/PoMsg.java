/*
 * Author: Kwstas Lekkas , kwstasl@gmail.com
 */
package org.lekkas.poclient;

public class PoMsg {

	byte len;
	byte[] data;
	
	public PoMsg(byte l, byte[] d) {
		len = l;
		data = d.clone();
	}
}
