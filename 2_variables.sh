#!/bin/bash
# Author: Martín Gil Blanco

# Muestra el contenido de variables en script.

echo "======================================================="
# Variable de entorno accesible en cualquier parte del sistema
echo $HOME

echo="======================================================="
# Variable de usuario cuya existencia se limita al scrip
mi_variable="Soy una variable de usuario"
echo $mi_variable

echo "======================================================="
# Operaciones aritméticas con variables numéricas
numA=3
numB=2

echo "Operaciones con los valores $numA y $numB"
echo "$numA + $numB = " $((numA + numB))
echo "$numA - $numB = " $((numA - numB))
echo "$numA * $numB = " $((numA * numB))
echo "$numA / $numB = " $((numA / numB))

echo "======================================================="
# Operadores relacionales con variables numéricas

echo "Operadores relacionales con los valores $numA y $numB"
echo "0 = False / 1 = True"
echo "$numA > $numB  = " $((numA > numB))
echo "$numA < $numB  = " $((numA < numB))
echo "$numA >= $numB = " $((numA >= numB))
echo "$numA <= $numB = " $((numA <= numB))
echo "$numA == $numB = " $((numA == numB))
echo "$numA != $numB = " $((numA != numB))

echo "======================================================="
# Operadores de asignación entra numA y numB

echo "Operadores de asignación con los valores $numA y $numB"
echo "$numA += $numB = " $((numA += numB))
echo "$numA -= $numB = " $((numA -= numB))
echo "$numA *= $numB = " $((numA *= numB))
echo "$numA /= $numB = " $((numA /= numB))
