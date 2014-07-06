#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 1>&2
   exit 1
fi

touch /etc/apt/sources.list.d/webmin.list
echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list.d/webmin.list
echo "deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib" >> /etc/apt/sources.list.d/webmin.list

wget http://www.webmin.com/jcameron-key.asc -O- | apt-key add -
apt-get update

apt-get install webmin -y

# Allow the webmin default port “10000″ via firewall, if you want to access the webmin console from a remote system.
ufw allow 10000
