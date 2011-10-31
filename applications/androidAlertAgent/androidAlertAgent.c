#include <pobicos.h>

#define TIMEOUT 6000
#define TIMER_ID 0

EVENT_HANDLER(PoInitEvent){
	PoEnableEvent(PoTimeoutEvent);
	if ( PoSetTimer(TIMER_ID, TIMEOUT) != PO_RETCODE_OK) {
		PoDbgString("LEKKAS: COULD NOT SET TIMER.");
	}
	else {
		PoDbgString("LEKKAS: TIMER SET OK");
	}
}

EVENT_HANDLER(PoTimeoutEvent) {

//	pongiAlertByDisplayingText();
	if ( PoSetTimer(TIMER_ID, TIMEOUT) != PO_RETCODE_OK) {
		PoDbgString("LEKKAS: COULD NOT RESET TIMER.");
	}
	else {
		PoDbgString("LEKKAS: TIMER RESET OK");
	}

//	PoDbgString("LEKKAS: BEFORE ALERT");
	pongiAlertByDisplayingText();
//	PoDbgString("LEKKAS: AFTER ALERT");
}
