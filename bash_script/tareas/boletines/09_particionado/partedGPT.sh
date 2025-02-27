#!/bin/bash
parted -s /dev/sdb mklabel gpt
parted -s /dev/sdb mkpart primary ext4 0% 50%
parted -s /dev/sdb mkpart primary ext4 50% 75%
parted -s /dev/sdb mkpart primary ext4 75% 100%
parted -s /dev/sdb print

# Formatear las particiones
mkfs.ext4 /dev/sdb1
mkfs.ext4 /dev/sdb2
mkfs.ext4 /dev/sdb3
