#ifndef _PO_JNIVARS_H
#define _PO_JNIVARS_H

#include <jni.h>

static int lekkas_re = 0;
static JavaVM* cached_vm = NULL;
static JNIEnv* cached_JNIEnv = NULL;

static jobject cached_timer_obj = NULL;
static jobject cached_net_obj = NULL;
static jobject cached_uart_obj = NULL;
static jobject cached_ng_obj = NULL;
static jobject cached_manager_obj = NULL;


static jclass cached_timer_cls = NULL;
static jclass cached_net_cls = NULL;
static jclass cached_uart_cls = NULL;
static jclass cached_ng_cls = NULL;
static jclass cached_manager_cls = NULL;


static jmethodID cached_jnidbg_mid = NULL;

/*Timers*/
static jmethodID cached_StartTimer_mid = NULL;
static jmethodID cached_TimerGetNow_mid = NULL;
static jmethodID cached_TimerGett0_mid = NULL;
static jmethodID cached_TimerGetdt_mid = NULL;
static jmethodID cached_TimerIsRunning_mid  = NULL;
static jmethodID cached_TimerIsOneShot_mid  = NULL;
static jmethodID cached_TimerStop_mid = NULL;

/*UART*/
static jmethodID cached_UARTTxByte_mid = NULL;

/*Non-Generic*/
static jmethodID cached_NGAlertText_mid = NULL;
static jmethodID cached_NGCreateDialog_mid = NULL;
static jmethodID cached_NGDismissDialog_mid = NULL;
static jmethodID cached_NGNotifyText_mid = NULL;

/*Network*/
static jmethodID cached_NetSendPacket_mid = NULL;
static jmethodID cached_NetJoinNet_mid = NULL;

static int iii;
static char* ppp;

#endif
