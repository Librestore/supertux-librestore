#!/usr/bin/env bash

set -e
cd $(dirname $0)/..
DESTDIR="$(pwd)/$1"

if [ ! -d "$DESTDIR" ]; then
  echo "path '$DESTDIR' is not a valid folder"
  exit 1
fi

# Install dependencies
# TODO

# Fetch repo
git clone https://github.com/supertux/supertux || true
cd supertux/
if [ ! "$LIBRESTORE_CHECKOUT" = "" ]; then
  git checkout $LIBRESTORE_CHECKOUT
fi

# Build
git submodule update --init --recursive
mkdir -p build.gnu
cd build.gnu
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)
cpack -G STGZ

# Move artifacts
OUTPUT=$(ls SuperTux*.sh | head -1)
mv -u $OUTPUT "$DESTDIR"

# Prepare install and launch scripts
echo "#!/usr/bin/env bash" > "$DESTDIR/install.sh"
echo "set -e" >> "$DESTDIR/install.sh"
echo "\$(dirname \"\$0\")/$OUTPUT --skip-license --exclude-subdir --prefix=\$1" >> "$DESTDIR/install.sh"
echo "cp \$(dirname \"\$0\")/run.sh \$1" >> "$DESTDIR/install.sh"
chmod +x "$DESTDIR/install.sh"

echo "#!/usr/bin/env bash" > "$DESTDIR/run.sh"
echo "set -e" >> "$DESTDIR/run.sh"
echo "\$(dirname \"\$0\")/games/supertux2 --datadir \$(dirname \"\$0\")/share/games/supertux2 --userdir \$1" >> "$DESTDIR/run.sh"
chmod +x "$DESTDIR/run.sh"

