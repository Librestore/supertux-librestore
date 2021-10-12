#!/usr/bin/env bash

set -e
cd $(dirname $0)/..
DESTZIP="$(realpath -m "$1")"

if [ "$TZ" = "" ]; then
  export TZ="America/New_York"
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
fi

# Install dependencies
apt-get update
apt-get install -y sudo zip git build-essential cmake libgtest-dev libc++-dev  \
                   libogg-dev libvorbis-dev libopenal-dev libboost-all-dev     \
                   libsdl2-dev libsdl2-image-dev libfreetype6-dev libglm-dev   \
                   libharfbuzz-dev libfribidi-dev libraqm-dev libglew-dev      \
                   libcurl4-openssl-dev

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
mv -u $(ls SuperTux*.zip | head -1) $DESTZIP
