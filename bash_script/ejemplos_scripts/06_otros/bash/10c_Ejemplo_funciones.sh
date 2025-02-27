#!/bin/bash             

suma() {                # Definimos la función suma
echo Dame un número      # Pedimos un número
read n1                 # Recogemos el número como valor en la variable n1
echo Dame otro número   # Pedimos otro número
read n2                 # Recogemos el número como valor en la variable n2
echo La suma de $n1 y $n2 es: $(($n1+$n2)) # Realizamos la suma
}                       # Finaliza la definición de la función suma
suma                    # Llamamos a la función suma definida antes de la llamada en las líneas 9 y 15

echo -------------------
sleep 3
echo -------------------

function suma() {       # Definimos de nuevo la función suma, pero ahora hará una multiplicación
echo Dame un número      # Pedimos un número
read n1                 # Recogemos el número como valor en la variable n1
echo Dame otro número   # Pedimos otro número
read n2                 # Recogemos el número como valor en la variable n2
echo La multiplicación de $n1 x $n2 es: $(($n1*$n2)) # AHORA HACEMOS UNA MULTIPLICACIÓN Y NO UNA SUMA
}                       # Finaliza la definición de la función suma
suma                    # Llamamos a la función suma definida antes de la llamada en las líneas 22 y 28
