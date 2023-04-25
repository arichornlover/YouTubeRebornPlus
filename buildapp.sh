read -p $'\e[34m==> \e[1;39mPath to the decrypted YouTube.ipa or YouTube.app: ' PATHTOYT
make package IPA=$PATHTOYT FINALPACKAGE=1
if [[ $? -eq 0 ]]; then
  open packages
  echo "\033[0;32m==> \033[1;39mSHASUM256: $(shasum -a 256 packages/*.ipa)"
else
  echo "\033[0;31m==> \033[1;39mFailed building CercubePlus"
fi
