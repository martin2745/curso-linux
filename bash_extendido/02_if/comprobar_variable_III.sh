 #!/bin/bash
# Author: Martín Gil Blanco

# Devuelve True cuando la variable no existe o tiene contenido 

variable=""

if [ ${variable-unset} ]
then
	echo "La variable no existe o no tiene contenido"
else
	echo "La variable existe"
fi
