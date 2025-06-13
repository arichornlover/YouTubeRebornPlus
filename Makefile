export ARCHS = arm64
export TARGET = iphone:clang:17.5:15.0
export SYSROOT = $(THEOS)/sdks/iPhoneOS17.5.sdk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CercubePlus
DISPLAY_NAME = YouTube
BUNDLE_ID = com.google.ios.youtube
PACKAGE_VERSION = 19.06.2-5.3.11
FINALPACKAGE = 1
CODESIGN_IPA = 0
MODULES = jailed

EXTRA_CFLAGS = -I$(THEOS_PROJECT_DIR)/Tweaks/RemoteLog -I$(THEOS_PROJECT_DIR)/Tweaks $(addprefix -I,$(shell find Tweaks/FLEX -name '*.h' -exec dirname {} \;))

CercubePlus_FILES = CercubePlus.xm $(shell find Source -name '*.xm' -o -name '*.x' -o -name '*.m') $(shell find Tweaks/FLEX -type f \( -iname \*.c -o -iname \*.m -o -iname \*.mm \))
CercubePlus_INJECT_DYLIBS = Tweaks/Cercube/Library/MobileSubstrate/DynamicLibraries/Cercube.dylib Tweaks/Cercube/Library/MobileSubstrate/DynamicLibraries/YouTube_Albums_Fix.dylib .theos/obj/libcolorpicker.dylib .theos/obj/iSponsorBlock.dylib .theos/obj/YTUHD.dylib .theos/obj/YouPiP.dylib .theos/obj/YouTubeDislikesReturn.dylib .theos/obj/YTABConfig.dylib .theos/obj/DontEatMyContent.dylib .theos/obj/YTHoldForSpeed.dylib .theos/obj/YTVideoOverlay.dylib .theos/obj/YouMute.dylib .theos/obj/YouQuality.dylib
CercubePlus_FRAMEWORKS = UIKit Foundation Security AVFoundation AVKit Photos Accelerate CoreMotion GameController VideoToolbox UniformTypeIdentifiers
CercubePlus_LIBRARIES = hooker z
CercubePlus_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unsupported-availability-guard -Wno-unused-but-set-variable -DTWEAK_VERSION=$(PACKAGE_VERSION) $(EXTRA_CFLAGS)
CercubePlus_LDFLAGS = -Wl,-no_multiply_defined
CercubePlus_IPA = ./tmp/Payload/YouTube.app
CercubePlus_USE_FISHHOOK = 0

SUBPROJECTS += Tweaks/Alderis Tweaks/iSponsorBlock Tweaks/YTUHD Tweaks/YouPiP Tweaks/Return-YouTube-Dislikes Tweaks/YTABConfig Tweaks/DontEatMyContent Tweaks/YTHoldForSpeed Tweaks/YTVideoOverlay Tweaks/YouMute Tweaks/YouQuality
include $(THEOS_MAKE_PATH)/aggregate.mk

before-package::
	@echo -e "==> \033[1mMoving tweak's bundle to Resources/...\033[0m"
	@mkdir -p tmp/Payload Resources/Frameworks/Alderis.framework
	@find .theos/obj/install/Library/Frameworks/Alderis.framework -maxdepth 1 -type f -exec cp {} Resources/Frameworks/Alderis.framework/ \;
	@cp -R Tweaks/YTUHD/layout/Library/Application\ Support/YTUHD.bundle Resources/
	@cp -R Tweaks/YouPiP/layout/Library/Application\ Support/YouPiP.bundle Resources/
	@cp -R Tweaks/Return-YouTube-Dislikes/layout/Library/Application\ Support/RYD.bundle Resources/
	@cp -R Tweaks/YTABConfig/layout/Library/Application\ Support/YTABC.bundle Resources/
	@cp -R Tweaks/DontEatMyContent/layout/Library/Application\ Support/DontEatMyContent.bundle Resources/
	@cp -R Tweaks/YTHoldForSpeed/layout/Library/Application\ Support/YTHoldForSpeed.bundle Resources/
	@cp -R Tweaks/YTVideoOverlay/layout/Library/Application\ Support/YTVideoOverlay.bundle Resources/
	@cp -R Tweaks/YouMute/layout/Library/Application\ Support/YouMute.bundle Resources/
	@cp -R Tweaks/YouQuality/layout/Library/Application\ Support/YouQuality.bundle Resources/
	@cp -R Tweaks/iSponsorBlock/layout/Library/Application\ Support/iSponsorBlock.bundle Resources/
	@cp -R Tweaks/Cercube/Library/Application\ Support/Cercube/Cercube.bundle Resources/
	@cp -R lang/CercubePlus.bundle Resources/
	@echo -e "==> \033[1mChanging the installation path of dylibs...\033[0m"
	@ldid -r .theos/obj/iSponsorBlock.dylib && install_name_tool -change /usr/lib/libcolorpicker.dylib @rpath/libcolorpicker.dylib .theos/obj/iSponsorBlock.dylib
	@ldid -r .theos/obj/libcolorpicker.dylib && install_name_tool -change /Library/Frameworks/Alderis.framework/Alderis @rpath/Alderis.framework/Alderis .theos/obj/libcolorpicker.dylib
	@echo -e "==> \033[1mPackaging IPA...\033[0m"
	@cp -R YouTube.app tmp/Payload/
	@sed -i 's|com.google.ios.youtube|com.google.ios.youtube.cercube|g' tmp/Payload/YouTube.app/Info.plist
	@plutil -convert binary1 tmp/Payload/YouTube.app/Info.plist
	@zip -qr CercubePlus.ipa tmp/Payload

after-clean::
	@rm -rf tmp
