#!/bin/bash                             # Línea necesaria para saber qué shell ejecutará el script

echo "Dame un número"                   # Pedimos un número
read n1                                  # Lo que se introduce por teclado se guarda como variable n1
[ $n1 -lt 100 ] && echo "El número $n1 es menor que 100" || ( [ $n1 -gt 100 ] && echo "El número $n1 es mayor que 100" || echo "El número $n1 es igual a 100" )

# [ ] -> Equivale a if
# &&  -> Equivale a then
# ||  -> Equivale a else
# ( ) -> Equivale a ejecutarse en una subshell

# [ $n1 -lt 100 ]                       # Inicio Condición: Si el valor de n1 es menor que 100
# &&                                    # entonces
  # echo "El número $n1 es menor que 100"   # Muestra en pantalla un mensaje
# ||                                    # sino

  # ( [ $n1 -gt 100 ] && echo "El número es mayor que 100" || echo "El número $n1 es igual a 100" ) -> Ejecución en una subshell de la Condición-2

    # (                                 # Inicio subshell
    # [ $n1 -gt 100 ]                   # Inicio Condición-2: Si el valor de n1 es mayor que 100
    # &&                                # entonces
    # echo "El número $n1 es mayor que 100" # Muestra en pantalla un mensaje
    # ||                                # sino
    # echo "El número $n1 es igual a 100"   # Muestra en pantalla un mensaje y Fin Condición-2
    # )                                 # Fin subshell y Fin Condición
