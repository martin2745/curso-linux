#!/bin/bash             

suma() {                # Definimos la función suma
echo Dame un número      # Pedimos un número
read n1                 # Recogemos el número como valor en la variable n1
echo Dame otro número   # Pedimos otro número
read n2                 # Recogemos el número como valor en la variable n2
echo La suma de $n1 y $n2 es: $(($n1+$n2)) # Realizamos la suma
}                       # Finaliza la definición de la función suma
suma                    # Llamamos a la función suma