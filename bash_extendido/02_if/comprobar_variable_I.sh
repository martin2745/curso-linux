 #!/bin/bash
# Author: Martín Gil Blanco

# Comprobamos si existe la variable y si tiene contenido 

variable=""

if [ $variable ]
then
	echo "Existe la variable"
else
	echo "La variable no existe o no tiene contenido"
fi
