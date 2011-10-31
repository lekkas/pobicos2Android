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
 * Simple RAM memory.
 *
 * @author Tomasz Paczesny WUT (Design)
 * @author Tomasz Paczesny WUT
 *
 *
 * @modified 06/10/2009 Version 346, PoMemI read/write length type changed to uint16_t by Tomek
 */

generic module PoRAMMemM(uint32_t size) {
    provides {	
        interface Init;
        interface PoRAMMemHALI;	
    }
    
}
implementation {
    
	//const uint32_t size = 1024;
    
    // Create memory buffer in RAM as a static variable
	uint8_t memBuffer[size];

	command error_t Init.init() {
	  int i;
	  	  
	  dbg("INIT", "PoRAMMemM init\n");
	  
	  for (i=0; i< size; i++) {
	  	memBuffer[i] = 0xFF;	
		}		

	  return SUCCESS;	
    }

	/**
   * Reads one byte of data from the selected address of the POBICOS memory.
   * @param addr memory address from where to start getting data
   * @return Fetched data byte.  
   *
   **/
	command uint8_t PoRAMMemHALI.get8(PoMemAddr_t addr) {				
		
		
		if (addr+sizeof(uint8_t) > size){
			assert(0, ASSERT_RAMMEM_READ_OUT_OF_BOUNDS, "PoRAMMemM: get8: out of bounds\n");
            return 0;
		}
	
        return memBuffer[addr];	
	}

   /**
   * Reads two bytes of data from the selected address of the POBICOS memory.
   * @param addr memory address from where to start getting data
   * @return Fetched data bytes.  
   *
   **/
	command uint16_t PoRAMMemHALI.get16(PoMemAddr_t addr) {		
		uint16_t buf;
		
		if (addr+sizeof(buf) > size){
			assert(0, ASSERT_RAMMEM_READ_OUT_OF_BOUNDS, "PoRAMMemM: get16: out of bounds\n");
            return 0;
        }
			
		memcpy(&buf, &memBuffer[addr], sizeof(buf));					
        return buf;		
	}

   /**
   * Reads four bytes of data from the selected address of the POBICOS memory.
   * @param addr memory address from where to start getting data
   * @return Fetched data bytes.  
   *
   **/
	command uint32_t PoRAMMemHALI.get32(PoMemAddr_t addr) {
		uint32_t buf;
		
		if (addr+sizeof(buf) > size){
			assert(0, ASSERT_RAMMEM_READ_OUT_OF_BOUNDS, "PoRAMMemM: get32: out of bounds\n");
            return 0;
		}
		memcpy(&buf, &memBuffer[addr], sizeof(buf));
	
        return buf;
     }	
	

   /**
   * Reads block of data from the selected address of the POBICOS memory.
   * @param addr memory address from where to start getting data
   * @param data pointer to the place where to store read data
   * @param len number of bytes to read  
   *
   **/
	command void PoRAMMemHALI.read(PoMemAddr_t addr, uint8_t* data, uint16_t len) {		
		
		if (addr+len > size){
			assert(0, ASSERT_RAMMEM_READ_OUT_OF_BOUNDS, "PoRAMMemM: read: out of bounds\n");
            return;
		}				        		
		memcpy(data, &memBuffer[addr], len);
				
	}


   /**
   * Writes one byte of data at the selected address of the POBICOS memory.
   * @param addr memory address where to start putting data
   * @param data byte to be written	     
   *
   **/
	command void PoRAMMemHALI.put8(PoMemAddr_t addr, uint8_t data) {
		if (addr+sizeof(uint8_t) > size){
			assert(0, ASSERT_RAMMEM_WRITE_OUT_OF_BOUNDS, "PoRAMMemM: put8: out of bounds\n");
            return;
		}	
		memBuffer[addr] = data;		
	}

   /**
   * Writes two bytes of data at the selected address of the POBICOS memory.
   * @param addr memory address where to start putting data
   * @param data 16-bit data to be written	     
   *
   **/
	command void PoRAMMemHALI.put16(PoMemAddr_t addr, uint16_t data) {
		if (addr+sizeof(data) > size){
			assert(0, ASSERT_RAMMEM_WRITE_OUT_OF_BOUNDS, "PoRAMMemM: put16: out of bounds\n");
            return;
        }
       
        memcpy(&memBuffer[addr], &data, sizeof(data));
       
	}

   /**
   * Writes four bytes of data at the selected address of the POBICOS memory.
   * @param addr memory address where to start putting data
   * @param data 32-bit data to be written	     
   *
   **/
	command void PoRAMMemHALI.put32(PoMemAddr_t addr, uint32_t data) {
		if (addr+sizeof(data) > size){
			assert(0, ASSERT_RAMMEM_WRITE_OUT_OF_BOUNDS, "PoRAMMemM: put32: out of bounds\n");
            return;
       }
        memcpy(&memBuffer[addr], &data, sizeof(data));      
	}

   /**
   * Writes a block of data at the selected address of the POBICOS memory.
   * @param addr memory address where to start putting data
   * @param data pointer to the data structure to be written
   * @param len length in bytes of the data block  
   *
   **/
	command void PoRAMMemHALI.write(PoMemAddr_t addr, uint8_t* data, uint16_t len) {					 		
		
	if (addr+len > size) {
			assert(0, ASSERT_RAMMEM_WRITE_OUT_OF_BOUNDS, "PoRAMMemM: write: out of bounds\n");
            return;
	}
                      	
        memcpy(&memBuffer[addr], data, len);        	       
	}



}
