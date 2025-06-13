export TARGET = iphone:clang:17.5:15.0
export SDK_PATH = $(THEOS)/sdks/iPhoneOS17.5.sdk/
export SYSROOT = $(SDK_PATH)
export ARCHS = arm64

export libcolorpicker_ARCHS = arm64
export libFLEX_ARCHS = arm64
export Alderis_XCODEOPTS = LD_DYLIB_INSTALL_NAME=@rpath/Alderis.framework/Alderis
export Alderis_XCODEFLAGS = DYLIB_INSTALL_NAME_BASE=/Library/Frameworks BUILD_LIBRARY_FOR_DISTRIBUTION=YES ARCHS="$(ARCHS)"
export libcolorpicker_LDFLAGS = -F$(TARGET_PRIVATE_FRAMEWORK_PATH) -install_name @rpath/libcolorpicker.dylib
export ADDITIONAL_CFLAGS = -I$(THEOS_PROJECT_DIR)/Tweaks/RemoteLog -I$(THEOS_PROJECT_DIR)/Tweaks

ifneq ($(JAILBROKEN),1)
export DEBUGFLAG = -ggdb -Wno-unused-command-line-argument -L$(THEOS_OBJ_DIR) -F$(_THEOS_LOCAL_DATA_DIR)/$(THEOS_OBJ_DIR_NAME)/install/Library/Frameworks
MODULES = jailed
endif

ifndef YOUTUBE_VERSION
YOUTUBE_VERSION = 20.23.3
endif
ifndef REBORN_VERSION
REBORN_VERSION = 4.2.9
endif
PACKAGE_NAME = $(TWEAK_NAME)
PACKAGE_VERSION = $(YOUTUBE_VERSION)-$(REBORN_VERSION)

INSTALL_TARGET_PROCESSES = YouTube
TWEAK_NAME = YouTubeRebornPlus
DISPLAY_NAME = YouTube
BUNDLE_ID = com.google.ios.youtube

$(TWEAK_NAME)_FILES := $(wildcard Source/*.xm) $(wildcard Source/*.x) $(wildcard Source/*.m)
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation AVFoundation AVKit Photos Accelerate CoreMotion GameController VideoToolbox Security
$(TWEAK_NAME)_LIBRARIES = bz2 c++ iconv z
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-but-set-variable -DTWEAK_VERSION=\"$(PACKAGE_VERSION)\"
$(TWEAK_NAME)_INJECT_DYLIBS = Tweaks/YouTubeReborn/Library/MobileSubstrate/DynamicLibraries/YouTubeReborn.dylib $(THEOS_OBJ_DIR)/libcolorpicker.dylib $(THEOS_OBJ_DIR)/iSponsorBlock.dylib $(THEOS_OBJ_DIR)/YouPiP.dylib $(THEOS_OBJ_DIR)/YouTubeDislikesReturn.dylib $(THEOS_OBJ_DIR)/YTABConfig.dylib $(THEOS_OBJ_DIR)/YTUHD.dylib $(THEOS_OBJ_DIR)/DontEatMyContent.dylib $(THEOS_OBJ_DIR)/YTHoldForSpeed.dylib $(THEOS_OBJ_DIR)/YTVideoOverlay.dylib $(THEOS_OBJ_DIR)/YouMute.dylib $(THEOS_OBJ_DIR)/YouQuality.dylib $(THEOS_OBJ_DIR)/YouGroupSettings.dylib
$(TWEAK_NAME)_EMBED_LIBRARIES = $(THEOS_OBJ_DIR)/libcolorpicker.dylib
$(TWEAK_NAME)_EMBED_FRAMEWORKS = $(_THEOS_LOCAL_DATA_DIR)/$(THEOS_OBJ_DIR_NAME)/install_Alderis.xcarchive/Products/var/jb/Library/Frameworks/Alderis.framework
$(TWEAK_NAME)_EMBED_BUNDLES = $(wildcard Bundles/*.bundle)
$(TWEAK_NAME)_EMBED_EXTENSIONS = $(wildcard Extensions/*.appex)

include $(THEOS)/makefiles/common.mk
ifneq ($(JAILBROKEN),1)
SUBPROJECTS += Tweaks/Alderis Tweaks/iSponsorBlock Tweaks/YTUHD Tweaks/YouPiP Tweaks/Return-YouTube-Dislikes Tweaks/YTABConfig Tweaks/DontEatMyContent Tweaks/YTHoldForSpeed Tweaks/YTVideoOverlay Tweaks/YouMute Tweaks/YouQuality Tweaks/YouGroupSettings
include $(THEOS_MAKE_PATH)/aggregate.mk
endif
include $(THEOS_MAKE_PATH)/tweak.mk

REMOVE_EXTENSIONS = 1
CODESIGN_IPA = 0

REBORN_PATH = Tweaks/YouTubeReborn
REBORN_DEB = $(REBORN_PATH)/YouTube.Reborn.v$(REBORN_VERSION).deb
REBORN_DYLIB = $(REBORN_PATH)/Library/MobileSubstrate/DynamicLibraries/YouTubeReborn.dylib
REBORN_BUNDLE = $(REBORN_PATH)/Library/Application\ Support/YouTubeReborn.bundle

internal-clean::
	@rm -rf $(REBORN_PATH)/*

ifneq ($(JAILBROKEN),1)
before-all::
	@if [[ ! -f $(REBORN_DEB) ]]; then \
		rm -rf $(REBORN_PATH)/*; \
		$(PRINT_FORMAT_BLUE) "Downloading Reborn"; \
	fi
before-all::
	@if [[ ! -f $(REBORN_DEB) ]]; then \
 		curl -s -L "https://www.dropbox.com/scl/fi/2rwb05kbeq64uo9qluv8s/YouTube.Reborn.v4.2.9.deb?rlkey=1k3jtwa76d791odg5djvs8f7f&st=q1lxdgym&dl=1" -o $(REBORN_DEB); \
 	fi; \
	if [[ ! -f $(REBORN_DYLIB) || ! -d $(REBORN_BUNDLE) ]]; then \
		tar -xf Tweaks/YouTubeReborn/YouTube.Reborn.v$(REBORN_VERSION).deb -C Tweaks/YouTubeReborn; tar -xf Tweaks/YouTubeReborn/data.tar.lzma -C Tweaks/YouTubeReborn; \
		if [[ ! -f $(REBORN_DYLIB) || ! -d $(REBORN_BUNDLE) ]]; then \
			$(PRINT_FORMAT_ERROR) "Failed to extract Reborn"; exit 1; \
		fi; \
	fi;
else
before-package::
    @mkdir -p $(THEOS_STAGING_DIR)/Library/Application\ Support; cp -r Localizations/YouTubeRebornPlus.bundle $(THEOS_STAGING_DIR)/Library/Application\ Support/
endif
