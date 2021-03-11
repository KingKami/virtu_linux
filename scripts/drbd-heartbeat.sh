#!/bin/bash

set -e

# edit variables to match yours
PRIMARY_NODE_HOSTNAME="debian"
SECONDARY_NODE_HOSTNAME"debian2"
DRBD_RESOURCE_NAME="wiki"
LV_DRBD_NAME="lv_drbd"
LV_DRBD_SIZE_MB=500
VG_NAME="vg2"
DRBD_DEVICE_NAME="/dev/drbd0"
DRBD_DISK_NAME="/dev/mapper/${$VG_NAME}-${LV_DRBD_NAME}"
PRIMARY_NODE_IP="192.168.1.44"
SECONDARY_NODE_IP="192.168.1.53"
DRBD_PORT=7789
DRBD_MOUNT_POINT="/mnt/drbd"
GATEWAY_IP="192.168.1.1"
NETWORK_ADAPTER="ens33"
NETWORK_MASK="/24"
HEARTBEAT_VIRTUAL_IP="192.168.1.100"

apt install drbd-utils heartbeat -y

# enable drbd in kernel
modprobe drbd
systemctl enable drbd heartbeat
systemctl stop drbd heartbeat nginx mysql

# set config file edit resource name to match your need
cp -f drbd/drbd.conf /etc/drbd.conf
sed -i "s#primary_node_hostname#${PRIMARY_NODE_HOSTNAME}#" "/etc/drbd.conf"
sed -i "s#secondary_node_hostname#${SECONDARY_NODE_HOSTNAME}#" "/etc/drbd.conf"
sed -i "s#primary_node_ip#${PRIMARY_NODE_IP}:${DRBD_PORT};#" "/etc/drbd.conf"
sed -i "s#secondary_node_ip#${SECONDARY_NODE_IP}:${DRBD_PORT};#" "/etc/drbd.conf"
sed -i "s#device#${DRBD_DEVICE_NAME};#" "/etc/drbd.conf"
sed -i "s#disk#${DRBD_DISK_NAME};#" "/etc/drbd.conf"

# create new lv for drbd volume on both servers edit lv size to match your need
lvcreate -n $LV_DRBD_NAME -L $LV_DRBD_SIZE_MB $VG_NAME

# create mount point
mkdir -p $DRBD_MOUNT_POINT

# create resource
drbdadm create-md $DRBD_RESOURCE_NAME
drbdadm up $DRBD_RESOURCE_NAME

# set the master node as primary on our resource change resource name to match yours
if [ "$HOSTNAME" = "$PRIMARY_NODE_HOSTNAME" ]; then
    # set the node to be primary
    drbdadm -- --overwrite-data-of-peer primary $DRBD_RESOURCE_NAME;
    # format the filesystem
    mkfs -t xfs $DRBD_DEVICE_NAME
    # mount the drbd disk
    mount -v $DRBD_DEVICE_NAME ${DRBD_MOUNT_POINT}

    # move bookstack and mysql data files
    mv /var/www/html/BookStack "${DRBD_MOUNT_POINT}/Bookstack"
    mv /var/lib/mysql "${DRBD_MOUNT_POINT}/mysql"
    ln --safelink "${DRBD_MOUNT_POINT}/Bookstack" /var/www/html/
    ln --safelink "${DRBD_MOUNT_POINT}/mysql" /var/lib/

fi

if [ "$HOSTNAME" = "$SECONDARY_NODE_HOSTNAME" ]; then
    # delete bookstack and mysql data on secondary node and point the node to look in the drbd disk
    rm -rf /var/www/html/BookStack
    rm -rf /var/lib/mysql
    ln --safelink "${DRBD_MOUNT_POINT}/Bookstack" /var/www/html/
    ln --safelink "${DRBD_MOUNT_POINT}/mysql" /var/lib/
fi

# you can check if the drbd is up with the following commands
# drbd-overview
# cat /proc/drbd
# tail -f /var/log/messages

# copy heartbeat config files
cp -f heartbeat/ha.cf /etc/ha.d/ha.cf
sed -i "s#primary_node_hostname#${PRIMARY_NODE_HOSTNAME}#" "/etc/ha.d/ha.cf"
sed -i "s#secondary_node_hostname#${SECONDARY_NODE_HOSTNAME}#" "/etc/ha.d/ha.cf"
sed -i "s#gateway#${GATEWAY_IP}#" "/etc/ha.d/ha.cf"
sed -i "s#network_adapter#${NETWORK_ADAPTER}#" "/etc/ha.d/ha.cf"

cp -f heartbeat/haresources /etc/ha.d/haresources
sed -i "s#primary_node_hostname#${PRIMARY_NODE_HOSTNAME}#" "/etc/ha.d/haresources"
sed -i "s#virtual_ip#${HEARTBEAT_VIRTUAL_IP}#" "/etc/ha.d/haresources"
sed -i "s#/mask#${NETWORK_MASK}#" "/etc/ha.d/haresources"
sed -i "s#network_adapter#${NETWORK_ADAPTER}#" "/etc/ha.d/haresources"
sed -i "s#drbd_resource_name#${DRBD_RESOURCE_NAME}#" "/etc/ha.d/haresources"
sed -i "s#drbd_device_name#${DRBD_DEVICE_NAME}#" "/etc/ha.d/haresources"
sed -i "s#drbd_mount_point#${DRBD_MOUNT_POINT}#" "/etc/ha.d/haresources"

# optionnal to make your services more resilient,
# add the option restart=on-failure or restart=on-abort to your services
# on-failure could keep your service in a restart loop if you have any configuration error

systemctl start drbd heartbeat nginx mysql