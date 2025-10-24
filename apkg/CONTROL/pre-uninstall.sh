#!/bin/sh
# Pre-uninstallation script for GnuPG

echo "Preparing to uninstall GnuPG..."

# Stop any running gpg-agent processes
pkill -u $(whoami) gpg-agent 2>/dev/null || true

exit 0
