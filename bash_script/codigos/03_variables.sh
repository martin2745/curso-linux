#!/bin/bash
v1="Hola"
echo "La variable guardada es ${v1}"

# Variables que indican información
echo "Nombre del script en uso ${0} y lo está ejecutando ${USER}"
echo "PID del proceso asignado al script en ejecución ${$}"
echo "Resultado devuelto por el último proceso ejecutado ${?}"
echo "Variable PATH: ${PATH}"

# Uso de las "" y las ''
echo "Vemos que interpretamos con \" correctamente v1: ${v1}"
echo 'Sin embargo, con comilla simple no se interpreta correctamente ${v1}'