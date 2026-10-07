#!/bin/bash
# Estado inicial del cortafuegos de la tarea 6.2.
#
# Simula un cortafuegos que ya esta en funcionamiento: politicas DROP,
# seguimiento de estados y cinco reglas previas en INPUT.
# Ejecutar como root desde la CONSOLA del cortafuegos: a partir de aqui
# solo se mantienen las sesiones SSH que ya estuvieran abiertas.
#
# Interfaces:
#   enp0s3  -> Internet   (203.0.113.100 y 203.0.113.254)
#   enp0s8  -> DMZ        (172.31.255.254/16)
#   enp0s9  -> LAN        (192.168.1.254/24)
#   enp0s10 -> Invitados  (192.168.20.254/24)

# Partir de cero: sin reglas ni cadenas de usuario
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# Politicas: se descarta todo lo que no este permitido
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# INPUT: cinco reglas previas
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
iptables -A INPUT -i enp0s9 -s 192.168.1.0/24 -p icmp --icmp-type echo-request -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -i enp0s8 -s 172.31.0.0/16 -p icmp --icmp-type echo-request -m conntrack --ctstate NEW -j ACCEPT

# OUTPUT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# FORWARD
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# IPv6 no se usa en el laboratorio: queda cerrado salvo el bucle local
ip6tables -F
ip6tables -X
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT DROP
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT

iptables -L -n -v --line-numbers
