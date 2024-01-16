TARGET := iphone:clang:15.5:15.0
INSTALL_TARGET_PROCESSES = SpringBoard
THEOS_DEVICE_ID = 127.0.0.1

export FINALPACKAGE

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SBarOverride

SBarOverride_FILES = Tweak.x
SBarOverride_CFLAGS = -fobjc-arc
SBarOverride_FRAMEWORKS = Alderis

ifeq ($(DEBUG_RLOG), 1)
	SBarOverride_CFLAGS += -DDEBUG_RLOG
endif

include $(THEOS_MAKE_PATH)/tweak.mk
	
SUBPROJECTS += sbartweakprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
