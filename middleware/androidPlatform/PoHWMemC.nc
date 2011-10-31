/*
 *
 * POBICOS - Platform for Opportunistic Behaviour
 * in Incompletely Specified, Heterogeneous Object Communities
 *
 * Contract Number: INFSO-ICT-223984
 * Webpage: www.ict-pobicos.eu
 *
 **************************************************************/

/* Configuration (decomposition) of PoHWMemM component.
 *
 * @author Jarek Domaszewicz WUT, Aleksander Pruszkowski WUT, Tomasz Paczesny WUT (Design)
 * @author Tomasz Paczesny WUT
 * 
 * @modified 15/06/2010: Added FlashStorage component for future compatibility with Flash memory - TomaszT
 */

#include "PoMemMngrM.h"
configuration PoHWMemC {
    provides {        
        interface Init;
        interface PoMemHALI;        
    }
    uses {
           ;     
    }
}
implementation {
    components PoHWMemM;       
	components new PoRAMMemM(MEM_V_RANDOM_TYPE_SIZE) as VolatileRandom;
	components new PoRAMMemM(MEM_NV_RANDOM_TYPE_SIZE) as NVolatileRandom;
	components new PoRAMMemM(MEM_STORAGE_TYPE_SIZE) as StorageRandom;
	components new PoRAMMemM(MEM_FLASH_STORAGE_TYPE_SIZE) as FlashStorage;


    Init = VolatileRandom.Init;
    Init = NVolatileRandom.Init;
    Init = StorageRandom.Init;
    Init = FlashStorage.Init;
	    
               
    PoMemHALI = PoHWMemM.PoMemHALI;
        	
    PoHWMemM.PoVRandomMemHALI -> VolatileRandom.PoRAMMemHALI;
    PoHWMemM.PoNVRandomMemHALI -> NVolatileRandom.PoRAMMemHALI;
    PoHWMemM.PoStorageMemHALI -> StorageRandom.PoRAMMemHALI;
    PoHWMemM.PoFlashStorageMemHALI -> FlashStorage.PoRAMMemHALI;
     
}
