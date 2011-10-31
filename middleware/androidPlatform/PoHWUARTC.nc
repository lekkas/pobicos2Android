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
 *  Component representing drivers and logic needed to provide
 *  UART communication abstraction at byte level.
 *  Implementation of this component depends on host platform used.
 *
 * @author Jarek Domaszewicz WUT, Aleksander Pruszkowski WUT, Tomasz Paczesny WUT (Design)
 * @author Tomasz Paczesny WUT
 */
 

configuration PoHWUARTC {
    provides {
        interface PoUARTHALI;                
        interface StdControl as Control;
        interface Init;
    }
}
implementation
{
  components PoHWUARTM;
  
  PoUARTHALI = PoHWUARTM.PoUARTHALI;
  Control = PoHWUARTM.Control;
  Init = PoHWUARTM.Init;
  
}
