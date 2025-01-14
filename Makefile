ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
TARGET = iphone:clang:latest:15.0
else
TARGET = iphone:clang:latest:11.0
endif
PACKAGE_VERSION = 1.3.1
INSTALL_TARGET_PROCESSES = YouTube
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YouMute

$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
