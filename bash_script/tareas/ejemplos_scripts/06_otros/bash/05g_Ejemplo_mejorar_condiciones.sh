#!/bin/bash                             

## Las variables declaradas como "enteros" en Bash están limitadas al rango de números enteros de:
#### 32 bits: desde -2147483648 hasta 2147483647 (-2^31 hasta 2^31 - 1)
#### 64 bits: desde -9223372036854775808 hasta 9223372036854775807 (-2^63 hasta 2^63 - 1)

echo Dame un número                     # Pedimos un número
read n1                                 # Lo que se introduce por teclado se guarda como variable n1
[[ $n1 =~ ^-?[0-9]+$ ]] &&              # Con los dobles corchetes y mediante expresión regular verificamos si la variable n1 es un número entero:
                                        ## ^      -> Indica el inicio de la cadena n1
                                        ## -?     -> Si coincide con un signo negativo o no existe signo
                                        ## [0-9]+ -> Coincide con 1 o más dígitos del 0 al 9
                                        ## $      -> Indica el final de la cadena.
                                        ## && -> Equivale a then
   [ $(uname -m) = 'x86_64' -a $n1 -ge -9223372036854775808 -a $n1 -le 9223372036854775807 ] 2>/dev/null ||  ## If anidado con corchetes simples y and (-a). Solo es verdadero si se cumplen todas las condiciones. Además mediante || también se valida otra condición/s siendo || equivalente a or. Así, o se cumplen las condiciones de la línea 20 o se deben cumplir las condiciones de la línea 26. A mayores, si no se cumplen las condiciones, enviamos la salida estándar de los mensajes de error (stderr) al dispositivo especial /dev/null para descartarlos.

    ## Condición1: $(uname -m) = 'x86_64'
    ## -a -> and
    ## Condición2: $n1 -ge -9223372036854775808 
    ## -a -> and
    ## Condición3: $n1 -le 9223372036854775807

   [ $n1 -ge -2147483648 -a  $n1 -le 2147483647 ] 2>/dev/null && 

    ## Condición4: $n1 -ge -2147483648
    ## -a -> and
    ## Condición5: $n1 -le 2147483647
    ## 2>/dev/null -> Descartar la salida estándar de los mensajes de error (stderr) al dispositivo especial /dev/null para descartarlos.
    ## && -> Equivale a then, lo que quiere decir que si se cumplieron las condiciones de la línea 20 o las de la línea 26

                                          # ( )   -> Equivale a ejecutarse en una subshell
    (                                     # Así ( -> Comienza la ejecución del código "then"
      [ $n1 -lt 100 ] && echo El número $n1 es menor que 100 || ( [ $n1 -gt 100 ] && echo El número $n1 es mayor que 100 ||  echo El número $n1 es igual a 100 )

      # [ ] -> Equivale a if
      # &&  -> Equivale a then
      # ||  -> Equivale a else
      # ( ) -> Equivale a ejecutarse en una subshell

      # [ $n1 -lt 100 ]                       # Inicio Condición: Si el valor de n1 es menor que 100
      # &&                                    # entonces
        # echo El número $n1 es menor que 100  # Muestra en pantalla un mensaje
      # ||                                    # sino

        # ( [ $n1 -gt 100 ] && echo El número es mayor que 100 ||  echo El número $n1 es igual a 100 ) -> Ejecución en una subshell la Condición-2

          # (                                 # Inicio subshell
          # [ $n1 -gt 100 ]                   # Inicio Condición-2: Si el valor de n1 es mayor que 100
          # &&                                # entonces
          # echo El número $n1 es mayor que 100 # Muestra en pantalla un mensaje
          # ||                                # sino
          # echo El número $n1 es igual a 100   # Muestra en pantalla un mensaje y Fin Condición-2
          # )                                 # Fin subshell y Fin Condición
    ) || (echo $? && echo 'Se solicitó un número')     # )   -> Finaliza la ejecución del código "then"
                                          # ||  -> Equivale a else
                                          ## echo $? && echo -> Mostramos la existencia del error mostrando el valor de $? y si lo introducido no es un número entero se muestra el mensaje: Se solicitó un número
