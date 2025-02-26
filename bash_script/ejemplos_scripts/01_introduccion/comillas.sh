#!/bin/bash

a=ls

echo $'${a}'	# Muestra el contenido ${a} sin interpretar
echo $"${a}"	# Muestra ls porque interpreta la variable
echo `${a}`	# Lanza el comando ls
