#!/bin/sh
adduser --disabled-password --no-create-home --uid $idscan scan
adduser --disabled-password --no-create-home --uid $idmedia media
apk add --no-cache samba
(echo $pwmedia; sleep 1; echo $pwmedia ) | smbpasswd -s -a media
(echo $pwscan; sleep 1; echo $pwscan ) | smbpasswd -s -a scan
mkdir /opt/monitor
echo "OK" > /opt/monitor/m.txt
