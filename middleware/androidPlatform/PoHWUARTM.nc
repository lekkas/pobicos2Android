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
 *  UART communication abstraction at byte level.
 *  Implementation of this component depends on host platform used.
 *
 * @author Jarek Domaszewicz WUT, Aleksander Pruszkowski WUT, Tomasz Paczesny WUT (Design)
 * @author Tomasz Paczesny WUT
 *
 * @modified 13/07/2010 added txStream command by Tomek
 */
 
#include "jnivars.h"
#define DBG_PO_HW_UART "PoHWUARTM"

module PoHWUARTM {
    provides {
        interface PoUARTHALI;                
        interface StdControl as Control;
        interface Init;
    }
}
implementation
{
	void Java_org_lekkas_poclient_PoAPI_UARTService_nativeRxByte(JNIEnv *env, 
		jobject obj, jbyte b) __attribute__ ((C, spontaneous)) {

		signal PoUARTHALI.rxByteReady(b, SUCCESS);
	}


	command error_t Init.init() {
		dbg(DBG_PO_HW_UART, "PoHWUARTM: initialized.\n");
        return SUCCESS;
	}

   // Standard StdControl interface function
    command error_t Control.start() {
        dbg(DBG_PO_HW_UART, "PoHWUARTM N#%02d: started\n");
        return SUCCESS;
    }

	// Standard StdControl interface function
    command error_t Control.stop() {
        dbg(DBG_PO_HW_UART, "PoHWUARTM N#%02d: stopping.\n", TOS_NODE_ID);
        return SUCCESS;
    }

  /**
   * Transmits a byte over UART
   *
   * @param data the byte to be transmitted
   *
   * @return SUCCESS if successful
   */
    async command error_t PoUARTHALI.txByte(uint8_t data) {    
        /*
		 * JNI Callback
		 */
		(*cached_JNIEnv)->CallIntMethod(cached_JNIEnv, cached_uart_obj, cached_UARTTxByte_mid, data);
        
        signal PoUARTHALI.txByteReady(SUCCESS);
        return SUCCESS;
    }
	
  /**
   * Transmits a stream of bytes over UART
   *
   * @param data pointer to the data to be transmitted
   * @param len length of the data to transmit
   *
   * @return SUCCESS if successful, FAIL otherwise
   */
  	async command error_t PoUARTHALI.txStream(uint8_t* data, uint8_t len) {
        uint8_t i;
		for(i = 0; i < len; i++) {
			call PoUARTHALI.txByte(data[i]);
		}

        signal PoUARTHALI.txByteReady(SUCCESS);
        return SUCCESS;
  	}

}
