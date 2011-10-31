/*
 * Author: Kwstas Lekkas , kwstasl@gmail.com
 */

package org.lekkas.PoDirectory;

import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.nio.channels.*;

public class Registry {
	public CopyOnWriteArrayList<NodeInfo> reg;
	public AtomicInteger addr;
		
	public Registry() {
		reg = new CopyOnWriteArrayList<NodeInfo>();
		addr = new AtomicInteger(1);
	}
	
	/*
	 * TODO: Fix this.  
	 */
	public char getAddr() {
		return (char) addr.getAndAdd(1);
	}
	
	public NodeInfo isRegisted(SocketChannel s) {
		for(NodeInfo n : reg) {
			if(n.getSocketChannel() == s)
				return n;
		}
		return null;
	}
	public NodeInfo isRegisted(char addr) {
		for(NodeInfo n : reg) {
			if(n.getPoNodeAddr() == addr)
				return n;
		}
		return null;
	}
	public NodeInfo isRegistered(char addr, int seed) {
		for(NodeInfo n : reg) {
			if((n.getPoNodeAddr() == addr) && (n.getSeed() == seed))
				return n;
		}
		return null;
	}

}
