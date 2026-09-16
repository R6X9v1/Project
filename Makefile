export THEOS = /root/theos

ROOTLESS = 1

ifeq ($(ROOTLESS),1)
THEOS_PACKAGE_SCHEME = rootless
endif

ifeq ($(ROOTLESS),2)
THEOS_PACKAGE_SCHEME = roothide
endif

THEOS_IGNORE_DEPRECATED = 1

TARGET = iphone:clang:latest:16.5
ARCHS = arm64

FRAMEWORK_NAME = libR6X9
libR6X9_STATIC = 1

PROJ_COMMON_FRAMEWORKS = UIKit Foundation MetalKit Metal ModelIO Security QuartzCore CoreGraphics CoreText AudioToolbox AVFoundation Accelerate Photos MediaPlayer CoreAudio

KITTYMEMORY_SRC = $(wildcard KittyMemory/*.cpp)
IMGUI_SRC = $(wildcard imgui/*.cpp)

libR6X9_FILES = \
2.mm \
fishhook/fishhook.c \
CheatState/CheatState.cpp \
Stream/HeeeNoScreenShotView.m \
imgui/imgui_impl_metal.mm \
$(IMGUI_SRC) \
$(KITTYMEMORY_SRC)

libR6X9_CFLAGS = \
-fobjc-arc \
-Wno-deprecated-declarations \
-Wno-unused-variable \
-Wno-unused-value \
-Wno-enum-conversion

libR6X9_CXXFLAGS = \
-std=c++14 \
-fno-rtti \
-fno-exceptions

libR6X9_FRAMEWORKS = $(PROJ_COMMON_FRAMEWORKS)

libR6X9_LDFLAGS = \
-lc++ \
-lobjc \
-lc \
-Wl,-ld_classic \
-Wl,-U,___isPlatformVersionAtLeast \
-force_load $(THEOS_PROJECT_DIR)/libs/libSniperGate.a \
-ObjC

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/framework.mk