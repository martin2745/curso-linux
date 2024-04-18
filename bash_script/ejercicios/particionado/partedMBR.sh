#!/bin/bash

# Crea un particionado del disco /dev/sdb con:
# Una partición primaria del 0% al 50%
# Una partición extendida del 50% al 100%
# Una partición lógica del 50% al 75%
# Monta la partición en /mnt/mbr

function montaje {
    mount | grep sdb | awk '{print $1}' | xargs umount
    if [ -e /mnt/script_mbr/1 ]; then 
        rm -r /mnt/script_mbr/1 &>/dev/null; 
    fi
    if [ -e /mnt/script_mbr/5 ]; then 
        rm -r /mnt/script_mbr/5 &>/dev/null; 
    fi
    if [ -e /mnt/script_mbr ]; then 
        rm -fr /mnt/script_mbr &>/dev/null; 
    fi
    mkdir -p /mnt/script_mbr/1 /mnt/script_mbr/5 &>/dev/null
    mount -t ext4 /dev/sdb1 /mnt/script_mbr/1 &>/dev/null
    mount -t ext4 /dev/sdb5 /mnt/script_mbr/5 &>/dev/null
    echo -e "\nDispositivos montados"
    df -Th
}

if [ $(id -u) -ne 0 ]; then
        echo "Usted está logueado como ${USER}"
        echo "Este script tiene que ser ejecutado por root"
    else
        if [ -e /dev/sdb ]; then
            parted -s /dev/sdb mklabel msdos &>/dev/null
            parted -s /dev/sdb mkpart primary 0% 50% &>/dev/null
            parted -s /dev/sdb mkpart extended 50% 100% &>/dev/null
            parted -s /dev/sdb mkpart logical 50% 75% &>/dev/null
            mkfs.ext4 /dev/sdb1 &>/dev/null
            mkfs.ext4 /dev/sdb5 &>/dev/null
            echo "$(fdisk -l /dev/sdb)"
            if [ ! -e /mnt/script_mbr ]; then
                montaje
            fi
        else
            echo "No existe el disco /dev/sdb a particionar"
        fi
fi
