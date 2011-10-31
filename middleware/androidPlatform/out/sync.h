/*

 */
/**
 * Author: Tomasz Paczesny
 * Date: October 7, 2009
 *
 * A header for TOSSIM and threads synchronization.
 *
 */
#ifndef  _SYNC_H_
#define  _SYNC_H_

#include <pthread.h>
#include <semaphore.h>

// added by Tomasz Paczesny


pthread_mutex_t event_queue_mutex;

sem_t event_queue_sem;

#endif   // ----- #ifndef _SYNC_H_  ----- 
