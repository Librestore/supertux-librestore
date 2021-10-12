#!/usr/bin/env bash

exit 1 # It's broken

set -e
cd $(dirname $0)/..
DESTZIP="$(realpath "$1")"
DESTDIR=$(mktemp -d)

# Install dependencies
git clone https://github.com/microsoft/vcpkg || true
./vcpkg/bootstrap-vcpkg.sh -disableMetrics
./vcpkg/vcpkg integrate install
./vcpkg/vcpkg install boost-date-time:x64-mingw-static
./vcpkg/vcpkg install boost-filesystem:x64-mingw-static
./vcpkg/vcpkg install boost-format:x64-mingw-static
./vcpkg/vcpkg install boost-locale:x64-mingw-static
./vcpkg/vcpkg install boost-optional:x64-mingw-static
./vcpkg/vcpkg install boost-system:x64-mingw-static
./vcpkg/vcpkg install curl:x64-mingw-static
./vcpkg/vcpkg install --recurse freetype:x64-mingw-static
./vcpkg/vcpkg install glew:x64-mingw-static
./vcpkg/vcpkg install libogg:x64-mingw-static
./vcpkg/vcpkg install libpng:x64-mingw-static
./vcpkg/vcpkg install libraqm:x64-mingw-static
./vcpkg/vcpkg install libvorbis:x64-mingw-static
./vcpkg/vcpkg install openal-soft:x64-mingw-static # FIXME: This won't work
./vcpkg/vcpkg install sdl2:x64-mingw-static
./vcpkg/vcpkg install sdl2-image:x64-mingw-static
./vcpkg/vcpkg install glm:x64-mingw-static

# Fetch repo
git clone https://github.com/supertux/supertux || true
cd supertux/
if [ ! "$LIBRESTORE_CHECKOUT" = "" ]; then
  git fetch
  git checkout $LIBRESTORE_CHECKOUT
fi
git submodule update --init --recursive

# Build
mkdir -p build.windows
cd build.windows
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME=Windows -DCMAKE_C_COMPILER=x86_64-w64-mingw32-gcc -DCMAKE_CXX_COMPILER=x86_64-w64-mingw32-g++ -DCMAKE_TOOLCHAIN_FILE=../../vcpkg/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-mingw-static ..
make -j$(nproc)
cpack -G NSIS64

# Move artifacts
OUTPUT=$(ls SuperTux*.exe | head -1)
mv -u $OUTPUT "$DESTDIR"

# Prepare install and launch scripts
# TODO


cd $DESTDIR
zip $DESTZIP ./* ./.*
