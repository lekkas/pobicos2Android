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
 *  Component representing drivers and logic needed to provide
 *  physical layer communication abstraction at byte level over TCP/IP connection.
 *
 * @author Aleksander Pruszkowski WUT, Tomasz Paczesny WUT (Design)
 * @author Tomasz Paczesny WUT
 *
 * @modified 23/10/2009, Version 413, changed to bigger, more reliable rx buffer by Tomek
 * @modified 26/10/2009 Version 415, added connection-waiting loop in the initialization routine by Tomek     
 * @modified 2010-07-29 - added source and destination address in sendPacket(..) and in handle_tcp_event(.,) by TomaszT  
 */
 
module PoTCPPhysicalLayerM {
    provides {
        interface PoCommPhysicalLayerI;                
        interface StdControl as Control;
        interface Init;
    }
}
implementation
{

#define DBG_PO_TCP_PHYSICAL_LAYER "PoTCPPhysicalLayerM"
	
	// Standard Init interface function

    command error_t Init.init() {
		dbg(DBG_PO_TCP_PHYSICAL_LAYER, "PoTCPPhysicalLayerM: initialized.\n");
        return SUCCESS;
    }

   // Standard StdControl interface function

    command error_t Control.start() {
        dbg(DBG_PO_TCP_PHYSICAL_LAYER, "PoTCPPhysicalLayerM: started\n");
        return SUCCESS;
    }

	// Standard StdControl interface function

    command error_t Control.stop() {
        dbg(DBG_PO_TCP_PHYSICAL_LAYER, "PoTCPPhysicalLayerM: stopping.\n");
        return SUCCESS;
    }

  /**
   * Sends a packet to the underlying network.
   * @param payload pointer to the packet data
   * @param len packet data length (maximum is PO_PHYSICAL_LAYER_PAYLOAD_SIZE)
   * @return SUCCESS if packet was transmited succesfully;
   *    ESIZE if 'len' paramater is too big for the underlying medium;
   *    EOFF if the underlying physical layer isn't operational
   *    FAIL otherwise.  
   *
   **/
   
    
    command error_t PoCommPhysicalLayerI.sendPacket(uint8_t* payload, uint8_t len, uint16_t source, uint16_t destination) {            
	/*
	 * JNI Magic
     */
        return SUCCESS;
    }
	
	void signals() {
		signal PoCommPhysicalLayerI.receivedPacket(NULL, 0, 0, 0);				// JNI Call
		signal PoCommPhysicalLayerI.physicalLayerStatusChanged(TRUE || FALSE);	// JNI Call

	}

}

