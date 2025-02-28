#!/bin/bash

# Función sin parametros
function mensaje {
    echo "Hola mundo!!!"
}

# Función con parametros
function imprime_mensaje {
    echo ${1}
}

mensaje
imprime_mensaje "Hola a todos"