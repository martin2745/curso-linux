#!/bin/bash
# Author: Martín Gil Blanco

# Uso de variables y parámetros dinámicos

nombre=$1
apellido=$2
ubicacion=$(pwd)
echo "El usuario $nombre $apellido, está en la ubicación: $ubicacion"
echo "La cantiadad de parámetros que recibe el script son: $#"
echo "Los parametros enviados por el usuario son: $*"
