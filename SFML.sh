#!/bin/bash -e

SFML_VERSION=2.6.1

. ./sdk.sh

mkdir -p output/sfml/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d sfml-src ]; then
	if [ ! -f "$SFML_VERSION.tar.gz" ]; then
		wget https://github.com/SFML/SFML/archive/$SFML_VERSION.tar.gz
	fi
	tar -xzf $SFML_VERSION.tar.gz
	mv SFML-$SFML_VERSION sfml-src
	sed -i 's/set(BUILD_SHARED_LIBS TRUE)/set(BUILD_SHARED_LIBS FALSE)/g' sfml-src/CMakeLists.txt
fi

cd sfml-src

mkdir -p build; cd build

cmake .. -DANDROID_STL="c++_static" \
    -DANDROID_NATIVE_API_LEVEL="$NATIVE_API_LEVEL" \
    -DANDROID_ABI="$ANDROID_ABI" \
    -DANDROID_PLATFORM="$API" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
    -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
    -DBUILD_SHARED_LIBS=0

cmake --build . -j

# update `include` folder
rm -rf ../../../output/sfml/include/
cp -r ../include ../../../output/sfml/include
# update lib
rm -rf ../../../output/sfml/lib/$TARGET_ABI/*
cp -r lib/*.a ../../../output/sfml/lib/$TARGET_ABI/

echo "SFML build successful"
