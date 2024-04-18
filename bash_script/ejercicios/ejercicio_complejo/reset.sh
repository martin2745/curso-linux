#!/bin/bash

function reset {
    delgroup alumnos &> /dev/null

    for i in $(seq 1 5); do
        userdel -r estudiante${i} &> /dev/null 
        delgroup estudiante${i} &> /dev/null
    done
}

if [ $(id -u) -ne 0 ]; then
    echo "Usted está logueado como ${USER}"
    echo "Este script tiene que ser ejecutado por root"
else
    reset
fi