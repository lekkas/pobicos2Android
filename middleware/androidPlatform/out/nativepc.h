/*

 */
/**
 * Author: Tomasz Paczesny
 * Date: Dec 8, 2010
 *
 * A header for native PC platform related services
 *
 */
#ifndef  _NATIVE_PC_H_
#define  _NATIVE_PC_H_


/* queue sync */

#include <pthread.h>
#include <semaphore.h>

pthread_mutex_t event_queue_mutex;

sem_t event_queue_sem;

#define MAX_CHANNEL_NAME_LEN	128
#define MAX_CHANNELS	128

#define INVALID_CHANNEL_NAME "__INVALID_CHANNEL"

#define ALL_CHANNELS "ALL_CHANNELS"

#define DEFAULT_CONFIG_NAME		"debug.cfg"

char dbg_channels[MAX_CHANNELS][MAX_CHANNEL_NAME_LEN];

int load_debug_channels_config();

inline int hasChannel(const char* channel);
	
void pc_dbg(char* channel, const char* format, ...);


#endif   
