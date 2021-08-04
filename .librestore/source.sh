#!/usr/bin/env bash

set -e
cd $(dirname $0)/..
DESTDIR="$(realpath "$1")"

if [ ! -d "$DESTDIR" ]; then
  echo "path '$DESTDIR' is not a valid folder"
  exit 1
fi

# Fetch repo
git clone https://github.com/supertux/supertux || true
cd supertux/
if [ ! "$LIBRESTORE_CHECKOUT" = "" ]; then
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

