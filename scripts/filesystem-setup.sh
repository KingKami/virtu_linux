#!/bin/bash

set -e

LV_ROOT="/dev/mapper/vg2-lv_root"
LV_VAR="/dev/mapper/vg2-lv_var"
LV_SWAP="/dev/mapper/vg2-lv_swap"
BOOT_DEVICE="/dev/md0"

ZRAM_SIZE_MB=100

BOOT_UUID=$(blkid ${BOOT_DEVICE} | cut -d " " -f 2)
ROOT_UUID=$(blkid ${LV_ROOT} | cut -d " " -f 2)
VAR_UUID=$(blkid ${LV_VAR} | cut -d " " -f 2)
SWAP_UUID=$(blkid ${LV_SWAP} | cut -d " " -f 2)

# configuration zram
echo -e "zram" > /etc/modules-load.d/zram.conf
echo -e "options zram num_devices=1" > /etc/modprobe.d/zram.conf
echo -e "KERNEL=='zram0', ATTR{disksize}='${ZRAM_SIZE_MB}M',TAG+='systemd'" > /etc/udev/rules.d/99-zram.rules

# regenerate fstab
echo -e "# /etc/fstab: static file system information." > /etc/fstab
echo -e "#" >> /etc/fstab
echo -e "# Use 'blkid' to print the universally unique identifier for a" >> /etc/fstab
echo -e "# device; this may be used with UUID= as a more robust way to name devices" >> /etc/fstab
echo -e "# that works even if disks are added and removed. See fstab(5)." >> /etc/fstab
echo -e "#" >> /etc/fstab

echo -e "# <file system>\t<mount point>\t<type>\t<options>\t<dump>\t<pass>" >> /etc/fstab
echo -e "$ROOT_UUID\t/\tbtrfs\tdefaults,compress=lzo\t0\t0" >> /etc/fstab

echo -e "" >> /etc/fstab

echo -e "# /boot was on /dev/md0 during installation" >> /etc/fstab
echo -e "$BOOT_UUID\t/boot\text2\tdefaults\t0\t2" >> /etc/fstab
echo -e "$VAR_UUID\t/var\txfs\tdefaults\t0\t0" >> /etc/fstab
echo -e "" >> /etc/fstab
echo -e "#$SWAP_UUID\tnone\tswap\tsw\t0\t0" >> /etc/fstab

#reload fstab
update-initramfs -u -k all
btrfs balance start /
