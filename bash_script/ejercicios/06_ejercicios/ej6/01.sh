#!/bin/bash

# Crear un script que dea todos os permisos de lectura e escritura aos ficheiros do
# directorio que se pasa como parámetro, e só de lectura e execución aos
# subdirectorios.

cd ${1}

for i in $(ls); do
        if test -f ${i}; then
                chmod 666 ${i}
        fi
        if test -d ${i}; then
                chmod 555 ${i}
        fi
done