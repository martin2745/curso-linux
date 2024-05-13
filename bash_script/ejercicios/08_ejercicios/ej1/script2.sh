#!/bin/bash

# Crea un script bash llamado manu1.sh que contenga un menú en el cual se den
# las siguientes opciones:

# Selecciona una opción sobre la interfaz de red $1:
# 1. Activar interfaz $1
# 2. Desactivar interfaz $1
# 3. Configurar alias $1:web con máscara de subred por defecto
# 4. Ver configuración de alias $1:web
# 5. Salir

function func_activar_interfaz() {
        echo "Activando ${eth}"
        sleep 5
        ifconfig ${eth} up
        ifconfig ${eth}
}

function func_desactivar_interfaz() {
        echo "Desactivando ${eth}"
        sleep 5
        ifconfig ${eth} down
        ifconfig ${eth}
}

function func_configuracion_alias_mascara() {
        read -p "IP de la interfaz con máscara: " ip
        echo "Configurando alias"
        sleep 5
        ifconfig ${eth}:web ${ip}
        ifconfig ${eth}
}

function func_configuracion_alias() {
        echo "Configurando alias"
        sleep 5
        ifconfig ${eth}:web
        ifconfig ${eth}
}

if [ $(id -u) -ne 0 ]; then
        echo "Solo el usuario root puede ejecutar el script"
        exit
fi

read -p "Interfaz a configurar: " eth

PS3="Selecciona una opción sobre la interfaz de red: "
OP1="Activar interfaz $1"
OP2="Desactivar interfaz $1"
OP3="Configurar alias $1:web con máscara de subred por defecto"
OP4="Ver configuración de alias $1:web"
OP5="Salir"

opciones=("${OP1}" "${OP2}" "${OP3}" "${OP4}" "${OP5}")

select op in "${opciones[@]}"; do
        case ${op} in
                ${OP1}) func_activar_interfaz;;
                ${OP2}) func_desactivar_interfaz;;
                ${OP3}) func_configuracion_alias_mascara;;
                ${OP4}) func_configuracion_alias;;
                ${OP5}) exit;;
                *) echo "Opción incorrecta";;
        esac
done