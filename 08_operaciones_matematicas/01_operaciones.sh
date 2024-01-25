#!/bin/bash
# Author: Martín Gil Blanco

num1=16
num2=5

echo "--------------------------------------------------"
echo "    Operaciones matemáticas para $num1 y $num2    "
echo "--------------------------------------------------"

echo "Suma: $(($num1+$num2))"
echo "Resta: $(($num1-$num2))"
echo "Multiplicación: $(($num1*$num2))"
echo "División: $(($num1/$num2))"
echo "Resto o módulo: $(($num1%$num2))"
echo "Potencia: $(($num1**$num2))"

num3=$num2
((num2-=3))
echo "$num3 - 3 = $num2"
((num1++))
echo "Incremental: $num1"
echo "Decremental: $((--num1))" # Primero decrementa y luego muestra
# echo "Incremental: $((num1++))" # En este caso no veremos el valor de
# la operación realizada, primero mostrará el valor de $num1 y luego
# hace el incremento

dividendo=21
divisor=5
# División con decimales
division_result=$(echo "scale=2; $dividendo/$divisor" | bc)
echo "División: $division_result"
