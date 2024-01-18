#!/bin/bash
# Authon: Martín Gil Blanco

# Uso de arrays e iteración

numeros=(1 2 3 4 5 6 7 8)
nombres=(martin julian diego rosa)
nombres_espacios=("martin gil" alex "juan castro" antonio)
rangos=({A..Z} {1..10})

echo "================Imprimir valores================="

echo "Array de Números: ${numeros[*]}"
echo "Array de Nombres: ${nombres[*]}"
echo "Array de Nombres con espacios: ${nombres_espacios[*]}"
echo "Array de Rangos de valores: ${rangos[*]}"

echo "Número de elementos del array de ${#nombres_espacios[*]}"

echo "Elemento 2 del arreglo nombres_espacios ${nombres_espacios[2]}"

unset  numeros[0]
echo "Array de Números sin el primer elemento: ${numeros[*]}"
echo "Elemento 0 del array de Números: ${numeros[0]}"
numeros[0]=1
echo "Array de Números: ${numeros[*]}"

echo "======================FOREACH======================="

for num in ${numeros[*]}
do
	echo "Número: $num"
done

echo "========================FOR========================="

for ((i=0; i<${#numeros[*]}; i++))
do
	echo "Número ${numeros[i]}"
done
