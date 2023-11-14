TARGET := iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SBarTweakPrefs

SBarTweakPrefs_FILES = XXXRootListController.m
SBarTweakPrefs_FRAMEWORKS = UIKit
SBarTweakPrefs_PRIVATE_FRAMEWORKS = Preferences
SBarTweakPrefs_INSTALL_PATH = /Library/PreferenceBundles
SBarTweakPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
