/*
 * Author: Kwstas Lekkas , kwstasl@gmail.com
 */
package org.lekkas.poclient;

import java.util.Calendar;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

import org.lekkas.poclient.PoAPI.PoAPI;

import android.app.*;
import android.content.*;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.IBinder;
import android.util.*;
import android.widget.Toast;

public class PoMiddlewareService extends Service {
	private static final String TAG  = "PoMiddlewareService";
	private static final int DIALOG_NOTIFICATION = 1;
	private static final int MESSAGE_NOTIFICATION = 2;
	private static final int CONNECTION_RETRY_DELAY = 5000;
	private static PoMiddlewareService INSTANCE;
	private static boolean Running;
	private static boolean onAppExit;
	private static ScheduledThreadPoolExecutor reconnect_sched;
	private static ScheduledFuture<?> reconnect_task;
	
	public static boolean isRunning() {
		return Running;
	}
	public static PoMiddlewareService getInstance() {
		return INSTANCE;
	}

	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		Log.d(TAG, "onStartCommand()");
		return START_NOT_STICKY;
	}
	
	@Override
	public void onCreate() {
		Log.d(TAG, "onCreate()");
		super.onCreate();
		PoApp.setMiddlewareService(this);
		INSTANCE = this;
		Running = true;
		onAppExit = false;
		startPoMiddleware();
	}

	@Override
	public IBinder onBind(Intent intent) {
		Log.d(TAG, "onBind()");
		return null;
	}

	@Override
	public void onDestroy() {
		Log.d(TAG, "onDestroy()");
		super.onDestroy();
		stopPoMiddleware();
		Running = false;
		if(!onAppExit)
			setAlarmAndExit();
		System.exit(0);
	}
	public void stopPoMiddleware() {
		if(PoConnectionManager.isConnected())
			PoConnectionManager.getInstance().disconnect();
		if(PoAPI.isRunning()) {
			Log.w(TAG, "Stopping PoAPI");
			PoAPI.getInstance().stop();
		}
		INSTANCE = null;
	}
	public void startPoMiddleware() {
		NetworkInfo wifi, mobile;
		ConnectivityManager cm = (ConnectivityManager)this.getSystemService(CONNECTIVITY_SERVICE);
		wifi = cm.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
		mobile = cm.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
        
		if(wifi.isConnected() || mobile.isConnected()) {
			if(!connect()) {
				if(PoApp.getMainActivity() != null)
					PoApp.getMainActivity().setConnectivityStatus(false);
				return;
			}
			PoAPI.getInstance().start();
			if(PoApp.getMainActivity() != null)
				PoApp.getMainActivity().setConnectivityStatus(true);
		}
		else {
			if(PoApp.getMainActivity() != null)
				PoApp.getMainActivity().setConnectivityStatus(false);
		}
	}
	
	/*
	 * Restarts our application.
	 */
	private void setAlarmAndExit(){
    	Intent myIntent = new Intent(this, PoConnStatusBR.class);
    	myIntent.putExtra("alarm_message", "This is an alarm intent.");
    	PendingIntent pendingIntent;
    	pendingIntent = PendingIntent.getBroadcast(this, 0, myIntent, PendingIntent.FLAG_ONE_SHOT);
    	
	    AlarmManager alarmManager = (AlarmManager)getSystemService(ALARM_SERVICE);
        Calendar calendar = Calendar.getInstance();
	    calendar.setTimeInMillis(System.currentTimeMillis());
  	    calendar.add(Calendar.SECOND, 3);
	    alarmManager.set(AlarmManager.RTC, calendar.getTimeInMillis(), pendingIntent);
	    System.exit(0);
    }
	public static void setOnAppExit(){
		onAppExit = true;
	}
	public static boolean onAppExit() {
		return onAppExit;
	}
	
	public void createDialogNotification(String msg) {
		Log.e(TAG, "CalledDialogNotification");
		String ns = Context.NOTIFICATION_SERVICE;
		NotificationManager mNotificationManager = (NotificationManager)getSystemService(ns);
		
		int icon = R.drawable.options_l;
		CharSequence tickerText = "POBICOS Dialog";
		long when = System.currentTimeMillis();
		Notification n = new Notification(icon, tickerText, when);
		n.defaults |= Notification.DEFAULT_VIBRATE;
		n.flags |= Notification.FLAG_AUTO_CANCEL;
		
		Context context = getApplicationContext();
		CharSequence title = "Dialog";
		CharSequence content = msg;
		Intent notificationIntent = new Intent(this, DialogActivity.class);
		notificationIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		notificationIntent.putExtra("dialog_data", msg);
		PendingIntent contentIntent = PendingIntent.getActivity(this, 0, 
				notificationIntent, PendingIntent.FLAG_ONE_SHOT);
	
		n.setLatestEventInfo(context, title, content, contentIntent);
		mNotificationManager.notify(DIALOG_NOTIFICATION, n);
	}
	
	public void createMessageNotification(String msg) {
		Log.e(TAG, "CalledMessageNotification");
		String ns = Context.NOTIFICATION_SERVICE;
		NotificationManager mNotificationManager = (NotificationManager)getSystemService(ns);
		
		int icon = R.drawable.options_l;
		CharSequence tickerText = "POBICOS Message";
		long when = System.currentTimeMillis();
		Notification n = new Notification(icon, tickerText, when);
		n.defaults |= Notification.DEFAULT_VIBRATE;
		n.flags |= Notification.FLAG_AUTO_CANCEL;
		
		Context context = getApplicationContext();
		CharSequence title = "Message";
		CharSequence content = msg;
		Intent notificationIntent = new Intent(this, NotificationMessageActivity.class);
		notificationIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		notificationIntent.putExtra("message_data", msg);
		PendingIntent contentIntent = PendingIntent.getActivity(this, 0, 
				notificationIntent, PendingIntent.FLAG_ONE_SHOT);
	
		n.setLatestEventInfo(context, title, content, contentIntent);
		mNotificationManager.notify(MESSAGE_NOTIFICATION, n);
	}
	
	/*
	 * true for long length, false for short.
	 */
	public void msg(String str, boolean length) {
		int l = length?Toast.LENGTH_LONG:Toast.LENGTH_SHORT;
		Toast.makeText(getApplicationContext(), str, l).show();
		
	}
	
	public boolean connect() {
		if(!PoConnectionManager.getInstance().connect()) {
			connectionRetryIntent();
			return false;
		}
		PoRegistryService.getInstance().register();
		return true;
	}
	
	private void connectionRetryIntent(){
    	Intent myIntent = new Intent(this, PoConnStatusBR.class);
    	myIntent.putExtra("connection_retry", "");
    	PendingIntent pendingIntent;
    	pendingIntent = PendingIntent.getBroadcast(this, 0, myIntent, PendingIntent.FLAG_ONE_SHOT);
    	
	    AlarmManager alarmManager = (AlarmManager)getSystemService(ALARM_SERVICE);
        Calendar calendar = Calendar.getInstance();
	    calendar.setTimeInMillis(System.currentTimeMillis());
  	    calendar.add(Calendar.SECOND, CONNECTION_RETRY_DELAY);
	    alarmManager.set(AlarmManager.RTC, calendar.getTimeInMillis(), pendingIntent);
    }
	public void scheduleConnectRetry() {
		reconnect_sched = new ScheduledThreadPoolExecutor(1);
		reconnect_task = reconnect_sched.schedule(new Runnable() {
			public void run() {
				PoMiddlewareService.getInstance().connect();
			}
		},	10000, TimeUnit.MILLISECONDS);
	}
	public void cancelConnectRetry() {
		if(reconnect_task != null) {
			reconnect_task.cancel(false);
			reconnect_task = null;
		}
		if(reconnect_sched != null) {
			reconnect_sched.shutdownNow();
			reconnect_sched = null;
		}
	}
}

