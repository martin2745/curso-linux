#!/bin/bash

echo "Dime tu nombre: "
read nombre
echo -e "Hola ${nombre}\n"

read -p "Dime tu primer apellido: " apellido
echo "Hola ${nombre} ${apellido}"

