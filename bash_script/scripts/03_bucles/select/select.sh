#!/bin/bash

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