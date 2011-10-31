/*
 * Author: Kwstas Lekkas , kwstasl@gmail.com
 */
package org.lekkas.poclient;

import android.app.*;
import android.content.Context;
import android.util.Log;

public class PoApp extends Application {
	public static final PoConnectionManager conn_manager = PoConnectionManager.getInstance();
	private static final String TAG = "PoApp";
	private static PoApp INSTANCE;
	private static boolean AppPill;
	private static PoMainA Main_Activity;
	private static PoMiddlewareService middleware_service;
	
	public PoApp() {
		super();
		Log.w(TAG, "Application started and conn_manager created.");
		INSTANCE = this;
	}
	public static void setAppPill(boolean b) {
		AppPill = b;
	}
	public static boolean isAppPill() {
		return AppPill;
	}
	public Context getContext() {
		return getApplicationContext();
	}
	
	public static PoApp getInstance() {
		return INSTANCE;
	}
	public static PoMainA getMainActivity() {
		return Main_Activity;
	}
	public static void setMainActivity(PoMainA a ) {
		Main_Activity = a;
	}
	public static PoMiddlewareService getMiddlewareService() {
		return middleware_service;
	}
	public static void setMiddlewareService(PoMiddlewareService s) {
		middleware_service = s;
	}

}
