#!/bin/bash
# chkconfig: - 99 10
case $1 in
start)
  /opt/scripts/supervisamem &
  ;;
stop)
  killall supervisamem
  ;;
esac