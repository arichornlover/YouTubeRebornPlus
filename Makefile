CercubePlus_INJECT_DYLIBS = Tweaks/uYou.dylib Tweaks/libcolorpicker.dylib .theos/obj/iSponsorBlock.dylib .theos/obj/YTUHD.dylib .theos/obj/YouPiP.dylib .theos/obj/YouTubeDislikesReturn.dylib 

CercubePlus_USE_FLEX = 0
ARCHS = arm64
MODULES = jailed
FINALPACKAGE = 1
CODESIGN_IPA = 0

TWEAK_NAME = CercubePlus
DISPLAY_NAME = YouTube
BUNDLE_ID = com.google.ios.youtube
 
CercubePlus_FILES = CercubePlus.x
CercubePlus_IPA = /path/to/your/decrypted/YouTube.ipa
### Important: edit the path to your decrypted YouTube IPA!!! 

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += Tweaks/iSponsorBlock Tweaks/YTUHD Tweaks/YouPiP Tweaks/Return-YouTube-Dislikes
include $(THEOS_MAKE_PATH)/aggregate.mk

all::
	@install_name_tool -change /usr/lib/libcolorpicker.dylib @rpath/libcolorpicker.dylib .theos/obj/iSponsorBlock.dylib
