#!/bin/bash
# Author: Martín Gil Blanco

# Pedimos nombre de usuario

echo "¿Cómo te llamas?"
read nombre
echo "Hola, $nombre, mucho gusto"

###################################################################

echo "¿Cómo te llamas?"
read
echo "Hola, $REPLY, mucho gusto"

###################################################################

read -p "¿Cómo te llamas? " nombre
echo "Hola, $nombre, mucho gusto"

###################################################################

read -d " " -p "¿Cómo te llamas? " nombre
echo "Hola, $nombre, mucho gusto"

###################################################################

read -d "x" -n 1 -t 5 -p "Pulsa x para salir del sistema o espera 5 segundos: "
echo ""
echo "Hasta luego, $nombre"
