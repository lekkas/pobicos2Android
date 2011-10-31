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
	
	uint32_t dialogResult = 0;

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
	
	int i;
	for(i = 0; i < 5; i++) {}

	(*cached_JNIEnv)->CallVoidMethod(cached_JNIEnv, cached_ng_obj, cached_NGAlertText_mid);

	signal PoResourcesHALI.returnValueReady(0, 0);
}

/*
 *	uint8_t *msg: Msg + terminating \0 , max 21 bytes;
 */

command void PoResourcesHALI.pongiNotifyByDisplayingText( uint8_t* msg, uint32_t millis) {

	jstring jmsg;
	jint mil = millis;

	jmsg = (*cached_JNIEnv)->NewStringUTF(cached_JNIEnv, (char *)msg);
	(*cached_JNIEnv)->CallVoidMethod(cached_JNIEnv, cached_ng_obj, cached_NGNotifyText_mid, jmsg, mil);

	signal PoResourcesHALI.returnValueReady(0, 0);
}
 

/*
 * Creates dialog
 */
command void PoResourcesHALI.pongiCreateDialog(uint8_t *text, uint32_t seconds) {
	jstring jmsg;
	jint secs = seconds;

	jmsg = (*cached_JNIEnv)->NewStringUTF(cached_JNIEnv, (char *)text);
	(*cached_JNIEnv)->CallVoidMethod(cached_JNIEnv, cached_ng_obj, cached_NGCreateDialog_mid, jmsg, secs);

	signal PoResourcesHALI.returnValueReady(sizeof(uint32_t), (uint32_t)SUCCESS);
}

/*
 * Gets dialog input.
 */
command void PoResourcesHALI.pongiGetDialogInput() {
	signal PoResourcesHALI.returnValueReady(sizeof(uint32_t), (uint32_t)dialogResult);
}

/*
 * Dismisses Dialog.
 * Currently not implemented.
 */
command void PoResourcesHALI.pongiDismissDialog() {
	(*cached_JNIEnv)->CallVoidMethod(cached_JNIEnv, cached_ng_obj, cached_NGDismissDialog_mid);
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

 jint Java_org_lekkas_poclient_PoAPI_NGResources_nativeDialogInputReceived(JNIEnv *env, 
		jobject obj, jbyte res) __attribute__ ((C, spontaneous)) {
		
		dialogResult = (int)res;
		signal PoResourcesHALI.dialogInputReceivedEvent();
		return 0;
	}

 jint Java_org_lekkas_poclient_PoAPI_NGResources_nativeDialogTimeout(JNIEnv *env, 
		jobject obj) __attribute__ ((C, spontaneous)) {
		
		signal PoResourcesHALI.dialogInputTimeoutEvent();
		return 0;
	}


}

