#!/bin/bash

# Realizar un script que deberá mostrar el siguiente menú:
# 1. Listar el contenido del directorio actual
# 2. Listar el contenido del directorio actual en formato largo
# 3. Salir

# Si se introduce un valor diferente, el script mostrará el mensaje “Error en la selección”.
# Se repetirá el menú hasta que el usuario introduzca la opción 3 (salir).

function f_menu() {
    echo "1. Listar el contenido del directorio actual"
    echo "2. Listar el contenido del directorio actual en formato largo"
    echo "3. Salir"

    read -p "Opción: " salir

    case $salir in
        1) ls && f_menu;;
        2) ls -l && f_menu;;
        3) ;;
        *) echo "Error en la selección" && f_menu;;
    esac
}

f_menu
