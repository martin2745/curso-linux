#!/bin/bash

# Realizar un script que recibe un directorio como parámetro y muestra de sus archivos el nombre y sus permisos.

echo "Nombre del directorio: ${1}"

cd "$1"

for i in $(ls); do
    if test -f "${i}"; then
        ls -la "${i}" | awk '{print "Archivo: " $NF " permisos: " $1}'
    fi
done
