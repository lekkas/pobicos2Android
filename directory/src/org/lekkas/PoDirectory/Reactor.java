/*
 * Author: Kwstas Lekkas , kwstasl@gmail.com
 */

package org.lekkas.PoDirectory;

import java.net.InetSocketAddress;
import java.nio.channels.*;
import java.io.*;
import java.util.*;
import java.util.concurrent.*;

public class Reactor implements Runnable{
	private static final int NTHREADS = 1;
	private static final String TAG = "REACTOR:";
	
	public static LinkedBlockingQueue<SockRegisterTask> RegisterTaskQ;
	public static Registry registry;
	public static Selector selector;
	final ServerSocketChannel serverSock;
	final ExecutorService exec;
	
	Reactor(int port) throws IOException {
		exec = Executors.newFixedThreadPool(NTHREADS);
		RegisterTaskQ = new LinkedBlockingQueue<SockRegisterTask>();
		
		registry = new Registry();
		
		selector = Selector.open();
		serverSock = ServerSocketChannel.open();
		serverSock.socket().bind(new InetSocketAddress(port));
		serverSock.configureBlocking(false);	// false for Non-Blocking
		SelectionKey sk = serverSock.register(selector,  SelectionKey.OP_ACCEPT);
		sk.attach(new Accept_Handler(serverSock, selector));
		System.out.println(TAG+"Server started on port "+port+". Accept()'ing..");
	}
	
	public void run() {
			try {
				while(true) {
					selector.select();
					Set<SelectionKey> selected = selector.selectedKeys();
					Iterator<SelectionKey> it = selected.iterator();
					while(it.hasNext()) {
						dispatch((SelectionKey)(it.next())); 
					}
				}
			} catch (IOException e) {
				System.out.println("Error: "+e.toString());
				exec.shutdown();
			}
	}

	void dispatch(SelectionKey k) {
		Runnable handler = (Runnable)(k.attachment());
		if(handler != null)
			handler.run();
		//if(!exec.isShutdown())
			//exec.execute(handler);
	}
}
