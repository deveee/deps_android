#!/bin/bash -e

. ./sdk.sh
CAIRO_VERSION=1.17.6

mkdir -p output/cairo/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d cairo-src ]; then
	git clone -b $CAIRO_VERSION --depth 1 https://gitlab.freedesktop.org/cairo/cairo.git cairo-src
fi

cd cairo-src

SYSROOT="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot"
INCLUDE_DIRS="-I$ANDR_ROOT/output/freetype/include -I$ANDR_ROOT/output/libpng/include -I$ANDR_ROOT/output/pixman/include"
LIBRARY_DIRS="-L$ANDR_ROOT/output/freetype/lib/$TARGET_ABI -L$ANDR_ROOT/output/libpng/lib/$TARGET_ABI -L$ANDR_ROOT/output/pixman/lib/$TARGET_ABI"

CFLAGS="$INCLUDE_DIRS $LIBRARY_DIRS $CFLAGS_NO_FAST"
CPPFLAGS="$INCLUDE_DIRS $LIBRARY_DIRS"
FREETYPE_CFLAGS="$INCLUDE_DIRS $LIBRARY_DIRS"
png_CFLAGS="$INCLUDE_DIRS $LIBRARY_DIRS"
pixman_CFLAGS="$INCLUDE_DIRS $LIBRARY_DIRS"

./autogen.sh \
	--host="$TARGET" --with-sysroot="$SYSROOT" --prefix=/ \
	--disable-shared --enable-static --enable-pthread --enable-ft \
	--disable-xlib --disable-xcb --disable-fc --disable-ps \
	--disable-pdf --disable-svg --disable-gobject --disable-gtk-doc \
	--disable-gtk-doc-html --disable-valgrind

make -C src -j

# update headers
rm -rf ../../output/cairo/include
mkdir -p ../../output/cairo/include/cairo
cp src/*.h ../../output/cairo/include/cairo/
# update lib
rm -rf ../../output/cairo/lib/$TARGET_ABI/libcairo.a
cp -r src/.libs/libcairo.a ../../output/cairo/lib/$TARGET_ABI/libcairo.a

echo "libcairo build successful"
