#!/bin/bash

# Tambien se puede crear la función de la siguiente forma --> function usuario { ...
# En cualquier caso, no tienen parametros y accedemos a ellos con ${1}, ${2} ...

function f_usuario() {
	read -p "Dime el usuario para hacer backup de su directorio home: " usuario
	f_backup
}

function f_backup(){
	if [  -d /home/${usuario} ]; then
		echo "Existe directorio /home/${usuario} para el ${usuario}"
		tar cvzf backup.tar.gz /home/${usuario} &> /dev/null
	else
		echo "El usuario ${usuario} no presenta un directorio en /home"
		f_usuario
}

f_usuario