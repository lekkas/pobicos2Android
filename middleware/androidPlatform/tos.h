#if !defined(__CYGWIN__)
#if defined(__MSP430__)
#include <sys/inttypes.h>
#else
#include <inttypes.h>
#endif
#else //cygwin
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#endif

#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <stddef.h>
#include <ctype.h>
#include <signal.h>

/* TEMPORARY: include the Safe TinyOS macros so that annotations get
 * defined away for non-safe users 

 * Commented out by lekkas
 *
 * #include "../lib/safe/include/annots_stage1.h"
 */

typedef uint8_t bool;
enum { FALSE = 0, TRUE = 1 };

typedef nx_int8_t nx_bool;
uint16_t TOS_NODE_ID = 1;

/* This macro is used to mark pointers that represent ownership
   transfer in interfaces. See TEP 3 for more discussion. */
#define PASS

#ifdef NESC
struct @atmostonce { };
struct @atleastonce { };
struct @exactlyonce { };
#endif

/* This platform_bootstrap macro exists in accordance with TEP
   107. A platform may override this through a platform.h file. */
#include <platform.h>
#ifndef platform_bootstrap
#define platform_bootstrap() {}
#endif

// define TOSSIM so we keep compatible with everywhere this was used to check if node is virtual
// lekkas out #define TOSSIM
#define ANDROID

//#define dbg(x, ...) printf(__VA_ARGS__)
#define dbg(s, ...) android_dbg(s, __VA_ARGS__)
extern void android_dbg(char* channel, const char* format, ...); // implemented in android.c

#define dbgerror(s, ...)
#define dbg_clear(s, ...)
#define dbgerror_clear(s, ...)

#include <android.c>

