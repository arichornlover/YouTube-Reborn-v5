TARGET = iphone:clang:26.5:16.0
export SDK_PATH = $(THEOS)/sdks/iPhoneOS26.5.sdk/
export SYSROOT = $(SDK_PATH)
YouTubeReborn_USE_FLEX = 0
YouTubeReborn_USE_FISHHOOK = 0
GO_EASY_ON_ME = 1
ARCHS = arm64
MODULES = jailed
FINALPACKAGE = 1
CODESIGN_IPA = 0

PACKAGE_NAME = $(TWEAK_NAME)
TWEAK_NAME = YouTubeReborn
DISPLAY_NAME = YouTube
BUNDLE_ID = com.google.ios.youtube
INSTALL_TARGET_PROCESSES = YouTube

YouTubeReborn_FILES = Sources/Tweak.xm $(shell find Sources -name '*.m') $(shell find Sources -name '*.xm') $(shell find Dependencies/YouTubeExtractor -name '*.m')
YouTubeReborn_IPA = tmp/Payload/YouTube.app
YouTubeReborn_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -I$(THEOS_PROJECT_DIR)/Sources -I$(THEOS_PROJECT_DIR)/Dependencies -F$(THEOS_PROJECT_DIR)/Dependencies/Lottie
YouTubeReborn_FRAMEWORKS = UIKit Foundation AVFoundation AVKit Photos Accelerate CoreMotion GameController VideoToolbox SwiftUI Combine QuartzCore JavaScriptCore
YouTubeReborn_LDFLAGS = -F$(THEOS_PROJECT_DIR)/Dependencies/Lottie
YouTubeReborn_SWIFTFLAGS = -F$(THEOS_PROJECT_DIR)/Dependencies/Lottie
YouTubeReborn_LIBRARIES = bz2 c++ iconv z sqlite3 dl

YouTubeReborn_SWIFT_FILES = $(shell find Sources/RebornUI -name '*.swift')
YouTubeReborn_SWIFT_BRIDGING_HEADER = Sources/RebornUI/Reborn-Bridging-Header.h
YouTubeReborn_SWIFT_VERSION = 5

$(TWEAK_NAME)_EMBED_BUNDLES = $(wildcard Bundles/*.bundle)

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk


.PHONY: before-package
before-package::
	@bash Tools/stage-ffmpeg.sh "$$(THEOS_PROJECT_DIR)/Bundles"
