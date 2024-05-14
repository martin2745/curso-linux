#!/bin/bash

##VARIABLES
cont=1

##FUNCIÓNS

#Atrapar sinal <Ctrl>+<c>: SIGGINT (2)
function control_c()
{
  echo -e "\n<Ctrl>+<c> ... Vai ser que non"
  cont=$(($cont+1))
}

#Atrapar sinal <Ctrl>+<z>: SIGTSTP (20)
function control_z()
{
  echo -e "\n<Ctrl>+<z> ... Vai ser que non"
  cont=$(($cont+1))
}


##main() 
trap control_c SIGINT #Executa a función control_c como acción para o sinal SIGINT 
trap control_z SIGTSTP #Executa a función control_z como acción para o sinal SIGSTP

while [ $cont -lt 3 ]
do
  read x
  echo $x
done
