#!/bin/bash

oldIFS=${IFS}
IFS=$'\n'

RUTA='/tmp/renombrar'

for i in $(ls "${RUTA}"); do
        A=$(echo ${i} | tr -d ' ')
        mv "${RUTA}/${i}" "${RUTA}/${A}"
        echo ${A} | grep 'volB' &>/dev/null

        if [ $? -eq 0 ]; then
                B=$(echo ${RUTA}/${A} | cut -d '_' -f2,3)
                mv "${RUTA}/${A}" ${RUTA}/entregado_${B}
        fi
done

IFS=${oldIFS}