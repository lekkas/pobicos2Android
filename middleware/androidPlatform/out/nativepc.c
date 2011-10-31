/*

 */
/**
 * Author: Tomasz Paczesny
 * Date: Dec 8, 2010
 *
 * A header for native PC platform related services
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

#include <nativepc.h>
/* queue sync */

#include <pthread.h>
#include <semaphore.h>
#include <time.h>
#include <sys/time.h>

/* events queue files */
#include <heap.c>
#include <sim_event_queue.c>

int load_debug_channels_config() {
 int i;

 FILE *confFile;
 char *confFilename = DEFAULT_CONFIG_NAME;

 // set up debug channels
 for (i=0; i< MAX_CHANNELS; i++) {
	strcpy(dbg_channels[i], INVALID_CHANNEL_NAME);
 }

 // read debug configuration from a file

  if ((confFile = fopen(confFilename, "r")) != NULL)
	{
		int confLen;
		char lineBuf[MAX_CHANNEL_NAME_LEN];
		int lineCnt=0;
		size_t bytesRead=0;
		size_t inLineBytesRead=0;

		fseek(confFile, 0, SEEK_END);
		confLen = ftell(confFile);
		rewind(confFile);

		while(bytesRead<confLen)
		{
				bytesRead+=fread(lineBuf+inLineBytesRead, 1, 1, confFile);

				if (lineBuf[inLineBytesRead] == ';') { // new entry found
					lineBuf[inLineBytesRead] = '\0'; // NULL-terminate

					if (lineCnt == MAX_CHANNELS) {
						fprintf(stderr, "Error: too many debug channels specified in configuration file - max is %d\n", MAX_CHANNELS);
						exit(1);
					}
					if (inLineBytesRead+1 >= MAX_CHANNEL_NAME_LEN) {
						fprintf(stderr, "Error: too long debug channel name specified in configuration file - max is %d\n", MAX_CHANNEL_NAME_LEN);
						exit(1);
					}
					memcpy(dbg_channels[lineCnt], lineBuf, inLineBytesRead+1);

					inLineBytesRead=0;
					lineCnt++;
				} else {
					inLineBytesRead++;
				}


		}

	}
	else
	{
		printf("Can't open %s file. Using DBG_ERROR, DBG_WARNING and DBG_APP channels only.\n", confFilename);
		strcpy(dbg_channels[0],"DBG_ERROR");
		strcpy(dbg_channels[1],"DBG_WARNING");
		strcpy(dbg_channels[2],"DBG_APP");
	}
	return 0;	//added missing return value -Mikko
}


inline int hasChannel(const char* channel) {
	int i;
	for (i=0; i< MAX_CHANNELS; i++) {
		if (strcmp(dbg_channels[i], channel) == 0)
			return 1;
		else if (strcmp(dbg_channels[i], ALL_CHANNELS) == 0)
			return 1;
		else if (strcmp(dbg_channels[i], INVALID_CHANNEL_NAME) == 0)
			break;

	}
	return 0;
}

void pc_dbg(char* channel, const char* format, ...) {
	va_list args;
	struct timeval tim;
    unsigned long time_now_ms;

    va_start(args, format);



    gettimeofday(&tim, NULL);
    time_now_ms = 1000*tim.tv_sec + (tim.tv_usec/1000);

	if (hasChannel(channel)) {
		//fprintf(stdout, "[\033[0;31m%02i\033[0m@\033[0;36m%0lu\033[0m]: ", (int)sim_node(), time_now_ms);
		fprintf(stdout, "DEBUG(%02i) @%0lu: ", (int)sim_node(), time_now_ms);
		vfprintf(stdout, format, args);
		fflush(stdout);
	}
	va_end(args);
}

bool run_next_event() __attribute__ ((C, spontaneous)) {
  sim_event_t *event;
  int sem_val;
  bool result = FALSE;

  //tp
  // wait to have at least one event to consume
  sem_getvalue(&event_queue_sem, &sem_val);
  //dbg("sync","sim_run_next_event waiting on semaphore (val: %d)\n", sem_val);

  //while (sem_wait(&event_queue_sem) == EINTR);
  sem_wait(&event_queue_sem);
  sem_getvalue(&event_queue_sem, &sem_val);
  //dbg("sync","sim_run_next_event goes through semaphore (val: %d)\n", sem_val);

  //assert(!sim_queue_is_empty());
  //  tp - queue may be empty when semaphore is open because of the signal handling
  if (sim_queue_is_empty())
	return FALSE;

  dbg("sync","sim_run_next_event requesting mutex\n");
  pthread_mutex_lock(&event_queue_mutex);
  dbg("sync","sim_run_next_event gets mutex\n");
  event = sim_queue_pop();
  //dbg("queue","event %d popped\n", events_cnt++);
  //tp
  pthread_mutex_unlock(&event_queue_mutex);
  //dbg("sync","sim_run_next_event releases mutex\n");

  //sim_set_time(event->time);
  //sim_set_node(event->mote);

  // Need to test whether function pointers are for statically
  // allocted events that are zeroed out on reboot
  //dbg("Tossim", "CORE: popping event 0x%p for %i at %llu with handler %p... ", event, sim_node(), sim_time(), event->handle);
  if (event->handle != NULL) {
	result = TRUE;
	if (!event->cancelled) {
		//dbg_clear("Tossim", " mote is on (or forced event), run it.\n");
		event->handle(event);
	} else {
		dbg("Queue","Event popped from queue is cancelled - ignoring\n");
	}
  }
  else {
    //dbg_clear("Tossim", "\n");
  }
  if (event->cleanup != NULL) {
    event->cleanup(event);
  }

  return result;
}


