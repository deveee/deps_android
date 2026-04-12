#!/bin/bash -e

. ./sdk.sh
PIXMAN_VERSION=0.42.2

mkdir -p output/pixman/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d pixman-src ]; then
	git clone -b pixman-$PIXMAN_VERSION --depth 1 https://gitlab.freedesktop.org/pixman/pixman.git pixman-src
fi

cd pixman-src

SYSROOT="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot"
INCLUDE_DIRS="-I$ANDR_ROOT/output/libpng/include"
LIBRARY_DIRS="-L$ANDR_ROOT/output/libpng/lib/$TARGET_ABI"

CFLAGS="$INCLUDE_DIRS $LIBRARY_DIRS $CFLAGS_NO_FAST"
CPPFLAGS="$INCLUDE_DIRS $LIBRARY_DIRS"
PNG_CFLAGS="$INCLUDE_DIRS $LIBRARY_DIRS"

./autogen.sh \
	--host="$TARGET" --with-sysroot="$SYSROOT" --prefix=/ \
	--disable-shared --enable-static --disable-gtk \
	--disable-arm-neon --disable-arm-a64-neon

make -C pixman -j

# update headers
rm -rf ../../output/pixman/include
mkdir -p ../../output/pixman/include
cp pixman/*.h ../../output/pixman/include/
# update lib
rm -rf ../../output/pixman/lib/$TARGET_ABI/libpixman.a
cp -r pixman/.libs/libpixman-1.a ../../output/pixman/lib/$TARGET_ABI/libpixman.a

echo "libpixman build successful"
