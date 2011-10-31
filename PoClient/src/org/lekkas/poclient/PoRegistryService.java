package org.lekkas.poclient;

import java.nio.ByteBuffer;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;


public class PoRegistryService extends Service {
	private static final String TAG = "PoRegistryService";
	private static PoRegistryService INSTANCE;
	private static final byte CLASS_MOBILE = 0x01;
	private STATE state;
	private LocationManager locationManager;
	private Location lastKnownLocation;
	private static final int TWO_MINUTES = 1000 * 60 * 2;
	
	private int seed;
	private char myAddr;
	private double lat;
	private double lon;
	

	public STATE getState() {
		return state;
	}
	public void setState(STATE s) {
		state = s;
	}

	public static PoRegistryService getInstance() {
		return INSTANCE;
	}
	
	public char getMyAddr() {
		return myAddr;
	}
	public int getSeed() {
		return seed;
	}
	
	public void setMyAddr(char b, int s) {
		myAddr = b;
		seed = s;
		state = STATE.REGISTERED;
		Log.w(TAG,"myAddr is set to: "+(int)myAddr+" and seed to "+(int)s);
	}
	public double getLat() {
		return lat;
	}
	public double getLon() {
		return lon;
	}
	public boolean register() {
		
		Network_Msg msg;
		ByteBuffer payload;
		
		byte payload_len = (byte)(1 + 8 + 8 + 2 + 4);	// Class of device + Lat + long + addr + seed

		payload = ByteBuffer.allocate(Serialization.uint8ToInt(payload_len));
		payload.put(CLASS_MOBILE).putDouble(lat).putDouble(lon);
		payload.putChar(myAddr).putInt(seed);
		payload.position(0);
		

		msg = new Network_Msg(Network_Msg.REGISTRY_REQ, payload_len, payload.array());
		payload.clear();
		return PoConnectionManager.getInstance().getOutMsgQ().offer(msg);
	}
	
	enum STATE {
		UNREGISTERED,
		REGISTERED,
		REJECTED
	};
	
	private void initLocationUpdates() {
		// Define a listener that responds to location updates
		LocationListener locationListener = new LocationListener() {
		    public void onLocationChanged(Location location) {
		      // Called when a new location is found by the network location provider.
		      //makeUseOfNewLocation(location);
		    	if (isBetterLocation(location, lastKnownLocation)) {
		    		lastKnownLocation = location;
		    		lat = location.getLatitude();
		    		lon = location.getLongitude();
		    		Log.e(TAG, "Got new location info: lat: "+lat+" lon: "+lon);
		    	}
		    }

		    public void onStatusChanged(String provider, int status, Bundle extras) {}

		    public void onProviderEnabled(String provider) {}

		    public void onProviderDisabled(String provider) {}
		  };

		// Register the listener with the Location Manager to receive location updates
		locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, TWO_MINUTES/2, 
				1000, locationListener);
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
		INSTANCE = this;
		// Acquire a reference to the system Location Manager
		locationManager = (LocationManager) this.getSystemService(Context.LOCATION_SERVICE);
		state = STATE.UNREGISTERED;
		lastKnownLocation = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
		if(lastKnownLocation != null) {
			lat = lastKnownLocation.getLatitude();
			lon = lastKnownLocation.getLongitude();
			Log.e(TAG, "Last known location: lat: "+lat+" lon: "+lon);
		}
		initLocationUpdates();
				
		//lat = 39.38406971202599;
		//lon = 22.816286087036133;
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
	}
	
	/** Determines whether one Location reading is better than the current Location fix
	  * @param location  The new Location that you want to evaluate
	  * @param currentBestLocation  The current Location fix, to which you want to compare the new one
	  */
	protected boolean isBetterLocation(Location location, Location currentBestLocation) {
	    if (currentBestLocation == null) {
	        // A new location is always better than no location
	        return true;
	    }

	    // Check whether the new location fix is newer or older
	    long timeDelta = location.getTime() - currentBestLocation.getTime();
	    boolean isSignificantlyNewer = timeDelta > TWO_MINUTES;
	    boolean isSignificantlyOlder = timeDelta < -TWO_MINUTES;
	    boolean isNewer = timeDelta > 0;

	    // If it's been more than two minutes since the current location, use the new location
	    // because the user has likely moved
	    if (isSignificantlyNewer) {
	        return true;
	    // If the new location is more than two minutes older, it must be worse
	    } else if (isSignificantlyOlder) {
	        return false;
	    }

	    // Check whether the new location fix is more or less accurate
	    int accuracyDelta = (int) (location.getAccuracy() - currentBestLocation.getAccuracy());
	    boolean isLessAccurate = accuracyDelta > 0;
	    boolean isMoreAccurate = accuracyDelta < 0;
	    boolean isSignificantlyLessAccurate = accuracyDelta > 200;

	    // Check if the old and new location are from the same provider
	    boolean isFromSameProvider = isSameProvider(location.getProvider(),
	            currentBestLocation.getProvider());

	    // Determine location quality using a combination of timeliness and accuracy
	    if (isMoreAccurate) {
	        return true;
	    } else if (isNewer && !isLessAccurate) {
	        return true;
	    } else if (isNewer && !isSignificantlyLessAccurate && isFromSameProvider) {
	        return true;
	    }
	    return false;
	}
	
	/* Checks whether two providers are the same */
	private boolean isSameProvider(String provider1, String provider2) {
	    if (provider1 == null) {
	      return provider2 == null;
	    }
	    return provider1.equals(provider2);
	}

}
