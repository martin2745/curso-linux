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

2. Script de aprovisionamiento.

Es necesario ejecutar el siguiente script.

```bash
#!/bin/bash

# Comprobar si se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root (sudo)."
  exit 1
fi

echo "--- INICIANDO APROVISIONAMIENTO PARA ENTORNO AD (SIN SNAP) ---"

# 1. ELIMINAR SNAP COMPLETAMENTE
# Snap da problemas con carpetas home no estándar (/home/INSTITUTO)
echo "[1/5] Eliminando paquetes Snap y el demonio snapd..."
snap remove firefox 2>/dev/null
apt purge -y snapd
rm -rf /root/snap /home/*/snap
rm -rf /var/cache/snapd
apt-mark hold snapd # Evita que se reinstale accidentalmente

# 2. BLOQUEAR REINSTALACIÓN AUTOMÁTICA DE SNAP
# Configura APT para que nunca priorice snap
echo "[2/5] Bloqueando reinstalación de Snap..."
cat <<EOF > /etc/apt/preferences.d/nosnap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

# 3. INSTALAR FIREFOX NATIVO (.DEB)
# Añade el repositorio oficial de Mozilla y le da prioridad
echo "[3/5] Configurando Firefox nativo (.deb)..."
add-apt-repository -y ppa:mozillateam/ppa
echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' > /etc/apt/preferences.d/mozilla-firefox

apt update
apt install -y firefox

# 4. HABILITAR FLATPAK (ALTERNATIVA A SNAP)
# Instala Flatpak y añade el repositorio Flathub
echo "[4/5] Instalando Flatpak y repositorio Flathub..."
apt install -y flatpak gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# 5. CONFIGURACIÓN GENERAL PARA EL DOMINIO (LA CLAVE DEL FUTURO)
# Esto permite que CUALQUIER app Flatpak futura pueda leer/escribir en /home/INSTITUTO
# Sin esto, las apps de Flatpak tendrían el mismo error que Snap.
echo "[5/5] Aplicando permisos globales para usuarios del dominio..."
flatpak override --system --filesystem=/home/INSTITUTO

echo "--- APROVISIONAMIENTO COMPLETADO ---"
echo "Firefox está listo."
echo "Snap ha sido eliminado."
echo "Flatpak está configurado y tiene permisos sobre /home/INSTITUTO."
echo "Es recomendable reiniciar el equipo: sudo reboot"
```

### 1. Contexto y Problemática

En la integración de clientes Ubuntu dentro de un dominio Active Directory (AD), nos enfrentamos a un error crítico al intentar ejecutar aplicaciones empaquetadas como **Snap** (específicamente Firefox, que viene así por defecto en Ubuntu).

- **El Problema:** Al intentar abrir el navegador, la aplicación se cerraba inmediatamente lanzando errores de "Permission denied" o fallos de montaje de directorios.
- **La Causa:** La configuración del dominio crea las carpetas personales de los usuarios en una ruta no estándar: `/home/INSTITUTO/alumno`. El sistema de seguridad de Ubuntu no estaba preparado para reconocer esta ruta como una carpeta de usuario válida.

### 2. Conceptos Técnicos Clave

Para entender el conflicto, hay que definir dos tecnologías que trabajan juntas en Ubuntu:

- **¿Qué es Snap?**
  Es un sistema de gestión de paquetes que "encapsula" las aplicaciones. A diferencia de los programas tradicionales, una aplicación Snap se ejecuta en una "burbuja" aislada (sandbox). Esto se hace por seguridad: la aplicación no ve todo el sistema operativo, solo lo que se le permite explícitamente. Por defecto, Snap asume que los usuarios siempre están en `/home/usuario` y no sabe cómo gestionar rutas personalizadas de red o de dominio corporativo.
- **¿Qué es AppArmor?**
  Es el módulo de seguridad del kernel de Linux. AppArmor vigila a los programas y les prohíbe acceder a archivos que no estén en su lista blanca.
  En nuestro caso, cuando Firefox intenta escribir en `/home/INSTITUTO/alumno`, AppArmor bloqueaba la acción porque consideraba que esa carpeta era del sistema y no del usuario, impidiendo que el programa arrancara.

### 3. Solución: El Script de Aprovisionamiento

Dado que configurar Snap para que funcione con rutas de red complejas es inestable y propenso a fallos con cada actualización, hemos creado un script de **aprovisionamiento inicial** que soluciona el problema de raíz y prepara el equipo para el futuro.

**¿Qué hace el script exactamente?**

1. **Limpieza (Eliminación de Snap):**
   Desinstala Firefox versión Snap y elimina el gestor `snapd` por completo. Esto quita la capa de aislamiento rígido que causaba el conflicto con las rutas del dominio.
2. **Bloqueo (Prevención):**
   Configura las preferencias de APT para "prohibir" que el sistema vuelva a instalar Snap automáticamente en el futuro.
3. **Instalación Nativa (Firefox .deb):**
   Instala la versión clásica de Firefox desde el repositorio oficial de Mozilla. Esta versión actúa como un programa normal de Linux: respeta los permisos del usuario del dominio y puede leer/escribir en `/home/INSTITUTO/` sin restricciones ni bloqueos.
4. **Preparación para el Futuro (Flatpak):**
   Instala **Flatpak** (una alternativa a Snap) y le aplica una regla global (`override`) para que tenga acceso de lectura/escritura en `/home/INSTITUTO`. El objetivo es que si el día de mañana un alumno necesita instalar una aplicación moderna que no está en los repositorios básicos (como Visual Studio Code o GIMP actualizado), podrá usar Flatpak y funcionará perfectamente sin dar los errores que daba Snap.
