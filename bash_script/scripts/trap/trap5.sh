#!/bin/bash

#VARIABLES
cont=1

#FUNCIONES

##Atrapar sinais:
#### <Ctrl>+<c>: SIGGINT (2)
#### <Ctrl>+<z>: SIGTSTP (20)

control_c_z(){
	echo -e "\n<Ctrl>+<c> ou <Ctrl>+<z>... Va ser que no"

	cont=$((cont+1))

	echo "El valor de cont es: ${cont}"

	if [ $cont -eq 3 ]; then
		VAR='sair'
	fi
}

trap control_c_z 2 20

until [ "$VAR" = 'sair' ]; do
	read -p "Introduce valor para x: " x
	echo $x
done
