package org.lekkas.poclient.PoAPI;

import org.lekkas.poclient.PoApp;
import org.lekkas.poclient.PoConnStatusBR;
import android.content.Intent;
import android.util.Log;

public class NGResources implements NGResourcesI {
	/*
	 * JNI Call used
	 */
	private native int nativeDialogInputReceived(byte result);
	private native int nativeDialogTimeout();
	
	private static final String TAG = "NGResources";
	private static final NGResources INSTANCE = new NGResources();
	
	private NGResources(){ 
		Log.w(TAG, "Started!");
	}
	
	public static NGResources getInstance() {
		return INSTANCE;
	}

	public void JNICallback_AlertText() {
		Intent myIntent = new Intent(PoApp.getMiddlewareService(), PoConnStatusBR.class);
    	myIntent.putExtra("pobicos_alert", "");
    	PoApp.getMiddlewareService().getApplicationContext().sendBroadcast(myIntent);
	}
	public void JNICallback_NotifyText(String msg, int unsigned_millis) {
		Intent myIntent = new Intent(PoApp.getMiddlewareService(), PoConnStatusBR.class);
    	myIntent.putExtra("pobicos_notify", msg);
    	PoApp.getMiddlewareService().getApplicationContext().sendBroadcast(myIntent);
	}
	
	public void JNICallback_CreateDialog(String msg, int unsigned_seconds) {
		Intent myIntent = new Intent(PoApp.getMiddlewareService(), PoConnStatusBR.class);
    	myIntent.putExtra("pobicos_dialog", msg);
    	PoApp.getMiddlewareService().getApplicationContext().sendBroadcast(myIntent);
	}
	public void JNICallback_DismissDialog() {
		//
	}
	public void JNICall_DialogInputReceived(byte result) {
		Log.e(TAG, "JNICALL DialogInputrECEIVED");
		nativeDialogInputReceived(result);
	}
	public void JNICall_DialogTimeout() {
		nativeDialogTimeout();
	}

	

}
