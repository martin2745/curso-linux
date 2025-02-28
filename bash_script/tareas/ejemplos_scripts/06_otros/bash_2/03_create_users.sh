#!/bin/bash

##VARIABLES
ARCHIVO="$1"
ARCHIVOTEMPORAL=$(mktemp)
ARCHIVODELOG='/var/log/usuarios.log'
FECHA=$(date)

##main()
clear
echo "Log creado en ${FECHA}" >> ${ARCHIVODELOG}

tail -n +2 $ARCHIVO > ${ARCHIVOTEMPORAL}
cat ${ARCHIVOTEMPORAL} | while read LINEA
do
  NOMBRE=$(echo ${LINEA} | cut -d';' -f1)
  PASSWORD=$(echo ${LINEA} | cut -d';' -f2)
  GRUPO=$(echo ${LINEA} | cut -d';' -f3)
  ACTIVO=$(echo ${LINEA} | cut -d';' -f4)

  grep ${GRUPO} /etc/group >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    groupadd ${GRUPO}
  fi

  grep ${NOMBRE} /etc/passwd >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    useradd -m -d /home/${NOMBRE} -p $(mkpasswd -m sha-512 ${PASSWORD}) -g ${GRUPO} ${NOMBRE}
    [[ ${ACTIVO} =~ ^[nN]$ ]] && usermod -L ${NOMBRE}
  else
    echo "El usuario ${NOMBRE} ya existe en el sistema" >> ${ARCHIVODELOG}
  fi
done

rm -f ${ARCHIVOTEMPORAL}
