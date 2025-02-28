#!/bin/bash

parametros(){
    echo "Parametro Funcion 1: " ${1}
    echo "Parametro Funcion 2: " ${2}
}

echo "Valores de parametros"
echo "Parametro 1: " ${1}
echo "Parametro 2: " ${2}
parametros "Tres" "Cuatro"
# Enviamos como parametros a la función los introducidos en la ejecución del script
parametros $*
parametros $@


