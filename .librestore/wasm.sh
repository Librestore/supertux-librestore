#!/usr/bin/env bash

set -e
cd $(dirname $0)/..
DESTZIP="$1"
DESTDIR=$(mktemp -d)

if [ "$TZ" = "" ]; then
  export TZ="America/New_York"
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
fi

# Install dependencies
apt-get update
apt-get install -y sudo zip git python3 cmake curl build-essential pkg-config  \
                   rsync

git clone https://github.com/emscripten-core/emsdk.git || true
./emsdk/emsdk install 1.40.1
./emsdk/emsdk activate 1.40.1
sed -i "s/\#define MALLOC_ALIGNMENT ((size_t)(2 \* sizeof(void \*)))/#define MALLOC_ALIGNMENT 16/g" emsdk/upstream/emscripten/system/lib/dlmalloc.c # Fixes a bug in emscripten - see https://github.com/emscripten-core/emscripten/issues/13590
sed -i 's/2b581c60ae401a79bbbe748ff2deeda5acd50bfd2ea22e5926e36d34b9ebcffb6580b0ff48e972c1441583e30e21e1ea821ca0423f9c67ce08a31dffabdbe6b7/b2affe9a1688bd49fc033f4682c4a242d4ee612f1affaef532f5adcb4602efc4433c4a52a4b3d69e7440ff1f6413b1b041b419bc90efd6d697999961a9a6afb7/g' emsdk/upstream/emscripten/tools/ports/libjpeg.py
sed -i 's/https:\/\/dl.bintray.com\/homebrew\/mirror\/jpeg-9c.tar.gz/https:\/\/storage.googleapis.com\/webassembly\/emscripten-ports\/jpegsrc.v9c.tar.gz/g' emsdk/upstream/emscripten/tools/ports/libjpeg.py
source ./emsdk/emsdk_env.sh

git clone https://github.com/microsoft/vcpkg || true
./vcpkg/bootstrap-vcpkg.sh -disableMetrics
./vcpkg/vcpkg install boost-date-time:wasm32-emscripten                        \
                      boost-filesystem:wasm32-emscripten                       \
                      boost-format:wasm32-emscripten                           \
                      boost-locale:wasm32-emscripten                           \
                      boost-optional:wasm32-emscripten                         \
                      boost-system:wasm32-emscripten                           \
                      glbinding:wasm32-emscripten                              \
                      libpng:wasm32-emscripten                                 \
                      libogg:wasm32-emscripten                                 \
                      libvorbis:wasm32-emscripten                              \
                      glm:wasm32-emscripten

# Fetch repo
git clone https://github.com/supertux/supertux || true
cd supertux/
if [ ! "$LIBRESTORE_CHECKOUT" = "" ]; then
  git fetch
  git checkout "$LIBRESTORE_CHECKOUT"
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
rm supertux2.html supertux2.desktop
cp -u template.html index.html

# Move artifacts
mv -u supertux2* "$DESTDIR"
mv -u index.html "$DESTDIR"

cd "$DESTDIR"
zip "$DESTZIP" -r .
