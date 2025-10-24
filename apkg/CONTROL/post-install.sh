#!/bin/sh
# Post-installation script for GnuPG

# Set up symbolic links for binaries
if [ -d /usr/local/gnupg/bin ]; then
    for binary in /usr/local/gnupg/bin/*; do
        if [ -f "$binary" ] && [ -x "$binary" ]; then
            ln -sf "$binary" /usr/local/bin/$(basename "$binary") 2>/dev/null || true
        fi
    done
fi

# Set up symbolic links for libraries
if [ -d /usr/local/gnupg/lib ]; then
    for library in /usr/local/gnupg/lib/*.so* ; do
        if [ -f "$library" ]; then
            libname=$(basename "$library")
            # Only create symlink if it doesn't exist (never replace existing library)
            if [ ! -e /usr/local/lib/"$libname" ]; then
                ln -sn "$library" /usr/local/lib/"$libname" 2>/dev/null || true
            fi
        fi
    done
    # Run ldconfig to update library cache
    ldconfig 2>/dev/null || true
fi

echo "GnuPG installation completed successfully."
echo "You can now use gpg, gpg-agent, and other GnuPG utilities from the command line."

exit 0
