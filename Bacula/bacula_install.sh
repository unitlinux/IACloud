#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 1>&2
   exit 1
fi

apt-get install bacula-server bacula-client -y

# Create Backup and Restore Directories
mkdir -p /mybackup/bacula/backup /mybackup/bacula/restore
chown -R bacula:bacula /mybackup/
chown -R 700 /mybackup/

# Modify config files...

# Install WEB client bacula-web
apt-get install libapache2-mod-php5 php5-mysql php5-gd -y
cd /var/www/html
wget http://www.bacula-web.org/files/bacula-web.org/downloads/bacula-web-6.0.0.tgz
tar -xzf bacula-web-6.0.0.tgz -C /var/www/
mv -v bacula-web-6.0.0 bacula-web
chown -Rv www-data: ./bacula-web
chmod -Rv u=rx,g=rx,o=rx ./bacula-web
chmod -Rv u=rx,g=rx,o=rx /var/www/html/bacula-web
chmod 777 /var/www/html/bacula-web/application/view/cache

# Configuration
cd bacula-web/application/config
cp -v config.php.sample config.php
chown -v www-data: config.php
