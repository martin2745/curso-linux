#!/bin/bash                             # Línea necesaria para saber qué shell ejecutará el script


echo "Dame un número"                   # Pedimos un número
read n1                                  # Lo que se introduce por teclado se guarda como variable n1
if test $n1 -lt 100                      # Inicio Condición: Si el valor de n1 es menor que 100
then                                     # entonces
    echo "El número $n1 es menor que 100"  # Muestra en pantalla un mensaje
else                                     # sino
    echo "El número $n1 es mayor que 100"  # Muestra en pantalla un mensaje
fi                                       # Fin Condición
