#!/bin/bash

cd "$(dirname "$0")"

# Check YouTube Reborn
if	[ ! -f Tweaks/Reborn/YouTube.Reborn.v4.0.9.deb ]
then
	echo -e "==> \033[1mYouTube Reborn v4.0.9 is not found. Downloading YouTube Reborn (v4.0.9)...\033[0m"
	curl https://dl.dropboxusercontent.com/s/8xv1vota8elfoml/YouTube.Reborn.v4.0.9.deb --output Tweaks/Reborn/YouTube.Reborn.v4.0.9.deb
else
   	echo -e "==> \033[1mFounded YouTube Reborn (v4.0.9)\033[0m"
fi

# Extract Cercube
	echo -e "==> \033[1mExtracting YouTube Reborn...\033[0m"
if 	(cd Tweaks/Reborn && tar -xf YouTube.Reborn.v4.0.9.deb && tar -xf data.tar.*)
then
	echo -e "\033[1m> Extracted YouTube Reborn!\033[0m"
else
	echo "> \033[1mCouldn't extract YouTube Reborn\033[0m"
fi

# Makefile
if 	[ -d ./tmp ]
then
	rm -rf ./tmp
fi
	read -e -p "==> Path to the decrypted YouTube.ipa or YouTube.app: " PATHTOYT
if 	[[ $PATHTOYT == *.ipa ]]
then 
	unzip -q "$PATHTOYT" -d tmp
	rm -rf tmp/Payload/YouTube.app/_CodeSignature/CodeResources
	rm -rf tmp/Payload/YouTube.app/PlugIns/*.appex
	cp -R Extensions/*.appex tmp/Payload/YouTube.app/PlugIns 
	make package FINALPACKAGE=1
	open packages

elif	[[ $PATHTOYT == *.app ]]
then
	mkdir -p ./tmp/Payload/
	cp -R "$PATHTOYT" tmp/Payload 2>/dev/null
	rm -rf tmp/Payload/YouTube.app/_CodeSignature/CodeResources
	rm -rf tmp/Payload/YouTube.app/PlugIns/*.appex
	cp -R Extensions/*.appex tmp/Payload/YouTube.app/PlugIns 
	make package FINALPACKAGE=1
	open packages
else
	echo "This is not an ipa/app!"
fi

# Clean up	
	tput setaf 1 && echo -e "==> \033[1mCleaning up...\033[0m"
	find Tweaks/Reborn -mindepth 1 ! -name "YouTube.Reborn.v4.0.9.deb" ! -name ".gitkeep" -exec rm -rf {} \; 2>/dev/null
	rm -rf tmp/ Resources .theos/_/Payload
	echo -e  "==> \033[1mSHASUM256: $(shasum -a 256 packages/*.ipa | cut -f1 -d' ')\033[0m"
