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
 * Types and defines for proxy TOSSIM setup
 *
 */
#ifndef PO_PROXY_H_
# define PO_PROXY_H_


#define PO_PHYSICAL_LAYER_PACKET_SIZE  (PO_PHYSICAL_LAYER_PAYLOAD_SIZE+PO_PHYSICAL_LAYER_HEADER_SIZE)
#define PO_PHYSICAL_LAYER_PAYLOAD_SIZE  128
#define PO_PHYSICAL_LAYER_HEADER_SIZE  2


#define PO_TCP_COMM_CHANNEL			0xF0

// UART message structure
typedef struct {
	uint8_t channel;
	uint8_t len;
	uint8_t data[PO_PHYSICAL_LAYER_PAYLOAD_SIZE];
} __attribute__ ((packed)) PoTCPMsg_t;




#endif
