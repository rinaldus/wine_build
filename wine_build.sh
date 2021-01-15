#!/bin/bash

if [ -z $1 ]; then
    echo "You had to input Wine version."
    exit 0
fi

# The directory where wine compiles
WORKDIR="/tmp/wine"
# Number of CPU cores +1 (e.g, if you have 8 cores CPU, you have to set -j9)
MAKEOPTS="-j9"
# You can change wine build flags if you need
BUILD_FLAGS="--with-x --without-gstreamer"

#do not modify these variables
WINE_NAME="wine-$1"
ARCHIVE_NAME="wine-$1.tar.xz"
# make script compatible with stable versions of Wine
if [[ "`echo -n $1 | tail -c 1`" == "0" ]]; then
    BRANCH_VERSION="`echo $1 | awk 'BEGIN {FS="."}{print $1".0"}' | awk 'BEGIN {FS="-"}{print $1}'`"
else
    BRANCH_VERSION="`echo $1 | awk 'BEGIN {FS="."}{print $1".x"}' | awk 'BEGIN {FS="-"}{print $1}'`"
fi
SRC_URL="https://dl.winehq.org/wine/source/$BRANCH_VERSION/$ARCHIVE_NAME"

# Delete all necessary directories if they are already exist
rm -rf "$WORKDIR/src/$WINE_NAME"
rm -rf "$WORKDIR/build/$WINE_NAME"
rm -rf "$WORKDIR/install/$WINE_NAME"

# Create necessary directories
mkdir -p "$WORKDIR/src"
mkdir -p "$WORKDIR/build/$WINE_NAME/wine64"
mkdir -p "$WORKDIR/build/$WINE_NAME/wine32"
mkdir -p "$WORKDIR/install"

echo "Which version of Wine we are going to build?"
echo "1. Staging (Wine + several useful patches)"
echo "2. Vanilla (original version)"
echo "Choose one variant (1 or 2)"
read KEYPRESS
case $KEYPRESS in
    "1" )
        STAGING_NAME="wine-staging-$1"
        STAGING_ARCHIVE_NAME="v$1.tar.gz"
        BUILD_NAME=$STAGING_NAME
        STAGING_SRC_URL="https://github.com/wine-staging/wine-staging/archive/$STAGING_ARCHIVE_NAME"
        
        cd "$WORKDIR/src"
        wget "$SRC_URL"
        tar xvJf $ARCHIVE_NAME
        wget "$STAGING_SRC_URL"
        tar xvf $STAGING_ARCHIVE_NAME
        "$WORKDIR/src/$STAGING_NAME/patches/patchinstall.sh" DESTDIR="$WORKDIR/src/$WINE_NAME" --all
    ;;
    "2" )
        BUILD_NAME=$WINE_NAME
        
        cd "$WORKDIR/src"
        wget "$SRC_URL"
        tar xvJf $ARCHIVE_NAME
    ;;
esac

# Configure and build Wine64
cd "$WORKDIR/build/$WINE_NAME/wine64"
"$WORKDIR/src/$WINE_NAME/configure" $BULD_FLAGS --enable-win64 --prefix="$WORKDIR/install/$BUILD_NAME" && make depend && make $MAKEOPTS && make install

# Configure and build Wine32
cd "$WORKDIR/build/$WINE_NAME/wine32"
"$WORKDIR/src/$WINE_NAME/configure" $BUILD_FLAGS --prefix="$WORKDIR/install/$BUILD_NAME" --with-wine64=../wine64 && make depend && make $MAKEOPTS && make install

# Pack installed Wine to archive
cd "$WORKDIR/install"
tar -zcvf $BUILD_NAME.tar.gz $BUILD_NAME

# Cleaning
rm -rf "$WORKDIR/src"
rm -rf "$WORKDIR/build"
rm -rf "$WORKDIR/install/$BUILD_NAME"
