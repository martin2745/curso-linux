#!/bin/bash

tinicio=$1
tlimite=$2
FATHERPID=$3
while [ $tlimite -gt $((`date +%s`-$tinicio)) ]
do

 tput sc 

 DATA=$(date -u --date @$(($tlimite - $((`date +%s`-$tinicio)))) +%M:%S)
 COLUMNS=$((`tput cols` - 5))
 tput cup 0 $COLUMNS

 COLOR_CHANGE=$(tput smso)
 COLOR_ORIGINAL=$(tput rmso)
 echo -n ${COLOR_CHANGE}$DATA${COLOR_ORIGINAL}

 tput rc

 sleep 1
done
tput sc
tput cup 0 $COLUMNS
echo -n "${COLOR_ORIGINAL}     ${COLOR_ORIGINAL}"
tput rc
kill $FATHERPID 1>/dev/null 2>&1 
echo -e "\nRematouse o tempo!!!--------------------------------------"
