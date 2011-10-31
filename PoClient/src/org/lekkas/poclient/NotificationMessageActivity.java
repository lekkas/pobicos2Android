package org.lekkas.poclient;

import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;


public class NotificationMessageActivity extends Activity {
	private static final String TAG = "NotificationMessageActivity";
	private String msg;
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.blank);
        Intent intent = getIntent();
        if(intent.hasExtra("message_data"))
        	msg = intent.getStringExtra("message_data");
	}
	@Override
    protected void onStart() {
    	super.onStart();
    	Log.e(TAG, "Message Activity Created");
    	showMessage();
    }
    @Override
    protected void onResume() {
    	super.onResume();
    }
    
    @Override
    protected void onPause() {
    	super.onPause();
    }
    @Override 
    public void onStop(){
    	Log.w(TAG, "OnStop()");
    	super.onStop();
    }

    public void showMessage() {
    	final AlertDialog.Builder alert = new AlertDialog.Builder(this);
    	final TextView text = new TextView(this);
    	text.setText(msg);
    	alert.setView(text);

		alert.setNeutralButton("Ok", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
				finish();
			}
		});
		alert.show();
    }
}
