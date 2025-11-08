#!/bin/bash
set -e

# Package script for GnuPG ASUSTOR APK
# This script prepares the package structure and updates config.json

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

# Get maintainer info from git
echo "Step 4: Getting maintainer info from git..."
COMMIT_EMAIL=$(git log -1 --format='%ae' 2>/dev/null || echo "")
COMMIT_AUTHOR=$(git log -1 --format='%an' 2>/dev/null || echo "")

if [ -z "$COMMIT_EMAIL" ]; then
    COMMIT_EMAIL="unknown@example.com"
fi

if [ -z "$COMMIT_AUTHOR" ]; then
    COMMIT_AUTHOR="Unknown"
fi

echo "  Maintainer: $COMMIT_AUTHOR"
echo "  Email: $COMMIT_EMAIL"

# Generate file lists for config.json
echo "Step 5: Generating file lists..."
BIN_FILES=""
if [ -d "${PACKAGE_DIR}/bin" ]; then
    for file in "${PACKAGE_DIR}/bin/"*; do
        if [ -f "$file" ] || [ -L "$file" ]; then
            filename=$(basename "$file")
            if [ -z "$BIN_FILES" ]; then
                BIN_FILES="\"$filename\""
            else
                BIN_FILES="$BIN_FILES, \"$filename\""
            fi
        fi
    done
fi

LIB_FILES=""
if [ -d "${PACKAGE_DIR}/lib" ]; then
    for file in "${PACKAGE_DIR}/lib/"*.so*; do
        if [ -f "$file" ] || [ -L "$file" ]; then
            filename=$(basename "$file")
            if [ -z "$LIB_FILES" ]; then
                LIB_FILES="\"$filename\""
            else
                LIB_FILES="$LIB_FILES, \"$filename\""
            fi
        fi
    done
fi

LIBEXEC_FILES=""
if [ -d "${PACKAGE_DIR}/libexec" ]; then
    for file in "${PACKAGE_DIR}/libexec/"*; do
        if [ -f "$file" ] || [ -L "$file" ]; then
            filename=$(basename "$file")
            if [ -z "$LIBEXEC_FILES" ]; then
                LIBEXEC_FILES="\"$filename\""
            else
                LIBEXEC_FILES="$LIBEXEC_FILES, \"$filename\""
            fi
        fi
    done
fi

# Update config.json
echo "Step 6: Updating config.json..."
CONFIG_FILE="${PACKAGE_DIR}/CONTROL/config.json"

# Create a temporary file with the updated config
cat > "${CONFIG_FILE}.tmp" << EOF
{
  "general": {
    "package": "gnupg",
    "name": "GnuPG",
    "version": "2.4.5",
    "depends": [],
    "conflicts": [],
    "developer": "GnuPG Project",
    "maintainer": "$COMMIT_AUTHOR",
    "email": "$COMMIT_EMAIL",
    "website": "https://gnupg.org/",
    "architecture": "x86-64",
    "firmware": "5.1"
  },
  "register": {
    "symbolic-link": {
      "/bin": [$BIN_FILES],
      "/lib": [$LIB_FILES],
      "/libexec": [$LIBEXEC_FILES]
    }
  }
}
EOF

# Replace the old config.json
mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"

echo ""
echo "================================================"
echo "Package preparation completed successfully!"
echo "================================================"
echo ""
echo "Package structure:"
echo "  bin/: $(find "${PACKAGE_DIR}/bin" \( -type f -o -type l \) 2>/dev/null | wc -l) files"
echo "  lib/: $(find "${PACKAGE_DIR}/lib" \( -type f -o -type l \) 2>/dev/null | wc -l) files"
echo "  libexec/: $(find "${PACKAGE_DIR}/libexec" \( -type f -o -type l \) 2>/dev/null | wc -l) files"
echo ""
echo "Binary files:"
ls -1 "${PACKAGE_DIR}/bin/" 2>/dev/null || echo "No binaries found"
echo ""
echo "Library files:"
ls -1 "${PACKAGE_DIR}/lib/" 2>/dev/null | head -10 || echo "No libraries found"
if [ $(ls -1 "${PACKAGE_DIR}/lib/" 2>/dev/null | wc -l) -gt 10 ]; then
    echo "... and $(($(ls -1 "${PACKAGE_DIR}/lib/" 2>/dev/null | wc -l) - 10)) more"
fi
echo ""
echo "Config.json updated with:"
echo "  Maintainer: $COMMIT_AUTHOR"
echo "  Email: $COMMIT_EMAIL"
echo "  Bin files: $(echo "$BIN_FILES" | grep -o '"' | wc -l | awk '{print $1/2}')"
echo "  Lib files: $(echo "$LIB_FILES" | grep -o '"' | wc -l | awk '{print $1/2}')"
echo "  Libexec files: $(echo "$LIBEXEC_FILES" | grep -o '"' | wc -l | awk '{print $1/2}')"
