if ! command -v termux-setup-storage; then
  echo -e "\e[92mThis script can be executed only on Termux"
  exit 1
fi

termux-wake-lock

pkg update
pkg upgrade -y
echo -e "\e[32mBasic Requirements Setup...\e[39m"
pkg install python-cryptography
pkg install -y python git cmake rust golang clang make wget ndk-sysroot zlib libxml2 libxslt pkg-config python-cryptography libjpeg-turbo
LDFLAGS="-L${PREFIX}/lib/" CFLAGS="-I${PREFIX}/include/" pip install --upgrade wheel pillow
pip install cython setuptools
CFLAGS="-Wno-error=incompatible-function-pointer-types -O0" pip install lxml
echo -e "\e[32mStarting SDK Tools installation...\e[39m"
if [[ -d "android-sdk" ]]; then
  echo -e "\e[91m seems like sdk tools already installed, skipping...\e[39m"
elif [[ -d "androidide-tools" ]]; then
  rm -rf androidide-tools
  git clone https://github.com/AndroidIDEOfficial/androidide-tools
  cd androidide-tools/scripts
  ./idesetup -c
else
  git clone https://github.com/AndroidIDEOfficial/androidide-tools
  cd androidide-tools/scripts
  ./idesetup -c
fi
cd $HOME
echo -e "\e[33mANDROID SDK TOOLS Successfully Installed!"
echo -e "\e[32mStarting NDK installation...\e[39m"
if [[ -f "ndk-install.sh" ]]; then
  chmod +x ndk-install.sh && bash ndk-install.sh
else
  cd && pkg upgrade && pkg install wget && wget https://github.com/MrIkso/AndroidIDE-NDK/raw/main/ndk-install.sh --no-verbose --show-progress -N && chmod +x ndk-install.sh && bash ndk-install.sh
fi

echo
echo -e "\e[34mWhich NDK version you installed ?\e[39m"
echo "for ex. 24.0.8215888"
read -r -p "NDK_VERSION > " ndk_version

if [[ $ndk_version = "" ]]; then
  echo -e "\e[91mndk version not provided terminating"
  exit 1
fi

cd $HOME

if [[ -f "$PREFIX/bin/apktool.jar" ]]; then
  echo "apktool is already installed"
else
  sh -c 'wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.9.1.jar -O $PREFIX/bin/apktool.jar'
  
  chmod +r $PREFIX/bin/apktool.jar
  
  sh -c 'wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O $PREFIX/bin/apktool' && chmod +x $PREFIX/bin/apktool || exit 2
fi

cd $HOME
if [[ -d "dex2c" ]]; then
  cd dex2c
elif [[ -f "dcc.py" ]] && [[ -d "tools" ]]; then
  :
else
  git clone https://github.com/ratsan/dex2c || exit 2
  cd dex2c || exit 2
fi

if [[ -f "$HOME/dex2c/tools/apktool.jar" ]]; then
  echo "apktool.jar is already at $HOME/dex2c/tools/apktool.jar"
else
sh -c 'wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.9.1.jar -O $HOME/dex2c/tools/apktool.jar'
fi

python3 -m pip install -U -r requirements.txt || exit 2

if [[ -f ".bashrc" ]]; then
  cat <<- EOL >> ~/.bashrc
export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$HOME/android-sdk/cmdline-tools/latest/bin
export PATH=$PATH:$HOME/android-sdk/platform-tools
export PATH=$PATH:$HOME/android-sdk/build-tools/34.0.4
export PATH=$PATH:$HOME/android-sdk/ndk/$ndk_version
export ANDROID_NDK_ROOT=$HOME/android-sdk/ndk/$ndk_version
EOL
elif [[ -f ".zshrc" ]]; then
  cat <<- EOL >> ~/.zshrc
export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$HOME/android-sdk/cmdline-tools/latest/bin
export PATH=$PATH:$HOME/android-sdk/platform-tools
export PATH=$PATH:$HOME/android-sdk/build-tools/34.0.4
export PATH=$PATH:$HOME/android-sdk/ndk/$ndk_version
export ANDROID_NDK_ROOT=$HOME/android-sdk/ndk/$ndk_version
EOL
else
  cat <<- EOL >> $PREFIX/etc/bash.bashrc
export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$HOME/android-sdk/cmdline-tools/latest/bin
export PATH=$PATH:$HOME/android-sdk/platform-tools
export PATH=$PATH:$HOME/android-sdk/build-tools/34.0.4
export PATH=$PATH:$HOME/android-sdk/ndk/$ndk_version
export ANDROID_NDK_ROOT=$HOME/android-sdk/ndk/$ndk_version
EOL
fi


echo -e "\e[32m============================"
echo "Great! dex2c installed successfully!"
echo "============================"