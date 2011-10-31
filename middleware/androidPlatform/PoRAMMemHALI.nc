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
 * Interface used to read from and write to a POBICOS node memory
 * emulated with a native RAM memory.
 * It gives set of commands to read and write in units of
 * one, two and four octets (e.g. get8(address), get16(address),
 * put8(address, 8bitValue), put16(address, 16bitValue)) and
 * command to flush (commit all writes).
 *
 * @author Jarek Domaszewicz WUT, Aleksander Pruszkowski WUT, Tomasz Paczesny WUT (Design)
 * @author Tomasz Paczesny WUT
 *
 * @modified 06/10/2009 Version 346, PoMemI read/write length type changed to uint16_t by Tomek
 */

//includes PoInternalTypes;

interface PoRAMMemHALI {
  

   /**
   * Reads one byte of data from the selected address of the RAM memory buffer.
   * @param addr memory address from where to start getting data
   * @return Fetched data byte.  
   *
   **/
	command uint8_t get8(PoMemAddr_t addr);

   /**
   * Reads two bytes of data from the selected address of the RAM memory buffer.
   * @param addr memory address from where to start getting data
   * @return Fetched data bytes.  
   *
   **/
	command uint16_t get16(PoMemAddr_t addr);

   /**
   * Reads four bytes of data from the selected address of the RAM memory buffer.
   * @param addr memory address from where to start getting data
   * @return Fetched data bytes.  
   *
   **/
	command uint32_t get32(PoMemAddr_t addr);

   /**
   * Reads block of data from the selected address of the RAM memory buffer.
   * @param addr memory address from where to start getting data
   * @param data pointer to the place where to store read data
   * @param len number of bytes to read  
   *
   **/
	command void read(PoMemAddr_t addr, uint8_t* data, uint16_t len);


   /**
   * Writes one byte of data at the selected address of the RAM memory buffer.
   * @param addr memory address where to start putting data
   * @param data byte to be written	     
   *
   **/
	command void put8(PoMemAddr_t addr, uint8_t data);

   /**
   * Writes two bytes of data at the selected address of the RAM memory buffer.
   * @param addr memory address where to start putting data
   * @param data 16-bit data to be written	     
   *
   **/
	command void put16(PoMemAddr_t addr, uint16_t data);

   /**
   * Writes four bytes of data at the selected address of the RAM memory buffer.
   * @param addr memory address where to start putting data
   * @param data 32-bit data to be written	     
   *
   **/
	command void put32(PoMemAddr_t addr, uint32_t data);

   /**
   * Writes a block of data at the selected address of the RAM memory buffer.
   * @param addr memory address where to start putting data
   * @param data pointer to the data structure to be written
   * @param len length in bytes of the data block  
   *
   **/
	command void write(PoMemAddr_t addr, uint8_t* data, uint16_t len);
	

	

	
}
