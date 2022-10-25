#!/usr/bin/bash
set -eu
fedora=$(rpm -E %fedora)
function dnf { microdnf --{assumeyes,nodocs,setopt=install_weak_deps=0} $@; }
echo "Using ID $1 for cloud user and group. Installing PHP version $2."
echo "This is Fedora $fedora."
cd /tmp
# Repositories
curl --location --no-progress-meter --remote-name-all \
https://rpms.remirepo.net/fedora/remi-release-$fedora.rpm \
https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$fedora.noarch.rpm
rpm -i *rpm
# Package management
dnf module enable php:remi-$2
dnf update
dnf install systemd php php-{cli,bcmath,gmp,fpm,xml,process,gd,mbstring,intl,pecl-{apcu,imagick-im7},opcache,json,zip,pgsql,sodium} ImageMagick7-heic ffmpeg
dnf clean all
# Permissions
groupadd --gid $1 cloud
useradd --system --uid $1 --gid $1 cloud
# Config files
mkdir --parents /etc/systemd/system/php-fpm.service.d
rm /etc/php-fpm.d/*
mv php/fpm.ini /etc/php-fpm.d/cloud.conf
mv php/php.ini /etc/php.d/99-nextcloud.ini
mv units/override.conf /etc/systemd/system/php-fpm.service.d/
mv units/* /etc/systemd/system/
rm -R *
# System units
systemctl disable systemd-oomd{,.socket} dbus{,.socket} systemd-userdbd.socket
systemctl enable php-fpm cloud-{cron,upgrade}.timer
