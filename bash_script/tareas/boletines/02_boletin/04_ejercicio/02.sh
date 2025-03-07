#!/bin/bash

# Realizar un script que deberá mostrar el siguiente menú:
# 1. Listar el contenido del directorio actual
# 2. Listar el contenido del directorio actual en formato largo
# 3. Salir

# Si se introduce un valor diferente, el script mostrará el mensaje “Error en la selección”.
# Se repetirá el menú hasta que el usuario introduzca la opción 3 (salir).

salir=0

until test $salir -eq 3
# until [[ $salir -eq 3 ]]
# until (( $salir==3 ))
do
        echo -e "\n1. Listar el contenido del directorio actual"
        echo "2. Listar el contenido del directorio actual en formato largo"
        echo "3. Salir"
        read -p "Opción: " salir

        case $salir in
                1) ls;;
                2) ls -l;;
                3) ;;
                *) echo "Error en la selección";;
        esac
done
