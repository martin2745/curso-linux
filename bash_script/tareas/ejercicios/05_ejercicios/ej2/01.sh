#!/bin/bash

# Realizar un script que recibe un directorio como parámetro e mostra dos seus ficheiros o nome, e os seus permisos.

echo "Nombre del directorio: ${1}"

cd $1

for i in $(ls); do
#    if [[ -f ${i} ]]; then
     if ( test -f ${i} ); then
        ls -la ${i} | awk '{print "Fichero: " $NF " permisos: " $1}'
    fi
done