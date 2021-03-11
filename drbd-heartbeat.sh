#!/bin/bash

apt install drbd-utils heartbeat -y
modprobe drbd
systemctl enable drbd heartbeat

lvcreate -n lv_drbd -L 500 vg2

mkdir -p /mnt/drbd

drbdadm create-md wiki
drbdadm up wiki

if [ "$HOSTNAME" = "debian" ]; then drbdadm -- --overwrite-data-of-peer primary wiki; fi

if [ "$HOSTNAME" = "debian" ]; then mkfs -t xfs /dev/drbd0; fi

if [ "$HOSTNAME" = "debian" ]; then mount -v /dev/drbd0 /mnt/drbd; fi
