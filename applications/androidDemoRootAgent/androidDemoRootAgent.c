#include <pobicos.h>
#include <string.h>

#define DIALOG_AGENT       			0x8001FFFF
#define NOTIFY_AGENT       			0x8002FFFF
#define POLL_EXPIRATION_TIMEOUT		60000
#define	POLL_TIMER_ID				0
#define CREATION_TIMEOUT			0

int	agentCnt = 0;
int	yesReplyCnt = 0;
int	noReplyCnt = 0;
PoAgentID notifyAgent = 0;

EVENT_HANDLER(PoInitEvent){
	PongObjectQualifier oq;

	PoEnableEvent(PoChildCreatedEvent);
	PoEnableEvent(PoReportArrivedEvent);
	PoEnableEvent(PoTimeoutEvent);

	PoBuildUpObjectQualifier(&oq, PO_INIT, PONGO_MONITOR__CONSUMER_ELECTRONICS_OBJECT);
	PoCreateNonGenericAgents(NOTIFY_AGENT, &oq, PO_CREATE_SINGLE, 0, 0);
	PoCreateNonGenericAgents(DIALOG_AGENT, &oq, PO_CREATE_MULTIPLE, CREATION_TIMEOUT, 0);
	PoSetTimer(POLL_TIMER_ID, POLL_EXPIRATION_TIMEOUT);
}

EVENT_HANDLER(PoChildCreatedEvent) {
	PoMsg msg;
	PoAgentID cid;
	PoAgentType ctype;
	PoReqHandle h;

	PoGetChildInfo(&cid,&ctype,&h);	
	if(ctype == NOTIFY_AGENT) {
		notifyAgent = cid;
		return;
	}
	agentCnt++;
	sprintf((char *)msg.data, "%s", "Are you happy? :-) :-(");
	msg.len=strlen((char *)msg.data)+1;
	PoSendCommand(cid,&msg,PO_MSG_BESTEFFORT);
}

EVENT_HANDLER(PoReportArrivedEvent) {
	PoMsg msg;
	PoAgentID cid;
	PoAgentType ctype;
	PoReqHandle h;

	PoGetChildInfo(&cid,&ctype,&h);
	PoGetReport(&msg);
	if(msg.data[0] == '0') 	// this is a NO
		noReplyCnt++;
	else					// this is a YES
		yesReplyCnt++;
}

EVENT_HANDLER(PoTimeoutEvent) {
	PoMsg msg;

	if(notifyAgent == 0)
		return;

	sprintf((char *)msg.data, "Total: %d. YES: %d. NO: %d",
		agentCnt, yesReplyCnt, noReplyCnt);

	msg.len=strlen((char *)msg.data)+1;
	PoSendCommand(notifyAgent,&msg,PO_MSG_BESTEFFORT);
	PoSetTimer(POLL_TIMER_ID, POLL_EXPIRATION_TIMEOUT);
	//PoRelease(PoGetMyID());
}




