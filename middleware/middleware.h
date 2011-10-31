/*
 *
 * POBICOS - Platform for Opportunistic Behaviour
 * in Incompletely Specified, Heterogeneous Object Communities
 *
 * Contract Number: INFSO-ICT-223984
 * Webpage: www.ict-pobicos.eu
 *
 **************************************************************/

/*
 * Common middleware internal types.
 *
 * @author WUT: Jarek Domaszewicz, Aleksander Pruszkowski, Tomasz Paczesny. CERETETH: Manos Koutsoubelias, Giorgis Georgakoudis, Nikolaos Tziritas. VTT: Mikko Ala-Louko
 * @author Tomasz Paczesny WUT, Manos Koutsoubelias CERETETH, Marko Jaakola VTT
 *
 * @modified 19/10/2009 V
ersion 391, added VIRTUAL_NULL definition by Tomek
 * @modified 28/10/2009 Version 447, added PoUATimerData_t definition by Tomek
 * @modified 2010-07-06 - some definitions are now in runtime.h due to runtime environment separation by TomaszT
 */
#ifndef PO_MIDDLEWARE_H_
# define PO_MIDDLEWARE_H_

// Definitions moved from PoHWResourceM by Tomek (15/12/2009)
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "master_config.h"
#include "pong.h"
#include "pog.h"
#include "runtime.h"

/* Assertion support for TOSSIM compilation. Possible place for iMote support also */
/* assert(bool expresion, uint8_t code, char * msg) */

//#ifdef TOSSIM
#ifdef ANDROID
#	define assert(arg1,arg2,arg3)								\
  	  if(!((arg1))){									\
		dbg(DBG_ERROR,"Assert failed, code: %d line %d msg: %s\n",arg2,__LINE__,arg3);	\
		while(0){asm("NOP");}			\
  	  }
#else
	extern void LED_loop(uint8_t code);
#	define assert(arg1,arg2,arg3)								\
 	   if(!((arg1))){									\
		LED_loop(arg2);									\
 	   }
#endif
/* USE THISS ASSERT IF DBG STRING SHOULD BE SEND REMOTELY BEFORE LED BLINKING
#else
#	define assert(arg1,arg2,arg3)								\
 	   if(!((arg1))){									\
		LED_loop(arg2);									\
		dbg(DBG_ERROR,"Assert failed, code: %d line %d msg: %s\n",arg2,__LINE__,arg3);	\
 	   }
#endif
*/

/* assert code defines */
#define ASSERT_NWKMNGR_JOIN_FAILED 1
#define ASSERT_CC2480_MSGBUF_FULL 2
#define ASSERT_COMM_MSGBUF_FULL 3
#define ASSERT_COMM_FRAGMBUF_FULL 4
#define ASSERT_COMM_SENDWIN_FULL 5
#define ASSERT_COMM_RECWIN_FULL 6
#define ASSERT_COMM_TOO_LARGE_MSG 7
#define ASSERT_INSP_REQ_MEMCPY_OVER_BOUNDS 8
#define ASSERT_INSP_RESP_MEMCPY_OVER_BOUNDS 9
#define ASSERT_NWKMNGR_MEM_TABLE_FULL 10

#define ASSERT_RAMMEM_WRITE_OUT_OF_BOUNDS 27
#define ASSERT_RAMMEM_READ_OUT_OF_BOUNDS 28
#define ASSERT_OBJECT_SETUP_FAIL 29
#define ASSERT_EVENT_QUEUE_OVERFLOW 30
#define ASSERT_CONCEPT_ALGEBRA_FAIL 31
#define ASSERT_QUALIFIER_INVALID 32
#define ASSERT_QUALIFIER_PROCESSING_ERROR 33
#define ASSERT_NG_INSTR_NOT_FOUND 34
#define ASSERT_DATA_ITEM_REMOVE_FAIL 35
#define ASSERT_DATA_ITEM_PUT_FAIL 36
#define ASSERT_FLASH_INIT_FAILURE 37
#define ASSERT_FLASH_WRITE_FAIL 38
#define ASSERT_FLASH_ERASE_FAIL 39
#define ASSERT_FLASH_READ_FAIL 40
#define ASSERT_FLASH_PAGE_WRITE_FAIL 41
#define ASSERT_FLASH_PAGE_READ_FAIL 42
#define ASSERT_FLASH_ASYNC 43
#define ASSERT_DESCRIPTOR_ERROR 44
#define ASSERT_UART_MSG_TOO_LONG 45
#define ASSERT_UART_TX_FAIL 46
#define ASSERT_MEM_SECTION_ID_MISMATCH 47
#define ASSERT_MEM_SECTION_OUT_OF_RANGE 48
#define ASSERT_REGISTER_AGENT_FAIL 49
#define ASSERT_TINYOS_TIMER_USED 50
#define ASSERT_TRUNCATE_REQUIREMENTS_BUFFER_TOO_SMALL 51
#define ASSERT_OUT_OF_MEMORY_FOR_EVENTS 52


#define ASSERT_AGENT_OUT_OF_BOUNDS 54
#define ASSERT_CHILD_OUT_OF_BOUNDS 55
#define ASSERT_CREQ_OUT_OF_BOUNDS 56
#define ASSERT_NODE_OUT_OF_BOUNDS 57
#define ASSERT_MSG_OUT_OF_BOUNDS 58
#define ASSERT_QUALIFIER_OUT_OF_BOUNDS 59
#define ASSERT_REPORT_OUT_OF_BOUNDS 60
#define ASSERT_MIGTASK_OUT_OF_BOUNDS 61
#define ASSERT_UNRECOGNIZED_BYTE_FLAG 62
#define ASSERT_SEND_NACK_MSG_FAILED 63
#define ASSERT_SEND_PING_MSG_FAILED 64
#define ASSERT_MIGRATION_FAILED 65
#define ASSERT_CREQ_FAILED 66
#define ASSERT_BROADCAST_FAILED 67
#define ASSERT_AGENT_INDEX_NOT_FOUND 68
#define ASSERT_AGENT_NOT_FOUND_IN_LIST 69
#define ASSERT_NODE_ALLOCATED_MEMORY_DEPLETED 70
#define ASSERT_ROOT_AGENT_CANNOT_BE_CREATED 71
#define ASSERT_NODE_DESC_NOT_FOUND 72
#define ASSERT_MIG_FAILED 73
#define ASSERT_MIG_DONE 74
#define ASSERT_MIG_ACK 75
#define ASSERT_REL_MSG_NOT_SENT 76
#define ASSERT_MIG_NACK 77


/* Warning and error debug channels (will be forwarded to PAM) */
/*usage: dbg(DBG_WARNING, "PoCommM: warning desription\n");*/
#define DBG_WARNING 	"DBG_WARNING"
#define DBG_ERROR 		"DBG_ERROR"
#define DBG_APP			"DBG_APP"


//#define IS_AGENT_GENERIC(x) (0)


/* POBICOS memory address type */
typedef uint32_t PoMemAddr_t;
#define PO_ADDRESS_INVALID (0xFFFFFFFFUL)

/* Type of offset value in the POBICOS memory */
typedef uint32_t PoMemOffs_t;

//(defined in runtime.h due to runtime enviroment separation )
typedef AgentMemAddr_t PoUAMemAddr_t;
#define PO_UA_ADDRESS_INVALID (0xFFFFU)

/* Type of node POBICOS network address */
typedef uint16_t PoNodeAddr_t;

/* status of event handler execution  (defined in runtime.h due to runtime enviroment separation )*/
typedef InterpreterStatus_t PoInterpreterStatus_t;

// Data item (PoDataItemM) types
#define PO_UA_IMAGE_DATA_ITEM			(0x01U)
#define PO_NG_REQUIREMENTS_DATA_ITEM	(0x02U)
#define PO_INVALID_DATA_ITEM			(0xFFU)

#define PO_DATA_ITEM_LEN_INVALID  0

// Client notification
typedef struct {
    uint8_t itemTypeID;
    uint32_t itemID;
    error_t itemReady;
} PoDataItemNotification_t;

#define PO_DATA_ITEM_REQUEST_CHUNK_MSG 		1
#define PO_DATA_ITEM_GIVE_CHUNK_MSG 		2
#define PO_DATA_ITEM_NO_SUCH_DATA_ITEM_MSG 	3

// Transaction structure
typedef struct {
    uint8_t itemTypeID;
    uint32_t itemID;
	PoNodeAddr_t sourceAddr;
	uint16_t leastReceivedChunkNumber;
	uint16_t totalChunksNumber;
	uint8_t lastChunkLen;
	int leastMsgID;
	uint8_t tickCounter;
	uint8_t pauseState;
} PoDataItemTransaction_t;

// (defined in runtime.h due to runtime environment separation )
#define PO_AGENT_ID_INVALID	(AGENT_ID_INVALID)
#define PO_AGENT_TYPE_INVALID	(AGENT_TYPE_INVALID)
#define PO_REQUEST_HANDLE_INVALID (REQUEST_HANDLE_INVALID)

/* instruction index in scope of the caller (microagent) (defined in runtime.h due to runtime environment separation )*/
typedef InstructionIndex_t PoInstructionIndex_t;

/* event handler index in scope of the microagent (defined in runtime.h due to runtime environment separation )*/
typedef EventHandlerIndex_t PoEventHandlerIndex_t;
#define PO_EVENT_HANDLER_INDEX_INVALID  (EVENT_HANDLER_INDEX_INVALID)

/* global instruction ID (defined in runtime.h due to runtime environment separation )*/
typedef InstructionID_t PoInstructionID_t;

// (defined in runtime.h due to runtime environment separation )
#define PO_INSTRUCTION_INVALID (INSTRUCTION_INVALID)
#define PO_EVENT_TYPE_INVALID (EVENT_TYPE_INVALID)


// (defined in runtime.h due to runtime environment separation )
typedef EventsMask_t PoEventsMask_t;

// Possible responses for event mask info request (defined in runtime.h due to runtime environment separation )
typedef EventMaskInfo_t PoEventMaskInfo_t;

// (defined in runtime.h due to runtime environment separation )
typedef RuntimeInstance_t PoUARuntimeInstance_t;


typedef struct {
		uint8_t tid;
		AgentID aid;
		TimerID uatid;
		uint8_t isSuspended;
		uint32_t timeLeft;
} PoUATimerData_t;
#define PO_RUNTIME_TIMER_ID_INVALID 	0xFF


// Extra data associated with events
typedef EventData_t PoEventData_t;

// Event handler execution request (defined in runtime.h due to runtime environment separation )
typedef ExecutionRequest_t PoExecutionRequest_t;

#define MSG_DATA_MAXLEN                 27 //used by UART
typedef struct {
    uint8_t len;
    uint8_t data[MSG_DATA_MAXLEN];
} __attribute__ ((packed)) UARTMsg;

// UART message structure
typedef struct {
	uint8_t channel;
	UARTMsg msg;
} PoUARTMsg_t;

// Invalid runtime SW timer ID
#define PO_RUNTIME_SW_TIMER_ID_INVALID 0xFF

// Non-generic resources related structures

/*
 *	fuzy number is (1/n) if n>0 or (1-1/(-n)) if n < 0
 */
typedef int8_t PongFuzyDist_t;
#define PONG_FUZY_POS 1
#define PONG_FUZY_NEG -1
#define PONG_FUZY_BEST 1
#define PONG_FUZY_WORST -1

// Serialized object qualifier structure (should not be used)
#define OBJ_QUALIFIER_SIZE	sizeof(PongObjectQualifier)
typedef struct {
	uint8_t array[OBJ_QUALIFIER_SIZE];
} PoObjQualifierByteArray_t;

typedef PongObjectQualifier PongTaxonomyQualifier;

// packed object qualifier
typedef struct{
	uint16_t size;
	uint8_t package[sizeof(PongObjectQualifier)];
} PongPackedObjectQualifier;

// Serialized distance vector structure
#define CONCEPT_DISTANCE_VECTOR_SIZE		(sizeof(uint8_t) + NUM_OBJECT_TAXONOMIES*sizeof(uint8_t))
typedef struct {
	uint8_t array[CONCEPT_DISTANCE_VECTOR_SIZE];
} PoDistVectorByteArray_t;

//checkNonGenRequirements return types
#define PO_REQ_NOT_MATCH 0
#define PO_REQ_MATCH 1
#define PO_REQ_MATCH_NOT_FREE 2

// Candidate nodes list structure
typedef struct {
	uint8_t candidatesNum;
	uint8_t candidatesToCreateNum;
	PoNodeAddr_t nodeAddresses[PO_MAX_CANDIDATE_NODES];
} PoCandidateNodesList_t;

typedef NonGenReqByteArray_t PoNonGenReqByteArray_t;


#include "PoNonGenResourceMngmtC.h"

#define PO_UART_CHANNEL_INVALID 	(0xFFU)



/* CERETETH */

//#define INSPECTION
//#define VERBOSE_INSPECTION
//#define PROXYZIG
#define AGENT_LIFETIME 180000 				//not used when ua mngr relies on nwk liveness
#define AMGR_MAX_RETRIES 4						//retries value passed to the comm. layer
#define PROBE_SCALE 1
#define PROBE_TIMEOUT (PROBE_SCALE*PO_COMM_MSG_TIMEOUT*1000*(MIN_RETRIES+1)) //max waiting
//#define PROBE_TIMEOUT 10000
#define PRESENCE_TIMEOUT 10000				//root robustness: for discovering double root agents (unreliable), ms
//#define CREQ_SVC_SCALE 5
//#define CREQ_SVC_TIMEOUT PROBE_TIMEOUT*CREQ_SVC_SCALE				//timeout between running the creation service again, ms
#define PING_TIMEOUT (PO_COMM_MSG_TIMEOUT*1000*(AMGR_MAX_RETRIES+1)) //ping liveness timeout, ms
#define ASAP 0 							//timeout for redoing an operation
#define BroadcastAddr 0xffff				//bcast address used by agent manager
#define MAX_HOPS 6							//hop awareness

#define MIG_REQ_GC_TIMEOUT					30000 //migration request garbage collection on new host side
#define MAX_RUNTIME_STATE_SIZE 			1161

//hop awareness
#define Cm 20//5
#define Rm 6//4
#define Lm 5//2

//migration policy
#define MaxInactPer 1 //how many periods an agent remains inactive for migration
#define MaxNodesLoad 10
#define P_BEN_THRES 10 //percentage benefit threshold
#define ABS_BEN_THRES 70 //absolute benefit threshold (in bytes)
#define MIG_CAP_PROB_TH 20 //probability of considering a node of full capacity
#define MIG_KHOP 1
/*TODO: restore #define MIG_ALG_TIMEOUT 300000
#define LOAD_CLEAN_TIMEOUT 450000*/
#define MIG_ALG_TIMEOUT 	10000	//how often do we take the decision to migrate an agent
#define LOAD_CLEAN_TIMEOUT 	30000	//for cleaning the collected loads

#define VIRTUAL_POOL_START 	40000
#define VIRTUAL_POOL_RANGE 	100


typedef uint16_t NodeAddr; //changed 020609, Imote testing

//this is WUT structure but it requires the NodeAddr type
typedef struct {
	AgentID appID;
	AgentType rootType;	
	AgentID rootID;
	NodeAddr rootAddr;
} appInfo_t;

enum
{
	CREQ_START=0x01,
	RLIST_START,
	REPORT_START,
	CHILD_DESC_START,
	RT_BUF,
 	RT_BLEN,
	END_OF_MSG,
	END_OF_TRANS
};
typedef enum
{
	MIG_IDLE,
	MIG_GETCODE,
	MIG_GETCODE_WAIT,
	MIG_GETCODE_FAIL,
	MIG_GETCODE_SUCCESS,
 	MIG_NOTIFY,
	MIG_NOTIFY_FAIL,
	MIG_NOTIFY_SUCCESS,
	MIG_SUSPEND_SUCCESS,
	MIG_FLUSH,
	MIG_FLUSH_FAIL,
	MIG_FLUSH_SUCCESS,
	MIG_DOIT,
	MIG_DOIT_WAIT,
	MIG_DOIT_STATUS,
	MIG_DOIT_ACK,
	MIG_DOIT_NACK,
	MIG_DOIT_FAIL,
	MIG_DOIT_SUCCESS
} migstate_t;

enum{
	NAckNeededFlag=1,
	NAckNotNeededFlag=2,
};

 enum{
	IS_VIRTUAL=1,
	IS_ROOT=2,
	IS_NORMAL=3,
};

enum{
	AGENT_UNREACHABLE=1,
	AGENT_SUICIDE=2,
	AGENT_RUNTIME_FAILURE=3,
	AGENT_RESOURCE_SHARING_EVICTION=4,
	CHILD_RELEASE=5,
	AGENT_INVALID_FLAG=6,
};


enum{
	CLEAN=1,
	DIRTY=2,
	ROOT_AVAIL=3,
};

enum{
	ParentFlag=1,
	ChildFlag=2,
};

enum{
	AgentMsgFlag=1,
	HeartbeatMsgFlag,
 	PingMsgFlag,
	NAckMsgFlag,
	HostAgentProbeMsgFlag,
	HostAgentProbeRepMsgFlag,
	HostAgentReqMsgFlag,
	HostAgentReqRepMsgFlag,
	GetAgentCodeReqMsgFlag,
	GetAgentCodeRepMsgFlag,
	MigNotifyMsgFlag,
	MigNotifyAckMsgFlag,
	MigFailedMsgFlag,
	MigReqMsgFlag,
	MigReplyMsgFlag,
	MigDoneMsgFlag,
	MigAckMsgFlag,
	MigNackMsgFlag,
	AgentStateMsgFlag,
	PresenceMsgFlag
	#ifdef INSPECTION
	,AgentMngrActionMsgFlag
	#endif
};

#ifdef INSPECTION
	enum{
		ACTION_MIG_OK=1,
		ACTION_MIG_FAIL=2,
		ACTION_CREQ_OK=3,
		ACTION_CREQ_FAIL=4,
		ACTION_RMV_AGENT=5,
		ACTION_TASK_INSERT=6,
		ACTION_SEND_MIG_NOTIFY_ACK=7,
		ACTION_RCV_MIG_NOTIFY=8,
		ACTION_NETWORK_JOIN=9,
		ACTION_NODE_RESET=10
	};
#endif


enum{
	WAIT_REQ_DATA_ITEM = 1,
	WAIT_MALLOC_RS=2,
	WAIT_PROBEREP=3,
	WAIT_REQREP=4,
	WAIT_MALLOC_LS=5
};

enum{
	NET_OK=0,
};

typedef enum
{
	MIG_OK=1,
	MIG_NOK
} mig_result_t;

/* CERETETH */

//Former POBICOS.h (VTT's COMM header) starts here:
	#define PO_COMM_GATEWAY_ADDR						0x0000
	#define DEFAULT_NUM_VIRTUAL_NODES					56
	#define IS_ADDR_VIRTUAL(addr) (((addr >= VIRTUAL_POOL_START) && (addr < (VIRTUAL_POOL_START+VIRTUAL_POOL_RANGE))) || (addr == PO_COMM_GATEWAY_ADDR)) ? TRUE : FALSE
	#define IS_MSG_VIRTUAL(type) ((type == PO_COMM_HDR_VIRTUAL_DATAGRAM) || (type == PO_COMM_HDR_VIRTUAL_RELIABLE) || (type == PO_COMM_HDR_VIRTUAL_ACK)) ? TRUE : FALSE

	uint16_t numVirtualNodes = DEFAULT_NUM_VIRTUAL_NODES;

	//#define COMM_ARBITER_RESOURCE "Comm.Arbiter.Resource"
	#define MAX_NODES 					67		//NOTE: MUST be a prime
	#define ID_TABLE_SIZE 				100
	#define MAX_SEQNUM 					255
	#define MAX_DATAGRAM_MSG_LEN		(55-PO_DATAGRAM_HEADER_LEN-4)	//largest msg that the ZB radio can stand is 55B
	#define AUTOMATIC_JOINING			1 								//define this to enable automatic network joining without PS-Card
	#define AUTOMATIC_JOINING_DELAY		100 							//delay before automatic joining
	//#define USE_SW_SECURITY				1							//define this to enable middleware-level security
	//#define PO_COMM_TEST					1
	//#define PO_HW_COMM_TEST				1
	//#define CC2480_RADIO					1
	//#define AM_RADIO						1

	#define PO_BROADCAST_IF_ID				50
	#define PO_SWSECURITY_IF_ID				51
	#define PO_NWKMNGR_IF_ID				52
	#define PO_SYSINSP_IF_ID				53
	#define PO_UAMNGR_IF_ID					54
	#define PO_DATAITEM_IF_ID				55
	#define PO_MEMSECTRANS_IF_ID			56
	#define PO_SYSINSPTIME_IF_ID			57
	#define PO_COMM_TEST_IF_ID				58

	//ZB CmdIds and handles
	#define PO_RELIABLE_ZB_HANDLE_MASK 	0x7F
	#define PO_DATAGRAM_ZB_HANDLE 		0x80
	#define PO_RELIABLE_ZB_CMD			0x0001
	#define PO_DATAGRAM_ZB_CMD			0x0000
	#define PO_REACHABLE_ZB_CMD			0x0002
	#define PO_LEAVE_NWK_ZB_CMD			0x0003
	#define PO_MEMBER_TABLE_REQ_CMD		0x0004
	#define PO_MEMBER_TABLE_RESP_CMD	0x0005

	//comm return values
	#define PO_COMM_OK					0		//success
	#define PO_COMM_HW_FAIL				1		//hw-communications component has failed
	#define PO_COMM_MSG_TOO_LARGE		2		//attempted to send too large message
	#define PO_COMM_NO_RESOURCES		3		//resources have run out (buffer is full)
	#define PO_COMM_NOT_STARTED			4		//component has not started yet
	#define PO_COMM_NODE_NOT_FOUND		5		//given node not found
	#define PO_COMM_BUSY				6		//component is busy
	#define PO_COMM_FAIL				7		//unspecified fail

	//msg send result values
	#define PO_COMM_SENDRESULT_OK		0
	#define PO_COMM_SENDRESULT_FAIL		1

	//comm header lengths
	#define PO_RELIABLE_HEADER_LEN		5
	#define PO_DATAGRAM_HEADER_LEN		2
	#define PO_ACKNOWLEDGE_LEN			4

	//comm header field positions
	#define PO_COMM_HDR_TYPE			0
	#define PO_COMM_HDR_IF_ID			1
	#define PO_COMM_REL_HDR_SEQNUM		2
	#define PO_COMM_REL_HDR_FLAGS		3
	#define PO_COMM_REL_HDR_FRAGM_NUM	4

	//comm header type indicators
	#define PO_COMM_HDR_DATAGRAM				0x00
	#define PO_COMM_HDR_RELIABLE				0x01
	#define PO_COMM_HDR_ACK						0x02
	#define PO_COMM_HDR_VIRTUAL_DATAGRAM		0x03
	#define PO_COMM_HDR_VIRTUAL_RELIABLE		0x04
	#define PO_COMM_HDR_VIRTUAL_ACK				0x05

	//comm header's flag-field's bit positions
	#define PO_COMM_FLAGS_SW_ACKS		2
	#define PO_COMM_FLAGS_FRAGM_EN		4
	#define PO_COMM_FLAGS_MORE_FRAGM	8
	#define PO_COMM_FLAGS_RESET			16

	//reliable transport options
	#define USE_SW_ACKS					1										//enable acknowledgements and message fragmentation at middleware level
	#define PO_COMM_WINDOW_SIZE			20 										//maximum number of unacked messages per one remote node
	#define MIN_RETRIES					3										//minimum amount of retries for reliable messages

	#ifdef TOSSIM
	#define MAX_BUFFERED_MSGS			(MAX_NODES*2*PO_COMM_WINDOW_SIZE)		//maximum number of buffered messages in communication component
	#else
	#define MAX_BUFFERED_MSGS			(MAX_NODES*5)							//maximum number of buffered messages in communication component
	#endif

	#define PO_COMM_MSG_TIMEOUT			7										//Timeout for sent messages in seconds
	#define PO_COMM_ACK_DELAY			500										//how long to wait for new msg before sending ack
	#define INITIAL_SEQNUM 				0
	//#define PO_COMM_RTT_MEAS

	#define MAX_RADIO_MSG_DATA			60										//NOTE: actual maximum for zb is 51

	//reliable transport timer
	#define BASE_TIMER_INTERVAL 		4000

	//network manager general
	#define PO_NWKMNGR_TIMEOUT_INTERVAL					1000								//"reacting time" of the network manager
	#define PO_NWKMNGR_SEND_RETRIES						5									//retries for nwk mngr
	#define PO_NWKMNGR_FREE_SLOT						0xffff								//free slot in member table
	#define PO_NWKMNGR_LOW_THRESH						40									//low threshold for the communication window occupation (in percentage)
	#define PO_NWKMNGR_HIGH_THRESH						80									//high threshold for the communication window occupation (in percentage)

	//keepalive protocol
	#define PO_NWKMNGR_KEEPALIVE_INTERVAL				(MAX_NODES*5)														//how often (in seconds) to send a KEEPALIVE msg
	#define PO_NWKMNGR_MAX_LOST_KEEPALIVES				6																	//how many keepalive intervals to wait before removing a node from the member table
	#define PO_NWKMNGR_DEFAULT_KEEPALIVE_STATE			PO_NWKMNGR_INITIAL_KEEPALIVE										//default state of the keepalive protocol
	#define PO_NWKMNGR_INITIAL_KEEPALIVE				(PO_NWKMNGR_KEEPALIVE_INTERVAL*PO_NWKMNGR_MAX_LOST_KEEPALIVES)		//number of nwk mngr timeouts before sending keep-alive msg (actual time-out time = PO_NWKMNGR_INITIAL_KEEPALIVE*NWK_MNGR_TIMEOUT_INTERVAL ms)
	#define PO_NWKMNGR_INFINITE_KEEPALIVE				0xffff																//infinite amount of timeouts

	//comm. timer types
	enum{
		PO_COMM_TIMER_MSG,
		PO_COMM_TIMER_ACK
	};

	//network manager header length
	#define PO_NWKMNGR_HDR_LEN			1

	//network manager header field positions
	#define PO_NWKMNGR_HDR_TYPE			0

	//network manager type indicators
	enum{
		PO_NWKMNGR_HDR_KEEPALIVE,
		PO_NWKMNGR_HDR_VIRT_KEEPALIVE
	};

	//broadcast component
	#define PO_BROADCAST_ADDR 			0xffff		//plaintext pobicos level broadcast (msg fragmentation)
	#define PO_SECURE_BROADCAST_ADDR	0xfffe		//encrypted pobicos level broadcast (msg fragmentation)
	#define PO_HW_BROADCAST_ADDR 		0xfffd		//plaintext hw level broadcast (NO msg fragmentation)
	#define PO_BROADCAST_HDR_IF_ID 		0
	#define PO_BROADCAST_HEADER_LEN 	1

typedef uint32_t addrtype;

typedef uint8_t* keytype;

typedef uint16_t idtype;

typedef struct{
	uint8_t len;
	uint8_t data[MAX_RADIO_MSG_DATA];
}PoRadioMsg;

typedef PoRadioMsg* PoRadioMsg_t;
typedef PoMsg* PoMsg_t;
/*
typedef struct {
	uint8_t len;
	uint8_t data[MAX_RF_MSG_DATA];
}PoRFMsg;

typedef PoRFMsg* PoRFMsg_t;
*/
typedef struct{
	AgentID		aid;
	AgentType	atype;
	AgentID		parent_id;
}AgentInfo;

typedef struct{
	addrtype addr;								//address of a remote node.
	uint8_t lastAckReceived;					//seqnum of last ack received
	uint8_t lastMsgSent;						//seqnum of last msg sent
	uint8_t lastMsgReceived;					//seqnum of last msg received
	uint8_t lastAckSent;						//seqnum of last ack sent
	uint8_t resetFlag;							//indicates if reset flag is on for this address
	uint16_t sentMsgBuf[PO_COMM_WINDOW_SIZE];	//indexes to unacked msgs in MsgNodeList. (0xffff = free slot)
	uint16_t recvMsgBuf[PO_COMM_WINDOW_SIZE];	//indexes to out-of-order received msgs in MsgNodeList. (0xffff = free slot)
	uint16_t fragmMsgBuf[PO_COMM_WINDOW_SIZE];	//indexes to received fragments in FragmList.
}addrInfo_t;

typedef struct{
	PoRadioMsg bufMsg;	//buffered msg waiting for ack
	int bufMsgId;		//MsgID of the msg
	int resends;		//amount of resends left for this msg
	#ifdef PO_COMM_RTT_MEAS
	uint32_t timeStamp;	//timestamp of the message
	#endif
	uint16_t next;		//index of the next buffered msg in the list (0xffff = last)
}msgNode_t;

typedef struct{
	PoRadioMsg fragmMsg;	//buffered msg waiting for ack
	//int bufMsgId;			//MsgID of the msg (needed?)
	uint16_t next;			//index of the next buffered msg in the list (0xffff = last)
}fragmNode_t;
/*
typedef struct{
	addrtype addr;				//destination address
	uint8_t timerEnabled;		//is the communications timer enabled for this node
	uint8_t timerValue;			//communications timer value
	//uint8_t keepAliveEnabled;	//is the keep alive protocol enabled for this node
	uint8_t keepAlive;			//keepalive timer value
	uint8_t keepAliveRetries;	//how many times the keepalive is sent before dropping a node
	uint8_t keepAliveTimeout;	//how many NWK_MNGR_TIMEOUT_INTERVAL periods to wait for one response to keep-alive
	uint8_t windowUtilization;	//percentual utilization of the communications window
	uint8_t signalWinUtil;		//whether or not to signal window utilization for this node
}nwkMngrNode_t;
*/

typedef struct{
	addrtype addr;								//destination address
	//uint8_t ackTimer;							//ack timer value
	//uint8_t ackSqnNumber;
	uint8_t msgTimers[PO_COMM_WINDOW_SIZE];		//message timer values
	uint8_t msgSqnNumbers[PO_COMM_WINDOW_SIZE];	//sequence counter values for the timers
	uint16_t keepAlive;							//keepalive timer value
	uint8_t windowUtilization;					//percentual utilization of the communications window
	uint8_t signalWinUtil;						//whether or not to signal window utilization for this node
}nwkMngrNode_t;

//struct for storing the ongoing split-phase requests in PoNetworkMngrM
typedef struct{
	int msgId;			//msgId of this request
	uint8_t reqType;	//request type (0xff for free slot)
} reqInfo_t;
/*
typedef struct{
	uint16_t numVirtualNodes;		//number of virtual nodes that are represented by this response
	addrtype primaryAddr:			//address of the primary virtual node
	addrtype secondaryPoolStart;	//start of the address pool of the secondary virtual nodes
	addrtype secondaryPoolEnd;		//end of the address pool of the secondary virtual nodes
} virtMemberInfoResp_t;
*/

typedef struct{
	uint16_t numVirtualNodes;		//number of virtual nodes that are represented by this message
	addrtype primaryAddr;			//address of the primary virtual node
	addrtype secondaryPoolStart;	//start of the address pool of the secondary virtual nodes
	addrtype secondaryPoolEnd;		//end of the address pool of the secondary virtual nodes
}virtKeepAlive_t;

	//PoMemI memory offsets for static variables in PoCommM//
	#define ADDRINFOTABLE_ADDR		0															//MAX_NODES*sizeof(addrInfo_t)
	#define ADDRINFOTABLELEN_ADDR	(sizeof(addrInfo_t)*MAX_NODES) 								//sizeof(uint16_t)
	#define MSGNODELIST_ADDR		(ADDRINFOTABLELEN_ADDR + sizeof(uint16_t))					//2*MAX_BUFFERED_MSGS*sizeof(msgNode_t)
	#define FIRSTFREEMSGNODE_ADDR	(MSGNODELIST_ADDR + 2*MAX_BUFFERED_MSGS*sizeof(msgNode_t))	//sizeof(uint16_t)
	#define LASTFREEMSGNODE_ADDR	(FIRSTFREEMSGNODE_ADDR + sizeof(uint16_t))					//sizeof(uint16_t)
	#define NEXT_MSG_ID_ADDR		(LASTFREEMSGNODE_ADDR+sizeof(uint16_t))						//sizeof(uint8_t)
	#define IDTABLE_ADDR			(NEXT_MSG_ID_ADDR+sizeof(uint8_t))							//ID_TABLE_SIZE*sizeof(uint8_t)
	#define FRAGMNODELIST_ADDR		(IDTABLE_ADDR+ID_TABLE_SIZE*sizeof(uint8_t))					//MAX_BUFFERED_MSGS*sizeof(fragmNode_t)
	#define FIRSTFREEFRAGMNODE_ADDR (FRAGMNODELIST_ADDR+MAX_BUFFERED_MSGS*sizeof(fragmNode_t))	//sizeof(uint16_t)
	#define LASTFREEFRAGMNODE_ADDR  (FIRSTFREEFRAGMNODE_ADDR+sizeof(uint16_t))					//sizeof(uint16_t)
	#define COMM_M_MEM_SIZE			(LASTFREEFRAGMNODE_ADDR+sizeof(uint16_t))

	//PoMemI memory offsets for static variables in PoCommTimersM//
	//#define TIMERBUF1_ADDR 		COMM_M_MEM_SIZE														//MAX_BUFFERED_MSGS*sizeof(commTimerInstance_t)/2
	//#define TIMERBUF2_ADDR		(TIMERBUF1_ADDR+MAX_BUFFERED_MSGS*sizeof(commTimerInstance_t)/2) 	//MAX_BUFFERED_MSGS*sizeof(commTimerInstance_t)/2
	//#define TIMERBUF1LEN_ADDR	(TIMERBUF2_ADDR+MAX_BUFFERED_MSGS*sizeof(commTimerInstance_t)/2)	//sizeof(int)
	//#define TIMERBUF2LEN_ADDR	(TIMERBUF1LEN_ADDR+sizeof(int))										//sizeof(int)
	//#define COMM_TIMERS_MEM_SIZE (TIMERBUF2LEN_ADDR+sizeof(int)-COMM_M_MEM_SIZE)

	//PoMemI memory offsets for static variables in PoNetworkMngrM//
	#define NWKMNGRTABLE_ADDR		(COMM_M_MEM_SIZE)												//MAX_NODES*sizeof(nwkMngrNode_t)
	//#define REQINFOTABLE_ADDR		(NWKMNGRTABLE_ADDR+MAX_NODES*sizeof(nwkMngrNode_t))				//PO_NWKMNGR_MAX_REQUESTS*sizeof(reqInfo_t)
	#define NWKMNGR_MEM_SIZE		(NWKMNGRTABLE_ADDR+MAX_NODES*sizeof(nwkMngrNode_t)-COMM_M_MEM_SIZE)

	#include "PoSecurityM.h"
	#ifdef USE_SW_SEC
	//PoMemI nv-ram memory section offsets for PoSWSecurityM
	#define MYNWKADDR_ADDR			(SECINFOLISTLEN_ADDR+sizeof(int))				//sizeof(addrtype)
	#define SECINFOLIST_ADDR		sizeof(addrtype)								//MAX_NODES*sizeof(secInfo_t)
	#define SECINFOLISTLEN_ADDR		(SECINFOLIST_ADDR+MAX_NODES*sizeof(secInfo_t))	//sizeof(int)
	#define NEXT_SECMSGID_ADDR		(SECINFOLISTLEN_ADDR+sizeof(int))				//sizeof(int)
	#define SWSECURITY_NVRAM_SIZE	(NEXT_SECMSGID_ADDR+sizeof(int))

	//PoMemI flash memory section offsets for PoSWSecurityM
	#define SECMSGNODELIST_ADDR			0														//PO_SECURITY_MSG_BUF_LEN*sizeof(secMsgNode_t)
	#define FIRSTFREESECMSGNODE_ADDR	(PO_SECURITY_MSG_BUF_LEN*sizeof(secMsgNode_t))			//sizeof(uint16_t)
	#define LASTFREESECMSGNODE_ADDR		(FIRSTFREESECMSGNODE_ADDR+sizeof(uint16_t))				//sizeof(uint16_t)
	#define SECINITLIST_ADDR			(LASTFREESECMSGNODE_ADDR+sizeof(uint16_t))				//MAX_NODES*sizeof(secInit_t)
	#define SECINITLISTLEN_ADDR			(SECINITLIST_ADDR+MAX_NODES*sizeof(secInit_t))			//sizeof(int)
	#define NWK_KEY_ADDR				(SECINITLISTLEN_ADDR+sizeof(int))						//PO_SECURITY_KEY_LEN
	#define SWSECURITY_FLASH_SIZE		(NWK_KEY_ADDR+PO_SECURITY_KEY_LEN)
	#else
	#define NWK_KEY_ADDR			0			//PO_SECURITY_KEY_LEN
	#define SWSECURITY_NVRAM_SIZE	0
	#define SWSECURITY_FLASH_SIZE	PO_SECURITY_KEY_LEN
	#endif

/* VTT SysInsp */
	#include "PoSysInsp.h"
/*/VTT SysInsp */



/* CERETETH structures */
enum
{
	AMGR_MAX_RESERVED_SLOTS = 2,
	AMGR_MAX_AGENTS = PO_MAX_RUNNING_AGENTS,
	AMGR_MAX_CHILDREN		= PO_MAX_RUNNING_AGENTS*8,				//how many children for the agents existing in this node
	AMGR_MAX_CREQS			= PO_MAX_RUNNING_AGENTS*2,					//how many creation requests can be ongoing in one node
	AMGR_MAX_NODE_DSCR	= MAX_NODES,				//how many nodes can the agent manager be aware of
	AMGR_MAX_MESSAGES		= PO_MAX_RUNNING_AGENTS*8,				//how many messages can be buffered
	AMGR_MAX_MIG_TASKS	= PO_MAX_RUNNING_AGENTS,					//how many migration tasks can be pending
	AMGR_MAX_REPORTS	= PO_MAX_RUNNING_AGENTS*8,					//how many reports can be stored in one node
	AMGR_MAX_NODE_CONFS	= MAX_NODES,//maximum number of node configurations
//#ifdef TOSSIM
	AMGR_MAX_RLISTS_PER_AGENT 	= 8,	//maximum number of report lists per agent
	AMGR_MAX_AGENTS_MIG_HOST = 1,			//maximum number of migration requests serviced in each node
	AMGR_MAX_CANDS = 32
};

#define PTR_INVALID		-1
typedef int ptr_t;
/* amgr uses doubly linked lists with head,tail pointers */
typedef struct
{
	ptr_t head;
	ptr_t tail;
} amgr_list_t;

typedef struct
{
	AgentID id;										/* child id */
	AgentType type;								/* child type */
	NodeAddr host;								/* child host */
	NodeAddr directNeighbor;
	uint32_t commLoad;
	ReqHandle reqHandler;
	uint32_t heartbeatT;					/* nxt heartbeat to child */
	uint8_t forceHeartbeatFlag;
	uint8_t cmig;									/* flag set if child is migrating */

	ptr_t ptrnext;
	ptr_t ptrprev;

} ChildDesc;

typedef struct
{
	NodeAddr node;
	uint32_t load;
} NodeLoad;


typedef struct
{
	AgentType atype;
	amgr_list_t rlist;
} ReportList;

typedef struct
{
	AgentID appId; 		/* used as application id, applicaiton pill address is also implied */
	AgentID id;					/* agent id */
	AgentID pid;				/* parent id */
	AgentType type;
	NodeAddr phost;			/* parent host */
	NodeAddr pdirectNeighbor;
	uint8_t specialFlag;
	NodeAddr pillAddr;
	uint8_t perToRemInact; /*periods to remain inactive for migration*/
	uint32_t pcommLoad;
	uint8_t pmig;				/* flag set if parent is migrating */
	uint32_t lifeT;			/* until declared orphan */
	uint32_t presenceT;			/* when a presence message should be sent */
	uint8_t sendNackMsgFlag; /* flag to indicate if an agent was released by its parent */

	uint8_t rlist_bitmap[AMGR_MAX_RLISTS_PER_AGENT/8+((AMGR_MAX_RLISTS_PER_AGENT%8)?1:0)];
	ReportList lists[AMGR_MAX_RLISTS_PER_AGENT];
	amgr_list_t child_list;
	ptr_t ptrnext;
	ptr_t ptrprev;
} LocalAgentDesc;

typedef struct
{
	AgentType type;
	uint8_t nofagents;
	uint8_t tried;
	uint16_t timeout;
	uint32_t lifeT;
	AgentID appId;
	NodeAddr pillAddr;
	ReqHandle reqHandler;
	uint8_t enabled;

	int cur_cand;
	NodeAddr cand[AMGR_MAX_CANDS];

	ptr_t ptrQualifier;
	ptr_t ptrLocalAgent;
	ptr_t ptrnext;
	ptr_t ptrprev;
} CreqDesc;

typedef struct
{
	uint32_t src;									/* source id */
	uint32_t dst;									/* destination id */
	uint8_t relflag;
	uint8_t reliable;							/* delivery option */
	uint8_t mig_marked;							/* marks a message as the last in this msgq for migration purposes */
	int mid;
	PoMsg msg;

	ptr_t ptrnext;
	ptr_t ptrprev;
} MsgDesc;

typedef struct
{
	PoNodeAddr_t nodeAddr;								/* node id */
	uint32_t ownEpoch;						/* own epoch number */
	uint32_t remEpoch;						/* remote epoch number */
	uint32_t ownSeqNo;						/* own sequence number */
	uint32_t remSeqNo;						/* remote sequence number */
	uint32_t mid;									/* reliable msg id for NET acks */
	uint8_t wait;									/* for transmission status */
	uint8_t capacity;             /* number of agents a node can host */
	uint32_t lastMsgT;

	amgr_list_t msg_list;
	ptr_t ptrnext;
	ptr_t ptrprev;
} NodeDesc;

typedef struct
{
	AgentID cid;
	PoMsg msg;

	ptr_t ptrnext;
	ptr_t ptrprev;
} Report;

typedef struct
{
	ptr_t ptrAgentDesc;
	PoNodeAddr_t hostAddr;
	uint8_t configSettingsChanged;
	uint8_t suspended;

	ptr_t ptrprev;
	ptr_t ptrnext;
} MigTask;

typedef struct
{
	uint16_t booted;
	uint16_t agentNo;
	uint32_t epoch;
	uint32_t creqSeqno;
	uint32_t migSeqno;
	uint32_t migHostSeqno;
} local_conf;

typedef struct
{
	PoNodeAddr_t nodeAddr;
	uint32_t nodeSeqno;
	uint32_t nodeEpoch;
} node_conf;

typedef struct
{
	uint32_t mig_req_seqno;
	AgentType atype;
	AgentID appId;
	NodeAddr pillAddr;
	AgentID aid;
	uint8_t rt_buf[MAX_RUNTIME_STATE_SIZE];
	uint16_t blen;
	uint32_t lifeT;
	uint8_t configSettingsChanged;
} amgr_mig_data;

/* CERETETH structures */

#endif  /* PO_MIDDLEWARE_H_ */

