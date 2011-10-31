package org.lekkas.poclient.PoAPI;

public interface MiddlewareManagerI {
	public void JNICall_InitMiddleware();
	public void JNICall_completeTasks();
	public void JNICallback_dbg(String dbg);
}
