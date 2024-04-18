#!/bin/bash

echo "Dame un número: " 			# Pedimos un número
read n1 					# Lo que se introduce por teclado se guarda como la variable n1
if test $n1 -le 100 				# Inicio de la condición: Si el valor de n1 es menor o igual que 100
then 						# entonces
    if test $n1 -lt 100; then 			# Inicio de la condición-2: Si el valor de n1 es menor que 100
        echo "El número ${n1} es menor que 100" # Muestra por pantalla un mensaje
    else 					# sino
        echo "El número ${n1} es igual a 100" 	# Muestra por pantalla un mensaje
    fi 						# Fin de la condición-2
else 						# sino
    echo "El número ${n1} es mayor que 100" 	# Muestra por pantalla un mensaje
fi 						# Fin de la condición
