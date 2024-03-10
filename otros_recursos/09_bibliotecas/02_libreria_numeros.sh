#!/bin/bash
# author: Martín Gil Blanco


# Función que comprueba si un elemento es numérico.
#
# Parametros
# 	Cualquier parámetro.
# ---------------
# Resultado:
# 	0 Muestra 0 si no es numérico.
# 	1 Muestra 1 si es numérico en formato anglosajon.
# 	2 Muestra 2 si es numérico en formato hispano.
# ---------------

function esnumerico(){
	if [[ $1 =~ ^(-?[0-9]+)?(\.[0-9]+)?$ ]]; then
		echo 1
	elif [[ $1 =~ ^(-?[0-9]+)?(\,[0-9]+)?$ ]]; then
		echo 2
	else
		echo 0
	fi
}


# Función que permite sumar dos números 
function suma(){
	num1=$1
	num2=$2
	resultado=$(echo "$num1 + $num2" | bc)
	echo "La suma de $num1 y $num2 es: $resultado"
}

#########################################################
num=$(esnumerico -1,24)
echo $num

echo $(suma 1.1 2.7)
