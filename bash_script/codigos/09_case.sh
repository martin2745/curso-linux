#!/bin/bash
read -p "Introduce tu nota para ver si has aprobado: " nota

case ${nota} in
    9|10)
        echo "Has sacado un ${nota}, tienes un sobresaliente";;
    7|8)
        echo "Has sacado un ${nota}, tienes un notable";;
    6)
        echo "Has sacado un ${nota}, tienes un bien";;
    5)
        echo "Has sacado un ${nota}, has aprobado";;
    [0-4])
        echo "Has sacado un ${nota}, has suspendido";;
    *)
        echo "Nota incorrecta"
esac