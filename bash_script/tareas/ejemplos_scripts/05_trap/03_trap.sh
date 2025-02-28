#!/bin/bash

##VARIABLES
cont=1

##FUNCIONES

#Atrapar señal <Ctrl>+<c>: SIGGINT (2)
function control_c(){
	echo -e "\n<Ctrl>+<c> ... Va ser que no"
	cont=$(($cont+1))
}

#Atrapar señal <Ctrl>+<z>: SIGTSTP (20)
function control_z(){
	echo -e "\n<Ctrl>+<z> ... Va ser que no"
	cont=$(($cont+1))
}


##main()
trap control_c SIGINT #Ejecuta la función control_c como acción para l siñal SIGINT
trap control_z SIGTSTP #Ejecuta la función control_z como acción para la siñal SIGSTP

while [ $cont -lt 3 ]; do
	echo "cont vale: ${cont}"
	read -p "Introduce valor para x: " x
	echo $x
done
