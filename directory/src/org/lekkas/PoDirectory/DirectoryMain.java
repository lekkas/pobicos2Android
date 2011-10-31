/*
 * Author: Kwstas Lekkas , kwstasl@gmail.com
 */

package org.lekkas.PoDirectory;

import java.io.IOException;
import java.nio.ByteOrder;



public class DirectoryMain {
	private static boolean verbose = false;
	
	public static void main(String[] args) {
		System.out.println(ByteOrder.nativeOrder().toString());
		System.out.println("dir2");
		try {
			if(args.length > 0)
				if(args[0].toLowerCase().contains("-v"))
					verbose = true;
			
			Reactor r = new Reactor(55555);
			r.run();
		} catch (IOException e) {
			System.out.println("Error: "+e.toString());
		}
	}
	public static boolean isVerbose() {
		return verbose;
	}
}
