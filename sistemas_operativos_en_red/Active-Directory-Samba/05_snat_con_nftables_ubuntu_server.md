# 05 SNAT con NFTABLES para Ubuntu Server

## Índice

1. [Conceptos de redes previos](#conceptos-de-redes-previos)
   - [¿Qué es SNAT (Source Network Address Translation)?](#qué-es-snat-source-network-address-translation)
   - [El Concepto General: NAT](#el-concepto-general-nat)
   - [¿Qué es NFTABLES?](#qué-es-nftables)
2. [Configuración de Ubuntu Server para dar salida al exterior](#configuración-de-ubuntu-server-para-dar-salida-al-exterior)
3. [Posibles problemas en Ubuntu Desktop](#posibles-problemas-en-ubuntu-desktop)
   - [1. Contexto y Problemática](#1-contexto-y-problemática)
   - [2. Conceptos Técnicos Clave](#2-conceptos-técnicos-clave)
   - [3. Solución: El Script de Aprovisionamiento](#3-solución-el-script-de-aprovisionamiento)

---

## Conceptos de redes previos

En este apartado vamos a realizar las modificaciones necesarias para que nuestro `DC-AD Ubuntu Server` actúe como un enrutador (router) utilizando la herramienta moderna de firewall en Linux llamada `nftables`. Esto permitirá que los clientes de la red interna puedan navegar por Internet.

### ¿Qué es SNAT (Source Network Address Translation)?

Es el mecanismo que permite que **varios equipos de una red privada salgan a Internet usando una sola dirección IP pública**.

- **El problema:** Tus equipos en casa o empresa (móviles, PCs) tienen IPs privadas (tipo `192.168.100.x`) que no son enrutables ni válidas en Internet. Si intentan salir con esa IP, los servidores de destino en Internet no sabrán adónde enviar las respuestas.
- **La solución (SNAT):** Cuando el paquete sale de tu red, el servidor `Ubuntu` (que actúa de intermediario o Gateway) **borra la IP privada de origen** del paquete y pone **su propia IP pública** (o la de la interfaz conectada a Internet).
- **El resultado:** Para el mundo exterior, es el servidor `Ubuntu` el único que está navegando. Cuando recibe la respuesta, consulta su tabla interna y se acuerda de a qué equipo privado debe devolvérsela.

### El Concepto General: NAT

**NAT (Network Address Translation)** es la acción de modificar las cabeceras de los paquetes IP (cambiando la IP de origen o la de destino) mientras atraviesan el router.

#### 1. Salir a Internet: SNAT + PAT

- **SNAT (Source NAT):** El router borra la IP Privada del cliente y pone la IP Pública en el campo "Origen" del paquete.
- **PAT (Port Address Translation):** Como el router tiene una sola IP Pública para muchos equipos, **usa los PUERTOS para distinguirlos**. El router anota en su tabla de conexiones: *"El Equipo A salió usando el puerto 10500"* y *"El Equipo B salió usando el puerto 20800"*. Cuando Google responde a la IP Pública, el router inspecciona el **puerto de destino** de esa respuesta. Si viene al `10500`, se lo pasa al Equipo A; si viene al `20800`, al Equipo B.

#### 2. Entrar desde Internet: DNAT

Aquí hablamos de tráfico nuevo, donde un equipo externo envía datos hacia nuestra red.

- **DNAT (Destination NAT):** El router recibe un paquete en su IP Pública (ej. en el puerto `80`) y verifica sus reglas. Una regla típica indica: *"Todo lo que venga al puerto 80, se envía internamente a la IP Privada 192.168.100.50"*. 
- Sin DNAT (también conocido como Port Forwarding), el firewall del router descartaría ese tráfico porque no sabría a qué equipo interno entregárselo.

#### Tabla Resumen

| Concepto | Significado            | Dirección del tráfico         | ¿Qué cambia?        | ¿Para qué sirve?                    | El "Truco"                                                                 |
| -------- | ---------------------- | ----------------------------- | ------------------- | ----------------------------------- | -------------------------------------------------------------------------- |
| **NAT**  | Traducción de Dir. Red | Cualquiera                    | IP Origen o Destino | Concepto general de traducción      | -                                                                          |
| **SNAT** | Source NAT             | **Salida** (LAN -> Internet)  | IP de **Origen**    | Navegar desde la red privada.       | Usa **PAT** (puertos aleatorios) para saber a quién devolver la respuesta. |
| **DNAT** | Destination NAT        | **Entrada** (Internet -> LAN) | IP de **Destino**   | Publicar un servidor (Web, SSH...). | Tú defines manualmente la regla (ej. Puerto 80 -> Servidor A).             |

**Analogía final:**

- **SNAT+PAT (Salida):** Es como la recepción de un edificio de oficinas. Todos los empleados dejan sus cartas en recepción. El conserje las envía todas con la dirección principal del edificio, pero anota en un cuaderno (Tabla NAT) *"Esta carta de respuesta es para la oficina 5"*.
- **DNAT (Entrada):** Es cuando le dices al conserje: *"Si llega un paquete a nombre de 'Administrador', mándalo directamente a la oficina 3"*.

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

Es el sucesor moderno y unificado de `iptables`. Es el subsistema del kernel de Linux encargado del filtrado de paquetes y clasificación de red (NAT).

- Es mucho más rápido, utiliza una sintaxis más limpia y lógica (inspirada en tcpdump) y combina IPv4 e IPv6 en un único framework.
- En `Ubuntu Server` (versiones recientes), `nftables` es el estándar predeterminado y recomendado por la comunidad.

---

## Configuración de Ubuntu Server para dar salida al exterior

Primero, debemos configurar nuestro `Ubuntu Server` para que los paquetes que reciba en su interfaz de red interna puedan ser reenviados (enrutados) hacia la interfaz que da salida a Internet.

1. **Habilitar el IP Forwarding (Enrutamiento):** Debemos indicar al kernel que actúe como router. Consultamos el valor actual y lo cambiamos temporalmente:

```bash
root@dc:~# cat /proc/sys/net/ipv4/ip_forward
0
root@dc:~# echo 1 > /proc/sys/net/ipv4/ip_forward
root@dc:~# cat /proc/sys/net/ipv4/ip_forward
1
```

> **Advertencia:** La modificación directa en `/proc/sys/` no es persistente y se perderá al reiniciar el equipo.

Para que el cambio sea permanente, editamos el fichero `/etc/sysctl.conf` y descomentamos la directiva `net.ipv4.ip_forward=1`.

```bash
root@dc:~# grep ip_forward /etc/sysctl.conf
net.ipv4.ip_forward=1
```

2. **Instalación de nftables:** Ahora realizamos la instalación de la herramienta. Vamos a configurar un SNAT dinámico (Masquerade) ya que en la mayoría de entornos con salida a Internet vía DHCP, la dirección IP pública o de salida de la interfaz externa (`enp0s3`) puede cambiar dinámicamente.

```bash
root@dc:~# apt update && apt install -y nftables
```

3. **Creación de la tabla NAT:** Creamos la estructura principal de la tabla para almacenar reglas relacionadas con la traducción de direcciones en la familia `ip` (IPv4).

```bash
root@dc:~# nft add table nat

root@dc:~# nft list tables
table ip nat
```

> **Nota:** Puedes eliminar la tabla completa con el comando `nft delete table nat`.

4. **Creación de la cadena:** Agregamos una nueva cadena llamada `postrouting` a la tabla `nat` previamente creada. Le indicamos al kernel que esta cadena interceptará el tráfico en la fase final de salida (`hook postrouting`), con una prioridad estándar (`100` o `srcnat`), que es el momento preciso donde los paquetes están a punto de abandonar la interfaz de red externa.

```bash
root@dc:~# nft add chain nat postrouting { type nat hook postrouting priority 100 \; }

root@dc:~# nft list chains
table ip nat {
        chain postrouting {
                type nat hook postrouting priority srcnat; policy accept;
        }
}
```

5. **Aplicación de la regla de enmascaramiento:** Creamos la regla para que nuestros equipos locales naveguen a través del servidor. 

Lógica de la regla: *"En la tabla NAT, dentro de la cadena postrouting: Si el paquete sale por la interfaz `enp0s3` y proviene de la red `192.168.100.0/24`, enmascara su IP origen (`masquerade`) y contabiliza los paquetes (`counter`)."*

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

En este punto, nuestro cliente interno ya debería tener salida a Internet.

> **Nota:** Puedes listar todas las reglas y cadenas del sistema con el comando `nft -a list ruleset`. Esto además mostrará el número de "handle", lo que te permite eliminar reglas concretas con `nft delete rule nat postrouting handle X`.

6. **Hacer persistentes las reglas:** Las reglas introducidas mediante comandos interactivos se borran al reiniciar. Debemos volcarlas al fichero de configuración principal `/etc/nftables.conf`.

Primero, revisamos las reglas en memoria, y luego sobreescribimos el archivo de configuración.

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

Para asegurar que `nftables` cargue estas reglas automáticamente en cada inicio del sistema, habilitamos e iniciamos el servicio en `systemd`.

```bash
root@dc:~# systemctl enable nftables
Created symlink /etc/systemd/system/sysinit.target.wants/nftables.service → /usr/lib/systemd/system/nftables.service.
root@dc:~# systemctl restart nftables
```

---

## Posibles problemas en Ubuntu Desktop

### 1. Configurar la puerta de enlace predeterminada

Para que el cliente `Ubuntu Desktop` sepa cómo llegar a Internet, debe tener configurado explícitamente a nuestro servidor AD (`192.168.100.6`) como su puerta de enlace (Gateway o router predeterminado). Editamos su fichero de configuración de red `Netplan`.

```yaml
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

### 2. Contexto y Problemática con Snap

En la integración de clientes Ubuntu modernos dentro de un dominio de Active Directory, nos enfrentamos a un error crítico al intentar ejecutar aplicaciones instaladas mediante **Snap** (como el navegador Firefox, que se instala así por defecto).

- **El Problema:** Al intentar abrir el navegador, la aplicación se cerraba inmediatamente y el sistema registraba errores de "Permission denied" o fallos de montaje de directorios virtuales.
- **La Causa:** Al unir el equipo al dominio usando Winbind y PAM, las carpetas personales de los usuarios se crean en rutas de red no estándar (ej. `/home/INSTITUTO/alumno`). El sistema de confinamiento de seguridad de Ubuntu (AppArmor/Snap) no está preparado para reconocer esta ruta compartida como un área segura válida del usuario.

### 3. Conceptos Técnicos Clave

- **¿Qué es Snap?** Es un sistema de gestión de paquetes desarrollado por Canonical. Una aplicación Snap se ejecuta en una "burbuja" aislada (sandbox) que no interactúa con el sistema principal de manera directa. Por defecto, Snap tiene reglas muy estrictas que asumen que los directorios de usuario siempre están bajo la ruta física `/home/usuario`.
- **¿Qué es AppArmor?** Es el módulo de control de acceso mandatorio (MAC) del kernel de Linux. Al intentar Snap acceder a un área no permitida en su perfil, AppArmor bloquea la acción para prevenir una posible intrusión, provocando que la aplicación falle al iniciar.

### 4. Solución: El Script de Aprovisionamiento

Debido a que forzar a Snap a comprender rutas dinámicas de dominio (Winbind) es inestable e inconsistente entre actualizaciones, la solución definitiva es reemplazar el sistema Snap por instalaciones nativas `.deb` y utilizar **Flatpak** (un sistema de sandbox similar a Snap pero más flexible) para el resto del software adicional.

A continuación, se detalla un script que soluciona el problema de raíz en la máquina `Ubuntu Desktop`.

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
apt-mark hold snapd # Evita que se reinstale accidentalmente mediante actualizaciones

# 2. BLOQUEAR REINSTALACIÓN AUTOMÁTICA DE SNAP
# Configura APT para que nunca priorice snap frente a paquetes deb
echo "[2/5] Bloqueando reinstalación de Snap..."
cat <<EOF > /etc/apt/preferences.d/nosnap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

# 3. INSTALAR FIREFOX NATIVO (.DEB)
# Añade el repositorio oficial de MozillaTeam (PPA) y le da prioridad
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

# 5. CONFIGURACIÓN GENERAL DE PERMISOS PARA FLATPAK
# Esto permite que CUALQUIER app Flatpak futura pueda leer/escribir en /home/INSTITUTO
echo "[5/5] Aplicando permisos globales para usuarios del dominio..."
flatpak override --system --filesystem=/home/INSTITUTO

echo "--- APROVISIONAMIENTO COMPLETADO ---"
echo "Firefox está listo y es una aplicación nativa."
echo "Snap ha sido eliminado por completo."
echo "Flatpak está configurado y tiene permisos sobre los perfiles móviles /home/INSTITUTO."
echo "Es recomendable reiniciar el equipo: sudo reboot"
```
