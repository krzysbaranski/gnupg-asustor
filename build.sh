#!/bin/bash
set -e

# Build script for GnuPG and dependencies for ASUSTOR NAS
# This script downloads, compiles, and packages GnuPG

GNUPG_VERSION="2.4.8"
LIBGPG_ERROR_VERSION="1.56"
LIBGCRYPT_VERSION="1.11.2"
LIBASSUAN_VERSION="3.0.2"
LIBKSBA_VERSION="1.6.7"
NPTH_VERSION="1.8"

# Build configuration
# PREFIX: Path used during build/staging (can be any path for development)
# INSTALL_PREFIX: Actual runtime path where ASUSTOR will install the package
PREFIX="/usr/local/gnupg"
BUILD_DIR="$(pwd)/build"
STAGING_DIR="$(pwd)/staging"
PACKAGE_DIR="$(pwd)/apkg"

# ASUSTOR installs packages to /usr/local/AppCentral/<package_name>
# We need to set RPATH to ensure binaries use the packaged libraries
INSTALL_PREFIX="/usr/local/AppCentral/gnupg"

# Create build and staging directories
mkdir -p "$BUILD_DIR"
mkdir -p "$STAGING_DIR"
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
    wget -q "${url}" -O "${name}-${version}.tar.bz2"
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
LDFLAGS="-L${STAGING_DIR}${PREFIX}/lib -Wl,-rpath,${INSTALL_PREFIX}/lib" \
./configure --prefix="$PREFIX" --disable-tests
make -j$(nproc)
make install DESTDIR="${STAGING_DIR}"
cd ..

# Set up environment to use staged dependencies for subsequent builds
export PKG_CONFIG_PATH="${STAGING_DIR}${PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH"
export PATH="${STAGING_DIR}${PREFIX}/bin:$PATH"
export LD_LIBRARY_PATH="${STAGING_DIR}${PREFIX}/lib:$LD_LIBRARY_PATH"
export CPPFLAGS="-I${STAGING_DIR}${PREFIX}/include"
export LDFLAGS="-L${STAGING_DIR}${PREFIX}/lib -Wl,-rpath,${INSTALL_PREFIX}/lib"

# Build libgcrypt
echo ""
echo "Step 3: Building libgcrypt..."
cd "libgcrypt-${LIBGCRYPT_VERSION}"
LDFLAGS="-L${STAGING_DIR}${PREFIX}/lib -Wl,-rpath,${INSTALL_PREFIX}/lib" \
./configure --prefix="$PREFIX" --with-libgpg-error-prefix="${STAGING_DIR}${PREFIX}"
make -j$(nproc)
make install DESTDIR="${STAGING_DIR}"
cd ..

# Build libassuan
echo ""
echo "Step 4: Building libassuan..."
cd "libassuan-${LIBASSUAN_VERSION}"
LDFLAGS="-L${STAGING_DIR}${PREFIX}/lib -Wl,-rpath,${INSTALL_PREFIX}/lib" \
./configure --prefix="$PREFIX" --with-libgpg-error-prefix="${STAGING_DIR}${PREFIX}"
make -j$(nproc)
make install DESTDIR="${STAGING_DIR}"
cd ..

# Build libksba
echo ""
echo "Step 5: Building libksba..."
cd "libksba-${LIBKSBA_VERSION}"
LDFLAGS="-L${STAGING_DIR}${PREFIX}/lib -Wl,-rpath,${INSTALL_PREFIX}/lib" \
./configure --prefix="$PREFIX" --with-libgpg-error-prefix="${STAGING_DIR}${PREFIX}"
make -j$(nproc)
make install DESTDIR="${STAGING_DIR}"
cd ..

# Build npth
echo ""
echo "Step 6: Building npth..."
cd "npth-${NPTH_VERSION}"
LDFLAGS="-L${STAGING_DIR}${PREFIX}/lib -Wl,-rpath,${INSTALL_PREFIX}/lib" \
./configure --prefix="$PREFIX"
make -j$(nproc)
make install DESTDIR="${STAGING_DIR}"
cd ..

# Build GnuPG
echo ""
echo "Step 7: Building GnuPG..."
cd "gnupg-${GNUPG_VERSION}"

LDFLAGS="-L${STAGING_DIR}${PREFIX}/lib -Wl,-rpath,${INSTALL_PREFIX}/lib" \
./configure \
    --prefix="$PREFIX" \
    --with-libgpg-error-prefix="${STAGING_DIR}${PREFIX}" \
    --with-libgcrypt-prefix="${STAGING_DIR}${PREFIX}" \
    --with-libassuan-prefix="${STAGING_DIR}${PREFIX}" \
    --with-ksba-prefix="${STAGING_DIR}${PREFIX}" \
    --with-npth-prefix="${STAGING_DIR}${PREFIX}" \
    --disable-tests

make -j$(nproc)
make install DESTDIR="${STAGING_DIR}"
cd ..

# Note: Package preparation is done by package.sh after build
cd ..

echo ""
echo "================================================"
echo "Build completed successfully!"
echo "================================================"
echo ""

# Run the packaging script
if [ -f "$(pwd)/package.sh" ]; then
    echo "Running package.sh to prepare ASUSTOR package..."
    "$(pwd)/package.sh"
else
    echo "Warning: package.sh not found, skipping package preparation"
fi

echo ""

# Run the validation script
if [ -f "$(pwd)/validate-package.sh" ]; then
    echo "Running validate-package.sh to validate package contents..."
    "$(pwd)/validate-package.sh" || echo "Note: Validation completed with warnings or errors (see above)"
else
    echo "Warning: validate-package.sh not found, skipping validation"
fi
