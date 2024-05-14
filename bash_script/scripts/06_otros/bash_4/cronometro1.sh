#!/bin/bash

declare -r tinicio=$(date +%s)
declare -r tlimite=30

tagora=$(date +%s)
texecucion=$((tagora-tinicio))
while [ $tlimite -gt $texecucion ]
do
tagora=$(date +%s)
texecucion=$((tagora-tinicio))
  echo -en "\t $(date -u --date @$(($tlimite - $texecucion)) +%M:%S)\r"
done
