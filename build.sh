#!/bin/bash
set -e

# Build script for jq and dependencies for ASUSTOR NAS
# This script downloads, compiles, and packages jq

JQ_VERSION="1.7.1"
ONIGURUMA_VERSION="6.9.9"

# Build configuration
# PREFIX: Path used during build/staging (can be any path for development)
# INSTALL_PREFIX: Actual runtime path where ASUSTOR will install the package
PREFIX="/usr/local/jq"
BUILD_DIR="$(pwd)/build"
STAGING_DIR="$(pwd)/staging"
PACKAGE_DIR="$(pwd)/apkg"

# ASUSTOR installs packages to /usr/local/AppCentral/<package_name>
# We need to set RPATH to ensure binaries use the packaged libraries
INSTALL_PREFIX="/usr/local/AppCentral/jq"

# Create build and staging directories
mkdir -p "$BUILD_DIR"
mkdir -p "$STAGING_DIR"
cd "$BUILD_DIR"

echo "================================================"
echo "Building jq ${JQ_VERSION} for ASUSTOR NAS"
echo "================================================"

# Function to download and extract
download_and_extract() {
    local name=$1
    local version=$2
    local url=$3
    local ext=$4
    
    echo "Downloading ${name} ${version}..."
    wget -q "${url}" -O "${name}-${version}.${ext}"
    echo "Extracting ${name} ${version}..."
    if [ "$ext" = "tar.gz" ]; then
        tar xzf "${name}-${version}.${ext}"
    elif [ "$ext" = "tar.bz2" ]; then
        tar xjf "${name}-${version}.${ext}"
    fi
}

# Download sources
echo "Step 1: Downloading source packages..."
download_and_extract "onig" "$ONIGURUMA_VERSION" "https://github.com/kkos/oniguruma/releases/download/v${ONIGURUMA_VERSION}/onig-${ONIGURUMA_VERSION}.tar.gz" "tar.gz"
download_and_extract "jq" "$JQ_VERSION" "https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-${JQ_VERSION}.tar.gz" "tar.gz"

# Build oniguruma
echo ""
echo "Step 2: Building oniguruma..."
cd "onig-${ONIGURUMA_VERSION}"
LDFLAGS="-L${STAGING_DIR}${PREFIX}/lib -Wl,-rpath,${INSTALL_PREFIX}/lib" \
./configure --prefix="$PREFIX" --disable-shared --enable-static
make -j$(nproc)
make install DESTDIR="${STAGING_DIR}"
cd ..

# Set up environment to use staged dependencies for jq build
export PKG_CONFIG_PATH="${STAGING_DIR}${PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH"
export PATH="${STAGING_DIR}${PREFIX}/bin:$PATH"
export LD_LIBRARY_PATH="${STAGING_DIR}${PREFIX}/lib:$LD_LIBRARY_PATH"
export CPPFLAGS="-I${STAGING_DIR}${PREFIX}/include"
export LDFLAGS="-L${STAGING_DIR}${PREFIX}/lib -Wl,-rpath,${INSTALL_PREFIX}/lib"

# Build jq
echo ""
echo "Step 3: Building jq..."
cd "jq-${JQ_VERSION}"

LDFLAGS="-L${STAGING_DIR}${PREFIX}/lib -Wl,-rpath,${INSTALL_PREFIX}/lib" \
./configure \
    --prefix="$PREFIX" \
    --with-oniguruma="${STAGING_DIR}${PREFIX}" \
    --disable-maintainer-mode

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
