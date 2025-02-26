#!/bin/bash 

# Cree un script bash llamado menu2.sh que contenga un menú en el que se proporcione lo siguiente
# opciones:
# Seleccione una opción sobre la interfaz de red eth0:
# 1. Ver solo IP
# 2. Ver solo la dirección MAC
# 3. Ver la tabla de enrutamiento sin resolución DNS
# 4. Ver la configuración de DNS
# 5. Salir

function menu() {
    
    clear

    echo "Seleccione una opción sobre la interface de red eth0:"
    echo "1. Ver IP soamente"
    echo "2. Ver MAC-Address solamente"
    echo "3. Ver tabla de enrutamiento sin resolución DNS"
    echo "4. Ver configuración DNS"
    echo "5. Salir" 
    echo "Elige opción: 1,2,3,4,5? " 
    read opcion 
    
    case $opcion in
        1) /sbin/ifconfig eth0 | egrep -o '([0-9]{1,3}\.){3}[0-9]{1,3}' | egrep -v '^127|255$|^255|0$';;
        2) /sbin/ifconfig eth0 | egrep -o '([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}';;
        3) /sbin/route -n;;
        4) cat /etc/resolv.conf;;
        5) exit;;
        *) echo Opción no válida;;
    esac
}

clear
menu