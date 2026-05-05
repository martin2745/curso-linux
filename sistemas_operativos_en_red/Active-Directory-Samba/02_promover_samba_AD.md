# 02 Promover Samba a AD

## Índice

1. [Configuración previa del servidor](#configuración-previa-del-servidor)
2. [Instalación de Samba](#instalación-de-samba)
3. [Configuración de Samba como AD](#configuración-de-samba-como-ad)
4. [Configurar la sincronización de tiempo](#configurar-la-sincronización-de-tiempo)
5. [Verificar Samba como AD](#verificar-samba-como-ad)
6. [Comandos principales de Samba para la gestión de usuarios, equipos y grupos](#comandos-principales-de-samba-para-la-gestión-de-usuarios-equipos-y-grupos)

---

## Configuración previa del servidor

Vamos a realizar las configuraciones necesarias en nuestro `Ubuntu Server` para promover este a controlador de dominio y para poder en un futuro integrar equipos en el dominio.

Primero de todo vamos a cambiar el nombre de host (`hostname`) del servidor para que sea representativo del rol que va a tomar.

```bash
root@ubuntuserver:~# hostnamectl set-hostname dc
root@ubuntuserver:~# hostname
dc
```

| Parámetro | Descripción |
|-----------|-------------|
| `set-hostname` | Asigna de manera persistente el nombre de host indicado a la máquina. |

A continuación, modificamos el fichero de hosts local para establecer las resoluciones estáticas:

```bash
root@ubuntuserver:~# cat /etc/hosts
127.0.0.1 localhost
127.0.1.1 ubuntuserver

192.168.100.6 dc.instituto.local dc

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

> **Importante:** La línea `192.168.100.6 dc.instituto.local dc` es crucial, ya que asocia la dirección IP de la máquina tanto con el nombre de dominio cualificado (FQDN) como con su nombre corto.

Verificamos el `FQDN` (Fully Qualified Domain Name), que es el nombre "largo" y absoluto de la máquina en una red.

```bash
root@ubuntuserver:~# hostname -f
dc.instituto.local
```

Seguidamente, verificamos si el equipo es capaz de resolver su propia IP haciendo ping tanto por nombre corto como por FQDN:

```bash
root@ubuntuserver:~# ping -c 3 dc
PING dc.instituto.local (192.168.100.6) 56(84) bytes of data.
64 bytes from dc.instituto.local (192.168.100.6): icmp_seq=1 ttl=64 time=0.036 ms
64 bytes from dc.instituto.local (192.168.100.6): icmp_seq=2 ttl=64 time=0.048 ms
64 bytes from dc.instituto.local (192.168.100.6): icmp_seq=3 ttl=64 time=0.036 ms

--- dc.instituto.local ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2046ms
rtt min/avg/max/mdev = 0.036/0.040/0.048/0.005 ms
root@ubuntuserver:~# ping -c 3 dc.instituto.local
PING dc.instituto.local (192.168.100.6) 56(84) bytes of data.
64 bytes from dc.instituto.local (192.168.100.6): icmp_seq=1 ttl=64 time=0.036 ms
64 bytes from dc.instituto.local (192.168.100.6): icmp_seq=2 ttl=64 time=0.027 ms
64 bytes from dc.instituto.local (192.168.100.6): icmp_seq=3 ttl=64 time=0.046 ms

--- dc.instituto.local ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2085ms
rtt min/avg/max/mdev = 0.027/0.036/0.046/0.007 ms
```

> **Recuerda:** Un ping local exitoso confirma que el archivo `/etc/hosts` está correctamente estructurado.

Debemos desactivar el servicio `systemd-resolved` ya que `Samba` necesita actuar como servidor `DNS` principal y utilizar el puerto `53`. El servicio `systemd-resolved` viene instalado por defecto ocupando ese puerto; si no lo apagas, Samba no podrá arrancar por un "conflicto de puerto".

```bash
root@ubuntuserver:~# systemctl disable --now systemd-resolved
Removed "/etc/systemd/system/dbus-org.freedesktop.resolve1.service".
Removed "/etc/systemd/system/sysinit.target.wants/systemd-resolved.service".
```

| Parámetro | Descripción |
|-----------|-------------|
| `--now`   | Detiene el servicio inmediatamente además de deshabilitarlo en el inicio del sistema. |

Eliminamos el enlace simbólico preexistente al archivo `/etc/resolv.conf`.

```bash
root@ubuntuserver:~# unlink /etc/resolv.conf
```

Creamos de nuevo el archivo `/etc/resolv.conf` como un fichero estático, ya que será aquí donde el servidor intentará resolver las direcciones del dominio.

Añadimos las siguientes líneas:

- `nameserver 192.168.100.6`: En tu contexto Samba, esta IP debe ser la dirección IP estática de tu propio servidor. Es fundamental que apunte a sí mismo porque es el único que conoce los detalles internos del dominio (como dónde está el usuario Administrador, Kerberos, etc.).
- `nameserver 8.8.8.8`: Servidor DNS de Google, que actuará como el servidor secundario o de respaldo para peticiones externas.
- `search instituto.local`: Define el Dominio de búsqueda predeterminado y nos permite usar "nombres cortos", por lo que al hacer ping a `pc-local` el sistema buscará `pc-local.instituto.local`.

```bash
root@ubuntuserver:~# cat /etc/resolv.conf
nameserver 192.168.100.6
nameserver 8.8.8.8
search instituto.local
```

Hacemos inmutable al archivo `/etc/resolv.conf` para que el sistema o el gestor de red no pueda sobreescribirlo automáticamente.

```bash
root@ubuntuserver:~# chattr +i /etc/resolv.conf
```

| Parámetro | Descripción |
|-----------|-------------|
| `+i`      | Aplica el atributo inmutable al archivo, impidiendo que sea borrado, renombrado o modificado. |

---

## Instalación de Samba

Primero de todo, debemos actualizar el índice de paquetes e instalar `Samba` con todos los módulos y dependencias necesarias para soportar Active Directory:

```bash
root@ubuntuserver:~# apt install -y acl attr samba samba-dsdb-modules samba-vfs-modules smbclient winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config krb5-user dnsutils chrony net-tools
```

En las pantallas interactivas sucesivas durante la instalación, el sistema nos pedirá indicar cuál va a ser el dominio, quién va a ser el servidor Kerberos y el servidor administrativo.

- **INSTITUTO.LOCAL**: El Reino (Realm). Es el nombre de tu dominio, pero escrito en mayúsculas (convención estricta de Kerberos).
- **dc.instituto.local** (1ª vez): El Servidor Kerberos. Es la máquina encargada de verificar las contraseñas cuando un usuario intenta iniciar sesión ("¿Es esta contraseña correcta?").
- **dc.instituto.local** (2ª vez): El Servidor Administrativo. Es la máquina encargada de gestionar la base de datos de usuarios, por ejemplo, cuando cambias una contraseña o creas un usuario nuevo.

Tras la instalación interactiva se habrán rellenado estos datos, que podríamos resumir de la siguiente manera:

```bash
INSTITUTO.LOCAL
dc.instituto.local
dc.instituto.local
```

> **Nota:** Es normal que algunos servicios fallen al arrancar durante la instalación porque aún no hemos aprovisionado el dominio.

Debemos detener y deshabilitar los servicios que el servidor de Active Directory de `Samba` no requiere como demonios independientes (`smbd`, `nmbd` y `winbind`). La razón principal es un cambio de roles. Ubuntu, por defecto, arranca Samba pensando que va a ser un simple "servidor de carpetas" (File Server), pero tú lo quieres convertir en un "Controlador de Dominio" (Domain Controller).

Los servicios que vamos a deshabilitar son los siguientes:

- `smbd` (Server Message Block Daemon): Se encarga de compartir archivos, carpetas e impresoras. Responde cuando alguien intenta abrir `\\servidor\carpeta`. Escucha en el puerto `445` (TCP).
- `nmbd` (NetBIOS Name Service Daemon): Se encarga de que tu servidor aparezca en el "Entorno de red" de Windows mediante el protocolo antiguo NetBIOS. Escucha en los puertos `137`, `138` (UDP) y `139` (TCP).
- `winbind`: Permite que los usuarios de Windows sean entendidos por el sistema Linux traduciendo un usuario de Windows (SID) a un usuario de Linux (UID/GID).

Cuando configuramos Samba como Controlador de Dominio, no utilizamos esos tres servicios por separado. En su lugar, utilizamos un único servicio especial llamado `samba-ad-dc` (o simplemente el binario `samba`) que integra todas las funcionalidades.

```bash
root@ubuntuserver:~# systemctl disable --now smbd nmbd winbind
```

El servidor solo necesita `samba-ad-dc` para funcionar como Active Directory. En primer lugar tenemos que desenmascararlo para poder usarlo ya que por defecto, en instalaciones de Samba estándar, este servicio viene enmascarado por seguridad. Posteriormente lo habilitamos para que arranque con el sistema.

```bash
root@ubuntuserver:~# systemctl unmask samba-ad-dc
root@ubuntuserver:~# systemctl enable samba-ad-dc
```

---

## Configuración de Samba como AD

Debemos crear una copia de seguridad del archivo `/etc/samba/smb.conf` por si necesitamos revertir la configuración.

```bash
mv /etc/samba/smb.conf /etc/samba/smb.conf.orig
```

Ejecutamos el comando `samba-tool` para comenzar a aprovisionar el dominio Samba Active Directory, lo que generará una base de datos nueva y los ficheros de configuración necesarios.

```bash
root@ubuntuserver:~# samba-tool domain provision
Realm [INSTITUTO.LOCAL]:
Domain [INSTITUTO]:
Server Role (dc, member, standalone) [dc]:
DNS backend (SAMBA_INTERNAL, BIND9_FLATFILE, BIND9_DLZ, NONE) [SAMBA_INTERNAL]:
DNS forwarder IP address (write 'none' to disable forwarding) [192.168.100.6]:  8.8.8.8
Administrator password: abc123.
Retype password: abc123.
...
```

> **Advertencia:** La contraseña del administrador debe cumplir con requisitos de complejidad (letras, números y caracteres especiales).

Samba habrá generado una configuración propia para Kerberos. Debemos crear una copia de seguridad de la configuración predeterminada de Kerberos en el sistema.

```bash
root@ubuntuserver:~# mv /etc/krb5.conf /etc/krb5.conf.orig
```

Reemplazamos con el archivo recién generado `/var/lib/samba/private/krb5.conf`.

```bash
root@ubuntuserver:~# cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
```

Ahora podemos iniciar el servicio principal de Samba Active Directory, `samba-ad-dc`.

```bash
root@ubuntuserver:~# systemctl start samba-ad-dc
```

Comprobamos que el servicio esté ejecutándose correctamente y sin errores.

```bash
root@ubuntuserver:~# systemctl status samba-ad-dc
● samba-ad-dc.service - Samba AD Daemon
     Loaded: loaded (/usr/lib/systemd/system/samba-ad-dc.service; enabled; preset: enabled)
     Active: active (running) since Fri 2026-01-09 10:14:54 UTC; 5min ago
       Docs: man:samba(8)
             man:samba(7)
             man:smb.conf(5)
    Process: 4073 ExecCondition=/usr/share/samba/is-configured samba (code=exited, status=0/S>
   Main PID: 4076 (samba)
```

---

## Configurar la sincronización de tiempo

Samba Active Directory depende estrictamente del protocolo Kerberos, y el protocolo Kerberos requiere que los tiempos del servidor AD y de las estaciones de trabajo estén sincronizados (con una tolerancia máxima de 5 minutos de diferencia). Para garantizar una sincronización de tiempo adecuada, configuraremos el servicio `chrony` como un servidor de Protocolo de Tiempo de Red (NTP) compatible con Samba.

> **Nota:** Los beneficios de la sincronización de tiempo de AD incluyen la prevención de ataques de repetición (Replay Attacks) y la resolución de conflictos de replicación de AD entre varios controladores.

Cambiamos el permiso y la propiedad predeterminados del directorio `/var/lib/samba/ntp_signd/`. El usuario/grupo `_chrony` debe tener permiso de lectura en el directorio `ntp_signd` para poder firmar las respuestas NTP con las claves criptográficas de Kerberos.

```bash
root@ubuntuserver:~# chown root:_chrony /var/lib/samba/ntp_signd/
root@ubuntuserver:~# chmod 750 /var/lib/samba/ntp_signd/
```

Modificamos el archivo de configuración `/etc/chrony/chrony.conf` para habilitar el servidor NTP de chrony y apuntar a la ubicación del socket NTP a `/var/lib/samba/ntp_signd`.

```bash
nano /etc/chrony/chrony.conf
```

Añadimos al final del archivo la siguiente configuración:

- `bindcmdaddress 192.168.100.6`: Restringe la escucha de comandos administrativos de control únicamente a la interfaz con la IP de tu servidor.
- `allow 192.168.100.0/24`: Autoriza a los ordenadores de esa red local a conectarse a este servidor para pedir y sincronizar la hora.
- `ntpsigndsocket /var/lib/samba/ntp_signd`: Indica la ruta para comunicarse con Samba y firmar digitalmente los paquetes de hora, requisito obligatorio para clientes Windows unidos al dominio.

```bash
root@ubuntuserver:~# tail -4 /etc/chrony/chrony.conf
# Configuración para NTP del AD
bindcmdaddress 192.168.100.6
allow 192.168.100.0/24
ntpsigndsocket /var/lib/samba/ntp_signd
```

Reiniciamos y verificamos el servicio `chronyd` en el servidor Samba AD.

```bash
root@ubuntuserver:~# systemctl restart chronyd
root@ubuntuserver:~# systemctl status chronyd
```

---

## Verificar Samba como AD

Para comprobar que el servidor de dominio interno está resolviendo correctamente los registros de DNS de nuestro dominio, verificamos los nombres de dominio con `host`:

```bash
root@ubuntuserver:~# host -t A instituto.local
instituto.local has address 192.168.100.6
instituto.local has address 10.0.2.15

root@ubuntuserver:~# host -t A dc.instituto.local
dc.instituto.local has address 192.168.100.6
dc.instituto.local has address 10.0.2.15
```

Verificamos que los registros especiales de servicio (`SRV`) para Kerberos y LDAP apunten correctamente al FQDN de nuestro servidor Samba Active Directory. Estos registros son críticos para que los clientes encuentren los servicios.

```bash
root@ubuntuserver:~# host -t SRV _kerberos._udp.instituto.local
_kerberos._udp.instituto.local has SRV record 0 100 88 dc.instituto.local.
```

```bash
root@ubuntuserver:~# host -t SRV _ldap._tcp.instituto.local
_ldap._tcp.instituto.local has SRV record 0 100 389 dc.instituto.local.
```

> **Importante:** Si estos registros no se resuelven correctamente, los clientes no podrán iniciar sesión en el dominio.

Verificamos los recursos compartidos predeterminados disponibles en Samba Active Directory mediante `smbclient`.

Tenemos los siguientes recursos y sus funciones principales:
- `sysvol`: Guarda las Políticas de Grupo (GPO) del dominio.
- `netlogon`: Guarda los Scripts que se ejecutan al iniciar sesión.
- `IPC$`: Es la conexión invisible e interprocesos necesaria para administrar el servidor.

```bash
root@ubuntuserver:~# smbclient -L localhost -N
Anonymous login successful

        Sharename       Type      Comment
        ---------       ----      -------
        sysvol          Disk
        netlogon        Disk
        IPC$            IPC       IPC Service (Samba 4.19.5-Ubuntu)
SMB1 disabled -- no workgroup available
```

| Parámetro | Descripción |
|-----------|-------------|
| `-L`      | Muestra la lista de servicios y recursos compartidos en el servidor especificado. |
| `-N`      | Realiza un inicio de sesión anónimo, sin solicitar contraseña. |

Comprobamos la autenticación en el servidor de Kerberos logueándonos como administrador de usuarios para crear y cachear un ticket de Kerberos:

```bash
root@ubuntuserver:~# kinit administrator@INSTITUTO.LOCAL
Password for administrator@INSTITUTO.LOCAL:
Warning: Your password will expire in 41 days on vie 20 feb 2026 10:08:27
```

A continuación verificamos que el ticket se ha otorgado con éxito visualizando el caché de tickets:

```bash
root@ubuntuserver:~# klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: administrator@INSTITUTO.LOCAL

Valid starting     Expires            Service principal
09/01/26 10:57:05  09/01/26 20:57:05  krbtgt/INSTITUTO.LOCAL@INSTITUTO.LOCAL
        renew until 10/01/26 10:57:03
```

Aprovechando el ticket generado, podemos intentar iniciar sesión en el servidor a través de `smb` al recurso `netlogon`:

```bash
root@ubuntuserver:~# smbclient //localhost/netlogon -U 'administrator'
Password for [INSTITUTO\administrator]:
Try "help" to get a list of possible commands.
smb: \> exit
```

> **Nota:** Si en un futuro queremos cambiar la contraseña del usuario Administrador podemos hacerlo con la herramienta `samba-tool`.

```bash
$ samba-tool user setpassword administrator
```

Verificamos la integridad de la configuración final de Samba volcando los parámetros con `testparm`:

```bash
root@ubuntuserver:~# testparm
Load smb config files from /etc/samba/smb.conf
Loaded services file OK.
Weak crypto is allowed by GnuTLS (e.g. NTLM as a compatibility fallback)

Server role: ROLE_ACTIVE_DIRECTORY_DC

Press enter to see a dump of your service definitions

# Global parameters
[global]
        dns forwarder = 8.8.8.8
        passdb backend = samba_dsdb
        realm = INSTITUTO.LOCAL
        server role = active directory domain controller
        workgroup = INSTITUTO
        rpc_server:tcpip = no
        ...
        vfs objects = dfs_samba4 acl_xattr


[sysvol]
        path = /var/lib/samba/sysvol
        read only = No


[netlogon]
        path = /var/lib/samba/sysvol/instituto.local/scripts
        read only = No
```

Verificamos el nivel funcional del dominio de Active Directory simulado por Samba:

```bash
root@ubuntuserver:~# samba-tool domain level show
Domain and forest function level for domain 'DC=instituto,DC=local'

Forest function level: (Windows) 2008 R2
Domain function level: (Windows) 2008 R2
Lowest function level of a DC: (Windows) 2008 R2
```

---

## Comandos principales de Samba para la gestión de usuarios, equipos y grupos

Las herramientas de `samba-tool` nos permiten interactuar y gestionar los objetos de Active Directory por línea de comandos.

**Crear un usuario SAMBA AD:**

```bash
root@dc:~# samba-tool user create alumno
New Password: abc123.
Retype Password: abc123.
User 'alumno' added successfully
```

**Listar usuarios SAMBA AD:**

```bash
root@dc:~# samba-tool user list
alumno
Guest
Administrator
krbtgt
```

**Eliminar un usuario:**

```bash
$ samba-tool user delete <nombre_del_usuario>
```

**Crear un equipo en SAMBA AD:**

```bash
sudo samba-tool computer create <nombre_del_equipo>
```

**Listar equipos SAMBA AD:**

```bash
root@dc:~# samba-tool computer list
DC$
```

**Eliminar equipo SAMBA AD:**

```bash
$ samba-tool computer delete <nombre_del_equipo>
```

**Crear un grupo de seguridad:**

```bash
$ samba-tool group add <nombre_del_grupo>
```

**Listar todos los grupos:**

```bash
$ samba-tool group list
```

**Listar miembros de un grupo específico:**

```bash
$ samba-tool group listmembers 'Domain Admins'
```

**Agregar un miembro a un grupo existente:**

```bash
$ samba-tool group addmembers <nombre_del_grupo> <nombre_del_usuario>
```

**Eliminar un miembro de un grupo:**

```bash
$ samba-tool group removemembers <nombre_del_grupo> <nombre_del_usuario>
```
