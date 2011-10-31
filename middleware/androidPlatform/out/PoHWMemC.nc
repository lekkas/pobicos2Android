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
 * @modified 15/06/2010 Added FlashStorage for future Flash memory compatibility by TomaszT
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
	components new PoPCMemM("V_R", MEM_V_RANDOM_TYPE_SIZE) as VolatileRandom;
	components new PoPCMemM("NVR", MEM_NV_RANDOM_TYPE_SIZE) as NVolatileRandom;
	components new PoPCMemM("NVS", MEM_STORAGE_TYPE_SIZE) as StorageRandom;
	components new PoPCMemM("FLASH", MEM_FLASH_STORAGE_TYPE_SIZE) as FlashStorage;

    Init = VolatileRandom.Init;
    Init = NVolatileRandom.Init;
    Init = StorageRandom.Init;
	Init = FlashStorage.Init;    
               
    PoMemHALI = PoHWMemM.PoMemHALI;
            
    PoHWMemM.PoVRandomMemHALI -> VolatileRandom.PoPCMemHALI;
    PoHWMemM.PoNVRandomMemHALI -> NVolatileRandom.PoPCMemHALI;
    PoHWMemM.PoStorageMemHALI -> StorageRandom.PoPCMemHALI; 
	PoHWMemM.PoFlashStorageMemHALI -> FlashStorage.PoPCMemHALI;     
}
