#include "middleware.h"
#define PO_COMM_VIRTUAL_FILTER_MAX_PAYLOAD_LEN		51

module PoCommVirtualFilterM{
	provides interface Init;
	provides interface PoReliableTransportI;
	provides interface PoDatagramTransportI;
	uses interface PoReliableTransportI as SubReliable;
	uses interface PoDatagramTransportI as SubDatagram;
	uses interface PoNetworkMngrI;
}
implementation{

	addrtype myAddr = 0xffff;
	
	command error_t Init.init(){
		return SUCCESS;
	}
	
	command int PoDatagramTransportI.sendMsg(addrtype Addr, int Hops, PoMsg_t BEMsg){
		PoRadioMsg tempMsg;
		
		memcpy(&tempMsg, BEMsg, sizeof(PoRadioMsg));
		
		if(myAddr == 0xffff){
			if(call PoNetworkMngrI.getMyNetworkAddr(&myAddr) != PO_COMM_OK){
				//the message cannot be delivered because we dont know the source address yet
				dbg(DBG_WARNING, "PoCommVirtualFilterM: (line %d) not started\n", __LINE__);
				return PO_COMM_NOT_STARTED;
			}
		}
		
		if(BEMsg->len > PO_COMM_VIRTUAL_FILTER_MAX_PAYLOAD_LEN){
			dbg(DBG_WARNING, "PoCommVirtualFilterM: (line %d) too long msg\n", __LINE__);
			return PO_COMM_MSG_TOO_LARGE;
		}
		else if((IS_ADDR_VIRTUAL(Addr)) || (Addr == PO_BROADCAST_ADDR)){
			//physical --> virtual OR virtual --> physical
			
			dbg("PoCommVirtualFilterM", "PoCommVirtualFilterM: tx addr change: source = 0x%04x, dest = 0x%04x\n", myAddr, Addr);
			
			//change to virtual header type
			tempMsg.data[PO_COMM_HDR_TYPE] += 3;
			
			//virtual footer (source and dest addresses)
			tempMsg.data[tempMsg.len] = (myAddr & 0xff00) >> 8;
			tempMsg.data[tempMsg.len+1] = myAddr & 0x00ff;
			tempMsg.data[tempMsg.len+2] = (Addr & 0xff00) >> 8;
			tempMsg.data[tempMsg.len+3] = Addr & 0x00ff; 
			
			//msg length extended by the virtual footer
			tempMsg.len += 4;

			if(Addr != PO_BROADCAST_ADDR){
				//send the message to the gateway address
				return call SubDatagram.sendMsg(PO_COMM_GATEWAY_ADDR, Hops, (PoMsg*)&tempMsg);
			}
		}
		
		//physical --> physical OR virtual --> virtual
		return call SubDatagram.sendMsg(Addr, Hops, (PoMsg*)&tempMsg);
	}
	
	command int PoReliableTransportI.sendMsg(addrtype Addr, PoMsg_t RelMsg, int Retries, int *MsgID){
		//should not be called
		return call SubReliable.sendMsg(Addr, RelMsg, Retries, MsgID);
	}
	
	event void SubDatagram.msgArrived(addrtype Addr, int Hops, PoMsg_t BEMsg){

		if(BEMsg->len > PO_COMM_VIRTUAL_FILTER_MAX_PAYLOAD_LEN+4){
			dbg(DBG_WARNING, "PoCommVirtualFilterM: (line %d) too long msg\n", __LINE__);
		}
		else if(((Addr == PO_COMM_GATEWAY_ADDR) && (IS_MSG_VIRTUAL(BEMsg->data[PO_COMM_HDR_TYPE])))
		|| ((myAddr == PO_COMM_GATEWAY_ADDR) && (IS_MSG_VIRTUAL(BEMsg->data[PO_COMM_HDR_TYPE])))){	//NOTE: if PO_COMM_GATEWAY_ADDR is physical
			addrtype source, dest;
			
			//change to normal header type
			BEMsg->data[PO_COMM_HDR_TYPE] -= 3;
			
			//source and dest addresses from the virtual footer
			source = BEMsg->data[BEMsg->len-4] << 8 | BEMsg->data[BEMsg->len-3];
			dest = BEMsg->data[BEMsg->len-2] << 8 | BEMsg->data[BEMsg->len-1];
			
			//msg length decremented by the virtual footer size
			BEMsg->len -= 4;
			
			if(dest != myAddr && dest != PO_BROADCAST_ADDR){
				int i;
				
				dbg(DBG_WARNING, "PoCommVirtualFilterM: (line %d) dest (0x%04x) != myAddr (0x%04x)\n", __LINE__, dest, myAddr);
				
				for(i=0; i< BEMsg->len; i++){
					dbg("PoCommVirtualFilterM", "PoCommVirtualFilterM: BEMsg->data[%d] = 0x%02x\n", i, BEMsg->data[i]);
				}
				
				return;
			}
			
			dbg("PoCommVirtualFilterM", "PoCommVirtualFilterM: rx addr change: source = 0x%04x, dest = 0x%04x\n", source, dest);
			
			signal PoDatagramTransportI.msgArrived(source, Hops, BEMsg);
			return;
		}
		
		signal PoDatagramTransportI.msgArrived(Addr, Hops, BEMsg);
	}
	
	event void SubReliable.msgArrived(addrtype Addr, PoMsg_t RelMsg){
		signal PoReliableTransportI.msgArrived(Addr, RelMsg);
	}

	event void SubReliable.MsgSendresult(addrtype Addr, int MsgID, int Result){
		signal PoReliableTransportI.MsgSendresult(Addr, MsgID, Result);
	}

	event void PoNetworkMngrI.joined(addrtype Addr){
		myAddr = Addr;
	}
  	event void PoNetworkMngrI.remoteNodeJoined(addrtype Addr){}
 	event void PoNetworkMngrI.remoteNodeLeft(addrtype Addr){}
	event void PoNetworkMngrI.windowUtilizationLow(addrtype Addr){};
	event void PoNetworkMngrI.windowUtilizationHigh(addrtype Addr){};

}
