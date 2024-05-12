#!/bin/bash

# Realizar un script que deberá mostrar o seguinte menú:
# 1. Listar o contido do directorio actual
# 2. Listar o contido do directorio actual en formato largo
# 3. Sair

# Se se introducir un valor diferente, o script mostrará a mensaxe “erro na selección”.
# Se repetirá o menú ata que o usuario introduza a opción 3 (sair)

PS3='Elige opción 1,2,3: '
OP1='1. Listar o contido do directorio actual'
OP2='2. Listar o contido do directorio actual en formato largo'
OP3='3. Sair'

select op in "${OP1}" "${OP2}" "${OP3}"; do
    case $op in
        ${OP1}) ls;;
        ${OP2}) ls -l;;
        ${OP3}) exit;;
        *) echo "Opcion incorrecta"
    esac
done