#!/usr/bin/bash
set -eu
# Package management
export DEBIAN_FRONTEND=noninteractive
apt-get -y update
apt-get -y install --no-install-recommends systemd-sysv caddy icinga{{cli,2},web2,db{,-web}} php-{fpm,pgsql,gd,redis} monitoring-plugins postgresql-client
apt-get clean
phpver=$(ls /etc/php/)
ln --symbolic --verbose /lib/systemd/system/php$phpver-fpm.service /etc/systemd/system/php-fpm.service
# Create user and matching group
# Place system unit files
rm -r /etc/caddy/*
rm -r /etc/icinga*
rm -r /var/lib/icinga*
rm /etc/php/$phpver/fpm/pool.d/*
cd /tmp
mv bin/* /usr/local/bin
chmod +x /usr/local/bin/*
mv units/* /etc/systemd/system/
mv php/fpm.ini /etc/php/$phpver/fpm/pool.d/fpm.conf
mv Caddyfile /etc/caddy/
rm -r *
for i in icinga{2,web2,db}; do ln --symbolic --verbose /mnt/pv/etc/$i /etc; done
for i in icinga{2,web2}; do ln --symbolic --verbose /mnt/pv/var/$i /var/lib; done
# Set system unit states
systemctl set-default container.target
