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
 * Component representing drivers and logic needed to
 * initialize host platform and prepare it for POBICOS
 * middleware execution.
 * Implementation of this component depends on host platform used.
 * 
 * @author Jarek Domaszewicz WUT, Aleksander Pruszkowski WUT, Tomasz Paczesny WUT (Design)
 * @author Tomasz Paczesny WUT
 */

module PoHWHostM {	
	provides {
        interface PoHostHALI;      
    }
    uses {
      	interface Boot;             	      	      	
    }
}
implementation {

	command void PoHostHALI.startMiddleware(){
		
	}

	event void Boot.booted() {
        call PoHostHALI.startMiddleware();      	
    }
 
}
