#include "middleware.h"

configuration PoHWCommC{
	provides interface PoReliableTransportI as PoReliableTransportHALI;
	provides interface PoDatagramTransportI as PoDatagramTransportHALI;
	provides interface PoNetworkMngrI as PoNetworkMngrHALI;
	provides interface PoCloseProximityI as PoCloseProximityHALI;
	provides interface Init;
}
implementation{
	components PoCommVirtualFilterM, PoHWCommM;
	
	Init = PoHWCommM;
	Init = PoCommVirtualFilterM;
	
	PoReliableTransportHALI = PoCommVirtualFilterM.PoReliableTransportI;
	PoDatagramTransportHALI = PoCommVirtualFilterM.PoDatagramTransportI;
	PoCommVirtualFilterM.SubReliable -> PoHWCommM.PoReliableTransportHALI;
	PoCommVirtualFilterM.SubDatagram -> PoHWCommM.PoDatagramTransportHALI;
	PoCommVirtualFilterM.PoNetworkMngrI -> PoHWCommM.PoNetworkMngrHALI;
	
	PoNetworkMngrHALI = PoHWCommM;
	PoCloseProximityHALI = PoHWCommM;
	
}
