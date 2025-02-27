#!/bin/bash             


inicio() {              # Definimos la función inicio
echo Dame carpeta      # Mensaje por pantalla
read carpeta           # Recogemos lo escrito como valor en la variable carpeta
testear                 # Llamamos a la función testear
}                       # Finaliza la definición de la función inicio
testear() {             # Definimos la función testear
if test -d $carpeta    # Comienza Condición: Si existe el directorio $carpeta
then                    # entonces,
    echo El directorio $carpeta existe      # Mensaje por pantalla
    tar -czvf $carpeta                     # # Comando incorrecto para: Empaquetar y comprimir el directorio $carpeta
    # # tar -czvf $carpeta-backup.tar.bz2 $carpeta    # # Comando correcto para: Empaquetar y comprimir el directorio $carpeta
else                    # si no
    echo El directorio $carpeta no existe  # Mensaje por pantalla
    inicio                                  # Llamamos a la función inicio
fi                      # Finaliza la condición
}                       # Finaliza la definición de la función testear
inicio                  # Llamamos a la función inicio