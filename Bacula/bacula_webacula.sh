#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 1>&2
   exit 1
fi

wget http://downloads.sourceforge.net/project/webacula/webacula/5.5.1/webacula-5.5.1.tar.gz
tar -zxvf webacula-5.5.1.tar.gz
mv webacula-5.5.1 /var/www/html/webacula


wget https://packages.zendframework.com/releases/ZendFramework-2.3.1/ZendFramework-2.3.1.tgz
tar -zxvf ZendFramework-2.3.1.tgz
cd ZendFramework-2.3.1
cp -r library /var/www/html/webacula/

nano /var/www/html/webacula/install/db.conf

# bacula settings (nome do banco do bacula)
#db_name="bacula"
# for Sqlite only
#db_name_sqlite="/var/bacula/working/bacula.db"
#db_user="root"

## CHANGE_THIS
#db_pwd="12345" # <==(Modifique!! Senha de usuário admin do banco de dados)

# Webacula web interface settings
...
#
# CHANGE_THIS
#webacula_root_pwd="12345" #<==(Modifique! Insira a senha do usuário administrador do Webacula).
cd /var/www/html/webacula/install/MySql
 ./10_make_tables.sh
 ./20_acl_make_tables.sh
 nano /var/www/html/webacula/html/.htaccess

## SetEnv APPLICATION_ENV development
#SetEnv APPLICATION_ENV production
# Add following line
#catalog = all, !skipped, !saved

nano /etc/bacula/bacula-dir.conf

# Edit section
#Messages {
#Name = Standard
#...
#catalog = all, !skipped, !saved

service bacula-director restart

nano /etc/php5/apache2/php.ini
# Change max_execution_time = 30
# max_execution_time = 3600

nano /var/www/html/webacula/application/config.ini

# Modufy next lines
#db.adapter = PDO_MYSQL
#db.config.host = localhost
#db.config.username = root
#db.config.password = 12345
#db.config.dbname = bacula
#...
#bacula.sudo = ""
#bacula.bconsole = "/sbin/bconsole"

chown www-data: /usr/bin/bconsole
chmod u=rwx,g=rx,o= /usr/bin/bconsole
chown www-data: /etc/bacula/bconsole.conf
chmod u=rw,g=r,o= /etc/bacula/bconsole.conf
chown -R www-data: /var/www/html/webacula

nano /etc/apache2/sites-available/webacula.conf

#Paste these lines:
#Alias /webacula /var/www/html/webacula/html
#<Directory /var/www/html/webacula/html>
#Options FollowSymLinks
#AllowOverride All
#Order deny,allow
#Allow from All
#</Directory>

service apache2 restart

# Login to web console at http://yourIP/webacula/
