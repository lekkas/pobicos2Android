LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := middleware
LOCAL_SRC_FILES := middleware.c
#LOCAL_C_INCLUDES := /usr/lib/jvm/java-6-sun-1.6.0.24/include 
#LOCAL_C_INCLUDES := /usr/lib/jvm/java-6-sun-1.6.0.24/include/linux


include $(BUILD_SHARED_LIBRARY)
