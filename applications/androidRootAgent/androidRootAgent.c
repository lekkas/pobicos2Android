#include <pobicos.h>

#define ALERT_AGENT       	0x8000FFFF
#define CREATION_TIMEOUT	0


EVENT_HANDLER(PoInitEvent){
  PoEnableEvent(PoChildCreatedEvent);

  PongObjectQualifier oq;
  PoBuildUpObjectQualifier(&oq, PO_INIT, PONGO_MONITOR__CONSUMER_ELECTRONICS_OBJECT);
  // PoCreateNonGenericAgents(ALERT_AGENT, &oq, PO_CREATE_SINGLE, CREATION_TIMEOUT ,0);
  PoCreateNonGenericAgents(ALERT_AGENT, &oq, PO_CREATE_MULTIPLE, 0, 0);
}

EVENT_HANDLER(PoChildCreatedEvent){
}
