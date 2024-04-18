#!/bin/bash

# Tambien se puede crear la función de la siguiente forma --> function usuario { ...
# En cualquier caso, no tienen parametros y accedemos a ellos con ${1}, ${2} ...

usuario(){
	read -p "Dime el usuario para hacer backup de su directorio home: " usuario
	backup
}

backup(){
	if [  -d /home/${usuario} ]; then
		echo "Existe directorio /home/${usuario} para el ${usuario}"
		tar cvzf backup.tar.gz /home/${usuario} &> /dev/null
		# Si quisieramos que la salida del comando no se muestre por pantalla sería:
		# tar cvzf backup.tar.gz /home/${usuario} &>/dev/null

	else
		echo "El usuario ${usuario} no presenta un directorio en /home"
		usuario
	fi
}

usuario
