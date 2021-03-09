#!/bin/bash
echo -e "zram" > /etc/modules-load.d/zram.conf
echo -e "options zram num_devices=1" > /etc/modprobe.d/zram.conf
echo -e 'KERNEL=="zram0", ATTR{disksize}="100M",TAG+="systemd"' > /etc/udev/rules.d/99-zram.rules

# remplacer les chemins par vos valeurs

BOOT_UUID=$(blkid /dev/md0 | cut -d " " -f 2)
ROOT_UUID=$(blkid /dev/mapper/vg2-lv_root | cut -d " " -f 2)
VAR_UUID=$(blkid /dev/mapper/vg2-lv_var | cut -d " " -f 2)
SWAP_UUID=$(blkid /dev/mapper/vg2-lv_swap | cut -d " " -f 2)

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

update-initramfs -u -k all
btrfs balance start /
