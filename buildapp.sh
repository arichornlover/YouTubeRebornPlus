#!/bin/bash

cd "$(dirname "$0")"

# Check Cercube
	if [[ ! -f Tweaks/Cercube/me.alfhaily.cercube_5.3.7_iphoneos-arm.deb ]]
then
    	echo -e "==> \033[1mCercube v5.3.7 is not found. Downloading Cercube (v5.3.7)...\033[0m"
	curl https://apt.alfhaily.me/files/me.alfhaily.cercube_5.3.7_iphoneos-arm.deb --output Tweaks/Cercube/me.alfhaily.cercube_5.3.7_iphoneos-arm.deb
else
    	echo -e "==> \033[1mFounded Cercube (v5.3.7)\033[0m"
	fi

# Extract Cercube
	echo -e "==> \033[1mExtracting Cercube...\033[0m"
	if (cd Tweaks/Cercube && tar -xf me.alfhaily.cercube_5.3.7_iphoneos-arm.deb && tar -xf data.tar.*) ; then
	echo -e "\033[1m> Extracted Cercube\033[0m"
else
	echo "> \033[1mCouldn't extract Cercube\033[0m"
	fi

# Makefile
	read -e -p "==> Path to the decrypted YouTube IPA: " PATHTOIPA
	sed -i '' "14s#.*#CercubePlus_IPA = $PATHTOIPA#g" ./Makefile
	make package
	open ./packages

# Clean up	
	tput setaf 1 && echo -e "==> \033[1mCleaning up...\033[0m"
	find Tweaks/Cercube -mindepth 1 -name me.alfhaily.cercube_5.3.7_iphoneos-arm.deb -prune -o -exec rm -rf {} +
	rm -rf Resources
	rm -rf .theos/_/Payload
