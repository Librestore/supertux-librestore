#!/usr/bin/env bash

set -e
cd $(dirname $0)/..
DESTDIR="$(pwd)/$1"

if [ ! -d "$DESTDIR" ]; then
  echo "path '$DESTDIR' is not a valid folder"
  exit 1
fi

# Install dependencies
git clone https://github.com/emscripten-core/emsdk.git || true
./emsdk/emsdk install 1.40.1
./emsdk/emsdk activate 1.40.1
sed -i "s/\#define MALLOC_ALIGNMENT ((size_t)(2 \* sizeof(void \*)))/#define MALLOC_ALIGNMENT 16/g" emsdk/upstream/emscripten/system/lib/dlmalloc.c # Fixes a bug in emscripten - see https://github.com/emscripten-core/emscripten/issues/13590
source ./emsdk/emsdk_env.sh
git clone https://github.com/microsoft/vcpkg || true
./vcpkg/bootstrap-vcpkg.sh
./vcpkg/vcpkg integrate install
./vcpkg/vcpkg install boost-date-time:wasm32-emscripten
./vcpkg/vcpkg install boost-filesystem:wasm32-emscripten
./vcpkg/vcpkg install boost-format:wasm32-emscripten
./vcpkg/vcpkg install boost-locale:wasm32-emscripten
./vcpkg/vcpkg install boost-optional:wasm32-emscripten
./vcpkg/vcpkg install boost-system:wasm32-emscripten
./vcpkg/vcpkg install glbinding:wasm32-emscripten
./vcpkg/vcpkg install libpng:wasm32-emscripten
./vcpkg/vcpkg install libogg:wasm32-emscripten
./vcpkg/vcpkg install libvorbis:wasm32-emscripten
./vcpkg/vcpkg install glm:wasm32-emscripten

# Fetch repo
git clone https://github.com/supertux/supertux || true
cd supertux/
if [ ! "$LIBRESTORE_CHECKOUT" = "" ]; then
  git checkout $LIBRESTORE_CHECKOUT
fi
git submodule update --init --recursive

# Build
cd external/SDL_ttf
git apply ../../mk/emscripten/SDL_ttf.patch || true
cd ../..
mkdir -p build.wasm
cd build.wasm
emcmake cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_OPENGLES2=ON -DCMAKE_TOOLCHAIN_FILE=../../vcpkg/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=wasm32-emscripten -DGLBINDING_ENABLED=ON -DEMSCRIPTEN=1 ..
rsync -aP ../data/ data/
emmake make -j$(nproc)
rm supertux2.html
mkdir -p upload/
mv -u supertux2* upload/
cp -u template.html upload/index.html
zip supertux2.zip upload/*

# Move artifacts
mv -u supertux2.zip "$DESTDIR"

