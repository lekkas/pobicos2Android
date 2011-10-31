#include <pobicos.h>
#include <string.h>

EVENT_HANDLER(PoInitEvent){
 	PoEnableEvent(PONGE_DIALOG_INPUT_RECEIVED);
	PoEnableEvent(PoCommandArrivedEvent);
}

EVENT_HANDLER(PONGE_DIALOG_INPUT_RECEIVED) {
	PoMsg msg;
	uint32_t reply = pongiGetDialogInput();	// 1 = YES, 0 = NO
	sprintf((char*)msg.data, "%d", (int)reply);
	msg.len = strlen((char*)msg.data) + 1;
	PoSendReport(&msg,PO_MSG_BESTEFFORT);
}

EVENT_HANDLER(PoCommandArrivedEvent){
	PoMsg msg;
	PoGetCommand(&msg);
	pongiCreateDialog((uint8_t *)msg.data, (uint32_t)0 );	// returns FAIL or SUCCESS (FAIL ==  NON-zero, SUCCESS == 0)
}
