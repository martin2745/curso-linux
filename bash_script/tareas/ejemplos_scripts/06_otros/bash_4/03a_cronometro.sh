#!/bin/bash

declare -r tinicio=$(date +%s)
declare -r tlimite=30

tahora=$(date +%s)
tejecucion=$((tahora-tinicio))
while [ $tlimite -gt $tejecucion ]
do
  tahora=$(date +%s)
  tejecucion=$((tahora-tinicio))
  echo -en "\t $(date -u --date @$(($tlimite - $tejecucion)) +%M:%S)\r"
done
