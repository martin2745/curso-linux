#!/bin/bash

# VARIABLES
cont=1

# FUNCIONES

## Atrapar señales:
#### <Ctrl>+<c>: SIGINT (2)
#### <Ctrl>+<z>: SIGTSTP (20)
control_c_z()
{
  echo -e "\n<Ctrl>+<c> o <Ctrl>+<z>... Parece que no"
  cont=$((cont+1))
  if [ $cont -eq 3 ]; then
    VAR='salir'
  fi
}

trap control_c_z 2 20
while [ "$VAR" != 'salir' ]
do
  read x
  echo $x 
done
