#!/bin/bash
sudo apt-get install -y net-tools nmap
clear
echo "0: Salir"
echo "1: Operaciones con usuarios, grupos, disco y memoria"
echo "2: Operaciones de red"
echo -n "Introduzca la opción deseada: "
read opcion
case $opcion in
0) exit;;
1) clear
   echo "0: Salir"
   echo "1: Ver el nombre del equipo con hostname"
   echo "2: Ver el nombre y la release del kernel con uname"
   echo "3: Ver los nombres de todos los grupos del usuario efectivo con id"
   echo "4: Ver los usuarios logueados con users"
   echo "5: Ver particiones del disco duro y espacio libre con df"
   echo "6: Ver memoria RAM y intercambio con free"
   echo -n "Introduzca la opción deseada: "
   read opcionEquipo
   case $opcionEquipo in
      0) exit;;
      1) hostname;;
      2) uname -sr;;
      3) id -Gn;;
      4) users;;
      5) df -h;;
      6) free -h;;
      *) echo "opción no válida"
         exit;;
   esac;;
2) clear
   echo "0: Salir"
   echo "1: Ver interfaces de red con ip"
   echo "2: Ver los paquetes enviados y recibidos por una interfaz de red con ip"
   echo "3: Ver la tabla de enrutamiento del sistema con netstat o con ip route"
   echo "4: Ver las conexiones establecidas y que están escuchando con netstat o con ss"
   echo "5: Ver las conexiones establecidas por un cierto proceso con lsof o con ss"
   echo "6: Hacer una consulta DNS a un servidor con nslookup"
   echo "7: Hacer un ping a un servidor (4 paquetes ICMP) con ping"
   echo "8: Ver los puertos abiertos de un servidor con nmap"
   echo -n "Introduzca la opción deseada: "
   read opcionRede
   case $opcionRede in
      0) exit;;
      1) ip address;;
      2) echo -n "Introduzca el nombre de la interfaz: "
         read interface
         ip -s link show $interface;;
      3) netstat -rn;; # También es válido: ip route show
      4) netstat -at;; # También es válido: ss -nap 
      5) echo -n "Ver las conexiones establecidas por un proceso: "
         read proceso
         lsof -ai -p "$proceso";; # También es válido ss -nap | grep $proceso;;
      6) echo -n "Introduzca el nombre del servidor: "
         read servidor
         nslookup $servidor;;
      7) echo -n "Introduzca la dirección IP: "
         read ip
         ping -c 4 $ip;;
      8) echo -n "Introduzca el nombre del servidor: "
         read servidor
         nmap $servidor;;
      *) echo "opción no válida"
         exit;;
   esac;;
*) echo "opción no válida"
   exit;;
esac
