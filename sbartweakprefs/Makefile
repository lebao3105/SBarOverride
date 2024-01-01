TARGET := iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SBarTweakPrefs


SBarTweakPrefs_FILES = $(wildcard *.m)
SBarTweakPrefs_FRAMEWORKS = UIKit
SBarTweakPrefs_PRIVATE_FRAMEWORKS = Preferences
SBarTweakPrefs_INSTALL_PATH = /Library/PreferenceBundles
SBarTweakPrefs_CFLAGS = -fobjc-arc

ifneq ($(FINALPACKAGE), 1)
	SBarTweakPrefs_CFLAGS += -DDEV_BUILD
endif

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/little12.plist$(ECHO_END)