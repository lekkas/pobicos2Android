/*
 * PoPerfInspC 
 * 
 * Configuration enabling HW and TinyOS performance measurements
 * 
 * @author  Jouni Hiltunen
 * @date  September 14 2010
 * */

#include "PoPerfInsp.h"

configuration PoHWPerfInspC{
	provides interface PoPerfInspHALI;
 	//provides interface Init;
}
implementation{
 	components PoHWPerfInspM;
 	
  	//Init = PoHWPerfInspM;
  	PoPerfInspHALI = PoHWPerfInspM;
}
