#!/bin/bash

# Realizar un script que deberá mostrar o seguinte menú:
# 1. Listar o contido do directorio actual
# 2. Listar o contido do directorio actual en formato largo
# 3. Sair

# Se se introducir un valor diferente, o script mostrará a mensaxe “erro na selección”.
# Se repetirá o menú ata que o usuario introduza a opción 3 (sair)

sair=0

until test $sair -eq 3
# until [[ $sair -eq 3 ]]
# until (( $sair==3 ))
do
        echo -e "\n1. Listar o contido do directorio actual"
        echo "2. Listar o contido do directorio actual en formato longo"
        echo "3. Sair"
        read -p "Opción:" sair

        case $sair in
                1) ls;;
                2) ls -l;;
                3) ;;
                *) echo "Erro na seleccion";;
        esac
done





