/*
 * PoPerfInspM
 * 
 * Module enabling HW and TinyOS performance measurements
 * 
 * @author  Jouni Hiltunen
 * @date  September 14 2010
 * */

#include "PoPerfInsp.h"

module PoHWPerfInspM{
 	provides interface PoPerfInspHALI;
}
implementation{
	
	command void PoPerfInspHALI.updateCpuFreq(){
		
	}
	
	command uint16_t PoPerfInspHALI.getCpuUsage(){
		return 0;
	}
	
	command void PoPerfInspHALI.startCpuUsageMeas(){
		
	}
	
}
