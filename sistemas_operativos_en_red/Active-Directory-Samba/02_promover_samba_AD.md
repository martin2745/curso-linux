# 02 Promover Samba a AD

Vamos a realizar las configuraciones necesarias en nuestro Ubuntu Server promover este a controlador de dominio y para poder en un futuro integrar equipos en el dominio.

Primero de todo vamos a cambiar el hostname del servidor.

```bash
root@ubuntuserver:~# hostnamectl set-hostname dc
root@ubuntuserver:~# hostname
dc
```

A continuación, modificamos el fichero de hosts:

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

Verificar el FQDN, que es el nombre "largo" y absoluto de tu máquina en una red.

```bash
root@ubuntuserver:~# hostname -f
dc.instituto.local
```

Verificar si el FQDN es capaz de resolver la dirección Ip del Samba

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

Desactivar servicio systemd-resolved ya que Samba necesita ser el servidor DNS principal y utilizar ese puerto (puerto 53). El servicio systemd-resolved viene instalado por defecto ocupando ese puerto; si no lo apagas, Samba no podrá arrancar por "conflicto de puerto".

```bash
root@ubuntuserver:~# systemctl disable --now systemd-resolved
Removed "/etc/systemd/system/dbus-org.freedesktop.resolve1.service".
Removed "/etc/systemd/system/sysinit.target.wants/systemd-resolved.service".
```

Eliminar enlace simbólico al archivo `/etc/resolv.conf`.

```bash
root@ubuntuserver:~# unlink /etc/resolv.conf
```

Creamos de nuevo el archivo `/etc/resolv.conf` como fichero estático ya que será aquí donde el servidor intentará resolver la dirección de dominio.

Añadimos las siguientes líneas:

- _nameserver 192.168.100.6_: En tu contexto Samba: Esta IP debe ser la dirección IP estática de tu propio servidor (el que estás configurando). Es fundamental que se apunte a sí mismo (o a su IP de red) porque es el único que conoce los detalles internos del dominio (como dónde está el usuario Administrador, Kerberos, etc.).
- _nameserver 8.8.8.8_: Servidor DNS de Google, que es el servidor secundario o de respaldo.
- _search instituto.local_: Esta linea define el Dominio de búsqueda predeterminado y nos permite usar "nombres cortos", es decir, en lugar de hacer ping a pc-profesor.insituto.local lo hacemos a pc-local. Esto es así ya que el servicio DNS de Samba almacena entradas de los elementos del AD como elemento.nombreDominio.local.

```bash
root@ubuntuserver:~# cat /etc/resolv.conf
nameserver 192.168.100.6
nameserver 8.8.8.8
search instituto.local
```

Hacemos inmutable al archivo /etc/resolv.conf para que no pueda modificarse.

```bash
root@ubuntuserver:~# chattr +i /etc/resolv.conf
```

## Instalación de Samba

Primero de todo actualizar el índice de paquetes e instalar Samba con sus paquetes y dependencias:

```bash
root@ubuntuserver:~# apt install -y acl attr samba samba-dsdb-modules samba-vfs-modules smbclient winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config krb5-user dnsutils chrony net-tools
```

En las pantallas sucesivas indicamos cual va a ser el dominio, quien va a ser el servidor Kerberos y el servidor administrativo.

- _INSTITUTO.LOCAL_: El Reino (Realm). Es el nombre de tu dominio, pero escrito en mayúsculas (convención de Kerberos).
- _dc.instituto.local_ (1ª vez): El Servidor Kerberos. Es la máquina encargada de verificar las contraseñas cuando un usuario intenta iniciar sesión ("¿Es esta contraseña correcta?").
- _dc.instituto.local_ (2ª vez): El Servidor Administrativo. Es la máquina encargada de gestionar la base de datos de usuarios, por ejemplo, cuando cambias una contraseña o creas un usuario nuevo ("Cambia la contraseña de Pepe").

```bash
INSTITUTO.LOCAL
dc.instituto.local
dc.instituto.local
```

Detener y deshabilitar los servicios que el servidor de Active Directory de Samba no requiere (smbd, nmbd y winbind). La razón principal es un cambio de roles. Ubuntu, por defecto, arranca Samba pensando que va a ser un simple "servidor de carpetas" (File Server), pero tú lo quieres convertir en un "Controlador de Dominio" (Domain Controller).

Los servicios que vamos a deshabilitar son los siguientes:

- _smbd (Server Message Block Daemon)_: Se encarga de compartir archivos, carpetas e impresoras. Es quien responde cuando alguien intenta abrir `\\servidor\carpeta`. Escucha en el puerto 445 (TCP).
- _nmbd (NetBIOS Name Service Daemon)_: Se encarga de que tu servidor aparezca en el "Entorno de red" de Windows mediante el protocolo antiguo NetBIOS. Escucha en los puertos 137, 138 (UDP) y 139 (TCP).
- _winbind_: Permite que los usuarios de Windows sean entendidos por el sistema Linux traduciendo un usuario de Windows (SID) a un usuario de Linux (UID/GID).

Cuando configuramos Samba como Controlador de Dominio (Active Directory), no utilizamos esos tres servicios por separado. En su lugar, utilizamos un único servicio especial llamado _samba-ad-dc_ (o simplemente el binario samba).

```bash
root@ubuntuserver:~# systemctl disable --now smbd nmbd winbind
```

El servidor solo necesita samba-ac-dc para funcionar como Active Directory y controlador de dominio. Tenemos que en primero momento desenmascararlo para así poder usarlo ya que por defecto samba se contempla únicamente para carpetas compartidas por lo que viene enmascarado por seguridad, como nosotros queremos promocionarlo a AD lo desenmascaramos y luego lo habilitamos.

```bash
root@ubuntuserver:~# systemctl unmask samba-ad-dc
root@ubuntuserver:~# systemctl enable samba-ad-dc
```

## Configuración de Samba como AD

Crear una copia de seguridad del archivo /etc/samba/smb.conf

```bash
mv /etc/samba/smb.conf /etc/samba/smb.conf.orig
```

Ejecutar el comando samba-tool para comenzar a aprovisionar Samba Active Directory.

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

Crear copia de seguridad de la configuración predeterminada de Kerberos.

```bash
root@ubuntuserver:~# mv /etc/krb5.conf /etc/krb5.conf.orig
```

Reemplazar con el archivo /var/lib/samba/private/krb5.conf.

```bash
root@ubuntuserver:~# cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
```

Iniciar servicio Samba Active Directory samba-ad-dc

```bash
root@ubuntuserver:~# systemctl start samba-ad-dc
```

Comprobar servicio

```bash
root@ubuntuserver:~# systemctl status samba
● samba-ad-dc.service - Samba AD Daemon
     Loaded: loaded (/usr/lib/systemd/system/samba-ad-dc.service; enabled; preset: enabled)
     Active: active (running) since Fri 2026-01-09 10:14:54 UTC; 5min ago
       Docs: man:samba(8)
             man:samba(7)
             man:smb.conf(5)
    Process: 4073 ExecCondition=/usr/share/samba/is-configured samba (code=exited, status=0/S>
   Main PID: 4076 (samba)
```

## Configurar la sincronización de tiempo

Samba Active Directory depende del protocolo Kerberos, y el protocolo Kerberos requiere que los tiempos del servidor AD y de la estación de trabajo estén sincronizados. Para garantizar una sincronización de tiempo adecuada, también deberemos configurar un servidor de Protocolo de tiempo de red (NTP) en Samba.
Los beneficios de la sincronización de tiempo de AD incluyen la prevención de ataques de repetición y la resolución de conflictos de replicación de AD.

Cambiar el permiso y la propiedad predeterminados del directorio /var/lib/samba/ntp_signd/ntp_signed. El usuario/grupo chrony debe tener permiso de lectura en el directorio ntp_signed.

```bash
root@ubuntuserver:~# chown root:_chrony /var/lib/samba/ntp_signd/
root@ubuntuserver:~# chmod 750 /var/lib/samba/ntp_signd/
```

Modificar el archivo de configuración `/etc/chrony/chrony.conf` para habilitar el servidor NTP de chrony y apuntar a la ubicación del socket NTP a `/var/lib/samba/ntp_signd`.

```bash
nano /etc/chrony/chrony.conf
```

Al final de todo:

- **bindcmdaddress 192.168.1.6**: Restringe la escucha de comandos administrativos de control únicamente a la interfaz con la IP de tu servidor.
- **allow 192.168.1.0/24**: Autoriza a los ordenadores de esa red local a conectarse a este servidor para pedir y sincronizar la hora.
- **ntpsigndsocket /var/lib/samba/ntp_signd**: Indica la ruta para comunicarse con Samba y firmar digitalmente los paquetes de hora, requisito obligatorio para clientes Windows.

```bash
root@ubuntuserver:~# tail -4 /etc/chrony/chrony.conf
# Configuración para NTP del AD
bindcmdaddress 192.168.1.6
allow 192.168.1.0/24
ntpsigndsocket /var/lib/samba/ntp_signd
```

Reiniciar y verificar el servicio chronyd en el servidor Samba AD.

```bash
root@ubuntuserver:~# systemctl restart chronyd
root@ubuntuserver:~# systemctl status chronyd
```

## Verificar Samba como AD

Verificar nombres de dominio:

```bash
root@ubuntuserver:~# host -t A instituto.local
instituto.local has address 192.168.100.6
instituto.local has address 10.0.2.15

root@ubuntuserver:~# host -t A dc.instituto.local
dc.instituto.local has address 192.168.100.6
dc.instituto.local has address 10.0.2.15
```

Verificar que los registros de servicio kerberos y ldap apunten al FQDN de su servidor Samba Active Directory.

```bash
root@ubuntuserver:~# host -t SRV _kerberos._udp.instituto.local
_kerberos._udp.instituto.local has SRV record 0 100 88 dc.instituto.local.
```

```bash
root@ubuntuserver:~# host -t SRV _ldap._tcp.instituto.local
_ldap._tcp.instituto.local has SRV record 0 100 389 dc.instituto.local.
```

Verificar los recursos predeterminados disponibles en Samba Active Directory Tenemos los siguientes recurso y función principal.

- _sysvol_: Guarda las Políticas de Grupo (GPO) del dominio.
- _netlogon_: Guarda los Scripts que se ejecutan al iniciar sesión.
- _IPC$_: Es la conexión invisible para administrar el servidor.

```bash
root@ubuntuserver:~# smbclient -L instituto.local -N
Anonymous login successful

        Sharename       Type      Comment
        ---------       ----      -------
        sysvol          Disk
        netlogon        Disk
        IPC$            IPC       IPC Service (Samba 4.19.5-Ubuntu)
SMB1 disabled -- no workgroup available
```

Comprobar la autenticación en el servidor de Kerberos mediante el administrador de usuarios para crear un ticket de con kerberos:

```bash
root@ubuntuserver:~# kinit administrator@INSTITUTO.LOCAL
Password for administrator@INSTITUTO.LOCAL:
Warning: Your password will expire in 41 days on vie 20 feb 2026 10:08:27
root@ubuntuserver:~# klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: administrator@INSTITUTO.LOCAL

Valid starting     Expires            Service principal
09/01/26 10:57:05  09/01/26 20:57:05  krbtgt/INSTITUTO.LOCAL@INSTITUTO.LOCAL
        renew until 10/01/26 10:57:03
```

Iniciar sesión en el servidor a través de smb

```bash
root@ubuntuserver:~# smbclient //localhost/netlogon -U 'administrator'
Password for [INSTITUTO\administrator]:
Try "help" to get a list of possible commands.
smb: \> exit
```

Si queremos cambiar contraseña usuario administrator podemos hacerlo de la siguiente forma:

```bash
$ samba-tool user setpassword administrator
```

Verificar la integridad del archivo de configuración de Samba.

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
        rpc_daemon:spoolssd = embedded
        rpc_server:spoolss = embedded
        rpc_server:winreg = embedded
        rpc_server:ntsvcs = embedded
        rpc_server:eventlog = embedded
        rpc_server:srvsvc = embedded
        rpc_server:svcctl = embedded
        rpc_server:default = external
        winbindd:use external pipes = true
        idmap config * : backend = tdb
        map archive = No
        vfs objects = dfs_samba4 acl_xattr


[sysvol]
        path = /var/lib/samba/sysvol
        read only = No


[netlogon]
        path = /var/lib/samba/sysvol/instituto.local/scripts
        read only = No
```

Verificar funcionamiento WINDOWS AD DC 2008:

```bash
root@ubuntuserver:~# samba-tool domain level show
Domain and forest function level for domain 'DC=instituto,DC=local'

Forest function level: (Windows) 2008 R2
Domain function level: (Windows) 2008 R2
Lowest function level of a DC: (Windows) 2008 R2
```

## Comandos principales de Samba para la gestión de usuarios, equipos y grupos

Crear usuario SAMBA AD

```bash
root@dc:~# samba-tool user create alumno
New Password: abc123.
Retype Password: abc123.
User 'alumno' added successfully
```

Listar usuarios SAMBA AD

```bash
root@dc:~# samba-tool user list
alumno
Guest
Administrator
krbtgt
```

Eliminar un usuario

```bash
$ samba-tool user delete <nombre_del_usuario>
```

Crear equipo en SAMBA AD

```bash
sudo samba-tool computer create <nombre_del_equipo>
```

Listar equipos SAMBA AD

```bash
root@dc:~# samba-tool computer list
DC$
```

Eliminar equipo SAMBA AD

```bash
$ samba-tool computer delete <nombre_del_equipo>
```

Crear grupo

```bash
$ samba-tool group add <nombre_del_grupo>
```

Listar grupos

```bash
$ samba-tool group list
```

Listar miembros de un grupo

```bash
$ samba-tool group listmembers 'Domain Admins'
```

Agregar un miembro a un grupo

```bash
$ samba-tool group addmembers <nombre_del_grupo> <nombre_del_usuario>
```

Eliminar un miembro de un grupo

```bash
$ samba-tool group removemembers <nombre_del_grupo> <nombre_del_usuario>
```
