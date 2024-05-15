#!/bin/bash

#   Operadores de comparación de archivos:
#       -e: Existe
#       -f: Es un archivo regular
#       -d: Es un directorio
#       -r: Tiene permisos de lectura
#       -w: Tiene permisos de escritura
#       -x: Tiene permisos de ejecución

read -p "Introduce la ruta de un fichero: " ruta

if [ -e ${ruta} ]; then
    echo "El archivo ${ruta} existe"
    if [ -f ${ruta} -a -r ${ruta} ]; then
        echo "Es un fichero ${ruta} es un fichero y se puede escribir en el"
    elif [ -d ${ruta} ]; then
        echo "Es un directorio ${ruta}"
    fi
else
    echo "El archivo ${ruta} no existe"
fi