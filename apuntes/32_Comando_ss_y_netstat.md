# Comando ss y netstat

## Índice

1. [Introducción a ss y netstat](#1-introducción-a-ss-y-netstat)
   1. [Opciones comunes](#11-opciones-comunes)
   2. [Interpretar la dirección local](#12-interpretar-la-dirección-local)
   3. [Las columnas Recv-Q y Send-Q](#13-las-columnas-recv-q-y-send-q)
   4. [Filtros de ss](#14-filtros-de-ss)
2. [Ejemplos de uso](#2-ejemplos-de-uso)

---

## 1. Introducción a ss y netstat

Tanto `ss` como `netstat` son comandos utilizados en sistemas Unix y Linux para mostrar información sobre conexiones de red, enrutamiento y estadísticas de red.

> **Importante:** `netstat` forma parte del paquete `net-tools`, que está **obsoleto** y ya no se instala por defecto en Debian ni en la mayoría de distribuciones actuales. Su sustituto es `ss` (*socket statistics*), del paquete `iproute2`, que obtiene los datos directamente del núcleo a través de `netlink` en lugar de leer y analizar los ficheros de `/proc/net`. La diferencia se nota sobre todo en servidores con muchas conexiones abiertas, donde `ss` es notablemente más rápido.
>
> | Herramienta obsoleta | Sustituto actual |
> |---|---|
> | `netstat` | `ss` |
> | `ifconfig` | `ip addr` |
> | `route` | `ip route` |
> | `arp` | `ip neigh` |
> | `iptunnel` | `ip tunnel` |
>
> Conviene conocer `netstat` porque sigue apareciendo en documentación y exámenes, pero lo correcto hoy es usar `ss`. Comparten casi todos los parámetros, de modo que aprender uno sirve para el otro. El documento 31 trata `ip` en detalle.

### 1.1 Opciones comunes

| Parámetro | Definición |
|-----------|------------|
| `-l` | Muestra sólo las conexiones que están en estado de escucha (`LISTEN`). |
| `-a` | Muestra todas las conexiones, tanto las que están en escucha como las establecidas. |
| `-t` | Muestra sólo las conexiones TCP. |
| `-u` | Muestra sólo las conexiones UDP. |
| `-n` | Muestra las direcciones IP y los números de puerto en formato numérico (sin resolución de nombres DNS). |
| `-p` | Muestra el PID y el nombre del programa a cargo de la conexión (requiere privilegios). |
| `-r` | Muestra la tabla de enrutamiento. |
| `-s` | Muestra estadísticas de protocolo acumuladas. |
| `-4` / `-6` | Restringe la salida a IPv4 o a IPv6. |
| `-i` | Solo en `netstat`: muestra estadísticas por interfaz. |
| `-x` | Muestra los sockets de dominio UNIX, que no usan la red sino el sistema de ficheros. |

> **Advertencia:** Sin privilegios, la columna de proceso aparece vacía con un simple guion, tal como se aprecia en el ejemplo de la sección siguiente, donde `netstat` avisa con `you would have to be root to see it all`. El motivo es que un usuario normal solo puede ver los procesos que le pertenecen. Para obtener la información completa hay que ejecutarlo con `sudo`.

La combinación que conviene memorizar es **`ss -tulpn`**, que responde a la pregunta más habitual en administración: qué servicios están escuchando en esta máquina y quién los ha abierto.

```bash
root@debian:~# ss -tulpn
Netid State  Local Address:Port   Peer Address:Port Process
udp   UNCONN 127.0.0.1:323        0.0.0.0:*         users:(("chronyd",pid=598,fd=5))
tcp   LISTEN 0.0.0.0:22           0.0.0.0:*         users:(("sshd",pid=588,fd=3))
tcp   LISTEN *:80                 *:*               users:(("apache2",pid=681,fd=4))
```

| Letra | Significado |
|---|---|
| `t` | TCP |
| `u` | UDP |
| `l` | Solo lo que está en escucha |
| `p` | Muestra el proceso |
| `n` | No resuelve nombres, con lo que la respuesta es inmediata |

### 1.2 Interpretar la dirección local

La dirección que aparece a la izquierda indica **en qué interfaces acepta conexiones** el servicio, y es el dato que más confusión genera:

| Dirección | Significado |
|---|---|
| `0.0.0.0:80` | Escucha en **todas** las interfaces IPv4 de la máquina. Accesible desde la red. |
| `127.0.0.1:3306` | Escucha **solo** en la interfaz de bucle local. Únicamente se puede conectar desde la propia máquina. |
| `192.168.1.50:80` | Escucha únicamente en esa interfaz concreta. |
| `[::]:22` o `*:22` | Equivalente a `0.0.0.0` para IPv6. En Linux, un socket IPv6 en `[::]` suele atender también conexiones IPv4. |

> **Recuerda:** Este es el primer sitio donde mirar cuando un servicio "no responde desde fuera". Si aparece escuchando en `127.0.0.1`, el problema no está en el cortafuegos ni en la red, sino en la configuración del propio servicio, que está vinculado solo al bucle local. Muchas bases de datos vienen así de fábrica precisamente por seguridad.

### 1.3 Las columnas Recv-Q y Send-Q

Ambas indican cuántos bytes hay pendientes en las colas del socket, pero su significado cambia según el estado:

| Estado | `Recv-Q` | `Send-Q` |
|---|---|---|
| `LISTEN` | Conexiones ya completadas que el programa aún no ha aceptado. | Tamaño máximo de esa cola de espera (*backlog*). |
| `ESTAB` | Bytes recibidos que la aplicación todavía no ha leído. | Bytes enviados cuya confirmación aún no ha llegado. |

> **Nota:** Un `Recv-Q` que crece de forma sostenida en una conexión establecida indica que la aplicación no da abasto leyendo lo que le llega. Un `Recv-Q` alto en un socket en `LISTEN` significa que se acumulan conexiones sin atender y que el servicio está saturado.

### 1.4 Filtros de ss

La ventaja más práctica de `ss` sobre `netstat` es su lenguaje de filtrado, que evita tener que encadenar `grep`:

```bash
root@debian:~# ss -t state established
root@debian:~# ss -t '( dport = :443 or sport = :443 )'
root@debian:~# ss -t dst 192.168.1.0/24
root@debian:~# ss -tn state time-wait
```

> **Recuerda:** Para averiguar quién ocupa un puerto concreto hay dos caminos equivalentes, y conviene conocer los dos: `ss -tulpn | grep :80` y `lsof -i :80`, este último tratado en el documento 22.

---

## 2. Ejemplos de uso

Podemos ver con ambos comandos la interfaz y puerto que ofrece el servicio (por ejemplo, `0.0.0.0` significa que se oferta en todas las interfaces de la máquina en el puerto especificado), así como el programa que lo expone.

```bash
vagrant@debian:~$ netstat -putan
(Not all processes could be identified, non-owned process info
 will not be shown, you would have to be root to see it all.)
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      -
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      -
tcp        0     52 192.168.33.11:22        192.168.33.1:53679      ESTABLISHED -
tcp6       0      0 :::80                   :::*                    LISTEN      -
tcp6       0      0 :::111                  :::*                    LISTEN      -
tcp6       0      0 :::22                   :::*                    LISTEN      -
udp        0      0 0.0.0.0:68              0.0.0.0:*                           -
udp        0      0 0.0.0.0:111             0.0.0.0:*                           -
udp        0      0 127.0.0.1:323           0.0.0.0:*                           -
udp6       0      0 :::111                  :::*                                -
udp6       0      0 ::1:323                 :::*                                -
```

```bash
vagrant@debian:~$ ss -putan
Netid                   State                    Recv-Q                   Send-Q                                     Local Address:Port                                     Peer Address:Port                   Process
udp                     UNCONN                   0                        0                                                0.0.0.0:68                                            0.0.0.0:*
udp                     UNCONN                   0                        0                                                0.0.0.0:111                                           0.0.0.0:*
udp                     UNCONN                   0                        0                                              127.0.0.1:323                                           0.0.0.0:*
udp                     UNCONN                   0                        0                                                   [::]:111                                              [::]:*
udp                     UNCONN                   0                        0                                                  [::1]:323                                              [::]:*
tcp                     LISTEN                   0                        4096                                             0.0.0.0:111                                           0.0.0.0:*
tcp                     LISTEN                   0                        128                                              0.0.0.0:22                                            0.0.0.0:*
tcp                     ESTAB                    0                        52                                         192.168.33.11:22                                       192.168.33.1:53679
tcp                     LISTEN                   0                        511                                                    *:80                                                  *:*
tcp                     LISTEN                   0                        4096                                                [::]:111                                              [::]:*
tcp                     LISTEN                   0                        128                                                 [::]:22                                               [::]:*
```
