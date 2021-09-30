CercubePlus_INJECT_DYLIBS = Cercube.dylib iSponsorBlock.dylib libcolorpicker.dylib YTUHD.dylib YouPiP.dylib


ARCHS = arm64
MODULES = jailed
FINALPACKAGE = 1
CODESIGN_IPA = 0


TWEAK_NAME = CercubePlus
DISPLAY_NAME = YouTube
BUNDLE_ID = com.google.ios.youtube
 
uYouPlus_FILES = CercubePlus.x
uYouPlus_IPA = /path/to/the/decrypted/YouTube/IPA
### edit the path to your decrypted YouTube IPA!!!
uYouPlus_FRAMEWORKS = Alderis


include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk


