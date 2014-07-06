http://www.unixmen.com/setup-backup-server-using-bacula-webmin-ubuntu-14-04/

##Setup Backup Server Using Bacula And Webmin On Ubuntu 14.04

Bacula is an open source network backup solution that permits you to backup and restore the data’s from a local or group of remote networked computers. It is very easy in terms of installation and configuration with many advanced storage management features.

In this tutorial, let us see how to install and configure Bacula on Ubuntu 14.04 server. My test box IP address is 192.168.1.250/24, and hostname is server.unixmen.local. Well, now let me get us into the tutorial.

##Install Bacula
Bacula uses an SQL database to manage its information. We can use either MySQL or PostgreSQL database. In this tutorial, I use MySQL server.

Enter the following command to install MySQL server.

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install mysql-server
During MySQL installation, you’ll be asked to set the database administrator password. Enter the password and click Ok.

Now, let us install bacula using the following command:

sudo apt-get install bacula-server bacula-client
By default, Bacula uses Postfix MTA. During installation, you’ll be asked to configure Postfix.

Select Internet Site and click Ok.
Enter server fully qualified name(FQDN): server.unixmen.local

Now, select Yes to configure database for Bacula with dbconfig-common.
Enter the MySQL database administrator password:
Set password for bacula-director-mysql to register with the database server.  If left blank, a random password will be generated.
Re-enter the password:

##Create Backup and Restore Directories
Now, let us backup and restore directories.

sudo mkdir -p /mybackup/bacula/backup /mybackup/bacula/restore
Set permissions and ownership to the above directories:

sudo chown -R bacula:bacula /mybackup/
sudo chown -R 700 /mybackup/

##Configure Bacula
Bacula has many configuration files which we have to configure.

Update Bacula Director configuration:

sudo vi /etc/bacula/bacula-dir.conf
Find the following section, and update the restore path. In our case, /mybackup/bacula/restore is my restore location.

[...]
Job {
  Name = "RestoreFiles"
  Type = Restore
  Client=server-fd
  FileSet="Full Set"
  Storage = File
  Pool = Default
  Messages = Standard
  Where = /mybackup/bacula/restore
}
[...]
Scroll down to “list of files to be backed up” section, and set the path of the directory to backup. For this tutorial, I want to backup the “/home/sk” directory. So, I included this directory path in the “File” parameter.

[...]

#  By default this is defined to point to the Bacula binary
#    directory to give a reasonable FileSet to backup to
#    disk storage during initial testing.
#
    File = /home/sk
  }
[...]
Scroll down further, fins the section Exclude section. Set the list of directories to be excluded from the backup. Here, I excluded the backup folder /mybackup directory from being backed up.

[...]

# If you backup the root directory, the following two excluded
#   files can be useful
#
  Exclude {
    File = /var/lib/bacula
    File = /nonexistant/path/to/file/archive/dir
    File = /proc
    File = /tmp
    File = /.journal
    File = /.fsck
    File = /mybackup
  }
}
[...]
Save and close file.

Update Bacula Storage Daemon settings:

Edit /etc/bacula/bacula-sd.conf,

sudo vi /etc/bacula/bacula-sd.conf
Set the backup folder location. i.e /mybackup/bacula/backup in our case.

[...]

Device {
  Name = FileStorage
  Media Type = File
  Archive Device = /mybackup/bacula/backup
  LabelMedia = yes;                   # lets Bacula label unlabeled media
  Random Access = Yes;
  AutomaticMount = yes;               # when device opened, read it
  RemovableMedia = no;
  AlwaysOpen = no;
}
[...]
Now, check if all the configurations are valid as shown below. If the commands displays nothing, the configuration changes are valid.

sudo bacula-dir -tc /etc/bacula/bacula-dir.conf
sudo bacula-sd -tc /etc/bacula/bacula-sd.conf
Once you done all the changes, restart all bacula services.

sudo /etc/init.d/bacula-director restart
sudo /etc/init.d/bacula-fd restart
sudo /etc/init.d/bacula-sd restart
That’s it. Now, bacula has been installed and configured successfully.

## Bacula-web configuration

Download the source tarball

# wget http://www.bacula-web.org/files/bacula-web.org/downloads/bacula-web-latest.tgz
Uncompress the archive

# tar -x -v -z -f bacula-web-latest.tgz
or in one shot

// Debian / Ubuntu
# tar -xzf bacula-web-latest.tgz -C /var/www/

# mv -v bacula-web-x.x.x bacula-web
Change files/folders permissions

// On Debian / Ubuntu
# chown -Rv www-data: ./bacula-web

# chmod -Rv u=rx,g=rx,o=rx ./bacula-web

Configuring Bacula-Web

From Bacula-Web root folder, copy the file config.php.sample as below

Please note that since version 5.1.0, the config file is a PHP script.

# cd application/config

# cp -v config.php.sample config.php

# chown -v apache: config.php
Languages
Bacula-Web have been translated in different language (thank you to all the contributors for their efforts).

English (default)
Spanish (last update by Juan Luis Francés Jiménez)
Italian (last update by Gian Domenico Messina (gianni.messina AT c-ict.it)
French (last update by Morgan LEFIEUX - comete AT daknet.org)
German (last update by Florian Heigl)
Swedish - Maintened by Daniel Nylander (po@danielnylander.se)
Portuguese Brazil - Last updated by J. Ritter (condector@gmail.com)
To change the default displayed language, modify the option in config.php (see below)

$config['language'] = 'en_EN'; // (default language)

// Other available languages

// en_US (or en_UK)
// es_ES
// it_IT
// fr_FR
// de_DE
// sv_SV
// pt_BR
Options

As of version 5.2.11, the configuration file contain two new options described below

// Show inactive clients (hidden by default)
$config['show_inactive_clients'] = true;

// Hide empty pools (displayed by default)
$config['hide_empty_pools'] = false;
Database connection settings

// Bacula catalog label (used for catalog selector)
$config[0]['label'] = 'Backup Server';

// Server
$config[0]['host'] = 'localhost';

// Database name
$config[0]['db_name'] = 'bacula';

// Database user
$config[0]['login'] = 'bacula';

// Database user's password
$config[0]['password'] = 'verystrongpassword';

// Database type (mysql | pgsql | sqlite)
$config[0]['db_type'] = 'mysql';

// Database port
$config[0]['db_port'] = '3306';
Single catalog (example)

$config['language'] = 'en_EN';

//MySQL bacula catalog
$config[0]['label'] = 'Backup Server';
$config[0]['host'] = 'localhost';
$config[0]['login'] = 'bacula';
$config[0]['password'] = 'verystrongpassword';
$config[0]['db_name'] = 'bacula';
$config[0]['db_type'] = 'mysql';
$config[0]['db_port'] = '3306';
Multiple catalogs (example)

<?php
//MySQL bacula catalog
$config[0]['label'] = 'Backup Server';
$config[0]['host'] = 'localhost';
$config[0]['login'] = 'bacula';
$config[0]['password'] = 'verystrongpassword';
$config[0]['db_name'] = 'bacula';
$config[0]['db_type'] = 'mysql';
$config[0]['db_port'] = '3306';

//PostgreSQL Lab serveur
$config[1]['label'] = 'Lab backup server';
$config[1]['host'] = '192.168.0.120';
$config[1]['login'] = 'bacula';
$config[1]['password'] = 'verystrongpassword';
$config[1]['db_name'] = 'bacula';
$config[1]['db_type'] = 'pgsql';
$config[1]['db_port'] = '5432';
?>
Configuration example

Here's below how your configuration file (config.php) could look like

<?php
// Language
$config[0]['language'] = 'en_EN';

// Show inactive clients
$config['show_inactive_clients'] = false;

// Hide empty pools
$config['hide_empty_pools'] = true;

//MySQL bacula catalog
$config[0]['label'] = 'Backup Server';
$config[0]['host'] = 'localhost';
$config[0]['login'] = 'baculaweb';
$config[0]['password'] = 'password';
$config[0]['db_name'] = 'bacula';
$config[0]['db_type'] = 'mysql';
$config[0]['db_port'] = '3306';

// PostgreSQL bacula catalog
$config[1]['label'] = 'Prod Server';
$config[1]['host'] = 'db-server.domain.com';
$config[1]['login'] = 'bacula';
$config[1]['password'] = 'otherstrongpassword';
$config[1]['db_name'] = 'bacula';
$config[1]['db_type'] = 'pgsql';
$config[1]['db_port'] = '5432';

// SQLite bacula catalog
$config[2]['db_type'] = 'sqlite';
$config[2]['label'] = 'bacula';
$config[2]['db_name'] = '/path/to/database';
?>

Configure PHP

Update the timezone parameter in your PHP configuration in order to prevent Apache warning messages (see below)

Warning: mktime(): It is not safe to rely on the system's timezone settings. You are *required* to use the date.timezone setting or the date_default_timezone_set() function. In case you used any of those methods and you are still getting this warning, you most likely misspelled the timezone identifier. We selected 'Europe/Berlin' for 'CEST/2.0/DST' instead in /var/www/html/bacula-web/config/global.inc.php on line 62

Modify PHP configuration file

# File: /etc/php5/apache2/php.ini
# For *BSD users, the file is located /usr/local/etc/php.ini

# Locate and modify the line below
date.timezone =

# with this value (for example)
date.timezone = Europe/Moscow
Reload Apache configuration

$ sudo service apache2 reload

Secure your web server

In order to secure the application folder and avoid exposing sensitive information contained in Bacula-Web configuration.

Edit the Apache configuration file as described below

Debian / Ubuntu

$ sudo nano /etc/apache2/sites-available/bacula-web.conf

and add the content below

<Directory /var/www/html/bacula-web>
  AllowOverride All
</Directory>
Then reload Apache to apply the configuration change

Debian / Ubuntu
$ sudo /etc/init.d/apache2 restart
