#!/bin/bash
# Author

# Trabajo con subcadenas de texto

cadena="Santiago es la capital de Galicia"
subcadena="G"

posicion=$(expr index "$cadena" "$subcadena")
echo "Posición de G: $posicion" # Posición 27 
echo "Posición en formato array de G: $(( $posicion -1 ))"

# Queremos trabajar con el nombre del fichero y la extensión por separado
fichero="imagen.jpg"
nombre=${fichero%%.*}
extension=${fichero##*.}
echo "El fichero $fichero tiene el nombre: $nombre y la extensión: $extension."

################ Trabajar con posiciones en las cadenas####################

tres_caracteres=${cadena:0:3} 
echo "Primeros tres caracteres: $tres_caracteres"
# echo ${cadena:X:Y} Extraer subcadena de X caracteres de X 
# caracteres desde la posición Y

# Indico punto de inicio y al no poner Y significa que toma el contenido
# hasta el final.
subcadena_dos=${cadena:9}
# echo "Santiago $subcadena_dos"

sin_ccaa=${subcadena_dos%% Galicia*}
echo "Barcelona $sin_ccaa Cataluña"

############### Recorrer caracter por caracter una subcadena #############

echo "Recorrer la cadena y mostrarla por pantella:"
for (( pos=0; pos<${#cadena}; pos++))
do
	echo -n "${cadena:$pos:1}"
	sleep 0.01
done

echo ""
