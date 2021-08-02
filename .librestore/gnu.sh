#!/usr/bin/env bash

set -e
cd $(dirname $0)/..

if [ ! -d  "$1" ]; then
  echo "path '$1' is not a valid folder"
  exit 1
fi

# Install dependencies
# TODO

# Build
git submodule update --init --recursive
cd supertux/
mkdir -p build.gnu
cd build.gnu
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)
cpack -G STGZ

# Move artifacts
OUTPUT=$(ls SuperTux*.sh | head -1)
mv $OUTPUT "$1"

# Prepare install and launch scripts
echo "#!/usr/bin/env bash" > "$1/install.sh"
echo "set -e" >> "$1/install.sh"
echo "\$(dirname \"\$0\")/$OUTPUT --skip-license --exclude-subdir --prefix=\$1" >> "$1/install.sh"
echo "cp \$(dirname \"\$0\")/run.sh \$1" >> "$1/install.sh"
chmod +x "$1/install.sh"

echo "#!/usr/bin/env bash" > "$1/run.sh"
echo "set -e" >> "$1/run.sh"
echo "\$(dirname \"\$0\")/games/supertux2 --datadir \$(dirname \"\$0\")/share/games/supertux2 --userdir \$1" >> "$1/run.sh"
chmod +x "$1/run.sh"

