# Configuración de red

Aunque `ip` como comando ha terminado por desbancar al popular `ifconfig` para las configuraciones a nivel de red en linux, se presenta a continuación el conjunto de comandos `ifconfig` con su equivalencia a comando `ip`.

Puedo ayudarte con eso. Aquí tienes los comandos organizados en un archivo Markdown:

## ifconfig

```bash
$ ifconfig            # Listar interfaces activas. Normalmente como usuario sin permisos de root (sudo) da error.
$ ifconfig -a         # Listar interfaces estén o no activas
$ /sbin/ifconfig     # Listar interfaces activas
$ /sbin/ifconfig -a  # Listar interfaces estén o no activas
$ ifconfig eth0       # Listar la configuración de la interfaz eth0
$ ifconfig eth0 up    # Activar interfaz eth0
$ ifconfig eth0 down  # Deshabilitar interfaz eth0
$ ifconfig eth0 192.168.100.100                   # Configuración de red para la interfaz eth0: IP=192.168.100.100, MS=255.255.255.0
$ ifconfig eth0 192.168.100.100/24               # Configuración de red para la interfaz eth0: IP=192.168.100.100, MS=255.255.255.0
$ ifconfig eth0 192.168.100.100 netmask 255.255.255.0  # Equivale al comando anterior.
$ ifconfig eth0:0 192.168.100.101/24            # Generar el alias eth0:0 para la interfaz eth0 con otra configuración de red: IP=192.168.100.101, MS=255.255.255.0.
$ ifconfig eth0:0 192.168.100.101 netmask 255.255.255.0   # Equivale al comando anterior.
$ ifconfig eth0:web 192.168.100.102 netmask 255.255.255.0  # Nuevo alias eth0:web para la interfaz eth0.
```

## ip

### `ip address`

```bash
$ ip addr          # Listar interfaces activas
$ ip -c addr          # Listar interfaces activas y aporta ayuda en color
$ ip addr show     # Equivale al comando anterior.
$ ip addr show eth0   # Listar la configuración de la interfaz eth0
$ ip link             # Muestra unicamente información a nivel de MAC.
$ ip link show eth0   # Muestra unicamente información a nivel de MAC para una tarjeta concreta.
$ ip link set eth0 up    # Activar interfaz eth0
$ ip link set eth0 down  # Deshabilitar interfaz eth0
$ ip address add 192.168.100.100 dev eth0   # Configuración de red para la interfaz eth0: IP=192.168.100.100, MS=255.255.255.255. NOTA: Si eth0 con la IP 192.168.100.100 ya había sido configurada con ifconfig, la nueva configuración realizada mediante ip no se vería en la ejecución de ifconfig.
$ ip address add 192.168.100.100/24 broadcast 192.168.100.255 dev eth0   # Configuración de red para la interfaz eth0: IP=192.168.100.100, MS=255.255.255.0
$ ip address add 192.168.100.104/24 dev eth0 label eth0:4   # Generar el alias eth0:4 para la interfaz eth0 con otra configuración de red: IP=192.168.100.104, MS=255.255.255.0.
$ ip address del 192.168.100.101/24 dev eth0   # Eliminar esa configuración IP en la interfaz eth0. En este caso esa configuración corresponde con el alias eth0:0, por lo que elimina ese alias de la configuración de red.
$ ip address del 192.168.100.102/24 dev eth0:web   # Eliminar el alias eth0:web
```

### `ip route`

```bash
$ route                       # Listar tabla de enrutamiento.
$ ip route                    # Listar tabla de enrutamiento
$ ip route show               # Equivale al comando anterior.
$ ip route list               # Equivale al comando anterior.
$ route -n                    # Listar tabla de enrutamiento sin resolución DNS

$ route add default gw 192.168.100.1       # Configurar puerta de enlace (gateway).
$ ip route add default via 192.168.100.1  # Equivale al comando anterior.

$ route del default gw 192.168.100.1      # Eliminar puerta de enlace (gateway).
$ ip route del default via 192.168.100.1 # Equivale al comando anterior.

$ route add -net 192.168.200.0 netmask 255.255.255.0 dev eth0  # Añadir regla de enrutamiento para la red 192.168.200.0 en la interfaz eth0
$ ip route add 192.168.200.0/24 dev eth0   # Equivale al comando anterior.

$ route del -net 192.168.200.0 netmask 255.255.255.0 dev eth0  # Eliminar regla de enrutamiento para la red 192.168.200.0 en la interfaz eth0
$ ip route delete 192.168.200.0/24 dev eth0   # Equivale al comando anterior.

$ route add -net 192.168.100.0 netmask 255.255.255.0 gw 192.168.100.1 dev eth0  # Añadir regla de enrutamiento para la red 192.168.100.0 en la interfaz eth0 con la puerta de enlace 192.168.100.1
$ ip route add 192.168.100.0/24 via 192.168.100.1 dev eth0 onlink   # Equivale al comando anterior.
```

- _*Nota: Es conveniente saber que tanto `ip a`, `ip addr` como `ip address` son equivalentes.*_

Tambien es importante hablar del fichero `/etc/hosts` que nos permite evitar la configuración de un servicio DNS. El archivo /etc/hosts es un archivo de configuración en sistemas operativos Unix y Linux que se utiliza para mapear nombres de host a direcciones IP. Actúa como una especie de "agenda telefónica" local, permitiendo la resolución de nombres de host sin necesidad de consultar servidores DNS externos.

```bash
si@si-VirtualBox:~$ cat /etc/hosts
127.0.0.1       localhost
127.0.1.1       si-VirtualBox

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

Ojo, una entrada como la siguiente sería correcta. Simplemente 9.9.9.9 respondería ante cualquiera de los 5 nombres.

```bash
<dirección IP> <nombre de host principal> <alias1> <alias2> ...
```

```bash
9.9.9.9 pepito grillo manu
9.9.9.9 manuel manolo
```
