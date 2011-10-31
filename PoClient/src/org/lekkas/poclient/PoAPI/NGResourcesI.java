package org.lekkas.poclient.PoAPI;

public interface NGResourcesI {
	public void JNICallback_AlertText();
	public void JNICallback_NotifyText(String msg, int unsigned_millis);
	public void JNICallback_CreateDialog(String msg, int unsigned_seconds);
	public void JNICallback_DismissDialog();
	
	public void JNICall_DialogInputReceived(byte result);
	public void JNICall_DialogTimeout();
	
}
