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
apt-get install -y sudo zip git

# Fetch repo
git clone https://github.com/supertux/supertux || true
cd supertux/
if [ ! "$LIBRESTORE_CHECKOUT" = "" ]; then
  git fetch
  git checkout "$LIBRESTORE_CHECKOUT"
fi
git submodule update --init --recursive

# Build
clickable build --verbose --arch amd64 --config mk/clickable/clickable.json --output "$(realpath -m "$DESTDIR")"

cd "$DESTDIR"
zip "$DESTZIP" -r .
