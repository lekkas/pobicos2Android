

generic configuration AlarmMilliC()
{
  provides interface Init;
  provides interface Alarm<TMilli,uint32_t> as AlarmMilli32;
}

implementation
{

  command error_t Init.init() {
	return SUCCESS;
  }

  // basic interface
  /**
   * Set a single-short alarm to some time units in the future. Replaces
   * any current alarm time. Equivalent to start(getNow(), dt). The
   * <code>fired</code> will be signaled when the alarm expires.
   *
   * @param dt Time until the alarm fires.
   */
  async command void AlarmMilli32.start(size_type dt) {
  
  }

  /**
   * Cancel an alarm. Note that the <code>fired</code> event may have
   * already been signaled (even if your code has not yet started
   * executing).
   */
  async command void AlarmMilli32.stop() {
  
  }

  /**
   * Signaled when the alarm expires.
   */
  async default event void AlarmMilli32.fired();

  // extended interface
  /**
   * Check if alarm is running. Note that a FALSE return does not indicate
   * that the <code>fired</code> event will not be signaled (it may have
   * already started executing, but not reached your code yet).
   *
   * @return TRUE if the alarm is still running.
   */
  async command bool AlarmMilli32.isRunning() {
	return TRUE;
  }

  /**
   * Set a single-short alarm to time t0+dt. Replaces any current alarm
   * time. The <code>fired</code> will be signaled when the alarm expires.
   * Alarms set in the past will fire "soon".
   * 
   * <p>Because the current time may wrap around, it is possible to use
   * values of t0 greater than the <code>getNow</code>'s result. These
   * values represent times in the past, i.e., the time at which getNow()
   * would last of returned that value.
   *
   * @param t0 Base time for alarm.
   * @param dt Alarm time as offset from t0.
   */
  async command void AlarmMilli32.startAt(size_type t0, size_type dt) {
  
  }

  /**
   * Return the current time.
   * @return Current time.
   */
  async command size_type AlarmMilli32.getNow() {
	return 0;
  }	

  /**
   * Return the time the currently running alarm will fire or the time that
   * the previously running alarm was set to fire.
   * @return Alarm time.
   */
  async command size_type AlarmMilli32.getAlarm() {
	return 0;
  }

}
