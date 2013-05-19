TEMP_LOCAL_PATH:= $(call my-dir)
LOCAL_PATH:= C:/Leadwerks/Engine/Library/Android

# Use absolute path so the library can be included from a project located anywhere on the hard drive
SRC_PATH := C:/Leadwerks/Engine/Source

GLOBAL_CFLAGS := -w #-DDEBUG -g

include $(CLEAR_VARS)
LOCAL_MODULE    := libleadwerks
LOCAL_SRC_FILES := libleadwerks.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE    := libnewtondynamics
LOCAL_SRC_FILES := libnewtondynamics.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE    := libopenal
LOCAL_SRC_FILES := libopenal.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE    := libzlib
LOCAL_SRC_FILES := libzlib.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE    := libenet
LOCAL_SRC_FILES := libenet.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE    := librecast
LOCAL_SRC_FILES := librecast.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE    := libtolua
LOCAL_SRC_FILES := libtolua.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE    := liblua
LOCAL_SRC_FILES := liblua.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE    := libfreetype
LOCAL_SRC_FILES := libfreetype.a
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_PATH:=$(TEMP_LOCAL_PATH)

#======================================
# Engine shared library
#======================================
include $(CLEAR_VARS)
LOCAL_MODULE := app

#======================================
# ADD NEW SOURCE FILES HERE!!!
#======================================

LOCAL_SRC_FILES := main.cpp \
../../../Source/App.cpp

#======================================
#
#======================================

LOCAL_LDLIBS := -llog -lGLESv2

#======================================
# Preprocessor Defines
#======================================
LOCAL_CFLAGS := $(GLOBAL_CFLAGS) -DOPENGLES -D_NEWTON_STATIC_LIB -DUSE_FILE32API -DAL_BUILD_LIBRARY -DAL_ALEXT_PROTOTYPES -D_SCALAR_ARITHMETIC_ONLY -D__arm__ -D_NEWTON_STATIC_LIB -D_POSIX_VER_64 -D_POSIX_VER -D_LINUX_VER_64 -D_LINUX_VER -DO2 -Dfpic -Dffloat-store -Dffast-math -Dfreciprocal-math -Dfunsafe-math-optimizations -Dfsingle-precision-constant -DANDROID -fPIC -DPIC -DDARWIN_NO_CARBON -DFT2_BUILD_LIBRARY -DOPENGLES -D_NEWTON_STATIC_LIB

#======================================
# Include Paths
#======================================
LOCAL_C_INCLUDES := $(SRC_PATH)/ \
	$(SRC_PATH)/Libraries/tolua++-1.0.93/include \
	$(SRC_PATH)/Libraries/lua-5.1.4 \
	$(SRC_PATH)/Libraries/enet-1.3.1/include \
	$(SRC_PATH)/Libraries/NewtonDynamics/coreLibrary_300/source/core \
	$(SRC_PATH)/Libraries/NewtonDynamics/coreLibrary_300/source/newton \
	$(SRC_PATH)/Libraries/NewtonDynamics/coreLibrary_300/source/physics \
	$(SRC_PATH)/Libraries/NewtonDynamics/coreLibrary_300/source/meshUtil \
	$(SRC_PATH)/Libraries/RecastNavigation/DebugUtils/include \
	$(SRC_PATH)/Libraries/RecastNavigation/DetourCrowd/include \
	$(SRC_PATH)/Libraries/RecastNavigation/DetourTileCache/include \
	$(SRC_PATH)/Libraries/RecastNavigation/Detour/include \
	$(SRC_PATH)/Libraries/RecastNavigation/Recast/include \
	$(SRC_PATH)/libraries/openal-soft/include/AL \
	$(SRC_PATH)/libraries/openal-soft/OpenAL32/Include \
	$(SRC_PATH)/libraries/android_external_freetype/include \
	$(SRC_PATH)/Libraries/NewtonDynamics/packages/dMath \
	$(SRC_PATH)/Libraries/NewtonDynamics/packages/dContainers \
	$(SRC_PATH)/Libraries/NewtonDynamics/packages/dCustomJoints

#======================================
# Leadwerks static library has to be listed first or linking errors will occur
#======================================
LOCAL_STATIC_LIBRARIES := leadwerks newtondynamics openal zlib enet recast tolua lua freetype

include $(BUILD_SHARED_LIBRARY)
