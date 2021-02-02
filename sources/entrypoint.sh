#!/usr/bin/env bash
set -e

FORCE_REINIT_CONFIG=${FORCE_REINIT_CONFIG:=false}
USE_SSL=${USE_SSL:=true}
PASSV_MIN_PORT=${PASSV_MIN_PORT:=60000}
PASSV_MAX_PORT=${PASSV_MAX_PORT:=63000}
APP_UMASK=${APP_UMASK:=007}
APP_UID=${APP_UID:=1000}
APP_GID=${APP_GID:=1000}
APP_USER_NAME=${APP_USER_NAME:=admin}
APP_USER_PASSWD=${APP_USER_PASSWD:=admin}
if [ -f "$FTPS_SOURCE_DIR/Initialized" ] && [ "$FORCE_REINIT_CONFIG" = false ]; then
	echo "[] Skip initializing"
else
	echo "[] Substitute config file"
	$FTPS_SOURCE_DIR/substitute.py $FTPS_SOURCE_DIR/vsftpd.conf /etc/vsftpd/vsftpd.conf
	echo "[] Done."

	UIDX=$APP_UID

	for name in $USERS; do

		echo "[] Creating User: $UIDX as $name"
		groupadd $name || true
		p=PASSWD_$name
		useradd -m -d /home/$name -m -s /bin/bash -g $APP_GID -u $UIDX $name -G $name -p ${!p} || true

		mkdir /home/$name/data
		chown $name:$name /home/$name/data

		let UIDX=$UIDX+1
	done

	echo "Done."
	
	touch $FTPS_SOURCE_DIR/Initialized || true
	echo "[] Initialize complete."
fi

echo "[] Run vsftpd ..."
touch /var/log/vsftpd.log
/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
echo "[] Done."	
exec tail -f /var/log/vsftpd.log