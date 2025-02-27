#!/bin/bash                             

echo Opción1. Ver directorio actual     # Muestra por pantalla
echo Opción2. Leer /tmp                 # Muestra por pantalla
echo Opción3. Salir                     # Salir
echo Elige opción: 1, 2, 3?              # Escoger opción
read opcion                             # La opción escogida se guarda como valor en la variable opcion
case $opcion in                         # Comienzo case para hacer menú
1) pwd                                  # Si el valor de la variable opcion es 1 se ejecutan los siguientes comandos.
   ;;                                   # Toda opción debe acabar con ;;
2) ls /tmp                              # Si el valor de la variable opcion es 2 se ejecutan los siguientes comandos.
   ;;                                   # Toda opción debe acabar con ;;
3) exit                                 # Si el valor de la variable opcion es 3 se ejecutan los siguientes comandos.
   ;;                                   # Toda opción debe acabar con ;;
*) echo No elegiste ni 1, 2, ni 3       # Mensaje por pantalla
   ;;                                   # Toda opción debe acabar con ;;
esac                                    # Fin case para hacer menú
