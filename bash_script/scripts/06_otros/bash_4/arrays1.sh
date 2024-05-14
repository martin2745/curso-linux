#!/bin/bash

##FUNCIONS
f_port() {
  for i in "${array_IPs[@]}"
  do
    nc -vz $i "${array_ports_TCP[@]}"
  done
}

##VARIABLES
array_ports_TCP=(21 22 23 80 443 445)
array_IPs=('127.0.0.1' 192.168.1.1)

##main()
f_port
