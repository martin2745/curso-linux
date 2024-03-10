#!/bin/bash

# En este ejercicio vamos a mostrar información de los estudiantes del grupo alumnos
# El espacio usado por su directorio personal
# Saber si está el usuario logueado en el sistema y en caso constrario, conocer
# la última vez que lo hizo
# Este script tiene que ser ejecutado por Root

#Elimina el grupo alumnos y los estudiantes
function reset {
    delgroup alumnos &> /dev/null

    for i in $(seq 1 5); do
        userdel -r estudiante${i} &> /dev/null 
        delgroup estudiante${i} &> /dev/null
    done
}

function comprueba_whois {
    if ! [ -e $(which whois) ]; then
        echo "...Instalando Whois..."
        apt update &> /dev/null
        apt install -y whois &> /dev/null
    fi
}

function crear_usuarios {
    if [ $(id -u) -ne 0 ]; then
        echo "Usted está logueado como ${USER}"
        echo "Este script tiene que ser ejecutado por root"
    else
        reset
        comprueba_whois
        echo -e "\n...Creando grupo alumnos..."
        addgroup alumnos &> /dev/null

        echo -e "\n...Creando 5 estudiantes para el grupo alumnos..."
        for i in $(seq 1 5); do
            echo "...Creando estudiante${i}..."
            addgroup estudiante${i} &> /dev/null
            useradd -d /home/estudiante${i} -m -s /bin/bash -g estudiante${i} -G alumnos -p "$(mkpasswd 'abc123.')" estudiante${i} &> /dev/null
        done

        echo -e "\nProceso terminado"
        # reset
    fi
}

function info_usuarios {
    guid=$(egrep ^alumnos:* /etc/group | cut -d":" -f3)
    echo "guid ${guid}"
}

crear_usuarios
info_usuarios