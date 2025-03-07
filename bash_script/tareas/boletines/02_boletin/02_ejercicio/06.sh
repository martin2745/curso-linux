#!/bin/bash

# Realizar un script que recibe un directorio como parámetro y muestra de sus archivos el nombre y sus permisos.

if [ -d $1 ]; then
        echo -e "El directorio ${1}\n"
        lineas=$(ls -la $1 | wc -l)
        lineas=$((${lineas}-1))
        ls -la $1 | tail -${lineas} | grep "^-" | awk -F " " '{print "PERMISOS: " $1 " NOMBRE " $NF}'
else
        echo "${1} no es un directorio"
fi





