# 04 Unir Ubuntu Desktop al dominio

## Configuraciones necesarias para unirse al dominio

Editamos el nombre de la máquina.

```bash
root@ubuntu:~# hostnamectl set-hostname ud101
root@ubuntu:~# hostname -f
ud101
```

Configuramos el fichero `/etc/hosts` con los datos del dominio.

```bash
root@ubuntu:~# cat /etc/hosts
...
192.168.100.6 instituto.local instituto
192.168.100.6 dc.instituto.local dc
...
```

Comprobamos la conexión a **instituto.local**.

```bash
root@ubuntu:~# ping -c3 instituto.local
PING instituto.local (192.168.100.6) 56(84) bytes of data.
64 bytes from instituto.local (192.168.100.6): icmp_seq=1 ttl=64 time=1.42 ms
64 bytes from instituto.local (192.168.100.6): icmp_seq=2 ttl=64 time=0.791 ms
64 bytes from instituto.local (192.168.100.6): icmp_seq=3 ttl=64 time=0.741 ms

--- instituto.local ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2012ms
rtt min/avg/max/mdev = 0.741/0.983/1.418/0.308 ms

```

Instalamos el paquete _ntpdate_ para poder sincronizar mi equipo con el servidor kerberos utilizando NTP.

```bash
root@ud101:~# apt install ntpdate -y
```

```bash
root@ud101:~# ntpdate -q instituto.local
2026-01-10 00:44:24.891035 (+0100) +0.222763 +/- 0.000836 instituto.local 192.168.100.6 s3 no-leap
root@ud101:~# ntpdate instituto.local
2026-01-10 00:45:22.889470 (+0100) +0.190513 +/- 0.000861 instituto.local 192.168.100.6 s3 no-leap
```

A continuación vamos a instalar todos los paquetes necesarios:

```bash
root@ud101:~# apt install -y samba krb5-config krb5-user winbind libpam-winbind libnss-winbind
```

A las preguntas contestamos lo siguiente:

```bash
INSTITUTO.LOCAL
dc.instituto.local
dc.instituto.local
```

Comprobamos la autenticación en el servidor de Kerberos mediante el administrador de usuarios creando un ticket:

```bash
root@ud101:~# kinit administrator@INSTITUTO.LOCAL
Password for administrator@INSTITUTO.LOCAL:
Warning: Your password will expire in 40 days on vie 20 feb 2026 11:08:27
```

```bash
root@ud101:~# klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: administrator@INSTITUTO.LOCAL

Valid starting     Expires            Service principal
11/01/26 10:38:06  11/01/26 20:38:06  krbtgt/INSTITUTO.LOCAL@INSTITUTO.LOCAL
        renew until 12/01/26 10:38:01
```

Movemos el archivo smb.conf y crear copia de seguridad

```bash
root@ud101:~# mv /etc/samba/smb.conf /etc/samba/smb.conf.initial
```

Creamos el archivo smb.conf vacio.

```bash
root@ud101:~# cat /etc/samba/smb.conf
[global]
    workgroup = INSTITUTO
    realm = INSTITUTO.LOCAL
    netbios name = ud101
    security = ADS
    dns forwarder = 192.168.100.6

    # Configuración de idmap (Mapeo de identidades)
    idmap config * : backend = tdb
    idmap config * : range = 50000-1000000

    # Opciones de Winbind y plantillas
    template homedir = /home/%D/%U
    template shell = /bin/bash
    winbind use default domain = true
    winbind offline logon = false
    winbind nss info = rfc2307
    winbind enum users = yes
    winbind enum groups = yes

    # Opciones VFS y permisos
    vfs objects = acl_xattr
    map acl inherit = Yes
    store dos attributes = Yes
```

Reiniciamos todos los daemons de samba:

```bash
root@ud101:~# systemctl restart smbd nmbd
```

Detener los servicios innecesarios:

```bash
root@ud101:~# systemctl stop samba-ad-dc
```

Habilitar los servicios de samba necesarios:

```bash
root@ud101:~# systemctl enable smbd nmbd
Synchronizing state of smbd.service with SysV service script with /usr/lib/systemd/systemd-sysv-install.
Executing: /usr/lib/systemd/systemd-sysv-install enable smbd
Synchronizing state of nmbd.service with SysV service script with /usr/lib/systemd/systemd-sysv-install.
Executing: /usr/lib/systemd/systemd-sysv-install enable nmbd
```

Unimos Ubuntu Desktop a SAMBA AD DC. Tenemos errores de DNS ya que de momento no tenemos un DNS configurado.

```bash
root@ud101:~# net ads join -U administrator
Password for [INSTITUTO\administrator]:
get_kdc_ip_string: get_kdc_list (site-less) fail NT_STATUS_NO_LOGON_SERVERS
Using short domain name -- INSTITUTO
Joined 'UD101' to dns domain 'instituto.local'
No DNS domain configured for ud101. Unable to perform DNS Update.
DNS update failed: NT_STATUS_INVALID_PARAMETER
```

Listamos los equipos SAMBA AD y vemos que nuestro equipo de linux se ha unido al dominio.

```bash
root@dc:~# samba-tool computer list
W101$
UD101$
DC$
```

## Configuración de autenticación de cuentas de AD

Editamos el archivo de configuración del conmutador de servicio de nombres (NSS). De este modo conseguimos que al realizar la autenticación se busquen los usuarios en el servidor a través del protocolo winbind.

Lo qué ocurre cuando buscas un usuario una vez realizada las siguientes modificaciones es la siguiente (por ejemplo, con getent passwd administrator):

- _passwd_: El sistema necesita información de un usuario.
- _compat_: Primero mira en los archivos locales (tu ordenador). Si el usuario "administrator" existe en `/etc/passwd`, usa ese y se detiene.
- _winbind_: Si no lo encuentra en local, le pregunta a Samba (Winbind). Aquí es donde Winbind consulta al Controlador de Dominio (Active Directory). Si lo encuentra allí, te devuelve la información.

```bash
root@ud101:~# cat /etc/nsswitch.conf
# /etc/nsswitch.conf
#
# Example configuration of GNU Name Service Switch functionality.
# If you have the `glibc-doc-reference' and `info' packages installed, try:
# `info libc "Name Service Switch"' for information about this file.

passwd:         compat winbind
group:          compat winbind
shadow:         compat winbind
gshadow:        files

hosts:          files dns
networks:       files

protocols:      db files
services:       db files sss
ethers:         db files
rpc:            db files

netgroup:       nis sss
automount:  sss
```

Reiniciamos el servicio winbind.

```bash
root@ud101:~# systemctl restart winbind
```

Comprobamos si Ubuntu Destkop se integró al dominio listando los usuarios y grupos del servidor samba.

```bash
root@ud101:~# wbinfo -u
alumno
guest
administrator
krbtgt

root@ud101:~# wbinfo -g
ras and ias servers
protected users
domain guests
domain users
cert publishers
schema admins
read-only domain controllers
allowed rodc password replication group
domain controllers
enterprise read-only domain controllers
domain admins
enterprise admins
denied rodc password replication group
group policy creator owners
dnsupdateproxy
domain computers
dnsadmins
```

Verificar el módulo winbind nsswitch con el comando getent. La diferencia clave entre getent y otros comando es la siguiente:

- cat /etc/passwd: Solo muestra usuarios locales.
- wbinfo -u: Solo muestra usuarios del dominio.
- getent passwd: Muestra TODOS (Locales + Dominio) listos para usarse.

```bash
root@ud101:~# getent passwd | grep administrator
administrator:*:50002:50000::/home/INSTITUTO/administrator:/bin/bash
root@ud101:~# getent group | grep 'domain admins'
domain admins:x:50010:
root@ud101:~# id administrator
uid=50002(administrator) gid=50000(domain users) grupos=50000(domain users),50010(domain admins),50012(denied rodc password replication group),50005(schema admins),50011(enterprise admins),50013(group policy creator owners)
```

Configurar pam-auth-update para autenticarnos con cuentas de dominio y que se creen automáticamente los directorios. Seleccionamos la opción de "Create home directory on login".

PAM significa Pluggable Authentication Modules (Módulos de Autenticación Conectables). PAM es imprescindible porque actúa como el puente de seguridad que permite a Linux enviar la contraseña al iniciar sesión directamente al Controlador de Dominio para que este la verifique; sin PAM, el sistema operativo solo sabría que el usuario existe (gracias a getent), pero no tendría forma de comprobar si la clave es correcta ni capacidad para crear automáticamente la carpeta personal (/home) del usuario la primera vez que entra.

```bash
root@ud101:~# pam-auth-update
```

Editamos el archivo `/etc/pam.d/common-account` para crear automáticamente directorios y añadimos al final del archivo el contenido "session required pam_mkhomedir.so skel=/etc/skel/ umask=0022".

```bash
root@ud101:~# echo "session required pam_mkhomedir.so skel=/etc/skel/ umask=0022" >> /etc/pam.d/common-account
```

Autenticarse con cuenta Samba4 AD

```bash
root@ud101:~# su - administrator
Creando directorio «/home/INSTITUTO/administrator».
administrator@ud101:~$
```

Añadir cuenta de dominio con privilegios root

```bash
root@ud101:~# usermod -aG sudo administrator
```

Autenticarse con GUI
administrator@instituto.local

Si vemos los directorios existentes comprobamos que existen los siguietes:

```bash
root@ud101:~# ls /home
INSTITUTO  usuario
root@ud101:~# ls /home/INSTITUTO/
administrator
```
