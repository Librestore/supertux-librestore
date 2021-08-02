#!/usr/bin/env bash

# Package source code
git submodule update --init --recursive
cd supertux/
mkdir build.source
cd build.source
cmake -DCMAKE_BUILD_TYPE=Release ..
cpack --config CPackSourceConfig.cmake -G ZIP

# Move artifacts
mv $(ls SuperTux*.zip | head -1) $1

