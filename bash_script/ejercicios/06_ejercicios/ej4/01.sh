#!/bin/bash

# Realizar un script que deberá mostrar o seguinte menú:
# 1. Listar o contido do directorio actual
# 2. Listar o contido do directorio actual en formato largo
# 3. Sair

# Se se introducir un valor diferente, o script mostrará a mensaxe “erro na selección”.
# Se repetirá o menú ata que o usuario introduza a opción 3 (sair)

opciones(){
    echo -e "\n1. Listar o contido do directorio actual"
    echo "2. Listar o contido do directorio actual en formato largo"
    echo "3. Salir"
}

pedirOpcion(){
    read -p "Opción: " op
}

opciones
pedirOpcion

while [ ${op} -ne 3 ]; do
    case ${op} in
        1) ls
           opciones
           pedirOpcion
           ;;
        2) ls -l
           opciones
           pedirOpcion
           ;;
        3) exit;;
        *) echo "Erro na selección"
           opciones
           pedirOpcion
           ;;
    esac
done