#!/bin/bash
set -e

HMMER_VERSION="3.4"
HMMER_URL="http://eddylab.org/software/hmmer/hmmer-${HMMER_VERSION}.tar.gz"
INSTALL_PREFIX="/usr/local"

echo "Installing HMMER ${HMMER_VERSION}..."

for tool in gcc make wget tar; do
    command -v $tool &> /dev/null || { echo "Error: $tool not found"; exit 1; }
done

BUILD_DIR=$(mktemp -d)
cd "$BUILD_DIR"

wget -q "$HMMER_URL"
tar xzf "hmmer-${HMMER_VERSION}.tar.gz"
cd "hmmer-${HMMER_VERSION}"

./configure --prefix="$INSTALL_PREFIX" > /dev/null
make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 2) > /dev/null
make install > /dev/null

cd / && rm -rf "$BUILD_DIR"

echo "Done! HMMER installed to $INSTALL_PREFIX"
hmmscan -h | grep "# HMMER"
