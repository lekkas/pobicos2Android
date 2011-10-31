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
 * Component representing drivers and logic needed to provide flat
 * memory abstraction used by Memory manager(POBICOS node memory).
 * It may control more then one memory type (e.g. FLASH, RAM, FRAM)
 * at a time as long as PoMemHALI is supported.
 * Each memoty type used must be mapped into the POBICOS memory area 
 * of specific functionality (storage, random non-volatile and random
 * volatile memory).
 *
 * Implementation of this component depends on hardware memory
 * module/s used. 
 *
 * Version using Rovers memory iplementation (RvMemC)
 * 
 * @author Jarek Domaszewicz WUT, Aleksander Pruszkowski WUT, Tomasz Paczesny WUT (Design)
 * @author Tomasz Paczesny WUT 
 * @modified 06/10/2009 Version 346, read/write length type changed to uint16_t by Tomek
 * @modified 15/06/2010 Added FlashStorage for future Flash memory compatibility by TomaszT
 */
 
 
#include "PoMemMngrM.h"
module PoHWMemM {	
	provides {
        interface PoMemHALI;      
    }
    uses {
      	interface PoPCMemHALI as PoVRandomMemHALI;
      	interface PoPCMemHALI as PoNVRandomMemHALI;
      	interface PoPCMemHALI as PoStorageMemHALI;
		interface PoPCMemHALI as PoFlashStorageMemHALI;
    }
}
implementation {

   /**
   * Reads one byte of data from the selected address of the POBICOS memory.
   * @param addr memory address from where to start getting data
   * @return Fetched data byte.  
   *
   **/
	command uint8_t PoMemHALI.get8(PoMemAddr_t addr) {
		if (IS_V_RANDOM_ADDRESS(addr))
			return call PoVRandomMemHALI.get8(MASK_PHYSICAL_ADDRESS(addr));
		else 
			if (IS_NV_RANDOM_ADDRESS(addr))
				return call PoNVRandomMemHALI.get8(MASK_PHYSICAL_ADDRESS(addr));
			else
				if (IS_STORAGE_ADDRESS(addr))
					return call PoStorageMemHALI.get8(MASK_PHYSICAL_ADDRESS(addr));
				else 
					return call PoFlashStorageMemHALI.get8(MASK_PHYSICAL_ADDRESS(addr));
	}

   /**
   * Reads two bytes of data from the selected address of the POBICOS memory.
   * @param addr memory address from where to start getting data
   * @return Fetched data bytes.  
   *
   **/
	command uint16_t PoMemHALI.get16(PoMemAddr_t addr) {		
		if (IS_V_RANDOM_ADDRESS(addr))
			return call PoVRandomMemHALI.get16(MASK_PHYSICAL_ADDRESS(addr));
		else 
			if (IS_NV_RANDOM_ADDRESS(addr))
				return call PoNVRandomMemHALI.get16(MASK_PHYSICAL_ADDRESS(addr));
			else
				if (IS_STORAGE_ADDRESS(addr))
					return call PoStorageMemHALI.get16(MASK_PHYSICAL_ADDRESS(addr));
				else 
					return call PoFlashStorageMemHALI.get16(MASK_PHYSICAL_ADDRESS(addr));
	}

   /**
   * Reads four bytes of data from the selected address of the POBICOS memory.
   * @param addr memory address from where to start getting data
   * @return Fetched data bytes.  
   *
   **/
	command uint32_t PoMemHALI.get32(PoMemAddr_t addr) {
		if (IS_V_RANDOM_ADDRESS(addr))
			return call PoVRandomMemHALI.get32(MASK_PHYSICAL_ADDRESS(addr));
		else 
			if (IS_NV_RANDOM_ADDRESS(addr))
				return call PoNVRandomMemHALI.get32(MASK_PHYSICAL_ADDRESS(addr));
			else
				if (IS_STORAGE_ADDRESS(addr))
					return call PoStorageMemHALI.get32(MASK_PHYSICAL_ADDRESS(addr));
				else 
					return call PoFlashStorageMemHALI.get32(MASK_PHYSICAL_ADDRESS(addr));
	}


   /**
   * Reads block of data from the selected address of the POBICOS memory.
   * @param addr memory address from where to start getting data
   * @param data pointer to the place where to store read data
   * @param len number of bytes to read  
   *
   **/
	command void PoMemHALI.read(PoMemAddr_t addr, uint8_t* data, uint16_t len) {
		if (IS_V_RANDOM_ADDRESS(addr))
			return call PoVRandomMemHALI.read(MASK_PHYSICAL_ADDRESS(addr), data, len);
		else 
			if (IS_NV_RANDOM_ADDRESS(addr))
				return call PoNVRandomMemHALI.read(MASK_PHYSICAL_ADDRESS(addr), data, len);
			else
				if (IS_STORAGE_ADDRESS(addr))
					return call PoStorageMemHALI.read(MASK_PHYSICAL_ADDRESS(addr), data, len);
				else 
					return call PoFlashStorageMemHALI.read(MASK_PHYSICAL_ADDRESS(addr), data, len);
	}
	
	
   /**
   * Writes one byte of data at the selected address of the POBICOS memory.
   * @param addr memory address where to start putting data
   * @param data byte to be written	     
   *
   **/
	command void PoMemHALI.put8(PoMemAddr_t addr, uint8_t data) {
		if (IS_V_RANDOM_ADDRESS(addr))
			return call PoVRandomMemHALI.put8(MASK_PHYSICAL_ADDRESS(addr),data);
		else 
			if (IS_NV_RANDOM_ADDRESS(addr))
				return call PoNVRandomMemHALI.put8(MASK_PHYSICAL_ADDRESS(addr),data);
			else
				if (IS_STORAGE_ADDRESS(addr))
					return call PoStorageMemHALI.put8(MASK_PHYSICAL_ADDRESS(addr),data);
				else 
					return call PoFlashStorageMemHALI.put8(MASK_PHYSICAL_ADDRESS(addr),data);
		
	}

   /**
   * Writes two bytes of data at the selected address of the POBICOS memory.
   * @param addr memory address where to start putting data
   * @param data 16-bit data to be written	     
   *
   **/
	command void PoMemHALI.put16(PoMemAddr_t addr, uint16_t data) {
		if (IS_V_RANDOM_ADDRESS(addr))
			return call PoVRandomMemHALI.put16(MASK_PHYSICAL_ADDRESS(addr),data);
		else 
			if (IS_NV_RANDOM_ADDRESS(addr))
				return call PoNVRandomMemHALI.put16(MASK_PHYSICAL_ADDRESS(addr),data);
			else
				if (IS_STORAGE_ADDRESS(addr))
					return call PoStorageMemHALI.put16(MASK_PHYSICAL_ADDRESS(addr),data);
				else 
					return call PoFlashStorageMemHALI.put16(MASK_PHYSICAL_ADDRESS(addr),data);

	}

   /**
   * Writes four bytes of data at the selected address of the POBICOS memory.
   * @param addr memory address where to start putting data
   * @param data 32-bit data to be written	     
   *
   **/
	command void PoMemHALI.put32(PoMemAddr_t addr, uint32_t data) {
		if (IS_V_RANDOM_ADDRESS(addr))
			return call PoVRandomMemHALI.put32(MASK_PHYSICAL_ADDRESS(addr),data);
		else 
			if (IS_NV_RANDOM_ADDRESS(addr))
				return call PoNVRandomMemHALI.put32(MASK_PHYSICAL_ADDRESS(addr),data);
			else
				if (IS_STORAGE_ADDRESS(addr))
					return call PoStorageMemHALI.put32(MASK_PHYSICAL_ADDRESS(addr),data);
				else 
					return call PoFlashStorageMemHALI.put32(MASK_PHYSICAL_ADDRESS(addr),data);

	}

   /**
   * Writes a block of data at the selected address of the POBICOS memory.
   * @param addr memory address where to start putting data
   * @param data pointer to the data structure to be written
   * @param len length in bytes of the data block  
   *
   **/
	command void PoMemHALI.write(PoMemAddr_t addr, uint8_t* data, uint16_t len) {
		
		if (IS_V_RANDOM_ADDRESS(addr))
			return call PoVRandomMemHALI.write(MASK_PHYSICAL_ADDRESS(addr),data,len);
		else 
			if (IS_NV_RANDOM_ADDRESS(addr))
				return call PoNVRandomMemHALI.write(MASK_PHYSICAL_ADDRESS(addr),data,len);
			else
				if (IS_STORAGE_ADDRESS(addr))
					return call PoStorageMemHALI.write(MASK_PHYSICAL_ADDRESS(addr),data,len);
				else 
					return call PoFlashStorageMemHALI.write(MASK_PHYSICAL_ADDRESS(addr),data,len);
	}
  
  
  /**
   * On the return of this command it is guaranteed that all
   * data writes to the POBICOS memory related to the same
   * hardware memory implementation are committed. Based on memory
   * section of calling component proper hardware memory module is addressed
   * for flushing. 
   * It's use is specially related to the non-volatile memory sections
   * where after the flush() command all written data are considered
   * non-volatile.       
   *
   * @param addr memory address of the beginning of the memory section
   * that is going to be flushed
   **/
   
	command void PoMemHALI.flush(PoMemAddr_t addr) {
		if (IS_V_RANDOM_ADDRESS(addr))
			return call PoVRandomMemHALI.flush();
		else 
			if (IS_NV_RANDOM_ADDRESS(addr))
				return call PoNVRandomMemHALI.flush();
			else
				if (IS_STORAGE_ADDRESS(addr))
					return call PoStorageMemHALI.flush();
				else 
					return call PoFlashStorageMemHALI.flush();
	}
  
}
