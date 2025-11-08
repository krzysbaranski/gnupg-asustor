#!/bin/bash
set -e

# Package script for GnuPG ASUSTOR APK
# This script prepares the package structure by copying files from staging

STAGING_DIR="$(pwd)/staging"
PACKAGE_DIR="$(pwd)/apkg"
PREFIX="/usr/local/gnupg"

echo "================================================"
echo "Packaging GnuPG for ASUSTOR"
echo "================================================"

# Check if staging directory exists
if [ ! -d "${STAGING_DIR}${PREFIX}" ]; then
    echo "Error: Staging directory not found at ${STAGING_DIR}${PREFIX}"
    echo "Please run build.sh first to build GnuPG"
    exit 1
fi

# Clean up old package structure (keep CONTROL)
echo "Step 1: Cleaning up old package structure..."
find "${PACKAGE_DIR}" -mindepth 1 -maxdepth 1 -type d ! -name "CONTROL" -exec rm -rf {} \; 2>/dev/null || true

# Create package directory structure at root level
echo "Step 2: Creating package directory structure..."
mkdir -p "${PACKAGE_DIR}/bin"
mkdir -p "${PACKAGE_DIR}/lib"
mkdir -p "${PACKAGE_DIR}/libexec"

# Copy files from staging to package
echo "Step 3: Copying files to package..."
if [ -d "${STAGING_DIR}${PREFIX}/bin" ]; then
    cp -a "${STAGING_DIR}${PREFIX}/bin/"* "${PACKAGE_DIR}/bin/" 2>/dev/null || true
fi

if [ -d "${STAGING_DIR}${PREFIX}/lib" ]; then
    # Copy all .so* files and symlinks
    find "${STAGING_DIR}${PREFIX}/lib" -name "*.so*" \( -type f -o -type l \) -exec cp -a {} "${PACKAGE_DIR}/lib/" \; 2>/dev/null || true
fi

if [ -d "${STAGING_DIR}${PREFIX}/libexec" ]; then
    cp -a "${STAGING_DIR}${PREFIX}/libexec/"* "${PACKAGE_DIR}/libexec/" 2>/dev/null || true
fi

echo ""
echo "================================================"
echo "Package preparation completed successfully!"
echo "================================================"
echo ""
echo "Package structure:"
echo "  bin/: $(find "${PACKAGE_DIR}/bin" \( -type f -o -type l \) 2>/dev/null | wc -l) files"
echo "  lib/: $(find "${PACKAGE_DIR}/lib" \( -type f -o -type l \) 2>/dev/null | wc -l) files"
echo "  libexec/: $(find "${PACKAGE_DIR}/libexec" \( -type f -o -type l \) 2>/dev/null | wc -l) files"
