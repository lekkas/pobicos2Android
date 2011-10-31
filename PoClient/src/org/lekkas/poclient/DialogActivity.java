package org.lekkas.poclient;

import java.util.concurrent.LinkedBlockingQueue;
import org.lekkas.poclient.PoAPI.PoAPI;
import org.lekkas.poclient.PoEvents.*;

import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;


public class DialogActivity extends Activity {
	private static final String TAG = "DialogActivity";
	private String msg;
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.blank);
        Intent intent = getIntent();
        if(intent.hasExtra("dialog_data"))
        	msg = intent.getStringExtra("dialog_data");
	}
	@Override
    protected void onStart() {
    	super.onStart();
    	Log.e(TAG, "DialogActivity Created");
    	showDialog();
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

    public void showDialog() {
    	final AlertDialog.Builder alert = new AlertDialog.Builder(this);
    	final TextView text = new TextView(this);
    	text.setText(msg);
    	alert.setView(text);
		alert.setPositiveButton("Yes", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				// Clicked YES
				LinkedBlockingQueue<PoEvent> q = PoAPI.getEventQueue();
				q.offer(new PoDialogInputReceived(PoDialogInputReceived.RESULT_YES));
				dialog.dismiss();
				finish();
			}
		});
		
		alert.setNegativeButton("No", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				// Clicked NO
				LinkedBlockingQueue<PoEvent> q = PoAPI.getEventQueue();
				q.offer(new PoDialogInputReceived(PoDialogInputReceived.RESULT_NO));
				dialog.dismiss();
				finish();
			}
		});
		alert.show();
    }
}
