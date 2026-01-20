# 05 SNAT con NFTABLES para Ubuntu Server

En este apartado vamos a realizar las modificaciones necesarias para que nuestro DC-AD Ubuntu Server actue de router utilizando la herramienta moderna de firewall llamada `nftables`.

## Conceptos de redes previos

### ¿Qué es SNAT (Source Network Address Translation)?

Es el mecanismo que permite que **varios equipos de una red privada salgan a Internet usando una sola dirección IP pública**.

- **El problema:** Tus equipos en casa (móviles, PCs) tienen IPs privadas (tipo `192.168.100.x`) que no son válidas en Internet. Si intentan salir así, Internet no sabrá cómo responderles.
- **La solución (SNAT):** Cuando el paquete sale de tu red, el servidor Ubuntu (que actúa de intermediario) **borra la IP privada de origen** del paquete y pone **su propia IP pública**.
- **El resultado:** Para el mundo exterior, es el servidor Ubuntu quien está navegando, y cuando recibe la respuesta, se acuerda de a qué equipo privado debe devolvérsela.

Podemos decir que:
Aquí tienes el resumen definitivo integrando todas las piezas del puzle. Este esquema mental te servirá para entender cualquier firewall o router.

### El Concepto General: NAT

**NAT (Network Address Translation)** es la acción de modificar las cabeceras de los paquetes IP (cambiar la IP de origen o la de destino) mientras pasan por el router.

#### 1. Salir a Internet: SNAT + PAT

- **SNAT (Source NAT):** El router borra la IP Privada del cliente y pone la IP Pública en el campo "Origen" del paquete.
- **PAT (Port Address Translation):** Como el router tiene una sola IP Pública para muchos equipos, **usa los PUERTOS para distinguirlos**. El Router anota en su tabla: _"El Equipo A salió usando el puerto 10500"_ y _"El Equipo B salió usando el puerto 20800"_. Cuando Google responde a la IP Pública, el router mira el **puerto de destino** de esa respuesta. ¿Viene al 10500? Se lo pasa al A. ¿Viene al 20800? Se lo pasa al B.

#### 2. Entrar desde Internet: DNAT

Aquí hay tráfico nuevo que un equipo externo a la red envía desde fuera hacia un equipo interno.

- **DNAT (Destination NAT):** El router recibe un paquete en su IP Pública (ej. puerto 80) y este tendría una configuración de una regla fija que indica: _"Todo lo que venga al puerto 80, se envía a la IP Privada 192.168.100.50"_.
- Sin DNAT, el router descartaría ese tráfico porque no sabría a qué equipo interno entregárselo.

#### Tabla Resumen

| Concepto | Significado            | Dirección del tráfico         | ¿Qué cambia?        | ¿Para qué sirve?                    | El "Truco"                                                                 |
| -------- | ---------------------- | ----------------------------- | ------------------- | ----------------------------------- | -------------------------------------------------------------------------- |
| **NAT**  | Traducción de Dir. Red | Cualquiera                    | IP Origen o Destino | Concepto general                    | -                                                                          |
| **SNAT** | Source NAT             | **Salida** (LAN -> Internet)  | IP de **Origen**    | Navegar desde la red privada.       | Usa **PAT** (puertos aleatorios) para saber a quién devolver la respuesta. |
| **DNAT** | Destination NAT        | **Entrada** (Internet -> LAN) | IP de **Destino**   | Publicar un servidor (Web, SSH...). | Tú defines manualmente la regla (ej. Puerto 80 -> Servidor A).             |

**Analogía final:**

- **SNAT+PAT (Salida):** Es como la recepción de un edificio de oficinas. Todos los empleados (equipos) dejan sus cartas en recepción. El conserje las envía todas con la dirección del edificio (IP Pública), pero anota en un cuaderno (Tabla NAT) _"Esta respuesta es para el de la oficina 5"_.
- **DNAT (Entrada):** Es cuando le dices al conserje: _"Si llega un paquete a nombre de 'Administrador', mándalo directamente a la oficina 3"_.

```bash
INTERNET (Nube)                            TU RED PRIVADA (LAN)
      (Google, Usuarios)                          (192.168.100.0/24)
            |
            | Cable ISP
            v
+-----------------------------+             +-----------------------------+
|      UBUNTU SERVER          |             |       WINDOWS 10            |
|       (ROUTER)              |             |      (Navegando)            |
|                             |             | IP: 192.168.100.8           |
| [IP PÚBLICA: 203.0.113.1]   |<------------| Puerto Origen: 10500        |
| [IP PRIVADA: 192.168.100.1] |    (1)      +-----------------------------+
|                             |
|  TABLA DE CONEXIONES (NAT)  |
|  +-----------------------+  |
|  | IN (Priv)  | OUT (Pub)|  |
|  |------------|----------|  |             +-----------------------------+
|  | .10:10500  | .1:10500 |  |             |      UBUNTU DESKTOP         |
|  | .20:20800  | .1:20800 |  |<------------|     (Servidor Web)          |
|  +-----------------------+  |    (2)      | IP: 192.168.100.7           |
|                             |             | Puerto Origen: 20800        |
|      Reglas NFTABLES        |             +-----------------------------+
|     (SNAT & DNAT)           |
+-----------------------------+
            ^
            | (3) Tráfico DNAT (Entrada)
            |
    Usuario Externo
    Pide ver un recurso (por ejemplo un servidor web en caso de existir)
```

### ¿Qué es NFTABLES?

Es el sucesor moderno de `iptables**`. Es la herramienta que usa el Kernel de Linux para filtrar paquetes y hacer NAT.

- Es más rápido, tiene una sintaxis más limpia y combina IPv4 e IPv6 en una sola herramienta.
- En Ubuntu Server (versiones recientes), `nftables` es el estándar recomendado, aunque muchos sigan usando `iptables` por costumbre.

## Configuración de Ubuntu Server para dar salida al exterior

Primero de todo tenemos que configurar nuestro Ubuntu Server para que las peticiones que se realicen a nuestro adaptador de la red interna sean enrutadas a nuestro adaptador que da salida a internet.

1. Primero de todo tenemos que permitir que el Router pueda redirigir paquetes. Para ello tendremos que realizar lo siguiente:

```bash
root@dc:~# cat /proc/sys/net/ipv4/ip_forward
0
root@dc:~# echo 1 > /proc/sys/net/ipv4/ip_forward
root@dc:~# cat /proc/sys/net/ipv4/ip_forward
1
```

El problema de esta configuración es que no es persistente. Para ello tenemos que editar el fichero `/etc/sysctl.conf` y descomentar a directiva **net.ipv4.ip_forward=1**.

```bash
root@dc:~# grep ip_forward /etc/sysctl.conf
net.ipv4.ip_forward=1
```

2. Ahora realizamos la instalación de _nftables_. Vamos a configurar un SNAT dinámico para que la dirección IP pública que nos conecta a Internet es dinámica por lo que se va a ir modificando de forma recurrente.

```bash
root@dc:~# apt update && apt install -y nftables
```

3. Llegados a este punto creamos una tabla NAT.

```bash
root@dc:~# nft add table nat

root@dc:~# nft list tables
table ip nat
```

_*Nota 1*_: Podemos eliminar la tabla con **nft delete table nat**.
_*Nota 2*_: Podemos listar la tabla con **nft list tables**.

4. Ahora agregamos una nueva cadena llamada postrouting a la tabla nat previamente creada. Además, le indicamos los atributos necesarios para establecer una traducción de direcciones y puertos de red por SNAT/DNAT y lo asociamos a la fase de salida del kernel mediante el hook postrouting, para que las reglas se apliquen justo antes de que los paquetes abandonen la interfaz de red.

```bash
root@dc:~# nft add chain nat postrouting { type nat hook postrouting priority 100 \; }

root@dc:~# nft list chains
table ip nat {
        chain postrouting {
                type nat hook postrouting priority srcnat; policy accept;
        }
}
```

_*Nota 1*_: Podemos eliminar la cadena con **nft delete chain nat postrouting**.
_*Nota 2*_: Podemos listar la cadena con **nft list chains**.

5. El siguiente paso es crear una regla postrouting para que nuestros equipos de la red local tengan salida al exterior tenemos que configurar SNAT dinámico.

En la tabla NAT, justo antes de salir (postrouting): Si un paquete intenta salir por la tarjeta de Internet (enp0s3) Y proviene de mi red interna (192.168.100.0/24) entonces cuéntalo para las estadísticas futuras de red (counter) y enmascáralo (masquerade / cámbiale su IP por la mía pública para que pueda navegar).

```bash
root@dc:~# nft add rule ip nat postrouting oifname "enp0s3" ip saddr 192.168.100.0/24 counter masquerade

root@dc:~# nft list table nat
table ip nat {
        chain postrouting {
                type nat hook postrouting priority srcnat; policy accept;
                oifname "enp0s3" ip saddr 192.168.100.0/24 counter packets 0 bytes 0 masquerade
        }
}
```

En este punto nuestro equipo Ubuntu Desktop tiene salida a Internet.

_*Nota 1*_: Podemos eliminar la regla con **nft delete rule nat postrouting handle 5**.
_*Nota 2*_: Podemos listar la regla con **nft -a list ruleset**.

6. El problema de esta configuración es que **no es persistente**. Llegados a este punto tenemos que editar el fichero `/etc/nftables.conf`.

```bash
root@dc:~# nft list ruleset
table ip nat {
        chain postrouting {
                type nat hook postrouting priority srcnat; policy accept;
                oifname "enp0s3" ip saddr 192.168.100.0/24 counter packets 0 bytes 0 masquerade
        }
}
root@dc:~# nft list ruleset > /etc/nftables.conf
```

```bash
root@dc:~# systemctl enable nftables
Created symlink /etc/systemd/system/sysinit.target.wants/nftables.service → /usr/lib/systemd/system/nftables.service.
root@dc:~# systemctl restart nftables
```

## Posibles problemas en Ubuntu Desktop

1. Edita el fichero de configuración de red de Ubuntu Desktop para indicar el router. Hasta ahora, no teniamos un router especificado en nuestra red, en este punto el Ubuntu Desktop actua de router.

```bash
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    enp0s3:
      renderer: networkd
      dhcp4: no
      addresses:
        - 192.168.100.7/24
      routes:
        - to: default
          via: 192.168.100.6
      nameservers:
        addresses: [192.168.100.6, 8.8.8.8]
```

2. Realiza la siguiente modificación

Al editar el archivo `/etc/apparmor.d/tunables/home`, estamos ampliando la "zona de confianza" de AppArmor. Le indicamos explícitamente que /home/INSTITUTO/ también es una ubicación válida para albergar carpetas de usuarios. El reinicio del servicio (systemctl restart apparmor) es necesario para recargar estas reglas en el kernel sin necesidad de reiniciar el servidor completo.

```bash
usuario@ud101:~$ grep INSTITUTO /etc/apparmor.d/tunables/home
@{HOMEDIRS}=/home/ /home/INSTITUTO/
usuario@ud101:~$ sudo systemctl restart apparmor
```
