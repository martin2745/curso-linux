#!/bin/bash

##VARIABLES
FILE='create-users.csv'
TEMPFILE=$(mktemp)
LOGFILE='/var/log/usuarios.log'
DATA=$(date)

##FUNCIONS
function f_help(){
  clear
  echo Execución errónea: Espérase 1 parámetro para a correcta execución do script
  echo Exemplo execución:
  echo "bash $0 create-users.csv  #Parámetro1 = Ficheiro csv para creación de usuarios"
  exit 55
}

function f_control_erros(){
  [ $# -ne 1 ] && f_help 
}

function f_remove(){
  rm -f ${TEMPFILE}
}

function f_message(){
  echo $* >> ${LOGFILE}
}

function f_comprobe_group(){
  grep $1 /etc/group >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    groupadd ${GRUPO}
  fi
}

function f_execute(){
  f_message "Log creado en ${DATA}" 

  tail -n +2 $FILE > ${TEMPFILE}
  while read LINE
  do
    NOME=$(echo ${LINE} | cut -d';' -f1)
    CONTRASINAL=$(echo ${LINE} | cut -d';' -f2)
    GRUPO=$(echo ${LINE} | cut -d';' -f3)
    ACTIVO=$(echo ${LINE} | cut -d';' -f4)

    f_comprobe_group ${GRUPO}

    grep ${NOME} /etc/passwd >/dev/null 2>&1
    if [ $? -ne 0 ]; then
      useradd -m -d /home/${NOME} -p $(mkpasswd -m sha-512 ${CONTRASINAL}) -g ${GRUPO} ${NOME}
      [[ ${ACTIVO} =~ ^[nN]$ ]] && usermod -L ${NOME}
    else
      f_message "O usuario ${NOME} xa existe no sistema"
    fi
  done<${TEMPFILE}
}

function f_main(){
  clear
  f_control_erros $*
  f_execute
  f_remove
}


##main()
f_main $*
