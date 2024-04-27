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
# Ejecuta el script en modo verbose (-v), mostrando cada línea de código a medida que se ejecuta, útil para entender el flujo de ejecución y detectar problemas.

# $ /bin/bash -x ./11_depurar.sh 
# Ejecuta el script en modo debug (-x), mostrando cada comando y su expansión, útil para rastrear problemas de ejecución o entender cómo se evalúan las variables y comandos.

# $ /bin/bash -n ./11_depurar.sh
# Realiza un chequeo de sintaxis (-n) en el script sin ejecutarlo, útil para detectar problemas de sintaxis antes de la ejecución del script.
