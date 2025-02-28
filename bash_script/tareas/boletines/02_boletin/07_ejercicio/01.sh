#!/bin/bash

# Facer un script que acepte como argumentos os nomes dos ficheiros e mostre o
# contido de cada un deles, precendendo a cada un dunha liña: “Contido do ficheiro x”

for i in ${@}; do
        if [ -f ${i} ]; then
                echo -e "\nEl contenido de ${i} es"
                cat ${i}
        fi
done