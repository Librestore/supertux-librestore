#!/usr/bin/env bash

set -e
cd $(dirname $0)/..
DESTDIR="$(realpath "$1")"

if [ ! -d "$DESTDIR" ]; then
  echo "path '$DESTDIR' is not a valid folder"
  exit 1
fi

# Install dependencies
sudo apt-get update
sudo apt-get install -y cmake build-essential libgtest-dev libc++-dev          \
                        libogg-dev libvorbis-dev libopenal-dev libboost-all-dev\
                        libsdl2-dev libsdl2-image-dev libfreetype6-dev         \
                        libharfbuzz-dev libfribidi-dev libglew-dev             \
                        libcurl4-openssl-dev libglm-dev # TODO: Add libraqm-dev

# Fetch repo
git clone https://github.com/supertux/supertux || true
cd supertux/
if [ ! "$LIBRESTORE_CHECKOUT" = "" ]; then
  git fetch
  git checkout $LIBRESTORE_CHECKOUT
fi
git submodule update --init --recursive

# Package source code
mkdir -p build.source
cd build.source
cmake -DCMAKE_BUILD_TYPE=Release ..
cpack --config CPackSourceConfig.cmake -G ZIP

# Move artifacts
mv -u $(ls SuperTux*.zip | head -1) $DESTDIR
