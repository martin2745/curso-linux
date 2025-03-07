#!/bin/bash

# Realizar un script que por 10 veces guarde cada 2 minutos los usuarios conectados en el sistema en el archivo `usuarios.log`.  

contador=1
while [ $contador -lt 10 ]; do
    contador=$((contador+1))
    who>>usuarios.log
    sleep 2m
done