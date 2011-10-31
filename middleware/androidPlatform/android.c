#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <android.h>
#include "jnivars.h"

void android_dbg(char* channel, const char* format, ...) {
	va_list args;
	char buf[500];
	jstring jmsg;

    va_start(args, format);
	vsprintf(buf, format, args);
	va_end(args);
	jmsg = (*cached_JNIEnv)->NewStringUTF(cached_JNIEnv, buf);

	(*cached_JNIEnv)->CallVoidMethod(cached_JNIEnv, cached_manager_obj, cached_jnidbg_mid, jmsg);

}
