#!/bin/bash

# Realizar un script que recibe un directorio como parámetro y muestra de sus archivos el nombre y sus permisos.

echo "Nombre del directorio: ${1}"

ls -la ${1} | grep "^-" | awk '{print "Fichero: " $1 " permisos: " $NF}'