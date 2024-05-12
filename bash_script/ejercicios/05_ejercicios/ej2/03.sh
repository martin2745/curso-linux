#!/bin/bash

# Realizar un script que recibe un directorio como parámetro e mostra dos seus fichei># o nome, e os seus permisos.

echo "Nombre del directorio: ${1}"

cd ${1}

stat -c "%A %n" * | grep '^-'
