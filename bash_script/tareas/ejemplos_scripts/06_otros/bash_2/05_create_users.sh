#!/bin/bash

##VARIABLES
ARCHIVO='create-users.csv'
ARCHIVOTEMPORAL=$(mktemp)
ARCHIVODELOG='/var/log/usuarios.log'
FECHA=$(date)

##FUNCIONES
function f_ayuda(){
  clear
  echo Ejecución errónea: Se espera 1 parámetro para la correcta ejecución del script
  echo Ejemplo de ejecución:
  echo "bash $0 create-users.csv  #Parámetro1 = Archivo csv para creación de usuarios"
  exit 55
}

function f_control_errores(){
  [ $# -ne 1 ] && f_ayuda
}

function f_quitar(){
  rm -f ${ARCHIVOTEMPORAL}
}

function f_mensaje(){
  echo $* >> ${ARCHIVODELOG}
}

function f_comprobar_grupo(){
  grep $1 /etc/group >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    groupadd ${GRUPO}
  fi
}

function f_ejecutar(){
  f_mensaje "Log creado en ${FECHA}"

  tail -n +2 $ARCHIVO > ${ARCHIVOTEMPORAL}
  while read LINEA
  do
    NOMBRE=$(echo ${LINEA} | cut -d';' -f1)
    PASSWORD=$(echo ${LINEA} | cut -d';' -f2)
    GRUPO=$(echo ${LINEA} | cut -d';' -f3)
    ACTIVO=$(echo ${LINEA} | cut -d';' -f4)

    f_comprobar_grupo ${GRUPO}

    grep ${NOMBRE} /etc/passwd >/dev/null 2>&1
    if [ $? -ne 0 ]; then
      useradd -m -d /home/${NOMBRE} -p $(mkpasswd -m sha-512 ${PASSWORD}) -g ${GRUPO} ${NOMBRE}
      [[ ${ACTIVO} =~ ^[nN]$ ]] && usermod -L ${NOMBRE}
    else
      f_mensaje "El usuario ${NOMBRE} ya existe en el sistema"
    fi
  done<${ARCHIVOTEMPORAL}
}

function f_main(){
  clear
  f_control_errores $*
  f_ejecutar
  f_quitar
}


##main()
f_main $*
