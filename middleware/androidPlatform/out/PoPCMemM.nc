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
 * Virtual memory for PC platform.
 *
 * @author Jarek Domaszewicz WUT, Aleksander Pruszkowski WUT, Tomasz Paczesny WUT (Design)
 * @author Tomasz Paczesny WUT
 * @modified 06/10/2009 Version 346, read/write length type changed to uint16_t by Tomek
 * @modified 19/10/2009 Version 390, raised read buffer size; former size could cause troubles with bigger reads by Tomek
 */

#include <stdio.h>
#include <stdlib.h>

generic module PoPCMemM(char typeName[], uint32_t size) {
    provides {	
        interface Init;
        interface PoPCMemHALI;
    }
}
implementation {
#define MEM_SIZE 0x40000000

    FILE *mem_file;

	command error_t Init.init() {
        char name_buff[sizeof("PCMem_XXX_XXXXX.img") + 1];

        sprintf(name_buff, "PCMem_%s_%05d.img", typeName, TOS_NODE_ID);
        if ((mem_file = fopen(name_buff, "r+b")) == NULL)
            mem_file = fopen(name_buff, "w+b");
        if (mem_file != NULL) {
            unsigned long len;

            if (fseek(mem_file, 0, SEEK_END) != 0) {
                fclose(mem_file);
                mem_file = NULL;
            }
            
            if ((len = ftell(mem_file)) < size) {
                char buff[256];

                memset((void*)buff, 0xff, 256);
                while (len < size) {
                    int n = ((size - len) > 256) ? 256 : size - len;
                    if (fwrite(buff, n, 1, mem_file) != 1) {
                        fclose(mem_file);
                        mem_file = NULL;
                        break;
                    } else {
                        len += n;
                    }
                }
            }
            
            fflush(mem_file);
        }
        return (mem_file == NULL) ? FAIL : SUCCESS;
    }

	/**
   * Reads one byte of data from the selected address of the POBICOS memory.
   * @param addr memory address from where to start getting data
   * @return Fetched data byte.  
   *
   **/
	command uint8_t PoPCMemHALI.get8(PoMemAddr_t addr) {
		uint8_t buf;
		
		if (addr > MEM_SIZE-1)
            return 0;

        if (fseek(mem_file, addr, SEEK_SET) != 0)
            return 0;

		if (fread(&buf, 1, sizeof(uint8_t), mem_file) != sizeof(uint8_t))
			return 0;	
	
        return buf;	
	}

   /**
   * Reads two bytes of data from the selected address of the POBICOS memory.
   * @param addr memory address from where to start getting data
   * @return Fetched data bytes.  
   *
   **/
	command uint16_t PoPCMemHALI.get16(PoMemAddr_t addr) {		
		uint16_t buf;
		
		if (addr > MEM_SIZE-1)
            return 0;
		
        if (fseek(mem_file, addr, SEEK_SET) != 0)
            return 0;
		
		if (fread(&buf, 1, sizeof(uint16_t), mem_file) != sizeof(uint16_t))
			return 0;		
				
        return buf;	
	
	}

   /**
   * Reads four bytes of data from the selected address of the POBICOS memory.
   * @param addr memory address from where to start getting data
   * @return Fetched data bytes.  
   *
   **/
	command uint32_t PoPCMemHALI.get32(PoMemAddr_t addr) {
		uint32_t buf;
		
		if (addr > MEM_SIZE-1)
            return 0;

        if (fseek(mem_file, addr, SEEK_SET) != 0)
            return 0;

		if (fread(&buf, 1, sizeof(uint32_t), mem_file) != sizeof(uint32_t))
			return 0;	
	
        return buf;
     }	
	

   /**
   * Reads block of data from the selected address of the POBICOS memory.
   * @param addr memory address from where to start getting data
   * @param data pointer to the place where to store read data
   * @param len number of bytes to read  
   *
   **/
	command void PoPCMemHALI.read(PoMemAddr_t addr, uint8_t* data, uint16_t len) {
#define PC_MEM_READ_BUFFER_SIZE 65534
		char buffer[PC_MEM_READ_BUFFER_SIZE];
		
		if (len > PC_MEM_READ_BUFFER_SIZE) {
			fprintf(stderr, "PC-MEM read buffer exceed (buffer size: %d  read length: %d)\n", PC_MEM_READ_BUFFER_SIZE, len);
			exit(1);
		}
		
		if (addr > MEM_SIZE-1)
            return;

        if (fseek(mem_file, addr, SEEK_SET) != 0)
            return;
				

		if (fread(buffer, 1, len, mem_file) != len)
			return;	
		
			
		//	printf("POPCMEMHALIi memcpy\n");	
		memcpy(data, buffer, len);	        			
		//	printf("POPCMEMHALIi memcpy after\n");	
		
	}


   /**
   * Writes one byte of data at the selected address of the POBICOS memory.
   * @param addr memory address where to start putting data
   * @param data byte to be written	     
   *
   **/
	command void PoPCMemHALI.put8(PoMemAddr_t addr, uint8_t data) {
		if (addr > MEM_SIZE-1)
            return;

        if (fseek(mem_file, addr, SEEK_SET) != 0)
            return;

		fwrite(&data, 1, sizeof(uint8_t), mem_file);
			
	}

   /**
   * Writes two bytes of data at the selected address of the POBICOS memory.
   * @param addr memory address where to start putting data
   * @param data 16-bit data to be written	     
   *
   **/
	command void PoPCMemHALI.put16(PoMemAddr_t addr, uint16_t data) {
		if (addr > MEM_SIZE-1)
            return;

        if (fseek(mem_file, addr, SEEK_SET) != 0)
            return;

		fwrite(&data, 1, sizeof(uint16_t), mem_file);
		
	}

   /**
   * Writes four bytes of data at the selected address of the POBICOS memory.
   * @param addr memory address where to start putting data
   * @param data 32-bit data to be written	     
   *
   **/
	command void PoPCMemHALI.put32(PoMemAddr_t addr, uint32_t data) {
		if (addr > MEM_SIZE-1)
            return;

        if (fseek(mem_file, addr, SEEK_SET) != 0)
            return;

		fwrite(&data, 1, sizeof(uint32_t), mem_file);
	}

   /**
   * Writes a block of data at the selected address of the POBICOS memory.
   * @param addr memory address where to start putting data
   * @param data pointer to the data structure to be written
   * @param len length in bytes of the data block  
   *
   **/
	command void PoPCMemHALI.write(PoMemAddr_t addr, uint8_t* data, uint16_t len) {		
		if (addr > MEM_SIZE-1)
            return;
		
        if (fseek(mem_file, addr, SEEK_SET) != 0)
            return;

		fwrite(data, 1, len, mem_file);		
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
   * @param addr memory address of the beginning of the memory section
   * that is going to be flushed
   *
   **/

	command void PoPCMemHALI.flush() {
		fflush(mem_file);	
	}


}
