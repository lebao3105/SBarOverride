TARGET := iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SBarOverride

SBarOverride_FILES = Tweak.x
SBarOverride_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += sbartweakprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
