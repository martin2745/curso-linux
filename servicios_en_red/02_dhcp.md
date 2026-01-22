# DHCP

Vamos a instalar un servidor DHCP en un **Servidor Linux (Ubuntu Server)** que actuará como router para gestionar dos redes físicas independientes. En este escenario contamos con el servidor y dos clientes conectados a redes distintas:

- **Servidor Ubuntu**: Tendrá tres tarjetas de red (WAN para internet, LAN1 y LAN2).
- **Ubuntu Desktop**: Conectado a la primera subred (LAN1).
- **Windows 10**: Conectado a la segunda subred (LAN2).

Dado que partimos de la red `192.168.100.0/24`, vamos a aplicar **Subnetting** para dividirla en dos subredes iguales utilizando una máscara de **/25** (255.255.255.128):

1. **Subred 1 (LAN1)**: `192.168.100.0/25` (IPs de la .1 a la .126).
2. **Subred 2 (LAN2)**: `192.168.100.128/25` (IPs de la .129 a la .254).

## Configuración previa de IPs estáticas en el Servidor

Antes de instalar el servicio DHCP, debemos configurar las interfaces de red del servidor para que actúen como **Puerta de Enlace (Gateway)** de cada subred.

Editamos la configuración de Netplan:

```bash
root@debian:~# nano /etc/netplan/00-installer-config.yaml

```

```bash
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s8:
      addresses:
        - 192.168.100.1/25
    enp0s9:
      addresses:
        - 192.168.100.129/25
```

Aplicamos los cambios y verificamos:

```bash
root@debian:~# netplan apply
root@debian:~# ip address show
```

```bash
enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:a0:71:dc brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.1/25 brd 192.168.100.127 scope global enp0s8
       valid_lft forever preferred_lft forever
enp0s9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:bc:38:14 brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.129/25 brd 192.168.100.255 scope global enp0s9
       valid_lft forever preferred_lft forever
```

## Implementación del servidor DHCP

### 1. Instalación del paquete

Actualizamos repositorios e instalamos el software estándar para DHCP en Linux (`isc-dhcp-server`).

```bash
root@debian:~# apt update && apt install -y isc-dhcp-server
```

### 2. Definición de las Interfaces de Escucha

Debemos indicar al servicio DHCP por qué tarjetas de red debe escuchar peticiones. Editamos el archivo de configuración por defecto:

```bash
root@debian:~# nano /etc/default/isc-dhcp-server
```

Modificamos la variable `INTERFACESv4`:

```bash
INTERFACESv4="enp0s8 enp0s9"
```

**INTERFACESv4**: Indicamos las dos tarjetas de red internas (LAN1 y LAN2). No incluimos la `enp0s3` porque esa es la conexión a Internet y ya recibe IP de otro router, no queremos repartir IPs hacia fuera.

### 3. Configuración del Servicio (dhcpd.conf)

Editamos el archivo principal `/etc/dhcp/dhcpd.conf` para definir los parámetros de red que entregaremos a los clientes.

#### Opciones Globales

Estas opciones se aplicarán a todas las redes a menos que se especifique lo contrario dentro de cada bloque.

```bash
option domain-name "aula.local";
option domain-name-servers 8.8.8.8, 8.8.4.4;

default-lease-time 3600;
max-lease-time 7200;
```

- **option domain-name**: Un nombre de dominio genérico para la red local.
- **option domain-name-servers**: Servidores DNS que usarán los clientes para navegar por Internet (ej. Google DNS). Al no estar en un dominio Active Directory, podemos usar DNS públicos directamente.
- **default-lease-time**: Tiempo de concesión de la IP por defecto (1 hora).
- **max-lease-time**: Tiempo máximo antes de forzar renovación.

#### Activación del Modo Autoritativo

Descomentamos la directiva `authoritative` para indicar que este es el servidor DHCP principal de la red.

```bash
authoritative;
```

#### Definición de las Subredes (Pools)

Aquí definimos los dos rangos distintos basándonos en nuestra división `/25`.

##### Subred 1 (LAN 1 - 192.168.100.0/25)

```bash
subnet 192.168.100.0 netmask 255.255.255.128 {
    option routers 192.168.100.1;
    option subnet-mask 255.255.255.128;
    range 192.168.100.10 192.168.100.110;
}
```

- **subnet ... netmask ...**: Define la red base. La máscara `.128` indica que la red termina en la IP 127.
- **option routers**: La Puerta de Enlace para estos clientes. Debe ser la IP de la interfaz `enp0s8` del servidor (`100.1`).
- **range**: El rango de IPs que se repartirán dinámicamente.

##### Subred 2 (LAN 2 - 192.168.100.128/25)

```bash
subnet 192.168.100.128 netmask 255.255.255.128 {
    option routers 192.168.100.129;
    option subnet-mask 255.255.255.128;
    range 192.168.100.140 192.168.100.240;
}
```

- **subnet**: Observa que la red comienza en `.128`.
- **option routers**: La Puerta de Enlace aquí es la `100.129` (Interfaz `enp0s9` del servidor).
- **range**: Repartimos IPs de la parte alta de la tabla.

### 4. Reinicio y Verificación del Servicio

Reiniciamos el servicio para aplicar los cambios:

```bash
root@debian:~# systemctl restart isc-dhcp-server
root@debian:~# systemctl status isc-dhcp-server
```

Si todo es correcto, veremos que el servicio está escuchando en ambas subredes:

```bash
● isc-dhcp-server.service - ISC DHCP IPv4 server
     Active: active (running)
...
ene 21 19:48:57 servidor dhcpd[1480]: Listening on LPF/enp0s9/../192.168.100.128/25
ene 21 19:48:57 servidor dhcpd[1480]: Sending on   LPF/enp0s9/../192.168.100.128/25
ene 21 19:48:57 servidor dhcpd[1480]: Listening on LPF/enp0s8/../192.168.100.0/25
ene 21 19:48:57 servidor dhcpd[1480]: Sending on   LPF/enp0s8/../192.168.100.0/25
```

## Comprobación en los clientes

### Cliente Ubuntu Desktop (Subred 1)

Configuramos el cliente para obtener IP automática vía Netplan o interfaz gráfica:

```bash
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    enp0s3:
      dhcp4: true
```

Verificamos la conexión haciendo ping a la puerta de enlace (nuestro servidor):

```bash
usuario@debian:~# ping -c 4 192.168.100.1
PING 192.168.100.1 (192.168.100.1) 56(84) bytes of data.
64 bytes from 192.168.100.1: icmp_seq=1 ttl=64 time=0.903 ms

--- 192.168.100.1 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss
```
