# Samba como servidor independiente (standalone) en Debian

> **Nota sobre autoría y licencia:** Estos apuntes son una adaptación al castellano, ampliada y actualizada a Debian 13, de la *Cheat-Sheet: Samba4 Debian GNU/Linux - Escenario Server Standalone* de **Ricardo Feijoo Costa** ([repoEDU-CCbySA](https://ricardofc.github.io/repoEDU-CCbySA/)), publicada bajo licencia [Creative Commons Reconocimiento-CompartirIgual 4.0 (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/deed.es). Por ese motivo, **este documento se distribuye también bajo la licencia CC BY-SA 4.0**, a diferencia del resto del repositorio. La continuación de estos apuntes, con Samba como controlador de dominio, está en el [documento 06](./06_samba_ad_dc.md).

## Índice

1. [Introducción: qué es Samba y qué es un servidor independiente](#1-introducción-qué-es-samba-y-qué-es-un-servidor-independiente)
2. [Escenario de la práctica](#2-escenario-de-la-práctica)
3. [Prioridad de permisos: las tres capas](#3-prioridad-de-permisos-las-tres-capas)
4. [Instalación](#4-instalación)
5. [El fichero de configuración smb.conf](#5-el-fichero-de-configuración-smbconf)
6. [Sección [global]](#6-sección-global)
7. [Secciones predefinidas: [homes], [printers] y [print$]](#7-secciones-predefinidas-homes-printers-y-print)
   1. [`[homes]`: las carpetas personales](#71-homes-las-carpetas-personales)
   2. [`[printers]`: las impresoras](#72-printers-las-impresoras)
   3. [`[print$]`: los controladores de impresora](#73-print-los-controladores-de-impresora)
8. [Crear recursos compartidos](#8-crear-recursos-compartidos)
   1. [Recurso `[temporal]`: carpeta con permiso de escritura](#81-recurso-temporal-carpeta-con-permiso-de-escritura)
   2. [Recurso `[descargas]`: solo lectura y control de usuarios, grupos y equipos](#82-recurso-descargas-solo-lectura-y-control-de-usuarios-grupos-y-equipos)
9. [Servicios](#9-servicios)
10. [Usuarios y grupos](#10-usuarios-y-grupos)
    1. [Paso 1: la cuenta de Unix](#101-paso-1-la-cuenta-de-unix)
    2. [Paso 2: el usuario de Samba](#102-paso-2-el-usuario-de-samba)
    3. [Listar usuarios y grupos](#103-listar-usuarios-y-grupos)
11. [Acceso a los recursos desde el cliente](#11-acceso-a-los-recursos-desde-el-cliente)
    1. [smbclient: acceso tipo consola](#111-smbclient-acceso-tipo-consola)
    2. [mount.cifs: montar el recurso como una carpeta](#112-mountcifs-montar-el-recurso-como-una-carpeta)
    3. [Montaje permanente en /etc/fstab](#113-montaje-permanente-en-etcfstab)
    4. [libpam-mount: montar al iniciar sesión](#114-libpam-mount-montar-al-iniciar-sesión)
12. [Ejemplos guiados](#12-ejemplos-guiados)
    1. [Ejemplo 1: verificación de permisos UGO en el servidor y en el cliente](#121-ejemplo-1-verificación-de-permisos-ugo-en-el-servidor-y-en-el-cliente)
    2. [Ejemplo 2: verificación del control de usuarios, grupos y equipos](#122-ejemplo-2-verificación-del-control-de-usuarios-grupos-y-equipos)
    3. [Ejemplo 3: montar `[homes]` al iniciar sesión y desmontarlo al cerrarla](#123-ejemplo-3-montar-homes-al-iniciar-sesión-y-desmontarlo-al-cerrarla)
    4. [Ejemplo 4: compartir impresoras con CUPS](#124-ejemplo-4-compartir-impresoras-con-cups)
13. [Gestión de arrays de discos RAID5 y RAID0](#13-gestión-de-arrays-de-discos-raid5-y-raid0)
14. [Apéndice: configuración de red](#14-apéndice-configuración-de-red)
    1. [Configuración manual](#141-configuración-manual)
    2. [El fichero /etc/network/interfaces](#142-el-fichero-etcnetworkinterfaces)

---

## 1. Introducción: qué es Samba y qué es un servidor independiente

**Samba** es la implementación libre del protocolo **SMB/CIFS** (*Server Message Block*), el que utiliza Windows para compartir carpetas e impresoras en red. Gracias a Samba, un servidor Linux puede ofrecer recursos compartidos a clientes Windows, Linux y macOS, e incluso actuar como controlador de un dominio Active Directory.

Samba puede funcionar en varios modos, que se eligen con la directiva `server role` de su fichero de configuración:

| Rol (`server role`) | Descripción |
|---|---|
| `standalone server` | **Servidor independiente**: gestiona sus propios usuarios y recursos, sin pertenecer a ningún dominio. Es el rol de este documento. |
| `member server` | Miembro de un dominio: comparte recursos, pero quien valida a los usuarios es el controlador de dominio. |
| `classic primary domain controller` | Controlador de dominio al estilo de Windows NT4. Obsoleto. |
| `classic backup domain controller` | Controlador de reserva al estilo de Windows NT4. Obsoleto. |
| `active directory domain controller` | Controlador de dominio Active Directory ([documento 06](./06_samba_ad_dc.md)). |

En un servidor independiente, cada usuario que quiera acceder a un recurso necesita una cuenta en el **propio servidor**. Es la configuración adecuada para una red pequeña o un grupo de trabajo, sin necesidad de montar un dominio.

> **Nota:** Samba y NFS ([documento 02](./02_NFS.md)) sirven para lo mismo, compartir carpetas en red, pero tienen orígenes distintos. NFS es el protocolo natural entre sistemas Linux y Unix, mientras que Samba es la opción cuando hay equipos Windows en la red o cuando se quiere que cada acceso se valide con usuario y contraseña.

---

## 2. Escenario de la práctica

La práctica se desarrolla en una **red NAT de VirtualBox** con tres máquinas virtuales:

| Equipo | Nombre | IP | Sistema | Función |
|---|---|---|---|---|
| A (servidor) | `lserver1` | `172.16.10.254/24` | Debian 13 | Servidor Samba, NTP y SSH. Disco `sda` para el sistema y `sdb`, `sdc`, `sdd` y `sde` (10 GB cada uno) para los arrays RAID. |
| B (cliente) | `lclient1` | `172.16.10.150/24` | Debian 13 | Cliente Samba y SSH. |
| C (cliente SSH) | `sshclient` | `172.16.10.10/24` | Debian 13 con XFCE | Cliente SSH con entorno gráfico. |

| Elemento de la red | Valor |
|---|---|
| Red NAT de VirtualBox | `LinuxNatNetwork`, `172.16.10.0/24` |
| Puerta de enlace (router) | `172.16.10.1` |
| Equipo anfitrión | `172.16.10.2` |
| Servidor DHCP de VirtualBox | `172.16.10.3`, que reparte el rango `172.16.10.4` - `172.16.10.254` |
| Servidores DNS | `8.8.4.4` y `8.8.8.8` |
| Credenciales del laboratorio | `root` / `abc123.` y `usuario` / `abc123.` |

```mermaid
flowchart LR
    INTERNET(("Internet"))
    subgraph NAT["Red NAT LinuxNatNetwork · 172.16.10.0/24"]
        GW["Router<br>172.16.10.1"]
        A["A · lserver1<br>172.16.10.254<br>Servidor Samba, NTP y SSH"]
        B["B · lclient1<br>172.16.10.150<br>Cliente Samba"]
        C["C · sshclient<br>172.16.10.10<br>Cliente SSH con XFCE"]
    end
    subgraph DISCOS["Discos de lserver1"]
        SDA["sda<br>Sistema"]
        RAID["sdb · sdc · sdd · sde<br>Arrays RAID"]
    end
    INTERNET --- GW
    GW --- A
    B -- "SMB / CIFS" --> A
    C -- "SSH" --> A
    A --- DISCOS
```

La red NAT se crea desde el equipo anfitrión, y se puede consultar en cualquier momento:

```powershell
PS C:\> VBoxManage natnetwork add --netname LinuxNatNetwork --network "172.16.10.0/24" --enable --dhcp on
PS C:\> VBoxManage list natnets
NetworkName:    LinuxNatNetwork
IP:             172.16.10.1
Network:        172.16.10.0/24
...
```

> **Nota:** En el escenario original, el equipo C tenía la IP `172.16.10.2`, pero en una red NAT de VirtualBox esa dirección está reservada para el **equipo anfitrión**, como se ve en la tabla anterior. Asignarla a una máquina virtual provoca conflictos, así que en estos apuntes se usa `172.16.10.10`.

> **Advertencia:** Las IP fijas del servidor y del cliente están **dentro del rango del DHCP** de VirtualBox. Como el DHCP suele repartir las direcciones desde la `.4` hacia arriba, en un laboratorio pequeño no llegan a chocar, pero si se quiere evitar del todo el riesgo se puede desactivar el DHCP de la red (`VBoxManage natnetwork modify --netname LinuxNatNetwork --dhcp off`) y usar solo IP fijas.

> **Nota:** El escenario original usa nombres de interfaz del tipo `eth0`. En Debian 13 sobre VirtualBox, la primera tarjeta de red se llama normalmente `enp0s3`; se comprueba con `ip a` ([documento 31](../apuntes/31_Configuracion_de_red.md)). Las credenciales `abc123.` son solo para el laboratorio.

---

## 3. Prioridad de permisos: las tres capas

Antes de configurar nada conviene entender la idea más importante de Samba, porque explica la mayoría de los «¿por qué no puedo escribir?». Cuando un cliente crea o modifica un fichero en un recurso compartido, intervienen **tres capas de permisos**, de mayor a menor prioridad:

```mermaid
flowchart TB
    C1["1 · Sistema de ficheros del servidor<br>Permisos UGO y ACL reales de la carpeta<br>chmod 0775 /srv/temporal"]
    C2["2 · Configuración de Samba<br>Directivas del recurso en smb.conf<br>read only · valid users · create mask"]
    C3["3 · Opciones de montaje en el cliente<br>Cómo ve el cliente los ficheros<br>uid · gid · file_mode · dir_mode"]
    C1 -->|"Samba nunca puede dar más permisos que el sistema de ficheros"| C2
    C2 -->|"El cliente solo cambia cómo los ve, no los permisos reales"| C3
```

| Capa | Dónde se configura | Ejemplo del escenario | Qué controla |
|---|---|---|---|
| **1. Sistema de ficheros del servidor** | `chmod`, `chgrp` y `setfacl` sobre la carpeta real | `chmod 0775 /srv/temporal` y grupo `g-usuarios` | Si el usuario puede entrar, leer o escribir. Es la capa que manda: Samba trabaja con la identidad del usuario conectado y el núcleo de Linux aplica estos permisos. |
| **2. Configuración de Samba** | Sección del recurso en `/etc/samba/smb.conf` | `create mask = 0660` y `directory mask = 0770` | Quién puede conectarse al recurso, si es de solo lectura y con qué permisos se crean los ficheros **en el servidor**. |
| **3. Montaje en el cliente** | Opciones de `mount` en el cliente | `uid=1000,gid=1000,file_mode=0664,dir_mode=0700` | Con qué propietario y permisos **muestra** el cliente los ficheros. No cambia lo que hay en el servidor. |

> **Importante:** Una consecuencia que desconcierta al principio es que **lo que se ve en el cliente puede no coincidir con lo que hay en el servidor**. Un fichero puede aparecer en el cliente con permisos `764` mientras que en el servidor tiene `660`. Los permisos que valen son siempre los del servidor; el ejemplo del apartado 12.1 lo comprueba paso a paso.

---

## 4. Instalación

```bash
root@lserver1:~# echo 'samba-common samba-common/dhcp boolean false' | debconf-set-selections
root@lserver1:~# dpkg -l samba ; [ $? -ne 0 ] && apt update && apt -y install samba
root@lserver1:~# smbd -V
Version 4.22.11-Debian-4.22.11+dfsg-0+deb13u1
```

| Orden | Qué hace |
|---|---|
| `debconf-set-selections` | Responde de antemano a una pregunta del instalador del paquete: si se quiere que `smb.conf` use la configuración WINS que reparta el DHCP. Se responde que **no** (`false`), y así la instalación no pregunta nada. |
| `dpkg -l samba ; [ $? -ne 0 ] && ...` | `dpkg -l` devuelve un código distinto de `0` si el paquete no aparece en la base de datos de `dpkg`. Solo en ese caso se actualizan los repositorios y se instala Samba. |
| `smbd -V` | Muestra la versión de Samba instalada. |

> **Nota:** `apt install` no vuelve a instalar un paquete que ya está instalado, así que el `if` es más una buena costumbre de *scripting* que una necesidad. Ojo con un detalle: `dpkg -l` también devuelve `0` para un paquete **eliminado pero no purgado** (estado `rc`, [documento 27](../apuntes/27_Gestion_de_paquetes.md)), así que en ese caso no lo reinstalaría. Para comprobar si está realmente instalado, `dpkg -s samba` es más preciso.

---

## 5. El fichero de configuración smb.conf

Toda la configuración de Samba está en **`/etc/samba/smb.conf`**. Su documentación está en `man 5 smb.conf` (todas las directivas), `man 7 samba` (visión general) y `man 8 samba` (el demonio del controlador de dominio). Los elementos del fichero son:

| Elemento | Significado |
|---|---|
| `#` | Comentario. En el fichero de Debian se usa para las explicaciones y para las opciones que **ya tienen** su valor por defecto. |
| `;` | También es un comentario, pero Debian lo reserva para opciones que **difieren** de las de por defecto y que basta con descomentar para activarlas. |
| `[global]` | Sección **obligatoria** con la configuración global del servidor. |
| `[homes]` | Sección **opcional** que comparte la carpeta personal de cada usuario. |
| `[printers]` | Sección **opcional** que comparte las impresoras del servidor. |
| `[print$]` | Sección **opcional** que comparte los controladores de las impresoras de `[printers]`. |
| `[nombre]` | Cualquier otra sección define un **recurso compartido** con ese nombre. |

Cada vez que se modifica el fichero conviene comprobar su sintaxis con **`testparm`**, que además muestra la configuración que Samba aplicará realmente, y después recargar la configuración:

```bash
root@lserver1:~# testparm -s
Load smb config files from /etc/samba/smb.conf
Loaded services file OK.
Server role: ROLE_STANDALONE
...
root@lserver1:~# smbcontrol all reload-config
```

El `smb.conf` de Debian es muy largo por la cantidad de comentarios. Para trabajar más cómodamente se puede guardar una copia del original y dejar solo las líneas activas:

```bash
root@lserver1:~# cp /etc/samba/smb.conf /etc/samba/smb.conf.orig
root@lserver1:~# apt -y install moreutils
root@lserver1:~# grep -vE '^#|^;' /etc/samba/smb.conf | sed -e '/^$/d' | sponge /etc/samba/smb.conf
```

> **Nota:** `grep -vE '^#|^;'` elimina las líneas que empiezan por `#` o `;`, y `sed -e '/^$/d'` borra las líneas vacías. El resultado no puede redirigirse con `>` sobre el propio `smb.conf`, porque el shell vaciaría el fichero antes de que `grep` llegara a leerlo ([documento 10](../apuntes/10_Redirecciones.md)). **`sponge`**, del paquete `moreutils`, resuelve el problema: primero «absorbe» toda la entrada y solo al final escribe el fichero.

En las directivas de `smb.conf` se pueden usar **variables** que Samba sustituye en cada conexión:

| Variable | Se sustituye por |
|---|---|
| `%U` | El nombre del usuario que inicia la sesión. |
| `%u` | El nombre del usuario del recurso actual. |
| `%S` | El nombre del recurso compartido actual. |
| `%H` | La carpeta personal del usuario `%u`. |
| `%m` | El nombre NetBIOS del equipo cliente. |
| `%I` | La dirección IP del equipo cliente. |

---

## 6. Sección [global]

Estas son las directivas de la sección `[global]` que trae la configuración de Debian:

| Directiva | Significado |
|---|---|
| `workgroup = WORKGROUP` | Nombre del grupo de trabajo al que pertenece el servidor. `WORKGROUP` es el que usa Windows por defecto. |
| `log file = /var/log/samba/log.%m` | Usa un fichero de registro distinto por cada equipo que se conecta (`%m`). |
| `max log size = 1000` | Limita el tamaño de cada fichero de registro a 1000 KiB. |
| `logging = file` | Envía los registros a ficheros en `/var/log/samba/` (`log.smbd`, `log.nmbd`...). |
| `panic action = /usr/share/samba/panic-action %d` | Acción a ejecutar si Samba sufre un fallo grave: envía un correo con el problema al administrador. |
| `server role = standalone server` | Modo de funcionamiento de Samba, en este caso **servidor independiente** (ver el apartado 1). |
| `obey pam restrictions = yes` | Samba respeta las restricciones de PAM sobre las cuentas y las sesiones. |
| `unix password sync = yes` | Cuando un usuario cambia su contraseña de Samba desde un cliente, se cambia también su contraseña de Unix. |
| `passwd program = /usr/bin/passwd %u` | Programa que Samba ejecuta para cambiar la contraseña de Unix. |
| `passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .` | «Diálogo» que Samba mantiene con `passwd`: espera cada mensaje y responde con la nueva contraseña (`%n`). Junto con las dos anteriores, hace funcionar la sincronización de contraseñas en Debian. |
| `pam password change = yes` | Usa PAM para cambiar la contraseña, en lugar del diálogo con `passwd`. |
| `map to guest = bad user` | Si alguien se conecta con un nombre de usuario **que no existe**, se le trata como invitado (acceso anónimo). Un usuario existente con contraseña incorrecta sigue siendo rechazado. |
| `usershare allow guests = yes` | Los usuarios del sistema pueden crear sus propios recursos compartidos (*usershares*) con acceso de invitados. |

> **Nota:** Para convertir el servidor en controlador de dominio, el rol no se cambia a mano en este fichero, sino con la orden `samba-tool domain provision`, que genera una configuración nueva. Es el punto de partida del [documento 06](./06_samba_ad_dc.md).

---

## 7. Secciones predefinidas: [homes], [printers] y [print$]

### 7.1 `[homes]`: las carpetas personales

Es una sección especial: no define un único recurso, sino uno **por cada usuario**. Cuando el usuario `ana` se conecta a `\\lserver1\ana`, Samba le ofrece su carpeta personal `/home/ana`. En el `smb.conf` de Debian viene comentada con `;`, así que hay que descomentarla para activarla.

| Directiva | Significado |
|---|---|
| `comment = Home Directories` | Descripción que se muestra al explorar el recurso. |
| `browseable = no` | El recurso no aparece en la lista al explorar la red. Cada usuario accede a la suya escribiendo su nombre. |
| `read only = yes` | Solo lectura. Para poder escribir hay que cambiarlo a `no`. |
| `create mask = 0700` | Permisos máximos de los ficheros creados en la carpeta (`rwx --- ---`). Controla los permisos UGO en el servidor. |
| `directory mask = 0700` | Permisos máximos de los directorios creados en la carpeta (`rwx --- ---`). |
| `valid users = %S` | Solo puede entrar el usuario cuyo nombre coincide con el del recurso (`%S`): `ana` en `\\lserver1\ana`, que corresponde a `/home/ana`. |

> **Importante:** Conviene distinguir las directivas *mask* de las *force mode*, porque hacen operaciones opuestas sobre los permisos que pide el cliente:
>
> | Directiva | Operación | Efecto |
> |---|---|---|
> | `create mask`, `directory mask` | Y lógico (`AND`) | Fijan el **máximo**: quitan cualquier permiso que no esté en la máscara. |
> | `force create mode`, `force directory mode` | O lógico (`OR`) | Fijan el **mínimo**: añaden siempre esos permisos. |
>
> Samba aplica primero la máscara y después el *force mode*. Por ejemplo, con `create mask = 0660`, un fichero que el cliente pide con `0777` se crea con `0660`.

### 7.2 `[printers]`: las impresoras

| Directiva | Significado |
|---|---|
| `comment = All Printers` | Descripción del recurso. |
| `browseable = no` | La sección no aparece como recurso; sí aparecen las impresoras que comparte. |
| `path = /var/tmp` | Carpeta de cola donde se dejan los trabajos de impresión antes de enviarlos a la impresora. |
| `printable = yes` | Indica que es un recurso de **impresora**, no de ficheros. |
| `guest ok = no` | Solo pueden imprimir los usuarios autenticados. |
| `read only = yes` | No se pueden escribir ficheros en el recurso (los trabajos de impresión sí se aceptan). |
| `create mask = 0700` | Permisos máximos de los trabajos guardados en la cola (`rwx --- ---`). |

### 7.3 `[print$]`: los controladores de impresora

| Directiva | Significado |
|---|---|
| `comment = Printer Drivers` | Descripción del recurso. |
| `path = /var/lib/samba/printers` | Carpeta con los controladores de impresora que descargan los clientes Windows. |
| `browseable = yes` | El recurso aparece al explorar la red. |
| `read only = yes` | Solo lectura. |
| `guest ok = no` | Solo para usuarios autenticados. |

---

## 8. Crear recursos compartidos

Los dos recursos de este apartado usan el grupo `g-usuarios` y los usuarios `ana` y `xurxo`, que se crean en el apartado 10. Si se sigue el documento en orden, hay que crear el grupo antes de ejecutar el `chgrp`: `groupadd g-usuarios`.

### 8.1 Recurso `[temporal]`: carpeta con permiso de escritura

Se prepara la carpeta real en el servidor:

```bash
root@lserver1:~# mkdir /srv/temporal && chgrp g-usuarios /srv/temporal && chmod 0775 /srv/temporal
```

Y se añade la sección al final de `smb.conf`:

```ini
[temporal]
   comment = temporal
   path = /srv/temporal
   browseable = yes
   read only = no
   create mask = 0660
   directory mask = 0770
```

| Directiva | Significado |
|---|---|
| `comment = temporal` | Descripción del recurso. |
| `path = /srv/temporal` | Carpeta real que se comparte. |
| `browseable = yes` | El recurso aparece al explorar la red. |
| `read only = no` | Permite escribir. |
| `create mask = 0660` | Permisos máximos de los ficheros creados (`rw- rw- ---`). |
| `directory mask = 0770` | Permisos máximos de los directorios creados (`rwx rwx ---`). |

### 8.2 Recurso `[descargas]`: solo lectura y control de usuarios, grupos y equipos

```bash
root@lserver1:~# mkdir /srv/descargas && chgrp g-usuarios /srv/descargas && chmod 2770 /srv/descargas
```

```ini
[descargas]
   comment = descargas
   path = /srv/descargas
   browseable = yes
   read only = yes
   guest ok = no
   valid users = ana, @g-usuarios
   invalid users = xurxo, @g-external
   hosts allow = 127.0.0.1 172.16.10.0/24 lclient1
   hosts deny = 172.16.10.150 lclient2
```

| Directiva | Significado |
|---|---|
| `read only = yes` | Solo lectura. |
| `guest ok = no` | Solo usuarios autenticados. |
| `valid users = ana, @g-usuarios` | Solo pueden entrar el usuario `ana` y los miembros del grupo `g-usuarios` (la `@` indica que es un grupo). |
| `invalid users = xurxo, @g-external` | Nunca pueden entrar el usuario `xurxo` ni los miembros del grupo `g-external`. |
| `hosts allow = 127.0.0.1 172.16.10.0/24 lclient1` | Equipos desde los que se permite el acceso: el propio servidor, toda la red del laboratorio y el equipo `lclient1`. |
| `hosts deny = 172.16.10.150 lclient2` | Equipos desde los que se deniega el acceso. |

> **Nota:** El permiso `2770` incluye el bit **SGID** (el `2` inicial). Aplicado a un directorio, hace que todo lo que se cree dentro herede su grupo (`g-usuarios`) en lugar del grupo principal de quien lo crea. Es lo habitual en las carpetas compartidas por un grupo.

Cuando varias directivas se contradicen, Samba sigue estas reglas de prioridad:

| Conflicto | Qué prevalece |
|---|---|
| Un usuario está en `valid users` y en `invalid users` | **`invalid users`**: se le deniega el acceso. |
| Un equipo está en `hosts allow` y en `hosts deny` | **`hosts allow`**: se le permite el acceso. |
| El equipo está denegado, pero el usuario es válido | **`hosts deny`**: los equipos se comprueban antes que los usuarios, así que no llega a validarse el usuario. |

> **Importante:** La configuración anterior contiene a propósito uno de esos conflictos. `lclient1` es precisamente el equipo `172.16.10.150`: aparece en `hosts allow` (por su nombre y por estar en la red `172.16.10.0/24`) y a la vez en `hosts deny`. Como **gana `hosts allow`**, `lclient1` **sí puede acceder**, y así se comprobará en los ejemplos. Para excluir de verdad un equipo concreto de una red permitida, la forma correcta es la palabra clave `EXCEPT`:
>
> ```ini
>    hosts allow = 127.0.0.1 172.16.10.0/24 EXCEPT 172.16.10.150
> ```

> **Advertencia:** Los **nombres de equipo** en `hosts allow` y `hosts deny` (`lclient1`, `lclient2`) solo funcionan si se añade `hostname lookups = yes` en `[global]`, porque por defecto Samba compara únicamente direcciones IP. Además, el servidor debe poder resolver esos nombres, por ejemplo con entradas en su `/etc/hosts`. Por eso es más fiable usar direcciones IP.

---

## 9. Servicios

En un servidor independiente, Samba funciona con dos servicios:

| Servicio | Función |
|---|---|
| `smbd` | Ofrece los recursos compartidos de ficheros e impresoras y atiende las peticiones SMB/CIFS de los clientes (puertos TCP 445 y 139). |
| `nmbd` | Resuelve los nombres NetBIOS a direcciones IP, para que los clientes encuentren los recursos al explorar la red (puertos UDP 137 y 138). |

| Orden | Acción |
|---|---|
| `systemctl status smbd && systemctl status nmbd` | Ver el estado. |
| `systemctl start smbd && systemctl start nmbd` | Arrancar. |
| `systemctl stop smbd && systemctl stop nmbd` | Parar. |
| `systemctl reload smbd && systemctl reload nmbd` | Recargar la configuración. |
| `smbcontrol all reload-config` | Recargar la configuración de todos los procesos de Samba. |

```bash
root@lserver1:~# ss -tulpn | grep -E 'smbd|nmbd'
udp   UNCONN 0  0  172.16.10.255:137  0.0.0.0:*  users:(("nmbd",pid=812,fd=15))
udp   UNCONN 0  0  172.16.10.255:138  0.0.0.0:*  users:(("nmbd",pid=812,fd=17))
tcp   LISTEN 0  50       0.0.0.0:445  0.0.0.0:*  users:(("smbd",pid=830,fd=27))
tcp   LISTEN 0  50       0.0.0.0:139  0.0.0.0:*  users:(("smbd",pid=830,fd=28))
```

> **Nota:** Al instalar Samba en Debian, el servicio del controlador de dominio (`samba-ad-dc`) queda desactivado y se usan `smbd` y `nmbd`. Cuando Samba se convierte en controlador de dominio ocurre lo contrario: se paran `smbd` y `nmbd` y se activa `samba-ad-dc`, tal como se explica en el [documento 06](./06_samba_ad_dc.md).

> **Nota:** Windows 10 y 11 ya no usan NetBIOS para descubrir equipos en la red, así que el servidor puede no aparecer en «Red» del Explorador, aunque se pueda acceder a él escribiendo `\\lserver1` o `\\172.16.10.254`. Para que aparezca hace falta un servicio de *WS-Discovery*, como el del paquete `wsdd2`.

---

## 10. Usuarios y grupos

### 10.1 Paso 1: la cuenta de Unix

Para que un usuario pueda acceder a Samba, **antes debe existir como usuario de Unix** en el servidor. Samba necesita esa cuenta para saber con qué UID y GID trabajar en el sistema de ficheros. Puede ser un usuario completo, con carpeta personal y shell:

```bash
root@lserver1:~# useradd -m -d /home/user -p $(mkpasswd -m sha-512 abc123.) -s /bin/bash user
```

Pero no hacen falta ni una shell válida ni una carpeta personal: basta con una cuenta de Unix habilitada. Para usuarios que solo van a usar Samba, lo más seguro es que **no puedan iniciar sesión** en el servidor:

```bash
root@lserver1:~# apt -y install whois
root@lserver1:~# useradd -M -s /usr/sbin/nologin -p $(mkpasswd -m sha-512 abc123.) user
```

| Opción | Significado |
|---|---|
| `-M` | No crea carpeta personal. |
| `-s /usr/sbin/nologin` | Shell que rechaza el inicio de sesión. |
| `-p $(mkpasswd -m sha-512 abc123.)` | Asigna una contraseña de Unix ya cifrada. `mkpasswd`, del paquete `whois`, genera el *hash* SHA-512 que espera `/etc/shadow`. |

Los usuarios y grupos que se usan en los ejemplos de este documento son:

```bash
root@lserver1:~# useradd -M -s /usr/sbin/nologin -p $(mkpasswd -m sha-512 abc123.) ana
root@lserver1:~# useradd -M -s /usr/sbin/nologin -p $(mkpasswd -m sha-512 abc123.) xurxo
root@lserver1:~# groupadd g-usuarios
root@lserver1:~# usermod -aG g-usuarios ana
root@lserver1:~# groupadd g-external
root@lserver1:~# usermod -aG g-external xurxo
```

> **Advertencia:** Escribir una contraseña en la línea de órdenes, aunque sea para generar su *hash*, la deja guardada en `~/.bash_history` y visible en `ps` mientras se ejecuta. Es aceptable en un laboratorio, pero en un servidor real la contraseña se pide de forma interactiva.

### 10.2 Paso 2: el usuario de Samba

Una vez existe la cuenta de Unix, se crea el usuario de Samba con **`smbpasswd`**. Samba guarda sus propias contraseñas en su base de datos (`/var/lib/samba/private/passdb.tdb`), y **no tienen por qué coincidir** con las de Unix:

```bash
root@lserver1:~# smbpasswd -a ana
New SMB password:
Retype new SMB password:
Added user ana.
```

| Orden | Acción |
|---|---|
| `smbpasswd -a user_samba` | Añade el usuario a Samba y establece su contraseña. Si ya existe, le cambia la contraseña (pulsando Intro sin escribir nada se deja la misma). |
| `smbpasswd -x user_samba` | Elimina el usuario de Samba. La cuenta de Unix no se toca. |
| `smbpasswd -d user_samba` | Deshabilita el usuario de Samba. |
| `smbpasswd -e user_samba` | Vuelve a habilitar el usuario. |

La documentación está en `man 8 smbpasswd` (la orden) y `man 5 smbpasswd` (el formato del fichero).

### 10.3 Listar usuarios y grupos

| Orden | Acción |
|---|---|
| `pdbedit -L` | Lista los usuarios de Samba. `pdbedit` es la evolución de `smbpasswd`. |
| `pdbedit -Lv` | Lo mismo, con todos los detalles de cada cuenta. |
| `getent passwd && getent group` | Lista los usuarios y grupos del **sistema**, según las fuentes de `/etc/nsswitch.conf`. No incluye los de un dominio Samba salvo que se configure para ello ([documento 06](./06_samba_ad_dc.md)). |

```bash
root@lserver1:~# pdbedit -L
ana:1001:
xurxo:1002:
```

---

## 11. Acceso a los recursos desde el cliente

En los ejemplos se usan estos nombres:

| Nombre | Representa |
|---|---|
| `lserver1` | El nombre (o la IP) del servidor Samba. |
| `Sharelserver1` | El nombre del recurso compartido en el servidor (`temporal`, `descargas`...). |
| `FolderClient` | La carpeta del cliente donde se monta el recurso. |
| `WORKGROUP` | El grupo de trabajo. |

Para que el cliente encuentre al servidor por su nombre, se añade al `/etc/hosts` del cliente:

```bash
root@lclient1:~# echo '172.16.10.254 lserver1' | tee -a /etc/hosts
```

### 11.1 smbclient: acceso tipo consola

`smbclient` es un cliente de línea de órdenes, similar a un cliente FTP:

```bash
root@lclient1:~# apt -y install smbclient
root@lclient1:~# smbclient -L //lserver1 -U%
root@lclient1:~# smbclient -L //lserver1 -Uana
root@lclient1:~# smbclient //lserver1/descargas -Uana
Password for [WORKGROUP\ana]:
Try "help" to get a list of possible commands.
smb: \>
```

| Orden | Acción |
|---|---|
| `smbclient -L //lserver1 -U%` | Lista los recursos compartidos con acceso **anónimo** (`-U%` significa usuario y contraseña vacíos). |
| `smbclient -L //lserver1 -Uana` | Lista los recursos compartidos con acceso **autenticado**. |
| `smbclient //lserver1/descargas -Uana` | Abre una consola en el recurso `[descargas]` con acceso autenticado. |

Dentro de la consola `smb: \>` se trabaja con órdenes parecidas a las de FTP:

| Orden | Acción |
|---|---|
| `ls` | Lista el contenido del recurso. |
| `cd carpeta` | Cambia de carpeta en el recurso. |
| `get fichero` / `put fichero` | Descarga o sube un fichero. |
| `mget patrón` / `mput patrón` | Descarga o sube varios ficheros. |
| `lcd carpeta` | Cambia de carpeta en el equipo local. |
| `exit` | Sale de la consola. |

### 11.2 mount.cifs: montar el recurso como una carpeta

Lo más cómodo es montar el recurso en una carpeta del cliente, de forma que se use como cualquier otra. Se necesita el paquete `cifs-utils` (`man mount.cifs`):

```bash
root@lclient1:~# apt -y install cifs-utils
root@lclient1:~# mkdir -p /mnt/temporal
root@lclient1:~# mount -t cifs //lserver1/temporal /mnt/temporal -o user=ana,uid=1000,gid=1000,file_mode=0660,dir_mode=0770
Password for ana@//lserver1/temporal:
root@lclient1:~# umount /mnt/temporal
```

`mount.cifs //lserver1/temporal /mnt/temporal -o ...` es equivalente a `mount -t cifs`. Las opciones de montaje son:

| Opción | Significado |
|---|---|
| `user=ana` | Usuario de Samba con el que se accede. |
| `uid=1000`, `gid=1000` | Usuario y grupo **del cliente** que aparecerán como propietarios de los ficheros. |
| `file_mode=0660`, `dir_mode=0770` | Permisos con los que el cliente **muestra** los ficheros y directorios. |

Desde un escritorio gráfico también se puede acceder sin montar nada, instalando `gvfs-backends` y escribiendo en el gestor de archivos (por ejemplo Thunar, con Alt+F2 y `thunar`) la dirección `smb://lserver1/temporal`.

> **Nota:** El cliente y el servidor negocian automáticamente la versión del protocolo, que hoy es SMB 3. **No debe forzarse `vers=1.0`**: SMB1 es inseguro y Samba lo tiene desactivado por defecto desde la versión 4.11 (`server min protocol = SMB2_02`), así que ese montaje fallaría.

### 11.3 Montaje permanente en /etc/fstab

Para que el recurso se monte en cada arranque, o con `mount -a`, se añade una línea en `/etc/fstab`:

```bash
root@lclient1:~# echo '//lserver1/temporal /mnt/temporal cifs user=ana,password=abc123.,uid=1000,gid=1000,file_mode=0660,dir_mode=0770 0 0' >> /etc/fstab
```

> **Advertencia:** `/etc/fstab` puede leerlo cualquier usuario del sistema, así que guardar en él la contraseña la deja al alcance de todos. La forma correcta es un **fichero de credenciales** que solo pueda leer `root`:

```bash
root@lclient1:~# echo -e 'username=ana\npassword=abc123.' > /root/file_credentials.txt
root@lclient1:~# chown root:root /root/file_credentials.txt
root@lclient1:~# chmod 400 /root/file_credentials.txt
root@lclient1:~# echo '//lserver1/temporal /mnt/temporal cifs credentials=/root/file_credentials.txt,uid=1000,gid=1000,file_mode=0660,dir_mode=0770,nofail 0 0' >> /etc/fstab
root@lclient1:~# mount -a
```

> **Nota:** La opción `nofail` evita que el arranque del cliente se quede esperando si el servidor no está disponible. Para el recurso `[homes]` hay que tener en cuenta las dos capas: el montaje debe ser de lectura y escritura (`rw`, el valor por defecto) **y** en el servidor la sección `[homes]` debe tener `read only = no`.

### 11.4 libpam-mount: montar al iniciar sesión

El paquete `libpam-mount` monta automáticamente un recurso compartido cuando el usuario **inicia sesión** y lo desmonta cuando **la cierra**, sin que tenga que escribir sus credenciales. Para ello aprovecha la contraseña que el usuario acaba de teclear al iniciar sesión, y de ahí su requisito fundamental:

> **Importante:** La contraseña del usuario en el cliente (Unix) debe ser **la misma** que su contraseña de Samba en el servidor (`smbpasswd -a`), porque `pam_mount` reutiliza la del inicio de sesión para montar el recurso.

La configuración global está en **`/etc/security/pam_mount.conf.xml`** (y cada usuario puede tener la suya en `~/.pam_mount.conf.xml`). Cada recurso se define con un elemento `<volume>`:

| Atributo | Significado |
|---|---|
| `user`, `uid` | Limita el volumen a ciertos usuarios. |
| `pgrp` | Limita el volumen a los usuarios cuyo grupo **principal** es el indicado. |
| `sgrp` | Limita el volumen a los usuarios que pertenecen al grupo, sea principal o secundario. |
| `fstype` | Tipo de sistema de ficheros: `cifs` para Samba. |
| `server`, `path` | Servidor y recurso compartido. `path="homes"` corresponde a la sección `[homes]`. |
| `mountpoint` | Carpeta del cliente donde se monta. Si no existe, se crea. |
| `options` | Opciones de montaje, las mismas que en `mount.cifs`. |

En los atributos se pueden usar variables de `pam_mount` como `%(USER)` (el nombre del usuario) o `%(USERUID)` (su UID). Por ejemplo, este volumen monta la carpeta personal del servidor de cada usuario en `/mnt/<usuario>`:

```xml
<volume user="*" fstype="cifs" server="lserver1" path="homes" mountpoint="/mnt/%(USER)"
        options="nodev,nosuid,workgroup=WORKGROUP,iocharset=utf8,file_mode=0700,dir_mode=0700" />
```

> **Nota:** No hace falta indicar `uid` ni `gid` en las opciones: la orden de montaje CIFS que trae `pam_mount` por defecto ya añade `username=%(USER),uid=%(USERUID),gid=%(USERGID)`, de modo que los ficheros aparecen a nombre del usuario que inicia sesión. El escenario original añadía también `vers=1.0`, que hoy hay que quitar por lo explicado en el apartado 11.2.

---

## 12. Ejemplos guiados

### 12.1 Ejemplo 1: verificación de permisos UGO en el servidor y en el cliente

Este ejemplo comprueba en la práctica las tres capas de permisos. Las opciones de montaje del cliente que intervienen son:

| Opción | Significado |
|---|---|
| `uid=número/usuario` | Propietario que muestra el cliente cuando el servidor no proporciona esa información. Por defecto, `0`. |
| `forceuid` | Obliga a usar el `uid` indicado aunque el servidor proporcione otro. |
| `gid=número/grupo` | Grupo que muestra el cliente cuando el servidor no proporciona esa información. Por defecto, `0`. |
| `forcegid` | Obliga a usar el `gid` indicado aunque el servidor proporcione otro. |
| `file_mode`, `dir_mode` | Permisos con los que el cliente muestra ficheros y directorios. |

> **Recuerda:** Una vez montado el recurso, cambiar en el cliente los permisos con `chmod` o `chown` no da error, pero **no tiene ningún efecto**: los permisos reales los decide el servidor.

En el servidor, el recurso `[temporal]` es como el del apartado 8.1, pero con la carpeta en `0770`:

```bash
root@lserver1:~# chmod 0770 /srv/temporal
root@lserver1:~# ls -ld /srv/temporal
drwxrwx--- 2 root g-usuarios 4096 oct  6 12:05 /srv/temporal
```

En el cliente, `ana` monta el recurso. `ana` es un usuario de Samba que **no tiene por qué existir en el cliente**; `uid=1001` y `gid=1001` son números del cliente:

```bash
root@lclient1:~# mkdir /mnt/temporal
root@lclient1:~# mount.cifs //lserver1/temporal /mnt/temporal -o user=ana,uid=1001,gid=1001,file_mode=0764,dir_mode=0755
root@lclient1:~# mkdir /mnt/temporal/dir1-ana && touch /mnt/temporal/f1-ana.txt
root@lclient1:~# ls -l /mnt/temporal
drwxr-xr-x 2 1001 1001 0 oct  6 12:10 dir1-ana
-rwxrw-r-- 1 1001 1001 0 oct  6 12:10 f1-ana.txt
```

En el cliente, el fichero aparece con permisos `764` y el directorio con `755`, que son los de las opciones de montaje. Si en el cliente existiera un usuario con UID `1001`, aparecería su nombre en lugar del número. Pero en el servidor la realidad es otra:

```bash
root@lserver1:~# ls -l /srv/temporal
drwxrwx--- 2 ana ana 4096 oct  6 12:10 dir1-ana
-rw-rw---- 1 ana ana    0 oct  6 12:10 f1-ana.txt
```

En el servidor, el fichero tiene `660` y el directorio `770`, tal como marcan `create mask` y `directory mask`, y su propietario es el usuario de Samba que montó el recurso, `ana`.

> **Nota:** Si se quisiera que en el cliente solo `ana` viera permisos sobre lo que crea, se montaría con `file_mode=0600,dir_mode=0700`. Pero eso solo cambiaría lo que muestra el cliente, no los permisos del servidor.

Ahora se intenta lo mismo con `xurxo`, que no es `ana` ni pertenece al grupo `g-usuarios` en el servidor:

```bash
root@lclient1:~# umount /mnt/temporal
root@lclient1:~# mount.cifs //lserver1/temporal /mnt/temporal -o user=xurxo,uid=1001,gid=1001,file_mode=0764,dir_mode=0755
mount error(13): Permission denied
```

El recurso `[temporal]` no tiene ninguna restricción de usuarios en Samba, pero la carpeta del servidor está en `0770` con grupo `g-usuarios`, y `xurxo` no tiene ningún permiso en ella. Es la **capa 1** (sistema de ficheros) la que lo impide. Si en el servidor se añade `xurxo` al grupo (`usermod -aG g-usuarios xurxo`), el montaje funciona; para dejarlo como estaba, se le quita después con `gpasswd -d xurxo g-usuarios`.

### 12.2 Ejemplo 2: verificación del control de usuarios, grupos y equipos

Se usa el recurso `[descargas]` del apartado 8.2. En el servidor, `xurxo` se cambia al grupo `g-external` como único grupo secundario:

```bash
root@lserver1:~# usermod -G g-external xurxo
root@lserver1:~# id ana && id xurxo
uid=1001(ana) gid=1001(ana) grupos=1001(ana),1003(g-usuarios)
uid=1002(xurxo) gid=1002(xurxo) grupos=1002(xurxo),1004(g-external)
```

En el cliente, `ana` puede montar el recurso, porque está en `valid users` y el equipo `lclient1` está permitido (recordando que `hosts allow` prevalece sobre `hosts deny`):

```bash
root@lclient1:~# mkdir /mnt/descargas
root@lclient1:~# mount.cifs //lserver1/descargas /mnt/descargas -o user=ana,uid=1001,gid=1001,file_mode=0777,dir_mode=0777
root@lclient1:~# ls -ld /mnt/descargas
drwxrwxrwx 2 1001 1001 0 oct  6 12:20 /mnt/descargas
root@lclient1:~# mkdir /mnt/descargas/dir1-ana && touch /mnt/descargas/f1-ana.txt
mkdir: no se puede crear el directorio «/mnt/descargas/dir1-ana»: Permiso denegado
touch: no se puede efectuar 'touch' sobre '/mnt/descargas/f1-ana.txt': Permiso denegado
```

Aunque en el cliente los permisos aparecen como `777`, no se puede crear nada: lo impide la directiva `read only = yes` de Samba (**capa 2**). Y `xurxo` ni siquiera puede montar el recurso, porque está en `invalid users`:

```bash
root@lclient1:~# umount /mnt/descargas
root@lclient1:~# mount.cifs //lserver1/descargas /mnt/descargas -o user=xurxo,uid=1001,gid=1001,file_mode=0400,dir_mode=0500
mount error(13): Permission denied
```

> **Nota:** En el servidor, la carpeta tiene el bit SGID (`2770`). Si el recurso tuviera `read only = no`, todos los subdirectorios y ficheros creados dentro tendrían como grupo `g-usuarios`, el del directorio principal, en lugar del grupo de quien los crea.

### 12.3 Ejemplo 3: montar `[homes]` al iniciar sesión y desmontarlo al cerrarla

El objetivo es que, al iniciar sesión en el cliente, el usuario `usuario` tenga en su carpeta personal la carpeta personal que tiene en el servidor. `usuario` existe en las dos máquinas con la **misma contraseña** en el cliente y en Samba. En el servidor, `[homes]` está como en el apartado 7.1, con `read only = yes`.

En el cliente se crea el grupo `g-usuarios` y se añade a él a `usuario`. Este grupo es **del cliente**: es el que comprobará `pam_mount`.

```bash
root@lclient1:~# apt -y install libpam-mount cifs-utils
root@lclient1:~# groupadd g-usuarios && usermod -aG g-usuarios usuario
root@lclient1:~# id usuario
uid=1000(usuario) gid=1000(usuario) grupos=1000(usuario),24(cdrom),25(floppy),29(audio),30(dip),44(video),46(plugdev),100(users),106(netdev),1001(g-usuarios)
```

En `/etc/security/pam_mount.conf.xml`, debajo del comentario `<!-- Volume definitions -->`, se añade:

```xml
<volume sgrp="g-usuarios" fstype="cifs" server="lserver1" path="homes" mountpoint="/home/%(USER)"
        options="nodev,nosuid,workgroup=WORKGROUP" />
```

`sgrp="g-usuarios"` limita el volumen a los miembros de ese grupo del cliente, sea su grupo principal o secundario. Al iniciar sesión se comprueba el resultado:

```bash
root@lclient1:~# su - usuario
reenter password for pam_mount:
usuario@lclient1:~$ mount | grep cifs
//lserver1/homes on /home/usuario type cifs (rw,nosuid,nodev,relatime,vers=3.1.1,...)
usuario@lclient1:~$ mkdir ~/dir1 && touch ~/f1
mkdir: no se puede crear el directorio «/home/usuario/dir1»: Permiso denegado
usuario@lclient1:~$ exit
```

Al cerrar la sesión (`exit`), el recurso se desmonta. No se puede escribir porque `[homes]` tiene `read only = yes` en el servidor. Para permitirlo, en el servidor se cambia esa directiva a `read only = no` en la sección `[homes]` y se recarga la configuración:

```bash
root@lserver1:~# smbcontrol all reload-config
```

Al repetir el inicio de sesión en el cliente, ya se pueden crear ficheros y directorios.

> **Nota:** Al hacer `su - usuario` desde `root` no se pide la contraseña, porque `root` no la necesita. Como `pam_mount` no ha podido capturarla, la pide él mismo con el mensaje `reenter password for pam_mount:`. Al iniciar sesión normalmente, en una consola o por SSH con contraseña, ese mensaje no aparece.

> **Advertencia:** Montar la carpeta del servidor **encima** de la carpeta personal local, como en este ejemplo, tapa por completo su contenido mientras dura la sesión. En una sesión gráfica, además, el escritorio necesita escribir en la carpeta personal nada más empezar, así que con `read only = yes` el inicio de sesión gráfico fallaría. Para un uso real es más práctico montar el recurso en una subcarpeta, como `/home/%(USER)/servidor`.

### 12.4 Ejemplo 4: compartir impresoras con CUPS

Samba no imprime por sí mismo: necesita un **servidor de impresión** instalado en la misma máquina que le haga de *backend*, porque no puede reenviar los trabajos a un equipo remoto. En Debian ese servidor es **CUPS**. Los trabajos se dejan primero en la carpeta de cola `/var/tmp`, que tiene permisos `1777`. Con la configuración por defecto de `smb.conf`, todas las impresoras configuradas en CUPS se comparten automáticamente a través de la sección `[printers]`.

En el servidor se instala CUPS y una **impresora virtual PDF**, que en lugar de imprimir guarda cada trabajo como un fichero PDF:

```bash
root@lserver1:~# apt -y install cups printer-driver-cups-pdf
```

La impresora se gestiona desde la interfaz web de CUPS, en `https://localhost:631/printers/PDF`, donde debe aparecer la impresora virtual `PDF` con el controlador *Generic CUPS-PDF Printer (w/ options)*. Los ficheros impresos se guardan en el servidor en la carpeta `~/PDF` del usuario que imprime, por ejemplo `/home/usuario/PDF`.

Como el servidor no tiene entorno gráfico, hay que permitir el acceso a CUPS desde el cliente, que sí lo tiene:

```bash
root@lserver1:~# sed -i 's|Listen localhost:631|&\nListen 172.16.10.254:631|' /etc/cups/cupsd.conf
root@lserver1:~# sed -i 's|</Location>|  Allow 172.16.10.150\n&|' /etc/cups/cupsd.conf
root@lserver1:~# systemctl restart cups
```

El primer `sed` hace que CUPS escuche también en la IP del servidor, y el segundo permite el acceso desde el cliente en todas las secciones `<Location>`. Desde `lclient1` ya se puede abrir `https://172.16.10.254:631/printers/PDF`.

> **Nota:** CUPS incluye una orden que hace lo mismo sin editar el fichero a mano: `cupsctl --remote-admin --remote-any --share-printers`. Es más cómoda, aunque abre la administración a cualquier equipo de la red y no solo al cliente.

Ahora se configura Samba. Primero se comprueba que se compiló con soporte de CUPS:

```bash
root@lserver1:~# smbd -b | grep "HAVE_CUPS"
   HAVE_CUPS
   HAVE_CUPS_CUPS_H
   HAVE_CUPS_LANGUAGE_H
```

Si no apareciera nada, habría que instalar una versión de Samba con soporte de CUPS. Después se añade en `[global]` la directiva `printing = CUPS` y una sección para la impresora:

```ini
[PDF]
   comment = Impresora PDF CUPS
   path = /var/tmp
   printer name = PDF
   printable = yes
   browseable = yes
;  valid users = usuario
```

> **Nota:** En el escenario original esta sección usa `write ok = yes`, pero esa directiva es un sinónimo de `read only = no` y no convierte el recurso en una impresora. La directiva que lo hace es **`printable = yes`**. En realidad, la impresora `PDF` ya se compartiría a través de `[printers]`; una sección propia solo hace falta para darle una configuración distinta, como limitar quién puede usarla con `valid users`.

```bash
root@lserver1:~# ls -ld /var/tmp
drwxrwxrwt 6 root root 4096 oct  6 12:30 /var/tmp
root@lserver1:~# smbcontrol all reload-config
```

En el cliente se instalan CUPS y `smbclient`, que aporta el programa con el que CUPS envía trabajos a una impresora Samba:

```bash
root@lclient1:~# apt -y install cups smbclient
```

Después, en la interfaz web del cliente, `https://localhost:631/admin`:

1. Pulsar **Añadir impresora** y elegir **Windows Printer via SAMBA**.
2. En **Conexión**, escribir `smb://usuario:abc123.@WORKGROUP/lserver1/PDF`.
3. Dar como **Nombre** `PDF`, como **Descripción** `PDF Virtual` y como **Ubicación** `lserver1`.
4. Elegir como controlador **Generic** → **Generic PostScript Printer (en)**, que es el recomendado.
5. Pulsar **Añadir impresora**.

Para probarla, se imprime una página de prueba desde `https://localhost:631/printers/PDF`, en el menú **Mantenimiento** → **Imprimir página de prueba**, o se imprime cualquier documento eligiendo la impresora `PDF`. El trabajo pasa por la cola `/var/tmp` del servidor y el PDF resultante aparece en `/home/usuario/PDF`.

> **Advertencia:** La contraseña escrita en la dirección `smb://` queda guardada en la configuración de CUPS del cliente. Además, el usuario que imprime debe tener carpeta personal en el servidor para que la impresora virtual pueda guardar en ella el PDF; por eso se usa `usuario` y no `ana`, que se creó sin carpeta personal.

---

## 13. Gestión de arrays de discos RAID5 y RAID0

El servidor tiene cuatro discos de 10 GB (`sdb`, `sdc`, `sdd` y `sde`) además del disco del sistema (`sda`). Con ellos se crean dos arrays, que en el [documento 06](./06_samba_ad_dc.md) se usarán para alojar los recursos compartidos del dominio. La teoría de RAID y de `mdadm` está en el [documento 38](../apuntes/38_Raid_con_mdadm.md).

Cada disco se divide en dos particiones, y cada array usa una partición de cada disco:

| Array | Particiones | Tipo | Punto de montaje |
|---|---|---|---|
| `/dev/md5` | `sdb1`, `sdc1`, `sdd1` activas y `sde1` de reserva (*spare*) | RAID5 | `/mnt/md5` |
| `/dev/md0` | `sdb2`, `sdc2`, `sdd2`, `sde2` | RAID0 | `/mnt/md0` |

```bash
root@lserver1:~# apt update && apt -y install mdadm parted
root@lserver1:~# for i in sdb sdc sdd sde
do
  parted -s /dev/${i} print
  parted --script /dev/${i} mklabel msdos
  parted --script /dev/${i} mkpart primary 0 50% -a cylinder
  parted --script /dev/${i} mkpart primary 50% 70% -a cylinder
  parted -s /dev/${i} print
done
root@lserver1:~# cat /proc/mdstat
root@lserver1:~# yes | mdadm --create /dev/md5 --level=5 \
  --raid-devices=3 /dev/sdb1 /dev/sdc1 /dev/sdd1 \
  --spare-devices=1 /dev/sde1
root@lserver1:~# yes | mdadm --create /dev/md0 --level=0 \
  --raid-devices=4 /dev/sdb2 /dev/sdc2 /dev/sdd2 /dev/sde2
root@lserver1:~# cat /proc/mdstat
root@lserver1:~# mdadm --examine --scan >> /etc/mdadm/mdadm.conf
root@lserver1:~# mdadm --detail /dev/md5
root@lserver1:~# mdadm --detail /dev/md0
root@lserver1:~# mkdir /mnt/md5 /mnt/md0
root@lserver1:~# mkfs.ext4 -F -L 'RAID5' /dev/md5
root@lserver1:~# mkfs.ext4 -F -L 'RAID0' /dev/md0
root@lserver1:~# UUID_MD5=$(lsblk -o +UUID | grep md5 | awk '{print $NF}' | sort -u)
root@lserver1:~# echo "UUID=${UUID_MD5} /mnt/md5 ext4 defaults 0 2" >> /etc/fstab
root@lserver1:~# UUID_MD0=$(lsblk -o +UUID | grep md0 | awk '{print $NF}' | sort -u)
root@lserver1:~# echo "UUID=${UUID_MD0} /mnt/md0 ext4 defaults 0 2" >> /etc/fstab
root@lserver1:~# mount -a
root@lserver1:~# findmnt /mnt/md5 && findmnt /mnt/md0
root@lserver1:~# mkdir -p /mnt/md5/dir5 && touch /mnt/md5/dir5/f1
root@lserver1:~# mkdir -p /mnt/md0/dir0 && touch /mnt/md0/dir0/f0
root@lserver1:~# ls -lR /mnt/md5 /mnt/md0
root@lserver1:~# umount /mnt/md5 /mnt/md0
root@lserver1:~# update-initramfs -u
root@lserver1:~# reboot
```

| Paso | Qué hace |
|---|---|
| Bucle con `parted` | Crea en cada disco una tabla de particiones MBR (`msdos`) y dos particiones: del 0 % al 50 % y del 50 % al 70 % del disco. |
| `mdadm --create` | Crea los arrays. `yes |` responde automáticamente a las preguntas de confirmación. |
| `mdadm --examine --scan >> mdadm.conf` | Guarda la definición de los arrays para que se vuelvan a montar en cada arranque. |
| `mkfs.ext4 -F -L` | Formatea cada array en ext4 y le pone una etiqueta. |
| `UUID_MD5=$(...)` | Extrae el UUID del array. `lsblk` lo muestra en varias líneas (una por partición del array), y `sort -u` deja una sola. |
| `echo "UUID=..." >> /etc/fstab` | Monta los arrays de forma permanente, identificados por su UUID ([documento 37](../apuntes/37_Particionado_con_fdisk_y_parted.md)). |
| `update-initramfs -u` | Actualiza el *initramfs* para que incluya la configuración de `mdadm` y los arrays se ensamblen al arrancar. |

> **Nota:** Una forma más directa de obtener el UUID de un array es `blkid -s UUID -o value /dev/md5`, que devuelve solo el valor sin necesidad de filtrar.

Una vez reiniciado el servidor, se comprueba que los arrays siguen funcionando:

```bash
usuario@lserver1:~$ findmnt /mnt/md5 && findmnt /mnt/md0
usuario@lserver1:~$ cat /proc/mdstat
root@lserver1:~# mdadm --detail /dev/md5
root@lserver1:~# mdadm --detail /dev/md0
root@lserver1:~# ls -lR /mnt/md5 /mnt/md0
```

---

## 14. Apéndice: configuración de red

La configuración de red de Debian se trata en detalle en el [documento 31](../apuntes/31_Configuracion_de_red.md). Aquí se recoge lo que necesita el escenario y algunas funciones de `/etc/network/interfaces` que no aparecen en ese documento.

### 14.1 Configuración manual

Las órdenes de `ip` (del paquete `iproute2`) sustituyen a las antiguas `ifconfig` y `route` (del paquete `net-tools`, obsoleto):

| Acción | Con `ip` | Equivalente antiguo |
|---|---|---|
| Ver la configuración de todas las tarjetas | `ip address show` o `ip a` | `ifconfig -a` |
| Desactivar y activar una tarjeta | `ip link set enp0s3 down && ip link set enp0s3 up` | `ifconfig enp0s3 down && ifconfig enp0s3 up` |
| Asignar una IP | `ip address add 172.16.10.254/24 dev enp0s3` | `ifconfig enp0s3 172.16.10.254/24` |
| Quitar una IP | `ip address del 172.16.10.254/24 dev enp0s3` | Sin equivalente |
| Ver la tabla de rutas | `ip route show` o `ip r` | `route` |
| Configurar la puerta de enlace | `ip route add default via 172.16.10.1` | `route add default gw 172.16.10.1` |
| Añadir una ruta a una red | `ip route add 172.16.10.0/24 dev enp0s3` | `route add -net 172.16.10.0 netmask 255.255.255.0 dev enp0s3` |

La resolución de nombres se configura en **`/etc/resolv.conf`**:

| Directiva | Significado |
|---|---|
| `domain ies.local` | Dominio que se añade a los nombres sin dominio: si falla la búsqueda de `host1`, se prueba `host1.ies.local`. |
| `search ies.local` | Lista de dominios que se prueban en ese caso. |
| `nameserver 8.8.8.8` | Servidor DNS. Se pueden poner varias líneas; se consultan en orden. |

> **Nota:** `domain` y `search` son **excluyentes**: si aparecen las dos, solo vale la última que figure en el fichero. Lo habitual es usar únicamente `search`.

### 14.2 El fichero /etc/network/interfaces

```bash
root@lserver1:~# cat /etc/network/interfaces
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto enp0s3
iface enp0s3 inet static
  address 172.16.10.254/24
  gateway 172.16.10.1
  post-up /etc/network/if-up.d/add_route_network.sh
  pre-down /etc/network/if-down.d/del_route_network.sh
  dns-nameservers 8.8.4.4 8.8.8.8
  dns-search ies.local
```

| Directiva | Significado |
|---|---|
| `auto` | La tarjeta se activa al arrancar el sistema. Para tarjetas que siempre están presentes. |
| `allow-hotplug` | La tarjeta se activa cuando el sistema detecta que se conecta. Para tarjetas extraíbles. |
| `address` | IP y máscara, en formato CIDR (`/24`), sin necesidad de la directiva `netmask`. |
| `gateway` | Puerta de enlace. |
| `pre-up` / `up` (o `post-up`) | Orden o *script* que se ejecuta antes o después de activar la tarjeta. |
| `down` (o `pre-down`) / `post-down` | Orden o *script* que se ejecuta antes o después de desactivarla. |
| `dns-nameservers`, `dns-search` | Servidores DNS y dominios de búsqueda. Solo funcionan si está instalado el paquete `resolvconf`, que es quien escribe `/etc/resolv.conf` con esos valores al reiniciar la red. |

Los *scripts* de este ejemplo añaden una ruta hacia otra red al activar la tarjeta y la quitan al desactivarla:

```bash
root@lserver1:~# cat /etc/network/if-up.d/add_route_network.sh
#!/bin/sh
ip route add 10.10.10.0/24 via 172.16.10.1
root@lserver1:~# cat /etc/network/if-down.d/del_route_network.sh
#!/bin/sh
ip route del 10.10.10.0/24 via 172.16.10.1
```

> **Nota:** En el escenario original, el *script* de bajada contenía por error `route add` en lugar de `route del`, de modo que no quitaba la ruta. Aquí se ha corregido y se ha cambiado `route` por `ip route`.

> **Advertencia:** Los *scripts* referenciados con `post-up` o `pre-down` deben existir y tener **permiso de ejecución** (`chmod +x`); si no, el servicio `networking` no arrancará. Además, cualquier *script* ejecutable que se deje en los directorios `if-up.d`, `if-down.d`, `if-pre-up.d` o `if-post-down.d` se ejecuta para **todas** las tarjetas, aunque no esté referenciado en `interfaces`.

Las tarjetas definidas en este fichero se activan y desactivan con `ifup enp0s3` e `ifdown enp0s3`, y el servicio completo se gestiona con `systemctl [start|stop|restart|reload] networking`.

> **Advertencia:** El servicio `networking` y **NetworkManager** son excluyentes: si los dos gestionan la misma tarjeta, se producen conflictos. En un equipo configurado con `/etc/network/interfaces` hay que asegurarse de que NetworkManager está parado y deshabilitado: `systemctl disable --now NetworkManager && systemctl enable networking`.
