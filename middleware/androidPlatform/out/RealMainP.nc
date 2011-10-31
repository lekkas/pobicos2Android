// $Id: RealMainP.nc,v 1.8 2008/06/26 03:38:27 regehr Exp $

/*
 * "Copyright (c) 2000-2003 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 *
 * Copyright (c) 2002-2003 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */
/*
 *
 * Authors:		Philip Levis
 * Date last modified:  $Id: RealMainP.nc,v 1.8 2008/06/26 03:38:27 regehr Exp $
 *
 */

/**
 * Modified by Tomasz Paczesny for compatibility with "native PC" platform.
*/

/**
 * RealMain implements the TinyOS boot sequence, as documented in TEP 107.
 *
 * @author Philip Levis
 * @date   January 17 2005
 */

#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>

#include "middleware.h"


/** Some C-code for native PC version */

unsigned long long int events_cnt = 0;



extern bool run_next_event();

module RealMainP @safe() {
  provides interface Boot;
  uses interface Scheduler;
  uses interface Init as PlatformInit;
  uses interface Init as SoftwareInit;
}
implementation {

/* user interface functions */
  static const struct option l_opts[] = {
  	{	"help",		no_argument,		NULL,	'h' },
  	{	"node",		required_argument,	NULL,	'n' }, 
  	{	"count",	required_argument,	NULL,	'c' },	
  	{	"version",	no_argument,		NULL,	'V' }
  };
  static const char s_opts[] = "ahm:r:n:c:V";
  
  static void print_help(const char *const app_name)
  {
  	printf(
  	"Usage: %s [-n NODE_ID] | [--node NODE_ID]\n"
  	"   or: %s -h | --help\n"
  	"   or: %s -V | --version\n",
  		app_name, app_name, app_name);  	
  	printf(
  	"\nOptions:\n"
  	"  -h, --help               print this help and exit\n"  	  	
	"  -n NODE_ID,              run virtual node with defined TOS_NODE_ID\n"
	"  --node NODE_ID           \n"
	"  -c NODE_COUNT,           set number of virtual nodes to NODE_COUNT\n"  
	"  --count NODE_COUNT       \n"			
  	"  -V, --version            show version and exit\n");
  }
   

  int main(int argc, char *const argv[]) @C() @spontaneous() {    	
	 	
	 int i;
	 	
	 atomic TOS_NODE_ID = 0;
	 
	 	while ((i = getopt_long(argc, argv, s_opts, l_opts, NULL)) != -1) {
	 		if (i == 'h') {
	 			print_help(argv[0]);
	 			return 0;
	 		} else if (i == 'V') {
	 			puts("not supported option");
	 			return 0;	 		
	 		} else if (i == 'n') {
	 			char *rv;
	 			
	 			long node = strtol(optarg, &rv, 10);

	 			if (*rv != '\0' || node < 0) {
	 				fprintf(stderr, "%s: invalid node id\n",
	 								argv[0]);
	 				return 1;
	 			}
				
				atomic TOS_NODE_ID = (uint16_t)node;							
	 		} else if (i == 'c'){
	 			numVirtualNodes = (uint16_t)strtol(optarg, NULL, 10);

	 			if(!numVirtualNodes){
	 				fprintf(stderr, "invalid number of virtual nodes\n");
	 				return 1;	
	 			}
	 		}
	 	}
		 		 
	load_debug_channels_config();
	
	sim_queue_init();
	pthread_mutex_init(&event_queue_mutex,NULL); 
    sem_init(&event_queue_sem, 0, 0); // Initially blocked
	
    atomic
      {
	/* First, initialize the Scheduler so components can post
	   tasks. Initialize all of the very hardware specific stuff, such
	   as CPU settings, counters, etc. After the hardware is ready,
	   initialize the requisite software components and start
	   execution.*/
	platform_bootstrap();
	
	call Scheduler.init(); 
    
	/* Initialize the platform. Then spin on the Scheduler, passing
	 * FALSE so it will not put the system to sleep if there are no
	 * more tasks; if no tasks remain, continue on to software
	 * initialization */
	call PlatformInit.init();    
	while (call Scheduler.runNextTask());

	/* Initialize software components.Then spin on the Scheduler,
	 * passing FALSE so it will not put the system to sleep if there
	 * are no more tasks; if no tasks remain, the system has booted
	 * successfully.*/
	call SoftwareInit.init(); 
	while (call Scheduler.runNextTask());
      }

    /* Enable interrupts now that system is ready. */
    __nesc_enable_interrupt();

    signal Boot.booted();

    /* Spin in the Scheduler and events queue */       
	while(1) {
		//dbg("RealMainP", "Executing all tasks...\n");
		while (call Scheduler.runNextTask());
		//dbg("RealMainP", "... tasks done\n");
		//dbg("RealMainP", "Processing next event from queue...\n");
		run_next_event();
		//dbg("RealMainP", "... event done\n");	
	}
    

    /* We should never reach this point, but some versions of
     * gcc don't realize that and issue a warning if we return
     * void from a non-void function. So include this. */
    return -1;
  }

  default command error_t PlatformInit.init() { return SUCCESS; }
  default command error_t SoftwareInit.init() { return SUCCESS; }
  default event void Boot.booted() { }
}

