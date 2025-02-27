#!/bin/bash             


echo "Dame tu nombre"    # Pedimos el nombre del usuario
read nombre                # Lo que se introduce por teclado se guarda como variable nombre
echo "Hola $nombre"        # Mostramos en pantalla Hola y el contenido de la variable nombre

read -p 'Dame tu nombre: ' nombre   # Pedimos el nombre del usuario y lo que se introduce por teclado se guarda como variable nombre
echo "Hola $nombre"                # Mostramos en pantalla Hola y el contenido de la variable nombre
