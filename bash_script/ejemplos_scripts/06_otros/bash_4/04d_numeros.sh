#!/bin/bash

##man tput && man terminfo

PID=$$

declare -r NUMBER=$((1+RANDOM%999))
declare -i NUMBER
cont=0
declare -r tinicio=$(date +%s)
declare -r tlimite=30

bash cronometro2.sh $(date +%s) $tlimite $PID &

function f_leer_numero() {
  read -p 'Adivina el número de 3 cifras: ' -n3 number
  declare -i number
  cont=$((cont+1))
}


function f_procesar() {
CHRONEPID=$(pgrep -f cronometro2)
texecucion=$((`date +%s` - tinicio))
while [ $tlimite -gt $texecucion ]
do
  echo -en "\t $(date -u --date @$(($tlimite - $texecucion)) +%M:%S)\r" 
  if [ $number -gt $NUMBER ] 2>/dev/null; then
  #echo -e "\naaa $?"
    echo -e '\nEl número es menor'
    f_leer_numero 
  else 
    if [ $number -lt $NUMBER ] 2>/dev/null; then
  #echo -e "\nbbb $?"
      echo -e '\nEl número es mayor'
      f_leer_numero
    else 
  #echo -e "\nccc $?"
      if [ $? -ne 2 ]; then
	echo -e "\n¡FELICIDADES! Adivinaste el número en $cont intentos y $texecucion segundos"
	tput sc
	COLUMNS=$((`tput cols` - 5))
	tput cup 0 $COLUMNS
	COLOR_ORIGINAL=$(tput rmso)
	echo -n "${COLOR_ORIGINAL}     ${COLOR_ORIGINAL}"
	tput rc
        kill $CHRONEPID 1>/dev/null 2>&1
	exit
      else
	echo -e "\nDebe introducir un número"
	f_leer_numero
      fi
    fi
  fi
##  f_procesar
texecucion=$((`date +%s` - tinicio))
done
echo -e "\n¡Se acabó el tiempo!--------------------------------------"
exit
}


f_main() {
  clear
##  echo -e "\n $NUMBER $number"
  f_leer_numero
  f_procesar
}

f_main
