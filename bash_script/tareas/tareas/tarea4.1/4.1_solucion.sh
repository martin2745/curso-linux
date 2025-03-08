#!/bin/bash
if [[ $# -ne 1 ]]
then
  echo "Uso: ./$0 archivo"
elif [[ ! -f $1 ]] #Compruebo si el archivo es regular
then
  echo "$1 no existe o no es un archivo regular"
elif [[ ! -r $1 ]] #Compruebo que se puede leer
then
  echo "$1 no tiene permiso de lectura"
else
  url=$(cat $1)
  if [[ $url == "" ]]
  then
    echo "El archivo $1 no contiene una URL"
  else
    respuesta=$(nslookup $url)
    # ¡Ojo! Si ahora ponemos echo $respuesta sin comillas devolverá todo en una sola línea!
    # Alternativa con cut
    #ip1=$(echo "$respuesta" | grep "Address" | head -2 | tail -1 | cut -d " " -f 2)
    #ip2=$(echo "$respuesta" | grep "Address" | head -3 | tail -1 | cut -d " " -f 2)
    # Alternativa con awk
    ip1=$(echo "$respuesta" | grep "Address"  | head -2 | tail -1 | awk -F" " '{print $2}')
    ip2=$(echo "$respuesta" | grep "Address"  | head -3 | tail -1 | awk -F" " '{print $2}')
    cabecera=$(echo $ip2 | cut -d ":" -f 1)
    if [[ $cabecera == "fe80" ]]
    then
      echo "La IP $ip2 es de tipo enlace local"
    else
      echo "La IPv4 es ${ip1} y la IPv6 es ${ip2}."
    fi
  fi
fi

# Alternativa con expresiones regulares
# Por ejemplo, para IPv4:
# grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | grep -v ^127`; 
# y para IPv6:
# egrep -o '(([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4})' | grep -v '^[e:]'`;
