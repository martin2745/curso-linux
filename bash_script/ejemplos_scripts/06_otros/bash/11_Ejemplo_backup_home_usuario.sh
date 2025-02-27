#!/bin/bash             


inicio() {              # Definimos la función inicio
echo Dame usuario       # Mensaje por pantalla
read user               # Recogemos el usuario como valor en la variable user
testear                 # Llamamos a la función testear
}                       # Finaliza la definición de la función inicio
testear() {             # Definimos la función testear
if test -d /home/$user  # Comienza condición: Si existe el directorio /home/$user
then                    # entonces
    echo El directorio /home/$user existe     # Mensaje por pantalla
    tar -czvf /home/$user                    # Comando incorrecto para: Empaquetar-Comprimir el directorio /home/$user
    # # tar -czvf $user-backup.tar.bz2 /home/$user    # Comando correcto para: Empaquetar-Comprimir el directorio /home/$user
else                    # si no
    echo El directorio /home/$user no existe # Mensaje por pantalla
    echo El contenido de /home es el siguiente `ls /home` # Muestra el directorio /home para escoger bien el usuario
    inicio                                   # Llamamos a la función inicio
fi                      # Finaliza Condición
}                       # Finaliza la definición de la función testear
inicio                  # Llamamos a la función inicio
