/*
 * Author: Kwstas Lekkas , kwstasl@gmail.com
 */

package org.lekkas.PoDirectory;


import java.nio.ByteBuffer;
import java.nio.channels.*;
import java.io.*;

public class RequestHandler implements Runnable{
	private static final String TAG = "RequestHandler:";
	private boolean v;
	private static final int TIME_THRESHOLD_MS = 60000;
	
	SelectionKey sk;
	SocketChannel sock;
	private ByteBuffer network_msg_header;
	private ByteBuffer payload;
	private ByteBuffer out_msg;
	private char node_addr;
	
	private char app_radiuskm = 0;
	private double app_lat = 0.0;
	private double app_lon = 0.0;
	
	// private char dstAddr;
	// private char srcAddr;
	
	enum OP {
		SEND_REG_MSG,
		SEND_PO_MSG
	};
	
	private OP	op;
	
	public RequestHandler(SocketChannel s) throws Exception {
		sock = s;		
		v = DirectoryMain.isVerbose();
	}
	
	/*
	 * Socket is ready for read()'ing
	 */
	public void run() {
		try {
			read();
			process();
			write();
		} catch(IOException e) {
			System.out.println(TAG+"IO Error: "+e.toString());
			/*
			NodeInfo n = Reactor.registry.isRegisted(node_addr);
			System.out.println(TAG+":Logging disconnection time for node "+
			(int)node_addr); 
			n.setDisconnectionTime(System.currentTimeMillis()); */
		} /*catch (Exception e) {
			System.out.println("Exception thrown from run() of SessionHandler:"+e.toString());
		}*/
	}
	private void read() throws IOException {
		if(v) System.out.println(TAG+"Read()");
		/*
		 * Reading network message header.
		 */
		network_msg_header = ByteBuffer.allocate(Network_Msg.HEADER_LEN);
		int ret = sock.read(network_msg_header);
		if(ret == 0) {
			if(v) System.out.println(TAG+"Read 0 bytes.");
			return;
		}
		if(ret == -1) {
			//exc_addr = Reactor.registry.isRegisted(sock).getPoNodeAddr();
			sock.close();
			throw new IOException("sock.read() returned -1. Server has probably " +
											"closed the connection");
		}
		int bytes_read = ret;
		while(bytes_read < Network_Msg.HEADER_LEN) {
			ret = sock.read(network_msg_header);
			if(ret == -1) throw new IOException("sock.read() returned -1. Server has probably " +
											"closed the connection");
			bytes_read += ret;
		}
		/*
		 * Reading message payload
		 */
		int pay_len = uByteToInt(network_msg_header.get(1));
		payload = ByteBuffer.allocate(pay_len);
		ret = sock.read(network_msg_header);
		if(ret == -1) throw new IOException("sock.read() returned -1. Server has probably " +
											"closed the connection");
		bytes_read = ret;
		while(bytes_read < pay_len) {
			ret = sock.read(payload);
			if(ret == -1) throw new IOException("sockch.read() returned -1. Server has probably " +
											"closed the connection");
			bytes_read += ret;
		}
		/*
		 * We now have header + payload.
		 */
		if(v) System.out.println(TAG+"Got header+payload");
		if(v) System.out.println(TAG+"packet: "+byteArrayToAscii(network_msg_header.array())
				+byteArrayToAscii(payload.array()));
	}
	private void process() throws IOException {
		if(network_msg_header.hasRemaining())
			return;
		if(v) System.out.println(TAG+"Process()");
		byte flag = network_msg_header.get(0);
		
		if(flag == Network_Msg.REGISTRY_REQ) {
			op = OP.SEND_REG_MSG;
			NodeInfo n = Reactor.registry.isRegisted(sock);
			
			ByteArrayOutputStream lat = new ByteArrayOutputStream(8);
			for(int i = 0; i < 8; i++) 
				lat.write(payload.array()[Network_Msg.LAT_OFFSET+i]);
			
			ByteArrayOutputStream lon = new ByteArrayOutputStream(8);
			for(int i = 0; i < 8; i++)
				lon.write(payload.array()[Network_Msg.LON_OFFSET+i]);
			
			double latitude = payload.getDouble(Network_Msg.LAT_OFFSET);
			double longitude = payload.getDouble(Network_Msg.LON_OFFSET);
			
			//System.out.println("latitude: "+latitude+", longitude: "+longitude);
			
			if(n == null) { // new incoming connection
				byte ad[] = { 	payload.array()[Network_Msg.ADDR_OFFSET], 
								payload.array()[Network_Msg.ADDR_OFFSET+1] 
							};
				
				byte sd[] = {	payload.array()[Network_Msg.ADDR_OFFSET+2], 
								payload.array()[Network_Msg.ADDR_OFFSET+3],
								payload.array()[Network_Msg.ADDR_OFFSET+4],
								payload.array()[Network_Msg.ADDR_OFFSET+5]
							};
				
				char addr = Serialization.byteArrayToChar(ad);
				node_addr = addr;
				int seed = Serialization.byteArrayToInt(sd);
				if(v) System.out.println(TAG+":GOT addr:"+(int)addr+" and seed: "+seed);
				
				if(seed == 0 & addr == 0) {	// first time connection
					if(v) System.out.println(TAG+"Registering new node");
					n = new NodeInfo(sock, latitude, longitude);
					Reactor.registry.reg.add(n);
					/*
					 * Reg reply
					 */
					out_msg = ByteBuffer.allocate(Network_Msg.HEADER_LEN + 2 + 4);
					out_msg.put(Network_Msg.REG_REPLY_WELCOME).put((byte)0x06);
					out_msg.putChar(n.getPoNodeAddr());
					out_msg.putInt(n.getSeed());
					out_msg.position(0);
					return;
				}
				if(v)System.out.println("Looking for node "+(int)addr+" and seed "+(int)seed);
				NodeInfo node = Reactor.registry.isRegistered(addr, seed);
				if((node == null) ) { // No such node exists 
					/*
					 * Reg reply fail
					 */
					out_msg = ByteBuffer.allocate(Network_Msg.HEADER_LEN );
					out_msg.put(Network_Msg.REG_REPLY_FAIL).put((byte)0x00);
					out_msg.position(0);
					return;
				}
				if((System.currentTimeMillis() - node.getLastSeen() 
						> TIME_THRESHOLD_MS) ) { // Registration has expired
					/*
					 * Reg reply fail
					 */
					out_msg = ByteBuffer.allocate(Network_Msg.HEADER_LEN );
					out_msg.put(Network_Msg.REG_REPLY_FAIL).put((byte)0x00);
					out_msg.position(0);
					Reactor.registry.reg.remove(node.getSocketChannel());
					if(v) System.out.println(TAG+"Node successfully unregisted.");
					return;
				} 
				else { // node already registered
					/*
					 * Update lat, lon
					 */
					node.setLatitude(latitude);
					node.setLongitude(longitude);
					/*
					 * Construct PONG message
					 */
					out_msg = ByteBuffer.allocate(Network_Msg.HEADER_LEN); // no payload
					out_msg.put(Network_Msg.REG_REPLY_PONG).put((byte)0x00);
					out_msg.position(0);
					node.setLastSeen(System.currentTimeMillis());
					return;
				}
			}
			
			else { // Node already registered and connected
				/*
				 * Update lat, lon
				 */
				n.setLatitude(latitude);
				n.setLongitude(longitude);
				/*
				 * Reg reply ready, now construct PONG message
				 */
				out_msg = ByteBuffer.allocate(Network_Msg.HEADER_LEN); // no payload
				out_msg.put(Network_Msg.REG_REPLY_PONG).put((byte)0x00);
				out_msg.position(0);
				n.setLastSeen(System.currentTimeMillis());
				return;
			}
		}
		if(flag == Network_Msg.POBICOS_MSG) {
			op = OP.SEND_PO_MSG;
			out_msg = ByteBuffer.allocate(network_msg_header.capacity()+payload.capacity());
			out_msg.put(network_msg_header.array()).put(payload.array());
			out_msg.position(0);
						
			if(v) System.out.println(TAG+"Source address: "+byteArrayToAscii(out_msg.array(), 2, 3));
			if(v) System.out.println(TAG+"Destination address: "+byteArrayToAscii(out_msg.array(), 4, 5));

			char rad = out_msg.getChar(out_msg.capacity()-18);
			double lat = out_msg.getDouble(out_msg.capacity()-16);
			double lon = out_msg.getDouble(out_msg.capacity()-8);
			
			if(rad != 0 && lat != 0.0 && lon != 0.0) {
				app_radiuskm = rad;
				app_lat = lat;
				app_lon = lon;
				System.out.println(TAG+"APP APP: Radius: "+(double)app_radiuskm+" lat: "+app_lat+" lon: "+app_lon);
			}
			NodeInfo n = Reactor.registry.isRegisted(sock);
			if(n != null)
				n.setLastSeen(System.currentTimeMillis());
		}
	}
	private void write() throws IOException {
		if(network_msg_header.hasRemaining())
			return;
		if(v) System.out.println(TAG+"Write()");
		if(op == OP.SEND_REG_MSG) {
			if(v) System.out.println(TAG+"Sending packet: "+byteArrayToAscii(out_msg.array()));
			while(out_msg.hasRemaining())
				sock.write(out_msg);
			if(v) System.out.println(TAG+"Sent REG reply. Wrote "+out_msg.capacity()+" bytes.");
		}

		if(op == OP.SEND_PO_MSG) {
			char dstId = Serialization.byteArrayToChar(out_msg.array(), 4);
			NodeInfo node = Reactor.registry.isRegisted(dstId);
			/*if(v) */System.out.println(TAG+"Node "+byteArrayToAscii(out_msg.array(), 2, 3)+" is looking for node with id: "+byteArrayToAscii(out_msg.array(), 4, 5));
			if(node != null){
				char rad = out_msg.getChar(out_msg.capacity()-18);
				double lat = out_msg.getDouble(out_msg.capacity()-16);
				double lon = out_msg.getDouble(out_msg.capacity()-8);
				
				if(appLocationSpecsSetUp() && (rad != 0 && lat != 0.0 && lon != 0.0)) {
					if (distCheck(node.getLatitude(), node.getLongitude(), app_lat, app_lon, app_radiuskm)) {
						System.out.println(TAG+"FOUND NODE WITHIN LOCATION SPECIFICATIONS");
						node.getSocketChannel().write(out_msg);
					}
				}
				else {
					System.out.println(TAG+"FOUND NODE");
					node.getSocketChannel().write(out_msg);
				}
			}
			/*
			 * Broadcast
			 */
			if( dstId == (char)0xffff) {
				if(v) System.out.println(TAG+"Node "+byteArrayToAscii(out_msg.array(), 2, 3)+" is broadcasting.");
				for(NodeInfo n : Reactor.registry.reg) {
					if(n.getSocketChannel() != sock) {
						
						char rad = out_msg.getChar(out_msg.capacity()-18);
						double lat = out_msg.getDouble(out_msg.capacity()-16);
						double lon = out_msg.getDouble(out_msg.capacity()-8);
						
						if(appLocationSpecsSetUp() && (rad != 0 && lat != 0.0 && lon != 0.0)) {
							if (distCheck(n.getLatitude(), n.getLongitude(), app_lat, app_lon, app_radiuskm)) {
								System.out.println(TAG+"FOUND NODE WITHIN LOCATION SPECIFICATIONS");
								try {
									n.getSocketChannel().write(out_msg);
								} catch(Exception e) {
									System.out.println(TAG+"Socket exception: "+e.toString()+", trying next socket ");
								}
							}
						}
						else {
							try {
								n.getSocketChannel().write(out_msg);
							} catch(Exception e) {
								System.out.println(TAG+"Socket exception: "+e.toString()+", trying next socket ");
							}
						}
					}
				}
				
			}
		}
		/*
			Reactor.RegisterTaskQ.offer(new SockRegisterTask(this, sock));
			Reactor.selector.wakeup();
		*/
	}
		
	private String byteArrayToAscii(byte[] b, int start, int end) {
		String result = "";
		if(b == null)
			return result;

		for (int i = start; i <= end; i++) {
		    result +=
		    Integer.toString( ( b[i] & 0xff ) + 0x100, 16).substring( 1 );
		}
		return result;

	}
	
	public String byteArrayToAscii(byte[] b) {
		String result = "";
		if(b == null)
			return result;

		for (int i=0; i < b.length; i++) {
		    result +=
		    Integer.toString( ( b[i] & 0xff ) + 0x100, 16).substring( 1 );
		}
		return result;

	}
	
	public static int uByteToInt(byte b) {
		return (int) (b & 0xFF);
	}
	
	/*
	 * returns true if the point with gps coords (lat1, lon1) is within the circle
	 * with center (center_lat, center_lon) and radius radiuskm
	 */
	private boolean distCheck(double lat1, double lon1, double center_lat, double center_lon, char radiuskm) {
		double dist = haversineDist(lat1, lon1,	center_lat, center_lon);
		if(dist <= radiuskm)
			return true;
		return false;
	}
	private double haversineDist(double lat1, double lng1, double lat2, double lng2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos(Math.toRadians(lat1)) * 
           Math.cos(Math.toRadians(lat2)) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a)) * 6371; // 6371 = average earth radius
    }
	
	private boolean appLocationSpecsSetUp() {
		return (app_lat != 0.0 && app_lon != 0.0 && app_radiuskm != 0);
	}
	
}
