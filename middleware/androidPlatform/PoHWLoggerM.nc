#include "PoSysInsp.h"
#include "PoLogger.h"
module PoHWLoggerM {
	uses interface PoUARTI;
	uses interface PoMemI;
	uses interface PoSystemTimeI;
	uses interface PoNetworkMngrI;
	uses interface PoOnlineLogI;
	uses interface Leds;
    provides interface PoLogI;
    provides interface StdControl;
    provides interface Init;
}
implementation {
norace uint8_t logger_started = 0;
norace uint8_t pam_started = 0;
norace addrtype myAddr = 0xFFFF;
norace addrtype gwAd = 0xFFFE;

	command error_t Init.init(){
		return SUCCESS;
	}
	
	event void PoUARTI.messageReceived(uint8_t channel, uint8_t len, uint8_t* payload) {

	}
	
//	command void PoLogI.temp(){ }
	
	command void PoLogI.write(uint8_t channelNum, char* text, uint32_t value){ }
	
	event void PoOnlineLogI.pamStarted(addrtype gwAddr){
		pam_started = TRUE;
		gwAd = gwAddr;
	}
	
	command error_t StdControl.start() {
		logger_started = 1;
		return SUCCESS;
	}

 	command error_t StdControl.stop() {
		logger_started = 0;
		return SUCCESS;
 	}
 	
 	//event void PoNetworkMngrI.networkMembersChanged(addrtype *Addr, int len){}
 	//event void PoNetworkMngrI.reachableResp(int result){}
 	event void PoNetworkMngrI.joined(addrtype Addr){
 		myAddr = Addr;
 	}
  	event void PoNetworkMngrI.remoteNodeJoined(addrtype Addr){}
 	event void PoNetworkMngrI.remoteNodeLeft(addrtype Addr){}
	event void PoNetworkMngrI.windowUtilizationLow(addrtype Addr){}
	event void PoNetworkMngrI.windowUtilizationHigh(addrtype Addr){}
}
