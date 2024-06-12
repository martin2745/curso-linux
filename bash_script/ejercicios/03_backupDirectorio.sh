#!/bin/bash

function f_directorio(){
	read -p "Introduce la ruta de un directorio para hacer backup: " directorio
	f_backup
}

function f_backup(){
	if test -d ${directorio}
	then
		echo "Existe el directorio ${directorio}"
		tar cvfj backupDirectorio.tar.bz2 ${directorio} &> /dev/null
		echo "..."
		echo "Archivo backupDirectorio.tar.bz2 generado"
	else
		echo "No existe el directorio ${directorio}"
	fi
}

f_directorio