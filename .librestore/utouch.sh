#!/usr/bin/env bash

set -e
cd $(dirname $0)/..
DESTDIR="$(pwd)/$1"

if [ ! -d "$DESTDIR" ]; then
  echo "path '$DESTDIR' is not a valid folder"
  exit 1
fi

# Install dependencies
# TODO: Install clickable

# Fetch repo
git clone https://github.com/supertux/supertux || true
cd supertux/
if [ ! "$LIBRESTORE_CHECKOUT" = "" ]; then
  git checkout $LIBRESTORE_CHECKOUT
fi
git submodule update --init --recursive

# Build
clickable build --verbose --arch amd64 --config mk/clickable/clickable.json --output "$(realpath -m "$DESTDIR")"

