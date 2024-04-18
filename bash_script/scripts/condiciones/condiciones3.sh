#!/bin/bash

# Haciendo uso de [[ para las operaciones lógicas and y or se emplea && || en lugar de -a -o

read -p "Dime un número: " numero

if [[ ${numero} -gt 50 && ${numero} -le 100 ]]; then
	echo "El número ${numero} es mayor que 50 y menor que 100"
elif [[ ${numero} -ge 25 && ${numero} -lt 50 ]]; then
	echo "El número ${numero} es mayor o igual a 25 y menor o igual a 50"
else
	echo "El número ${numero} no está entre 25 y 100"
fi

echo "------------------------------------"

if [ ${numero} -gt 50 -a ${numero} -le 100 ]; then
        echo "El número ${numero} es mayor que 50 y menor que 100"
elif [ ${numero} -ge 25 -a ${numero} -lt 50 ]; then
        echo "El número ${numero} es mayor o igual a 25 y menor o igual a 50"
else
        echo "El número ${numero} no está entre 25 y 100"
fi

echo "------------------------------------"
