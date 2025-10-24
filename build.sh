#!/bin/bash
set -e

# Build script for GnuPG and dependencies for ASUSTOR NAS
# This script downloads, compiles, and packages GnuPG

GNUPG_VERSION="2.4.5"
LIBGPG_ERROR_VERSION="1.49"
LIBGCRYPT_VERSION="1.10.3"
LIBASSUAN_VERSION="2.5.7"
LIBKSBA_VERSION="1.6.6"
NPTH_VERSION="1.7"

# Installation prefix
PREFIX="/usr/local/gnupg"
BUILD_DIR="$(pwd)/build"
PACKAGE_DIR="$(pwd)/apkg"

# Create build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "================================================"
echo "Building GnuPG ${GNUPG_VERSION} for ASUSTOR NAS"
echo "================================================"

# Function to download and extract
download_and_extract() {
    local name=$1
    local version=$2
    local url=$3
    
    echo "Downloading ${name} ${version}..."
    wget -q --show-progress "${url}" -O "${name}-${version}.tar.bz2"
    echo "Extracting ${name} ${version}..."
    tar xjf "${name}-${version}.tar.bz2"
}

# Download sources
echo "Step 1: Downloading source packages..."
download_and_extract "libgpg-error" "$LIBGPG_ERROR_VERSION" "https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-${LIBGPG_ERROR_VERSION}.tar.bz2"
download_and_extract "libgcrypt" "$LIBGCRYPT_VERSION" "https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-${LIBGCRYPT_VERSION}.tar.bz2"
download_and_extract "libassuan" "$LIBASSUAN_VERSION" "https://gnupg.org/ftp/gcrypt/libassuan/libassuan-${LIBASSUAN_VERSION}.tar.bz2"
download_and_extract "libksba" "$LIBKSBA_VERSION" "https://gnupg.org/ftp/gcrypt/libksba/libksba-${LIBKSBA_VERSION}.tar.bz2"
download_and_extract "npth" "$NPTH_VERSION" "https://gnupg.org/ftp/gcrypt/npth/npth-${NPTH_VERSION}.tar.bz2"
download_and_extract "gnupg" "$GNUPG_VERSION" "https://gnupg.org/ftp/gcrypt/gnupg/gnupg-${GNUPG_VERSION}.tar.bz2"

# Build libgpg-error
echo ""
echo "Step 2: Building libgpg-error..."
cd "libgpg-error-${LIBGPG_ERROR_VERSION}"
./configure --prefix="$PREFIX"
make -j$(nproc)
make install DESTDIR="${PACKAGE_DIR}"
cd ..

# Build libgcrypt
echo ""
echo "Step 3: Building libgcrypt..."
cd "libgcrypt-${LIBGCRYPT_VERSION}"
export PKG_CONFIG_PATH="${PACKAGE_DIR}${PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="${PACKAGE_DIR}${PREFIX}/lib:$LD_LIBRARY_PATH"
./configure --prefix="$PREFIX" --with-libgpg-error-prefix="${PACKAGE_DIR}${PREFIX}"
make -j$(nproc)
make install DESTDIR="${PACKAGE_DIR}"
cd ..

# Build libassuan
echo ""
echo "Step 4: Building libassuan..."
cd "libassuan-${LIBASSUAN_VERSION}"
./configure --prefix="$PREFIX" --with-libgpg-error-prefix="${PACKAGE_DIR}${PREFIX}"
make -j$(nproc)
make install DESTDIR="${PACKAGE_DIR}"
cd ..

# Build libksba
echo ""
echo "Step 5: Building libksba..."
cd "libksba-${LIBKSBA_VERSION}"
./configure --prefix="$PREFIX" --with-libgpg-error-prefix="${PACKAGE_DIR}${PREFIX}"
make -j$(nproc)
make install DESTDIR="${PACKAGE_DIR}"
cd ..

# Build npth
echo ""
echo "Step 6: Building npth..."
cd "npth-${NPTH_VERSION}"
./configure --prefix="$PREFIX"
make -j$(nproc)
make install DESTDIR="${PACKAGE_DIR}"
cd ..

# Build GnuPG
echo ""
echo "Step 7: Building GnuPG..."
cd "gnupg-${GNUPG_VERSION}"

# Set up environment for finding our libraries
export PKG_CONFIG_PATH="${PACKAGE_DIR}${PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH"
export LDFLAGS="-L${PACKAGE_DIR}${PREFIX}/lib"
export CPPFLAGS="-I${PACKAGE_DIR}${PREFIX}/include"

./configure \
    --prefix="$PREFIX" \
    --with-libgpg-error-prefix="${PACKAGE_DIR}${PREFIX}" \
    --with-libgcrypt-prefix="${PACKAGE_DIR}${PREFIX}" \
    --with-libassuan-prefix="${PACKAGE_DIR}${PREFIX}" \
    --with-ksba-prefix="${PACKAGE_DIR}${PREFIX}" \
    --with-npth-prefix="${PACKAGE_DIR}${PREFIX}"

make -j$(nproc)
make install DESTDIR="${PACKAGE_DIR}"
cd ..

# Clean up build artifacts
echo ""
echo "Step 8: Cleaning up..."
cd ..
# Keep the build directory for debugging purposes
# rm -rf "$BUILD_DIR"

echo ""
echo "================================================"
echo "Build completed successfully!"
echo "Package contents are in: ${PACKAGE_DIR}"
echo "================================================"
echo ""
echo "Installed binaries:"
ls -lh "${PACKAGE_DIR}${PREFIX}/bin/" 2>/dev/null || echo "No binaries found"
echo ""
echo "Installed libraries:"
ls -lh "${PACKAGE_DIR}${PREFIX}/lib/" 2>/dev/null || echo "No libraries found"
