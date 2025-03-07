#!/bin/bash

# Realizar un script que deberá mostrar el siguiente menú:
# 1. Listar el contenido del directorio actual
# 2. Listar el contenido del directorio actual en formato largo
# 3. Salir

# Si se introduce un valor diferente, el script mostrará el mensaje “Error en la selección”.
# Se repetirá el menú hasta que el usuario introduzca la opción 3 (salir).

function f_opciones() {
    echo -e "\n1. Listar el contenido del directorio actual"
    echo "2. Listar el contenido del directorio actual en formato largo"
    echo -e "3. Salir\n"
    read -p "Opción: " op
}

op=0

while [ ${op} -ne 3 ]; do

    f_opciones

    case ${op} in
        1) ls;;
        2) ls -l;;
        3) exit;;
        *) echo "Error en la selección";;
    esac
done
