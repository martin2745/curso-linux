#!/bin/bash

# Hacer un script que acepte como argumentos los nombres de los archivos y muestre el
# contenido de cada uno de ellos, precediendo a cada uno de una línea: “Contenido del archivo x”

for i in ${@}; do
        if [ -f ${i} ]; then
                echo -e "\nEl contenido de ${i} es"
                cat ${i}
        fi
done
