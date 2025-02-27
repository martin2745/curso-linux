#!/bin/bash

######################################################################################
[ -f /etc/passwd ] && grep root /etc/passwd

if [ -f /etc/passwd ]; then
  grep root /etc/passwd
fi


######################################################################################
[ -d $HOME ] && mkdir -p $HOME/bin/scripts

if [ -d $HOME ]; then 
  mkdir -p $HOME/bin/scripts
fi


######################################################################################
[ -r $HOME/bin/scripts/comprobar.sh ] && cat $HOME/bin/scripts/comprobar.sh

if [ -r $HOME/bin/scripts/comprobar.sh ]; then 
  cat $HOME/bin/scripts/comprobar.sh
fi


######################################################################################
[ -r $HOME/bin/scripts/comprobar.sh ] &&  [ -x $HOME/bin/scripts/comprobar.sh ] && . $HOME/bin/scripts/comprobar.sh

if [ -r $HOME/bin/scripts/comprobar.sh ]; then
  if  [ -x $HOME/bin/scripts/comprobar.sh ]; then 
    . $HOME/bin/scripts/comprobar.sh
  fi
fi


######################################################################################
[ -r $HOME/bin/scripts/comprobar.sh ] || [ -x $HOME/bin/scripts/comprobar.sh ] && . $HOME/bin/scripts/comprobar.sh 

if [ -r $HOME/bin/scripts/comprobar.sh ] || [ -x $HOME/bin/scripts/comprobar.sh ]; then 
    . $HOME/bin/scripts/comprobar.sh
fi


######################################################################################
[ -r $HOME/bin/scripts/comprobar.sh ] && bash /bin/scripts/comprobar.sh || echo "No se ejecuta el script"
 
if [ -r $HOME/bin/scripts/comprobar.sh ]; then
  bash $HOME/bin/scripts/comprobar.sh
else
  echo "No se ejecuta el script"
fi
