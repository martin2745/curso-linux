#!/bin/bash -x

# Depuramos el contenido del script con -v o -x
numero=$((${RANDOM}%11))
if [ $((${numero}%2)) -eq 0 ]; then
    echo "El ${numero} es par"
else
    echo "El ${numero} no es par"
fi

# Ejecuciones si no ponemos arriba -xv
# $ /bin/bash -v ./11_depurar.sh
# $ /bin/bash -x ./11_depurar.sh