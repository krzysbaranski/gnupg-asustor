#!/bin/sh

GNUPG_CONFIGS=".gnupg"

case "$APKG_PKG_STATUS" in
	install)
		;;
	upgrade)
		[ -d "${APKG_PKG_DIR}/${GNUPG_CONFIGS}" ] && cp -af "${APKG_PKG_DIR}/${GNUPG_CONFIGS}" "$APKG_TEMP_DIR/"
		;;
	*)
		;;
esac

exit 0
