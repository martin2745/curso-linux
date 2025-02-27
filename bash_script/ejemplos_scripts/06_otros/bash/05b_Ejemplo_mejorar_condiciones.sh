#!/bin/bash                             


echo "Dame un número"                   # Pedimos un número
read n1                                  # Lo que se introduce por teclado se guarda como variable n1
if test $n1 -le 100                      # Inicio Condición: Si el valor de n1 es menor o igual a 100
then                                     # entonces
    if test $n1 -lt 100 ;then            # Inicio Condición-2: Si el valor de n1 es menor que 100
      echo "El número $n1 es menor que 100" # Muestra en pantalla un mensaje
    else                                  # sino
      echo "El número es igual a 100"    # Muestra en pantalla un mensaje
    fi                                    # Fin Condición-2
else                                      # sino
    echo "El número $n1 es mayor que 100" # Muestra en pantalla un mensaje
fi                                        # Fin Condición
