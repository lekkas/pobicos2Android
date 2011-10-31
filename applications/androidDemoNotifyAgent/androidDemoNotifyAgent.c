#include <pobicos.h>

EVENT_HANDLER(PoInitEvent){
	PoEnableEvent(PoCommandArrivedEvent);
}


EVENT_HANDLER(PoCommandArrivedEvent){
	PoMsg msg;
	PoGetCommand(&msg);
	pongiNotifyByDisplayingText((uint8_t *)msg.data, (uint32_t)0);
}
