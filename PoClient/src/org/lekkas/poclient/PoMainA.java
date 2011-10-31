/*
 * Author: Kwstas Lekkas , kwstasl@gmail.com
 */
package org.lekkas.poclient;


import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.*;
import android.util.*;

import org.lekkas.poclient.AppLoader.PoAppPillLoader;


public class PoMainA extends Activity {
		
	private static final String TAG = "PoMainA";
	private static Intent service_intent;
	
	private static boolean app_status;
	
	/*
	 * False for disconnected, true for connected.
	 */
	public void setConnectivityStatus(boolean s) {
		TextView t = (TextView)this.findViewById(R.id.connectivityStatusText);
		if(t != null) {
			if(s) 
				t.setText(R.string.statusConnected);
			else
				t.setText(R.string.statusDisconnected);
		}
	}
		
	private void setAppStatus(boolean s) {
		TextView t = (TextView)this.findViewById(R.id.appStatusText);
		app_status = s;
		if(t != null) {
			if(s)
				t.setText("App started.");
			else
				t.setText("No App loaded.");
		}
	
	}
		
	
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        PoApp.setMainActivity(this);
        Log.d(TAG, "onCreate()");
        /*
        Intent in = getIntent();
        if(in.hasExtra("SERVICE_INTENT")) {
        	Log.w(TAG, "SERVICE INTENT STARTED MAIN!");
        	return;
        }*/
        if(!PoApp.isAppPill())
        	setContentView(R.layout.basic);
        else {
        	setAppPillInterface();
        }	
        firstConnectivityCheck();
        Log.w(TAG, "MAINACTIVITY oncreate RETURNING");
    }
    
    @Override
    protected void onStart() {
    	super.onStart();
    	Log.d(TAG, "onStart() called.");
    	if(!PoApp.isAppPill())
    		connectivityCheck();
    	else
    		setAppStatus(app_status);
    	
    	Log.w(TAG, "MAINACTIVITY onstart RETURNING");
    }
    
    @Override
    protected void onResume() {
    	super.onResume();
    	Log.d(TAG, "onResume() called.");
    }
    
    @Override
    protected void onPause() {
    	super.onPause();
    	Log.d(TAG, "onPause() called.");
    }
    @Override 
    public void onStop(){
    	super.onStop();
    }
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
    	super.onCreateOptionsMenu(menu);
    	MenuInflater inflater = getMenuInflater();
    	inflater.inflate(R.menu.mainmenu, menu);
    	return true;
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
    	switch(item.getItemId()) {
    	case R.id.menu_exit:    		
    		PoMiddlewareService.setOnAppExit();
    		if(PoMiddlewareService.isRunning()) {
    			service_intent = new Intent(this, PoMiddlewareService.class);
    			stopService(service_intent);
    			
    			service_intent = new Intent(this, PoRegistryService.class);
    	        stopService(service_intent);   
    		}
    		finish();
    		return true;
    	case R.id.menu_pass:
    		final AlertDialog.Builder alert = new AlertDialog.Builder(this);
    		final EditText input = new EditText(this);
    		alert.setView(input);
    		alert.setPositiveButton("Ok", new DialogInterface.OnClickListener() {
    			public void onClick(DialogInterface dialog, int which) {
    				String value = input.getText().toString();
    				if(value.compareTo("1234") == 0) {
    					PoApp.setAppPill(true);
    					setAppPillInterface();
    				}
    			}
    		});
    		alert.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
    			public void onClick(DialogInterface dialog, int which) {
    				dialog.cancel();
    			}
    		});
    		alert.show();
    		return true;
    	default:
    		return super.onOptionsItemSelected(item);
    	}
    }
    
    private void firstConnectivityCheck() {
		if(connectivityCheck() && !PoMiddlewareService.isRunning()) {
			service_intent = new Intent(this, PoRegistryService.class);
	        startService(service_intent);
			
			service_intent = new Intent(this, PoMiddlewareService.class);
	        startService(service_intent);   
		}	
	}
    
    /*
     * Returns true if we have an available network, 
     * false otherwise.
     */
    private boolean connectivityCheck() {
    	NetworkInfo wifi, mobile;
		ConnectivityManager cm = (ConnectivityManager)this.getSystemService(CONNECTIVITY_SERVICE);
		wifi = cm.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
		mobile = cm.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
		if((wifi.isConnected() || mobile.isConnected()) ) {
			setConnectivityStatus(true);
			return true;
		}
		else {
			setConnectivityStatus(false);
			return false;
		}
    }
    private void setAppPillInterface() {
    	setContentView(R.layout.pill);
    	Button startButton = (Button)this.findViewById(R.id.startButton);
        Button killButton = (Button)this.findViewById(R.id.killButton);
        
        startButton.setOnClickListener(new OnClickListener() {
            public void onClick(View v) {
            	if(!app_status) {
            		PoAppPillLoader.getInstance().loadAndStartApp();
                	setAppStatus(true);
                	Toast.makeText(getApplicationContext(), "App started.", Toast.LENGTH_SHORT).show();
            	}
            }
          });
        
        killButton.setOnClickListener(new OnClickListener() {
            public void onClick(View v) {
            	if(app_status) {
            		PoAppPillLoader.getInstance().killRunningApp();
                	setAppStatus(false);
                	Toast.makeText(getApplicationContext(), "App killed.", Toast.LENGTH_SHORT).show();
            	}
            	
            }
          });
    }
    
}