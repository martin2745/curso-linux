#!/bin/bash

# Realizar un script que recibe un directorio como parámetro y muestra de sus archivos el nombre y sus permisos.

echo "Nombre del directorio: ${1}"

cd ${1}

find . -maxdepth 1 -type f -a -not -iname "\.*" -exec ls -la {} \; | awk '{print "Fichero: " $NF " permisos: " $1}'