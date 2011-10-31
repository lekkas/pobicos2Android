interface PoRuntimeSWTimersI
{
	command error_t createTimer(uint8_t * id);
	command error_t destroyTimer(uint8_t id);
	command error_t startOneShot(uint8_t id, uint32_t timeout);
	command error_t startPeriodic(uint8_t id, uint32_t timeout);
	command uint32_t getNow();
	command error_t getTimeLeft(uint8_t id, uint32_t *remaining);
	event void fired(uint8_t id);
}
