#!/bin/bash

# Realizar un script que deberá mostrar el siguiente menú:
# 1. Listar el contenido del directorio actual
# 2. Listar el contenido del directorio actual en formato largo
# 3. Salir

# Si se introduce un valor diferente, el script mostrará el mensaje “Opción incorrecta”.
# Se repetirá el menú hasta que el usuario introduzca la opción 3 (salir).

PS3='Elige opción 1, 2 o 3: '
OPS=("1. Listar el contenido del directorio actual" "2. Listar el contenido del directorio actual en formato largo" "3. Salir")

select op in "${OPS[@]}"; do
    case $op in
        ${OPS[0]}) ls;;
        ${OPS[1]}) ls -l;;
        ${OPS[2]}) exit;;
        *) echo "Opción incorrecta"
    esac
done
