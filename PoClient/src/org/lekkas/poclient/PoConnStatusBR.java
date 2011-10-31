/*
 * Author: Kwstas Lekkas , kwstasl@gmail.com
 */
package org.lekkas.poclient;

import android.content.*;
import android.util.Log;
import android.os.Bundle;
import android.net.*;
import android.content.Context;

public class PoConnStatusBR extends android.content.BroadcastReceiver {
	private static STATE status;
	private static final String TAG = "CONNSTATUSBR";
	private Context context;
	
	
	@Override
	public void onReceive(Context c, Intent intent) {
		Log.w(TAG,"Inside BR");
		context = c;
		Bundle extras = intent.getExtras();
		
		/*
		 * In case we have just been restarted from an AlarmManager intent.
		 */
		if(intent.hasExtra("alarm_message")){
			String msg = extras.getString("alarm_message");
			Log.w(TAG, "GOT ALARM MESSAGE: "+msg);
			firstConnectivityCheck();
			return;
		}
		/*
		 * Got notification message from POBICOS
		 */
		if(intent.hasExtra("pobicos_notify")) {
			Log.w(TAG, "GOT pobicos notify: ");
			PoApp.getMiddlewareService().createMessageNotification(intent.getStringExtra("pobicos_notify"));
			return;
		}
		/*
		 * Got dialog message from POBICOS
		 */
		if(intent.hasExtra("pobicos_dialog")) {
			Log.w(TAG, "GOT pobicos dialog: ");
			PoApp.getMiddlewareService().createDialogNotification(intent.getStringExtra("pobicos_dialog"));
			return;
		}
		/*
		 * Got POBICOS Alert
		 */
		if(intent.hasExtra("pobicos_alert")) {
			Log.w(TAG, "GOT pobicos alert");
			PoApp.getMiddlewareService().msg("ALERT!", false);
			return;
		}
		/*
		 * disconnected from socket: reconnect, sent from reader thread
		 *
		if(intent.hasExtra("reconnect")) {
			Log.w(TAG, "GOT RECONNECT");
			//PoConnectionManager.getInstance().disconnect();
			PoApp.getMiddlewareService().scheduleConnectRetry();
			return;
		}*/
		/*
		 * Connection retry; alarm intent timer set by our service.
		 */
		if(intent.hasExtra("connection_retry")) {
			Log.w(TAG, "GOT connection retry");
			if(PoApp.getMiddlewareService() == null)
				return;
			PoApp.getMiddlewareService().connect();
			return;
		}
		/*
		 * We've got a registry intent
		 */
		if(intent.hasExtra("registry_event")) {
			Log.w(TAG, "GOT registry event");
			/*
			 * If we get a rejected state it means that our seed has expired.
			 */
			if(PoRegistryService.getInstance().getState() == PoRegistryService.STATE.REJECTED) 
				stopMiddlewareService();
			if(PoRegistryService.getInstance().getState() == PoRegistryService.STATE.REGISTERED)
				PoConnectionManager.getInstance().startUpdateThread();
			Log.w(TAG, "BROADCAST RECEIVER ONCREATE() RETURNING...(REGISTRY_EVENT)");
			return;
		}
		
		if (extras != null && intent.getAction().equals(ConnectivityManager.CONNECTIVITY_ACTION)) {
			Log.w(TAG,"RECEIVED CONNECTIVITY_ACTION");
			
			/*
			 * The following 3 'if' are very ugly; The reason for these checks
			 * is that the CONNECTIVITY_ACTION intents differ when having
			 * different connectivity status. 
			 */
			if(intent.hasExtra(ConnectivityManager.EXTRA_NO_CONNECTIVITY)) {
				Log.w(TAG, "NO connectivity: "+intent.getBooleanExtra(ConnectivityManager.EXTRA_NO_CONNECTIVITY, false));
				status = STATE.DISCONECTED;
				//stopMiddlewareService();
				PoConnectionManager.getInstance().disconnect();
				if(PoApp.getMainActivity() != null)
					PoApp.getMainActivity().setConnectivityStatus(false);
				return;
			}
			
			if(intent.hasExtra(ConnectivityManager.EXTRA_IS_FAILOVER)) {
				if(intent.getBooleanExtra(ConnectivityManager.EXTRA_IS_FAILOVER, false)) {
					Log.w(TAG, "FAILOVER ");
					NetworkInfo netif = intent.getParcelableExtra(ConnectivityManager.EXTRA_NETWORK_INFO);
					status = (netif.getType()==ConnectivityManager.TYPE_WIFI)?STATE.WIFI 
							:STATE.MOBILE;
					//stopMiddlewareService();
					PoConnectionManager.getInstance().disconnect();
					if(PoApp.getMiddlewareService() == null) {
						Log.w(TAG, "FAILOVER: Starting middlewareservice.");
						startMiddlewareService();
					}
					else {
						Log.w(TAG, "FAILOVER: Connecting...");
						PoMiddlewareService.getInstance().connect();
						if(PoApp.getMainActivity() != null)
							PoApp.getMainActivity().setConnectivityStatus(true);
					}
					Log.w(TAG, "BROADCAST RECEIVER ONCREATE() RETURNING(failover)...");
					return;
				}
			}
			
			if(intent.hasExtra(ConnectivityManager.EXTRA_NETWORK_INFO)) {
				NetworkInfo netif = intent.getParcelableExtra(ConnectivityManager.EXTRA_NETWORK_INFO);
				if(netif.getState() == NetworkInfo.State.CONNECTED) {	
					Log.w(TAG, "Connected to "+netif.getTypeName()+" network.");
					if(status == STATE.DISCONECTED) {
						status = (netif.getType()==ConnectivityManager.TYPE_WIFI)?STATE.WIFI 
								:STATE.MOBILE;
					}
					
					if(PoApp.getMiddlewareService() == null) {
						Log.w(TAG, "Starting middleware service");
						startMiddlewareService();
					}
					else {
						Log.w(TAG, "trying to connect");
						PoMiddlewareService.getInstance().connect();
						if(PoApp.getMainActivity() != null)
							PoApp.getMainActivity().setConnectivityStatus(true);
					}
					return;
				}
			}
		}
		Log.w(TAG, "BROADCAST RECEIVER ONCREATE() RETURNING...");
	}
	private void stopMiddlewareService() {
		Log.w(TAG, "Stopping service.");
		if(PoMiddlewareService.isRunning()) {
			Intent i = new Intent(context, PoMiddlewareService.class);
			context.stopService(i);
		}
			
	}
	private void startMiddlewareService() {
		Log.w(TAG, "Starting service");
		if(!PoMiddlewareService.isRunning()) {
			Intent i = new Intent(context, PoMiddlewareService.class);
			context.startService(i);
		}		
	}
	
	private void firstConnectivityCheck() {
		NetworkInfo wifi, mobile;
		Intent service_intent;
		ConnectivityManager cm = (ConnectivityManager)context.getSystemService(android.content.Context.CONNECTIVITY_SERVICE);
		wifi = cm.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
		mobile = cm.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
		if((wifi.isConnected() || mobile.isConnected()) && !PoMiddlewareService.isRunning()) {
			service_intent = new Intent(context, PoMiddlewareService.class);
	        context.startService(service_intent);
		}
	}
	
	public enum STATE {
		MOBILE,
		WIFI,
		DISCONECTED
	};
	
}
