#APP_STL := stlport_static
APP_STL := gnustl_static
APP_CPPFLAGS += -fexceptions #-g
LOCAL_CFLAGS := -ffast-math -freciprocal-math -funsafe-math-optimizations -fsingle-precision-constant -D_LINUX_VER -D_LINUX_VER_64 -D_SCALAR_ARITHMETIC_ONLY
