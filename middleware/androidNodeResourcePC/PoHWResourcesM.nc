/* 
 * This file was editted manually
 */

/*
 *
 * POBICOS - Platform for Opportunistic Behaviour
 * in Incompletely Specified, Heterogeneous Object Communities
 *
 * Contract Number: INFSO-ICT-223984
 * Webpage: www.ict-pobicos.eu
 *
 **************************************************************/
/**
 * Component representing drivers and logic for all node specific
 * resources. Each non-generic instruction is represented with a
 * command and each physical event is represented with an event.
 * Interface provided is machine-generated based on specific node
 * configuration.
 */
/* ************************************************************
 * !!!
 * !!! Component is specific for node configuration:
 * !!! androidNode.xml 
 * !!!
 * ************************************************************/

//#include <inttypes.h>

module PoHWResourcesM {

	provides {
		interface PoResourcesHALI;
		interface Init;
		interface StdControl;
	}
	uses {
		interface PoUARTI;
		interface Leds;
		interface Timer <TMilli> as Timer;
	}


}

#define DBG_PO_HW_RESOURCES	"PoHWResourcesM"


implementation {
	
//	const char alert[] = "Alert!";

 command error_t Init.init() {
	dbg(DBG_PO_HW_RESOURCES, "PoHWResourcesM: Initializing...\n"); 
	return SUCCESS;
 }

 command error_t StdControl.start() {
	dbg(DBG_PO_HW_RESOURCES, "PoHWResourcesM: Starting...\n"); 
	return SUCCESS;
 }

 command error_t StdControl.stop() {
	dbg(DBG_PO_HW_RESOURCES, "PoHWResourcesM: Stopping...\n"); 
	return SUCCESS;
 }

command void PoResourcesHALI.pongiAlertByDisplayingText() {
	
//	(*cached_JNIEnv)->CallVoidMethod(cached_JNIEnv, cached_ng_obj, cached_NGAlertText_mid);
	int i;


	dbg(DBG_PO_HW_RESOURCES, "LEKAS LEKKAS LEKKAS ALERT !!!!!!!!!!!!!"); 

	for(i = 0; i < 5; i++) {}

	signal PoResourcesHALI.returnValueReady(0, 0);
}
 
/* ***************************************************
 * Physical (hardware) events that may be signalled: */    


 
 event void Timer.fired(){
        /* */
 }

 event void PoUARTI.messageReceived(uint8_t channel, uint8_t len, uint8_t* payload) {
 	/* */
 } 

}

