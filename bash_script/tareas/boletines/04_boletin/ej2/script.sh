#!/bin/bash

while read linea; do
        USERS=$(echo ${linea} | cut -d ':' -f1)
        HOMES=$(echo ${linea} | cut -d ':' -f6)
        SHELLS=$(echo ${linea} | cut -d ':' -f7)
        HACTIVO=$(echo /home/alumno-15-16/${USERS})
        SACTIVO=$(echo /bin/bash)
        INACTIVO=$(echo /bin/false)
        if [ ${SHELLS} = ${INACTIVO} ]; then
                echo "${USERS}. Usuario inactivo, se borra su cuenta."
                userdel -r ${USERS}
        elif [ ${HOMES} = ${HACTIVO} -a ${SHELLS} = ${SACTIVO} ]; then
                echo "${USERS}. Usuario activo, copiando su /HOMES en /var/tmp/${USERS}"
                tar cvfz /var/tmp/${USERS}.tar.gz ${HACTIVO}
        else
                echo "${USERS}. Usuario no matriculado"
        fi
done < /etc/passwd.txt