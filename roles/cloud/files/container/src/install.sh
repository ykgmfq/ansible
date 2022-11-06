#!/usr/bin/bash
set -eu
fedora=$(rpm -E %fedora)
function dnf { microdnf --{assumeyes,nodocs,setopt=install_weak_deps=0} $@; }
echo "Using ID $1 for cloud user and group. Installing PHP version $2."
echo "This is Fedora $fedora."
cd /tmp
# Configure extra repositories
curl --location --no-progress-meter --remote-name-all \
https://rpms.remirepo.net/fedora/remi-release-$fedora.rpm \
https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$fedora.noarch.rpm
rpm -i *.rpm
# Package management
dnf module enable php:remi-$2
dnf update
dnf install systemd ImageMagick7-heic ffmpeg \
php{,-{cli,bcmath,gmp,fpm,xml,process,gd,mbstring,intl,opcache,json,zip,pgsql,sodium,pecl-{apcu,imagick-im7}}}
dnf reinstall tzdata
dnf clean all
# Create user and matching group
echo u cloud $1 | systemd-sysusers -
# Place PHP Config files
rm /etc/php-fpm.d/*
mv php/fpm.ini /etc/php-fpm.d/cloud.conf
mv php/php.ini /etc/php.d/99-nextcloud.ini
# Place system unit files
mkdir --parents /etc/systemd/system/php-fpm.service.d
mv units/override.conf /etc/systemd/system/php-fpm.service.d/
new_units=$(ls units/)
mv units/* /etc/systemd/system/
rm -r *
# Set system unit states
systemctl disable systemd-oomd{,.socket} dbus{,.socket} systemd-userdbd.socket
systemctl enable php-fpm $new_units
