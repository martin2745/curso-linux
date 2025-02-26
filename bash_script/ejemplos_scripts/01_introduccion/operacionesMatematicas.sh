#!/bin/bash

num1=5
num2=2

echo "La suma es $(( ${num1} + ${num2} ))"
echo "La resta es $(( ${num1} - ${num2} ))"
echo "La multiplicacion es $(( ${num1} * ${num2} ))"
echo "La division es $(( ${num1} / ${num2} ))"
echo "El módulo de la división entera es $(( ${num1} % ${num2} ))"
echo "Número aleatorio entre 1 y 10 es $(( ${RANDOM}%11 ))"

echo -e "\nOtras formas de hacer operaciones"
expr 2 \* 2 # Operación 2*2
echo "2 * 2" | bc # Operación 2*2
