#!/bin/bash

echo "Nombre del script ${0}"
echo "Primer parametros que recibo ${1} y segunda parametros ${2}"
echo "Número total de parametros pasados al script ${#}"
echo "Lista de parametros del script pasados por el usuario ${*}"
echo "Identificador del proceso (PID) ${$}"
echo "Salida de ejecución del útimo comando (exito=0|fracaso!=0) ${?}"
