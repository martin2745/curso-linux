#!/bin/bash
read -p "Introduzca el primer número: " num1
read -p "Introduzca el segundo número: " num2

echo "La suma de ${num1} y ${num2} es: $((${num1}+${num2}))"
echo "La resta de ${num1} y ${num2} es: $((${num1}-${num2}))"
echo "La multiplicación de ${num1} y ${num2} es: $((${num1}*${num2}))"
echo "La división de ${num1} y ${num2} es: $((${num1}/${num2}))"
echo "El resto de ${num1} y ${num2} es: $((${num1}%${num2}))"

# Muestra números muy elevados, puedo conseguir los números
# entre 0 y 25 haciendo RANDOM%26
echo "Número aleatorio $((${RANDOM}%26))"