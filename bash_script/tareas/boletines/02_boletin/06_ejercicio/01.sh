#!/bin/bash

# Crear un script que dé todos los permisos de lectura y escritura a los archivos del
# directorio que se pasa como parámetro, y solo de lectura y ejecución a los
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
