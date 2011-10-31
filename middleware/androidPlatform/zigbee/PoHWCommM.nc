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
* HW-dependent communications module for Android
*
* This module provides the POBICOS communication and network management interfaces for
* a the Android platform, using the JNI Callback mechanism.
* 
* 
**/

#include "middleware.h"
#define PO_HW_COMM_MAX_PAYLOAD_LEN		55

module PoHWCommM{
	provides{
		interface PoReliableTransportI as PoReliableTransportHALI;
		interface PoDatagramTransportI as PoDatagramTransportHALI;
		interface PoNetworkMngrI as PoNetworkMngrHALI;
		interface PoCloseProximityI as PoCloseProximityHALI;
		interface Init;
	}
}
implementation{
	
	typedef struct{
		PoRadioMsg msg;
		addrtype dest;
		uint8_t hops;
	} zbTxMsg;
	
	enum states{
		S_INITIAL,
		S_JOINED,
		S_SENDING,
		S_IDLE
	};
	uint8_t mState;
	
	addrtype myAddr;
	uint8_t *msgBuf;	


	command error_t Init.init(){
		dbg("INIT", "PoHWCommM\n");
		mState = S_INITIAL;
		myAddr = 0xffff;
		return SUCCESS;
	}

	command int PoReliableTransportHALI.sendMsg(addrtype Addr, PoMsg_t RelMsg, int Retries, int *MsgID){	
		//not supported at this layer
		return PO_COMM_FAIL;
	}
	
	command int PoDatagramTransportHALI.sendMsg(addrtype addr, int maxHops, PoMsg_t poMsg) {
		if(mState == S_INITIAL){
			dbg("PoHWCommM", "PoHWCommM: not running\n");
			return PO_COMM_NOT_STARTED;
		}
		else if(poMsg->len > PO_HW_COMM_MAX_PAYLOAD_LEN || poMsg->len > MAX_RADIO_MSG_DATA){
			dbg(DBG_WARNING, "PoHWCommM: (l:%d) too long msg\n", __LINE__);
			return PO_COMM_MSG_TOO_LARGE;
		}
		else if(addr == myAddr) { /* loopback */
			signal PoDatagramTransportHALI.msgArrived(myAddr, 0, poMsg);
			return PO_COMM_OK;
		}
		else {
			error_t ret;
			jbyte len = poMsg->len;
			jchar srcAddr = myAddr;
			jchar dstAddr = addr;
			int i;	
			// jbyte *buf;
			jbyteArray buf;

			buf = (*cached_JNIEnv)->NewByteArray(cached_JNIEnv, poMsg->len);
			if(buf == NULL) {
				dbg("PoHWCommM", "Error allocating JNI TX buf");
				return PO_COMM_FAIL;
			}
/*
			for(i = 0; i < poMsg->len; i++)
				buf[i] = poMsg->data[i];
*/
			(*cached_JNIEnv)->SetByteArrayRegion(cached_JNIEnv, buf, 0, poMsg->len, (jbyte *)poMsg->data);
			/*
			 * JNI Callback
			 */
			(*cached_JNIEnv)->CallVoidMethod(cached_JNIEnv, cached_net_obj, cached_NetSendPacket_mid, 
				buf, len, srcAddr, dstAddr);
			return PO_COMM_OK;
			// return PO_COMM_FAIL;
		}
		// dbg("PoHWCommM", "PoHWCommM: PO_COMM_NO_RESOURCES\n");
		// return PO_COMM_NO_RESOURCES;
	}

	command int PoNetworkMngrHALI.getMyNetworkAddr(addrtype *Addr){
		if(mState != S_INITIAL){
			*Addr = myAddr;
			return PO_COMM_OK;
		}
		return PO_COMM_NOT_STARTED;
	}
	
	command int PoNetworkMngrHALI.getMyPhysicalAddr(uint8_t *phyAddr){
		phyAddr[0] = 0x00;
		phyAddr[1] = 0x00;
		phyAddr[2] = 0x00;
		phyAddr[3] = 0x00;
		phyAddr[4] = 0x00;
		phyAddr[5] = 0x00;
		phyAddr[6] = (uint8_t)(TOS_NODE_ID >> 8);
		phyAddr[7] = (uint8_t)TOS_NODE_ID;
		return PO_COMM_OK;
	}
	
	command int PoNetworkMngrHALI.setNodeLivenessChecking(addrtype Addr, uint8_t state){
		return PO_COMM_FAIL;
	}
	
	command int PoNetworkMngrHALI.getNetworkMembers(addrtype **Addr, int *len){
		return PO_COMM_FAIL;
	}

	command int PoNetworkMngrHALI.joinNetwork(idtype NetworkID, keytype NetworkKey, addrtype *Addr){
		/* uint16_t netaddr = jnicallback_join()  */

		/*
		 * JNI Callback
		 */
		myAddr = (*cached_JNIEnv)->CallCharMethod(cached_JNIEnv, cached_net_obj, cached_NetJoinNet_mid);
		TOS_NODE_ID = myAddr;

		dbg("PoHWCommM", "LEKKAS: Got address: %d", myAddr);
		*Addr = myAddr;		
		mState = S_IDLE;
		signal PoNetworkMngrHALI.joined(myAddr);

		return PO_COMM_OK;	
	}
	
	command int PoNetworkMngrHALI.leaveNetwork(){
		/* jnicallback_leave_net */
		return PO_COMM_OK;
	}

	command int PoCloseProximityHALI.sendMsg(PoRadioMsg_t CPMsg){
		return PO_COMM_FAIL;
	}
	
	void Java_org_lekkas_poclient_PoAPI_NetworkService_nativeReceivedPacket(JNIEnv *env, 
		jobject obj, jbyteArray bArray, jbyte len, jchar source, jchar destination) __attribute__ ((C, spontaneous)) {
		PoRadioMsg rxMsg;

		uint8_t payload[len];
		(*cached_JNIEnv)->GetByteArrayRegion(cached_JNIEnv, bArray, 0, len, payload);

		if(destination != myAddr && destination != PO_BROADCAST_ADDR){
			// Discard
			return;
		}
		else if(len > MAX_RADIO_MSG_DATA){
			dbg(DBG_WARNING, "PoHWCommM: (line %d) received a too large msg (%d)\n", __LINE__, len);
			return;	
		}
		memcpy(rxMsg.data, payload, len);
		rxMsg.len = len;		
		dbg("PoHWCommM", "PoHWCommM: recv %d B from 0x%04x\n", len, source);
		signal PoDatagramTransportHALI.msgArrived(source, 1, (PoMsg*)&rxMsg);		
	}
}
