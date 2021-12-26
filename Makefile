CercubePlus_INJECT_DYLIBS = Tweaks/Cercube.dylib Tweaks/libcolorpicker.dylib Tweaks/iSponsorBlock.dylib Tweaks/YTUHD.dylib Tweaks/YouPiP.dylib Tweaks/YouTubeDislikesReturn.dylib

ARCHS = arm64
MODULES = jailed
FINALPACKAGE = 1
CODESIGN_IPA = 0

TWEAK_NAME = CercubePlus
DISPLAY_NAME = YouTube
BUNDLE_ID = com.google.ios.youtube

CercubePlus_FILES = CercubePlus.x
CercubePlus_IPA = /path/to/your/decrypted/YouTube.ipa
### edit the path to your decrypted YouTube IPA!!!

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
