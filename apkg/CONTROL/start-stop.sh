#!/bin/sh

APP_PATH=/usr/local/AppCentral/gnupg
GNUPG_CONFIGS=".gnupg"

case $1 in

	start)
		echo "Starting GnuPG..."
		[ -d ${APP_PATH}/${GNUPG_CONFIGS} ] && cp -a ${APP_PATH}/${GNUPG_CONFIGS} /root/${GNUPG_CONFIGS}
		;;

	stop)
		echo "Stopping GnuPG..."
		[ -d /root/${GNUPG_CONFIGS} ] && cp -a /root/${GNUPG_CONFIGS} ${APP_PATH}/${GNUPG_CONFIGS}
		;;

	*)
		echo "usage: $0 {start|stop}"
		exit 1
		;;
		
esac
exit 0
