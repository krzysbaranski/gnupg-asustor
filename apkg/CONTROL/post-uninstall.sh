#!/bin/sh
# Post-uninstallation script for GnuPG

# Remove symbolic links
for binary in gpg gpg-agent gpgconf gpgv dirmngr gpg-connect-agent gpgparsemail gpgsm gpgtar kbxutil watchgnupg; do
    rm -f /usr/local/bin/$binary 2>/dev/null || true
done

# Clean up library configuration
if [ -f /etc/ld.so.conf.d/gnupg.conf ]; then
    rm -f /etc/ld.so.conf.d/gnupg.conf
    ldconfig 2>/dev/null || true
fi

# Remove installation directories
rm -rf /usr/local/gnupg

echo "GnuPG has been uninstalled."

exit 0
