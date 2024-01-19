#!/bin/bash
# Author: Martín Gil Blanco

function funcionParametros(){
    echo "Hola a todos, Soy funcionParametros"
    echo "Los parametros son $#"
    echo "He recibido el parametro $1"
    echo "He recibido el parametro $2"
}

# Llamamos a la función con algunos parámetros
funcionParametros "PrimerParametro" "SegundoParametro"
