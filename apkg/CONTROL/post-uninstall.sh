#!/bin/sh
# Post-uninstallation script for GnuPG

# Remove symbolic links for binaries
for binary in gpg gpg-agent gpgconf gpgv dirmngr gpg-connect-agent gpgparsemail gpgsm gpgtar kbxutil watchgnupg; do
    rm -f /usr/local/bin/$binary 2>/dev/null || true
done

# Remove symbolic links for libraries
if [ -d /usr/local/gnupg/lib ]; then
    for library in /usr/local/gnupg/lib/*.so* ; do
        if [ -f "$library" ]; then
            libname=$(basename "$library")
            # Only remove if it's a symlink pointing to our library
            if [ -L /usr/local/lib/"$libname" ]; then
                target=$(readlink /usr/local/lib/"$libname")
                if [ "$target" = "$library" ]; then
                    rm -f /usr/local/lib/"$libname" 2>/dev/null || true
                fi
            fi
        fi
    done
    # Run ldconfig to update library cache
    ldconfig 2>/dev/null || true
fi

# Remove installation directories
rm -rf /usr/local/gnupg

echo "GnuPG has been uninstalled."

exit 0
