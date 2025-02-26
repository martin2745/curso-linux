#!/bin/bash

# Realizar un script que deberá mostrar o seguinte menú:
# 1. Listar o contido do directorio actual
# 2. Listar o contido do directorio actual en formato largo
# 3. Sair

# Se se introducir un valor diferente, o script mostrará a mensaxe “erro na selección”.
# Se repetirá o menú ata que o usuario introduza a opción 3 (sair)

function f_opciones() {
    echo -e "\n1. Listar o contido do directorio actual"
    echo "2. Listar o contido do directorio actual en formato largo"
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
        *) echo "Erro na selección";;
    esac
done