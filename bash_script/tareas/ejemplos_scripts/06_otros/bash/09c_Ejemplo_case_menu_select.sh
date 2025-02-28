#!/bin/bash                             

PS3='Elige opción:1,2,3? '              # Definir el valor de la variable PS3 para establecer el prompt del comando select.
OPCION1='Ver directorio actual'         # Definir la variable OPCION1 con el valor de la primera opción del menú.
OPCION2='Leer /tmp'                      # Definir la variable OPCION2 con el valor de la segunda opción del menú.
OPCION3='Salir'                          # Definir la variable OPCION3 con el valor de la tercera opción del menú.

select opcion in "${OPCION1}" "${OPCION2}" "${OPCION3}"         # Inicia el bucle select con las opciones definidas
do 
  case ${opcion} in                         # Comienzo case para hacer menú
    ${OPCION1}) pwd                           # Si el valor de la variable opcion es el valor de la variable OPCION1 (Ver directorio actual) se ejecutan los siguientes comandos.
       break                                  # Sale del bucle luego de ejecutar la opción 1. 
       ;;                                     # Toda opción debe acabar con ;;
    ${OPCION2}) ls /tmp                       # Si el valor de la variable opcion es el valor de la variable OPCION2 (Leer /tmp) se ejecutan los siguientes comandos.
       break                                  # Sale del bucle luego de ejecutar la opción 2.
       ;;                                     # Toda opción debe acabar con ;;
    ${OPCION3}) exit                          # Si el valor de la variable opcion es el valor de la variable OPCION3 (Salir) se ejecutan los siguientes comandos.
       ;;                                     # Toda opción debe acabar con ;;
    *) echo No elegiste ni 1,2,3              # Mensaje por pantalla en caso de no elegir una de las opciones anteriores
       ;;                                     # Toda opción debe acabar con ;;
  esac                                      # Fin case para hacer menú
done                                        # Finaliza el bucle select.