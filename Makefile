TARGET := iphone:clang:15.5:15.0
INSTALL_TARGET_PROCESSES = SpringBoard

export FINALPACKAGE

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SBarOverride

SBarOverride_FILES = UIColor+SBO.m Tweak.x
SBarOverride_CFLAGS = -fobjc-arc

ifeq ($(DEBUG_RLOG), 1)
	SBarOverride_CFLAGS += -DDEBUG_RLOG
endif

include $(THEOS_MAKE_PATH)/tweak.mk
	
SUBPROJECTS += sbartweakprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
