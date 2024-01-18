 #!/bin/bash
# Author: Martín Gil Blanco

# En caso de no existir la variable o no contener nada devuelve True 

variable=""

if [ -z $variable ]
then
	echo "La variable no existe o no tiene contenido"
else
	echo "La variable existe"
fi

echo "=================================================="

if [ ! -z $variable ]
then
	echo "La variable existe"
else
        echo "La variable no existe o no tiene contenido"
fi
