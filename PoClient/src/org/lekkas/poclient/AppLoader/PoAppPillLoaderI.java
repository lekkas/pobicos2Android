package org.lekkas.poclient.AppLoader;

public interface PoAppPillLoaderI {
	public void loadAndStartApp();
	public void killRunningApp();
	public void loadApp(String path);
}
