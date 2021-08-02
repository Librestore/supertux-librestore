#!/usr/bin/env bash

set -e
cd $(dirname $0)/..
DESTDIR="$(pwd)/$1"

if [ ! -d  "$DESTDIR" ]; then
  echo "path '$DESTDIR' is not a valid folder"
  exit 1
fi

# Package source code
git submodule update --init --recursive
cd supertux/
mkdir -p build.source
cd build.source
cmake -DCMAKE_BUILD_TYPE=Release ..
cpack --config CPackSourceConfig.cmake -G ZIP

# Move artifacts
mv -u $(ls SuperTux*.zip | head -1) $DESTDIR

