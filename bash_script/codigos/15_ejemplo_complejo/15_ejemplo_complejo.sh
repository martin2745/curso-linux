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
            $(dd if=/dev/zero of=/home/estudiante${i}/ficheroZeros.img bs=4M count=1 &>/dev/null) # Creo contenido dentro del directorio de trabajo del usuario
        done
        # reset
    fi
}

function info_usuarios {
    guid=$(egrep ^alumnos:* /etc/group | cut -d":" -f3)
    echo "${guid}"
    usuarios=$(egrep ^alumnos:* /etc/group | cut -d":" -f4 | sed "s/,/ /g") # Array de usuarios
    for u in ${usuarios}; do
        echo -e "\n\nUSUARIO: ${u}"
        echo -e "\tEl usuario ${u} tiene como información de usuario:"
        echo -e "\t$(id ${u})"
        echo -e "\tPertenece a los grupos $(groups ${u})"
        echo -e "\tEn su directorio de trabajo hay tiene: "
        echo -e "\t$(du -h /home/${u})"

    done
}

crear_usuarios
info_usuarios
echo -e "\nProceso terminado"