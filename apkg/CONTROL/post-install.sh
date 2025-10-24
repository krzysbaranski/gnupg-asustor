#!/bin/sh
# Post-installation script for GnuPG

# Set up symbolic links
if [ -d /usr/local/gnupg/bin ]; then
    for binary in /usr/local/gnupg/bin/*; do
        if [ -f "$binary" ] && [ -x "$binary" ]; then
            ln -sf "$binary" /usr/local/bin/$(basename "$binary") 2>/dev/null || true
        fi
    done
fi

# Update library cache
if [ -f /etc/ld.so.conf ]; then
    echo "/usr/local/gnupg/lib" >> /etc/ld.so.conf
    ldconfig 2>/dev/null || true
fi

echo "GnuPG installation completed successfully."
echo "You can now use gpg, gpg-agent, and other GnuPG utilities from the command line."

exit 0
