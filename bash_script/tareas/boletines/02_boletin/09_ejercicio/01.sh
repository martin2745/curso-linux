#!/bin/bash

# Realizar un script que dado un nome de ficheiro, se este existe, é un ficheiro normal e
# se pode escribir, mostre a mensaxe seguinte: O fichero f existe, e un ficheiro
# normal e se puede escribir. Se non se puede escribir: O fichero f existe, e un
# ficheiro normal pero non se pode escribir. Se non existe ou é un directorio
# aparecerán as seguintes mensaxes: O ficheiro f non existe ou f e un directorio
# respectivamente

if [[ -f $1 ]]; then
        if [[ -w $1 ]]; then
                echo "O ficheiro existe, e un ficheiro normal e se pode escribir"
        else
                echo "O ficheiro existe, e un ficheiro normal pero non se pode escribir"
        fi
else
        if [[ ! -e $1 ]]; then
                echo "O ficheiro non existe"
        elif [[ -d $1 ]]; then
                echo "E un directorio"
        fi
fi