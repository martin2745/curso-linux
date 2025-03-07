#!/bin/bash

# Realizar un script que dado un nombre de archivo, si este existe, es un archivo normal y
# si se puede escribir, muestre el siguiente mensaje: El archivo f existe, es un archivo
# normal y se puede escribir. Si no se puede escribir: El archivo f existe, es un
# archivo normal pero no se puede escribir. Si no existe o es un directorio
# aparecerán los siguientes mensajes: El archivo f no existe o f es un directorio
# respectivamente

if [[ -f $1 ]]; then
        if [[ -w $1 ]]; then
                echo "El archivo existe, es un archivo normal y se puede escribir"
        else
                echo "El archivo existe, es un archivo normal pero no se puede escribir"
        fi
else
        if [[ ! -e $1 ]]; then
                echo "El archivo no existe"
        elif [[ -d $1 ]]; then
                echo "Es un directorio"
        fi
fi