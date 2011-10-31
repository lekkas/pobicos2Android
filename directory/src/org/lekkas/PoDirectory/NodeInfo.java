/*
 * Author: Kwstas Lekkas , kwstasl@gmail.com
 */

package org.lekkas.PoDirectory;

import java.nio.channels.*;
import java.util.Random;

public class NodeInfo {
	private char PoNodeAddr;
	private double Latitude;
	private double Longitude;
	private int seed;
	private SocketChannel Sock;
	private long last_seen;
	
	
	public NodeInfo(SocketChannel s) {
		Sock = s;
		PoNodeAddr = Reactor.registry.getAddr();
		last_seen = System.currentTimeMillis();
		Random r = new Random(System.currentTimeMillis());
		seed = r.nextInt();
		System.out.println("Created node with addr: "+(int)PoNodeAddr+" and seed: "+(int)seed);
	}
	public NodeInfo(SocketChannel s, double lat, double lon) {
		Sock = s;
		last_seen = System.currentTimeMillis();
		PoNodeAddr = Reactor.registry.getAddr();
		Random r = new Random(System.currentTimeMillis());
		seed = r.nextInt();
		System.out.println("Created node with addr: "+(int)PoNodeAddr+", seed: "+(int)seed+" lat: "+lat+
				", lon: "+lon);
		
		Latitude = lat;
		Longitude = lon;
	}

	public void setSock(SocketChannel s) {
		Sock = s;
	}
	public SocketChannel getSocketChannel() {
		return Sock;
	}
	public void setLatitude(double lat) {
		Latitude = lat;
	}
	public double getLatitude() {
		return Latitude;
	}
	public void setLongitude(double lon) {
		Longitude = lon;
	}
	public double getLongitude() {
		return Longitude;
	}
	
	public void setPoNodeAddr(char addr) {
		PoNodeAddr = addr;
	}
	public char getPoNodeAddr() {
		return PoNodeAddr;
	}
	public int getSeed() {
		return seed;
	}
	public long getLastSeen() {
		return last_seen;
	}
	public void setLastSeen(long d) {
		last_seen = d;
	}
}
