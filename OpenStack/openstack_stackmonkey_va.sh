#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 1>&2
   exit 1
fi

# have we run before?
if [ -f ./stackmonkeyrc ]; then
echo;
echo "####################################################################################################

This script has already been run.  If you want to launch a new StackMonkey VA, enter the following
on the command line:

  . ./stackmonkeyrc
  nova boot --poll --key_name stackmonkey --user-data postcreation.sh --flavor 1 --image 'Ubuntu Precise 12.04 LTS' 'StackMonkey VA'
  nova list

####################################################################################################
"
exit
fi

# grab a new password
read -p "Enter a new password for the 'stackmonkey' user: " monkeypass

# source the stack and setup files
. ./setuprc
. ./stackrc

# indicate we've now run ourselves
cat >> stackmonkeyrc <<EOF
export SM_VA_LAUNCH=true
export OS_TENANT_NAME=StackMonkey
export OS_USERNAME=stackmonkey
export OS_PASSWORD=$monkeypass
export OS_AUTH_URL=$OS_AUTH_URL
export KEYSTONE_REGION=$KEYSTONE_REGION
EOF

# get_id function for loading variables from command runs
function get_id () {
    echo `$@ | awk '/ id / { print $4 }'`
}

# create stackmonkey project, user and roles
STACKMONKEY_TENANT=$(get_id keystone tenant-create --name=stackmonkey)
STACKMONKEY_USER=$(get_id keystone user-create --name=stackmonkey --pass="$monkeypass" --email=$SG_SERVICE_EMAIL)
STACKMONKEY_ROLE=$(get_id keystone role-create --name=monkey)
keystone user-role-add --user-id $STACKMONKEY_USER --role-id $STACKMONKEY_ROLE --tenant-id $STACKMONKEY_TENANT

# the following steps are run using the admin user and tenant
# instance managment of the virtual appliance is done in horizon using the admin user/pass

# create and add keypairs
ssh-keygen -f stackmonkey-id -N ""
nova keypair-add --pub_key stackmonkey-id.pub stackmonkey

# configure default security group to allow port 80 and 22, plus pings
nova secgroup-add-rule default tcp 80 80 0.0.0.0/0
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0

# create a new flavor for the va w/ 8GB drive space
nova-manage instance_type create va.xovo 512 1 8

# boot va with key, post boot data, flavor, image, instance name
nova boot --poll --key_name stackmonkey --user-data postcreation.sh --flavor va.xovio --image "Ubuntu Precise 12.04 LTS" "StackMonkey VA"

# grab the IP address for display to the user
APPLIANCE_IP=`nova list | grep "private*=[^=]" | cut -d= -f2 | cut -d, -f1`

# source the stackmonkeyrc file for user/pass
. ./stackmonkeyrc

# instruction bonanza
echo "#####################################################################################################

The StackMonkey appliance is being built and a private key called 'stackmonkey.pem' has been created.

The username/password for the OpenStack Horizon account is $OS_USERNAME/$OS_PASSWORD.

Log into your OpenStack cluster with this user/pass to download your credentials file to your local
machine.  You will need to upload this file when you configure the appliance.

You may now configure the appliance at: http://$APPLIANCE_IP/

#####################################################################################################
"

# switch tenant name and username back, just in case user runs stuff
export OS_TENANT_NAME=admin
export OS_USERNAME=admin

exit
