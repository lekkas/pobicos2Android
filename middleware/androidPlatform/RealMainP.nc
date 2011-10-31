// $Id: RealMainP.nc,v 1.5 2007/03/01 04:21:44 scipio Exp $

/*									tab:4
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
 * Date last modified:  $Id: RealMainP.nc,v 1.5 2007/03/01 04:21:44 scipio Exp $
 *
 */

/**
 * RealMain implements the TinyOS boot sequence, as documented in TEP 107.
 *
 * @author Philip Levis
 * @date   January 17 2005
 */

#include "jnivars.h"
#include "middleware.h"

module RealMainP {
  provides interface Boot;
  uses interface Scheduler;
  uses interface Init as PlatformInit;
  uses interface Init as SoftwareInit;
}
implementation {


  int main() __attribute__ ((C, spontaneous)) {
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

    /* Spin in the Scheduler */       
/*
 * Lekkas Comment_out: this loop never ends, unless an interrupt handler
 * is called. No interrupts in android platform, so the runNextTask()
 * loop will be called manually after each jni call.
 *
   call Scheduler.taskLoop();
 */
    

    /* We should never reach this point, but some versions of
     * gcc don't realize that and issue a warning if we return
     * void from a non-void function. So include this. */
	
	/* Lekkas comment: this is reached in Android */
    
	/* return -9; (-1 original) */
	  
   iii = 1;
   ppp = (char *) &iii;
   if (ppp[0] == 1) // Lowest address contains the least significant byte
      return 0; // LITTLE_ENDIAN;
   else
      return 1; // BIG_ENDIAN;
}

  default command error_t PlatformInit.init() { return SUCCESS; }
  default command error_t SoftwareInit.init() { return SUCCESS; }
  default event void Boot.booted() { }
	

	jint Java_org_lekkas_poclient_PoAPI_MiddlewareManager_nativeMain(JNIEnv *env, 
		jobject obj) __attribute__ ((C, spontaneous)) {

		return main();
	}

	jint Java_org_lekkas_poclient_PoAPI_MiddlewareManager_nativeInit(JNIEnv *env, 
		jobject mgrobj) __attribute__ ((C, spontaneous)) {

		jclass local_cls;
		jfieldID fid;
		jobject local_obj;
		jmethodID mid;

		cached_JNIEnv = env;

		/*
		 * Middleware Manager class / objects / methods caching
		 */

		/* Class */
		local_cls = (*env)->FindClass(env, "org/lekkas/poclient/PoAPI/MiddlewareManager");
		if(local_cls == NULL)
			return JNI_ERR;
		cached_manager_cls = (*env)->NewGlobalRef(env, local_cls);
		if(cached_manager_cls == NULL)
			return JNI_ERR;
		(*env)->DeleteLocalRef(env, local_cls);

		/* Object */
		cached_manager_obj = (*env)->NewGlobalRef(env, mgrobj);
		if(cached_manager_obj == NULL)
			return JNI_ERR;
		// (*env)->DeleteLocalRef(env, mgrobj);

		/* Callback Methods */
		mid = (*env)->GetMethodID(env, cached_manager_cls, "JNICallback_dbg", "(Ljava/lang/String;)V");
		if(mid == NULL)
			return JNI_ERR;
		cached_jnidbg_mid = mid;

		/*
		 * Timer class / objects / methods caching
		 */

		/* Class */
		local_cls = (*env)->FindClass(env, "org/lekkas/poclient/PoAPI/TimerService");
		if(local_cls == NULL)
			return JNI_ERR;
		cached_timer_cls = (*env)->NewGlobalRef(env, local_cls);
		if(cached_timer_cls == NULL)
			return JNI_ERR;
		(*env)->DeleteLocalRef(env, local_cls);

		/* Object */
		fid = (*env)->GetStaticFieldID(env, cached_manager_cls, "timer", "Lorg/lekkas/poclient/PoAPI/TimerService;");
		if(fid == NULL) 
			return JNI_ERR;
		local_obj = (*env)->GetStaticObjectField(env, cached_manager_cls, fid);
		if(local_obj == NULL)
			return JNI_ERR;
		cached_timer_obj = (*env)->NewGlobalRef(env, local_obj);
		if(cached_timer_obj == NULL)
			return JNI_ERR;
		(*env)->DeleteLocalRef(env, local_obj);
			
		/* Callback Methods */
		mid = (*env)->GetMethodID(env, cached_timer_cls, "JNICallback_startTimer", "(BIIZ)V"); /*OK*/
		if(mid == NULL)
			return JNI_ERR;
		cached_StartTimer_mid = mid;

		mid = (*env)->GetMethodID(env, cached_timer_cls, "JNICallback_getNow", "(B)I"); /*ok*/
		if(mid == NULL)
			return JNI_ERR;
		cached_TimerGetNow_mid = mid;

		mid = (*env)->GetMethodID(env, cached_timer_cls, "JNICallback_gett0", "(B)I"); /*OK*/
		if(mid == NULL)
			return JNI_ERR;
		cached_TimerGett0_mid = mid;

		mid = (*env)->GetMethodID(env, cached_timer_cls, "JNICallback_getdt", "(B)I"); /*OK*/ 
		if(mid == NULL)
			return JNI_ERR;
		cached_TimerGetdt_mid = mid;

		mid = (*env)->GetMethodID(env, cached_timer_cls, "JNICallback_isRunning", "(B)Z"); /*OK*/
		if(mid == NULL)
			return JNI_ERR;
		cached_TimerIsRunning_mid = mid;

		mid = (*env)->GetMethodID(env, cached_timer_cls, "JNICallback_isOneShot", "(B)Z"); /*OK*/
		if(mid == NULL)
			return JNI_ERR;
		cached_TimerIsOneShot_mid = mid;

		mid = (*env)->GetMethodID(env, cached_timer_cls, "JNICallback_stop", "(B)V"); /*OK*/
		if(mid == NULL)
			return JNI_ERR;
		cached_TimerStop_mid = mid;


		/*
		 * UART class / objects / methods caching
		 */

		/* Class */
		local_cls = (*env)->FindClass(env, "org/lekkas/poclient/PoAPI/UARTService");
		if(local_cls == NULL)
			return JNI_ERR;
		cached_uart_cls = (*env)->NewGlobalRef(env, local_cls);
		if(cached_uart_cls == NULL)
			return JNI_ERR;
		(*env)->DeleteLocalRef(env, local_cls);

		/* Object */
		fid = (*env)->GetStaticFieldID(env, cached_manager_cls, "uart", "Lorg/lekkas/poclient/PoAPI/UARTService;");
		if(fid == NULL) 
			return JNI_ERR;
		local_obj = (*env)->GetStaticObjectField(env, cached_uart_cls, fid);
		if(local_obj == NULL)
			return JNI_ERR;
		cached_uart_obj = (*env)->NewGlobalRef(env, local_obj);
		if(cached_uart_obj == NULL)
			return JNI_ERR;
		(*env)->DeleteLocalRef(env, local_obj);

		/* Callback Methods */
		mid = (*env)->GetMethodID(env, cached_uart_cls, "JNICallback_TxByte", "(B)V"); 
		if(mid == NULL)
			return JNI_ERR;
		cached_UARTTxByte_mid = mid;

		/*
		 * NGResources class / objects / methods caching
		 */

		/* Class */
		local_cls = (*env)->FindClass(env, "org/lekkas/poclient/PoAPI/NGResources");
		if(local_cls == NULL)
			return JNI_ERR;
		cached_ng_cls = (*env)->NewGlobalRef(env, local_cls);
		if(cached_ng_cls == NULL)
			return JNI_ERR;
		(*env)->DeleteLocalRef(env, local_cls);

		/* Object */
		fid = (*env)->GetStaticFieldID(env, cached_manager_cls, "ng", "Lorg/lekkas/poclient/PoAPI/NGResources;");
		if(fid == NULL) 
			return JNI_ERR;
		local_obj = (*env)->GetStaticObjectField(env, cached_ng_cls, fid);
		if(local_obj == NULL)
			return JNI_ERR;
		cached_ng_obj = (*env)->NewGlobalRef(env, local_obj);
		if(cached_ng_obj == NULL)
			return JNI_ERR;
		(*env)->DeleteLocalRef(env, local_obj);

		/* Callback Methods */
		mid = (*env)->GetMethodID(env, cached_ng_cls, "JNICallback_AlertText", "()V"); 
		if(mid == NULL)
			return JNI_ERR;
		cached_NGAlertText_mid = mid;

		mid = (*env)->GetMethodID(env, cached_ng_cls, "JNICallback_CreateDialog", "(Ljava/lang/String;I)V"); 
		if(mid == NULL)
			return JNI_ERR;
		cached_NGCreateDialog_mid = mid;

		mid = (*env)->GetMethodID(env, cached_ng_cls, "JNICallback_DismissDialog", "()V"); 
		if(mid == NULL)
			return JNI_ERR;
		cached_NGDismissDialog_mid = mid;

		mid = (*env)->GetMethodID(env, cached_ng_cls, "JNICallback_NotifyText", "(Ljava/lang/String;I)V"); 
		if(mid == NULL)
			return JNI_ERR;
		cached_NGNotifyText_mid = mid;

		
		/*
		 * Network class / objects / methods caching
		 */

		/* Class */
		local_cls = (*env)->FindClass(env, "org/lekkas/poclient/PoAPI/NetworkService");
		if(local_cls == NULL)
			return JNI_ERR;
		cached_net_cls = (*env)->NewGlobalRef(env, local_cls);
		if(cached_net_cls == NULL)
			return JNI_ERR;
		(*env)->DeleteLocalRef(env, local_cls);

		/* Object */
		fid = (*env)->GetStaticFieldID(env, cached_manager_cls, "net", "Lorg/lekkas/poclient/PoAPI/NetworkService;");
		if(fid == NULL) 
			return JNI_ERR;
		local_obj = (*env)->GetStaticObjectField(env, cached_net_cls, fid);
		if(local_obj == NULL)
			return JNI_ERR;
		cached_net_obj = (*env)->NewGlobalRef(env, local_obj);
		if(cached_net_obj == NULL)
			return JNI_ERR;
		(*env)->DeleteLocalRef(env, local_obj);

		/* Callback Methods */
		mid = (*env)->GetMethodID(env, cached_net_cls, "JNICallback_SendPacket", "([BBCC)V"); 
		if(mid == NULL)
			return JNI_ERR;
		cached_NetSendPacket_mid = mid;

		mid = (*env)->GetMethodID(env, cached_net_cls, "JNICallback_JoinNetwork", "()C"); 
		if(mid == NULL)
			return JNI_ERR;
		cached_NetJoinNet_mid = mid;


		return JNI_OK;
	}

	jint Java_org_lekkas_poclient_PoAPI_MiddlewareManager_nativeCompleteTasks(JNIEnv *env, 
		jobject obj) __attribute__ ((C, spontaneous)) {
/*
		jint testvar = 0xFF000000; -> 4278190080  
		uint32_t uutime;

		char msggg[50];
        const jstring *jmsg;

		(*env)->CallVoidMethod(env, cached_timer_obj, cached_SetTimer_mid, testvar);
		uutime =  (*env)->CallIntMethod(env, cached_timer_obj, cached_TimerGetNow_mid);

		sprintf(msggg, "Library: now = %u", uutime);
		jmsg = (*env)->NewStringUTF(env, msggg);
		
		(*env)->CallVoidMethod(env, cached_manager_obj, cached_jnidbg_mid, jmsg);

		(*cached_JNIEnv)->CallIntMethod(cached_JNIEnv, cached_ng_obj, cached_NGAlertText_mid); -> test
*/
		while (call Scheduler.runNextTask());
		return JNI_OK;
	}

/*	
	jint JNI_OnLoad(JavaVM* jvm, void* reserved) __attribute__ ((C, spontaneous)) {
		JNIEnv *env;
	    //cached_vm = jvm;
		jclass cls;

		if ((*jvm)->GetEnv(jvm, (void**) &env, JNI_VERSION_1_6) != JNI_OK) {
			return JNI_ERR;
		}
		

		JNINativeMethod nm;				
		
		cls = (*env)->FindClass(env, "org/lekkas/poclient/PoAPI/MiddlewareManager");
		if(cls == NULL)
			return JNI_ERR;
		nm.name = "nativeMain";
		nm.signature = "()I";
		nm.fnPtr = JNIMain;
		(*env)->RegisterNatives(env, cls, &nm, 1);

		return JNI_VERSION_1_4;
	}
*/    
}

