#!/bin/bash
while true
  do
  ahora=$(date "+%H:%M:%S - ")
  echo -n $ahora >> /var/log/supervisamem.log
  grep Dirty /proc/meminfo >> /var/log/supervisamem.log
  sleep 30
done