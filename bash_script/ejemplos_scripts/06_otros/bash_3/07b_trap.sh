#!/bin/bash

## VARIABLES
cont=1

## FUNCIONES

# Atrapar señal <Ctrl>+<c>: SIGINT (2)
function control_c()
{
  echo -e "\n<Ctrl>+<c> ... Parece que no"
  cont=$(($cont+1))
}

# Atrapar señal <Ctrl>+<z>: SIGTSTP (20)
function control_z()
{
  echo -e "\n<Ctrl>+<z> ... Parece que no"
  cont=$(($cont+1))
}

## main() 
trap control_c SIGINT # Ejecuta la función control_c como acción para la señal SIGINT 
trap control_z SIGTSTP # Ejecuta la función control_z como acción para la señal SIGTSTP

while [ $cont -lt 3 ]
do
  read x
  echo $x
done
