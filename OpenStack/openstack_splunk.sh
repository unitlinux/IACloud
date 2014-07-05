#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 1>&2
   exit 1
fi

clear 

. ./setuprc

echo;
echo "####################################################################################################	

This script is installing and configuring Splunk for ingestion of the OpenStack logs.  Splunk can 
be used to debug and monitor your OpenStack configuration. Access it from the following URL:

http://$SG_SERVICE_CONTROLLER_IP:8000/

####################################################################################################	
"
echo;

# download
wget -O splunk-6.1.1-207789-Linux-x86_64.tgz 'http://www.splunk.com/page/download_track?file=6.1.1/splunk/linux/splunk-6.1.1-207789-Linux-x86_64.tgz&ac=&wget=true&name=wget&platform=Linux&architecture=x86_64&version=6.1.1&product=splunk&typed=release'

# extract, move, cleanup
tar xvfz splunk-6.1.1-207789-Linux-x86_64.tgz
mv splunk /opt/splunk
rm splunk-6.1.1-207789-Linux-x86_64.tgz

# whack on inputs.conf file
echo "
[monitor:///var/log/keystone]
disabled = false
followTail = 0

[monitor:///var/log/nova]
disabled = false
followTail = 0

[monitor:///var/log/glance]
disabled = false
followTail = 0

[monitor:///var/log/cinder]
disabled = false
followTail = 0

[monitor:///var/log/rabbit]
disabled = false
followTail = 0

[monitor:///var/log/mongodb]
disabled = false
followTail = 0

[monitor:///var/log/ceilometer]
disabled = false
followTail = 0

[monitor:///var/log/libvirt]
disabled = false
followTail = 0
" >> /opt/splunk/etc/apps/launcher/default/inputs.conf

# start splunk
/opt/splunk/bin/splunk start --accept-license