#!/bin/bash

# Realizar un script que deberá mostrar o seguinte menú:
# 1. Listar o contido do directorio actual
# 2. Listar o contido do directorio actual en formato largo
# 3. Sair

# Se se introducir un valor diferente, o script mostrará a mensaxe “erro na selección”.
# Se repetirá o menú ata que o usuario introduza a opción 3 (sair)

function f_menu() {
echo "1. Listar o contido de directorio actual"
echo "2. Listar o contido do directorio actual en formato longo"
echo "3. Saír"

read -p "Opción: " sair

case $sair in
        1) ls && f_menu;;
        2) ls -l && f_menu;;
        3) ;;
        *) echo "Erro na selección" && f_menu;;
esac
}

f_menu

