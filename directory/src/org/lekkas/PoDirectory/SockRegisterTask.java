/*
 * Author: Kwstas Lekkas , kwstasl@gmail.com
 */

package org.lekkas.PoDirectory;

import java.nio.channels.*;

public class SockRegisterTask {
	RequestHandler hndl;
	SocketChannel sock;
	Request REQ;
	
	public SockRegisterTask(RequestHandler h, SocketChannel s) {
		hndl = h;
		sock = s;
		REQ = Request.REGISTER;
	}
	
	enum Request {
		REGISTER,
		UNREGISTER
	} ;
}
