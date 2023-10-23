#!/usr/bin/bash
set -eu
fedora=$(rpm -E %fedora)
function f { dnf --{assumeyes,nodocs,setopt=install_weak_deps=0} $@; }
echo "Using ID $1 for cloud user and group. Installing PHP version $2."
echo "This is Fedora $fedora."
cd /tmp
# Configure extra repositories
f install \
fedora-repos-modular \
https://rpms.remirepo.net/fedora/remi-release-$fedora.rpm \
https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$fedora.noarch.rpm
f module enable postgresql:14 php:remi-$2
# Package management
f install systemd postgresql-server ffmpeg ImageMagick-heic \
php{,-{cli,bcmath,gmp,fpm,xml,process,gd,mbstring,intl,opcache,json,zip,pgsql,sodium,pecl-{apcu,imagick-im7}}}
#f reinstall tzdata
f clean all
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
systemctl disable $(ls /etc/systemd/system/multi-user.target.wants/) systemd-{userdb,login}d
systemctl enable php-fpm postgresql $new_units
