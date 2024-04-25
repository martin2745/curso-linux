#!/bin/bash
contador=1
while [ $contador -lt 10 ]; do
    contador=$((contador+1))
    who>>usuarios.log
    sleep 2m
done