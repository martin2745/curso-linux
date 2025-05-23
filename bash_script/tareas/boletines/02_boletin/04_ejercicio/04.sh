#!/bin/bash

# Realizar un script que deberá mostrar el siguiente menú:
# 1. Listar el contenido del directorio actual
# 2. Listar el contenido del directorio actual en formato largo
# 3. Salir

# Si se introduce un valor diferente, el script mostrará el mensaje “Opción incorrecta”.
# Se repetirá el menú hasta que el usuario introduzca la opción 3 (salir).

PS3='Elige opción 1, 2 o 3: '
OP1='1. Listar el contenido del directorio actual'
OP2='2. Listar el contenido del directorio actual en formato largo'
OP3='3. Salir'

select op in "${OP1}" "${OP2}" "${OP3}"; do
    case $op in
        ${OP1}) ls;;
        ${OP2}) ls -l;;
        ${OP3}) exit;;
        *) echo "Opción incorrecta"
    esac
done
