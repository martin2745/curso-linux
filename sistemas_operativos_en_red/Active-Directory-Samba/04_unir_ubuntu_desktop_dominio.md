# 04 Unir Ubuntu Desktop al dominio

## Índice

1. [Configuraciones necesarias para unirse al dominio](#configuraciones-necesarias-para-unirse-al-dominio)
2. [Instalación de paquetes requeridos](#instalación-de-paquetes-requeridos)
3. [Configuración de Samba y Winbind](#configuración-de-samba-y-winbind)
4. [Unión del equipo al dominio](#unión-del-equipo-al-dominio)
5. [Configuración de autenticación de cuentas de AD](#configuración-de-autenticación-de-cuentas-de-ad)

---

## Configuraciones necesarias para unirse al dominio

Al igual que hicimos con el cliente Windows, primero debemos preparar nuestro equipo `Ubuntu Desktop` para integrarse correctamente en el dominio de Active Directory gestionado por Samba.

Editamos el nombre de la máquina para que sea identificable en el dominio, por ejemplo `ud101`.

```bash
root@ubuntu:~# hostnamectl set-hostname ud101
root@ubuntu:~# hostname -f
ud101
```

Configuramos el fichero local `/etc/hosts` con los datos de resolución estática del dominio para facilitar el descubrimiento inicial.

```bash
root@ubuntu:~# cat /etc/hosts
...
192.168.100.6 instituto.local instituto
192.168.100.6 dc.instituto.local dc
...
```

Comprobamos que tenemos conectividad hacia el dominio `instituto.local`.

```bash
root@ubuntu:~# ping -c 3 instituto.local
PING instituto.local (192.168.100.6) 56(84) bytes of data.
64 bytes from instituto.local (192.168.100.6): icmp_seq=1 ttl=64 time=1.42 ms
64 bytes from instituto.local (192.168.100.6): icmp_seq=2 ttl=64 time=0.791 ms
64 bytes from instituto.local (192.168.100.6): icmp_seq=3 ttl=64 time=0.741 ms

--- instituto.local ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2012ms
rtt min/avg/max/mdev = 0.741/0.983/1.418/0.308 ms
```

> **Recuerda:** El protocolo Kerberos es extremadamente sensible a las diferencias de tiempo entre el cliente y el servidor (tolerancia máxima típica de 5 minutos). 

Por lo tanto, instalamos el paquete `ntpdate` para poder sincronizar el reloj de nuestro equipo cliente con el servidor de dominio antes de solicitar tickets.

```bash
root@ud101:~# apt install ntpdate -y
```

Ejecutamos la sincronización de tiempo apuntando a nuestro Controlador de Dominio.

```bash
root@ud101:~# ntpdate -q instituto.local
2026-01-10 00:44:24.891035 (+0100) +0.222763 +/- 0.000836 instituto.local 192.168.100.6 s3 no-leap
root@ud101:~# ntpdate instituto.local
2026-01-10 00:45:22.889470 (+0100) +0.190513 +/- 0.000861 instituto.local 192.168.100.6 s3 no-leap
```

---

## Instalación de paquetes requeridos

A continuación vamos a instalar todos los paquetes necesarios para la integración de un cliente Linux en Active Directory.

```bash
root@ud101:~# apt install -y samba krb5-config krb5-user winbind libpam-winbind libnss-winbind
```

Durante la instalación interactiva de `krb5-config`, el sistema nos realizará preguntas sobre nuestro entorno de Kerberos. Contestamos lo siguiente:

- **Reino (Realm) por defecto:** `INSTITUTO.LOCAL` (siempre en mayúsculas).
- **Servidor Kerberos de tu reino:** `dc.instituto.local`.
- **Servidor Administrativo de tu reino:** `dc.instituto.local`.

```bash
INSTITUTO.LOCAL
dc.instituto.local
dc.instituto.local
```

Comprobamos la autenticación en el servidor de Kerberos solicitando un ticket TGT para el administrador del dominio:

```bash
root@ud101:~# kinit administrator@INSTITUTO.LOCAL
Password for administrator@INSTITUTO.LOCAL:
Warning: Your password will expire in 40 days on vie 20 feb 2026 11:08:27
```

Verificamos que el ticket ha sido otorgado y almacenado correctamente en la caché local:

```bash
root@ud101:~# klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: administrator@INSTITUTO.LOCAL

Valid starting     Expires            Service principal
11/01/26 10:38:06  11/01/26 20:38:06  krbtgt/INSTITUTO.LOCAL@INSTITUTO.LOCAL
        renew until 12/01/26 10:38:01
```

---

## Configuración de Samba y Winbind

El cliente Ubuntu debe actuar como miembro del dominio (`member server`) y no como Controlador de Dominio.

Movemos el archivo `smb.conf` por defecto para crear una copia de seguridad.

```bash
root@ud101:~# mv /etc/samba/smb.conf /etc/samba/smb.conf.initial
```

Creamos un archivo `smb.conf` nuevo y vacío, e introducimos la siguiente configuración optimizada para un cliente de Active Directory.

```bash
root@ud101:~# cat /etc/samba/smb.conf
[global]
    workgroup = INSTITUTO
    realm = INSTITUTO.LOCAL
    netbios name = ud101
    security = ADS
    dns forwarder = 192.168.100.6

    # Configuración de idmap (Mapeo de identidades de SID a UID/GID)
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

Reiniciamos todos los demonios de Samba asociados a los roles de compartición y resolución NetBIOS para aplicar la configuración.

```bash
root@ud101:~# systemctl restart smbd nmbd
```

Detenemos y deshabilitamos el servicio `samba-ad-dc`, que es innecesario y contraproducente en un cliente (solo debe correr en el Controlador de Dominio):

```bash
root@ud101:~# systemctl stop samba-ad-dc
```

Habilitamos explícitamente los servicios de cliente/servidor de ficheros para que inicien con el sistema:

```bash
root@ud101:~# systemctl enable smbd nmbd
Synchronizing state of smbd.service with SysV service script with /usr/lib/systemd/systemd-sysv-install.
Executing: /usr/lib/systemd/systemd-sysv-install enable smbd
Synchronizing state of nmbd.service with SysV service script with /usr/lib/systemd/systemd-sysv-install.
Executing: /usr/lib/systemd/systemd-sysv-install enable nmbd
```

---

## Unión del equipo al dominio

Con la configuración de red y Samba listas, procedemos a unir el `Ubuntu Desktop` al dominio de Active Directory. Ejecutamos el comando `net ads join` empleando un usuario con privilegios administrativos en el dominio.

> **Nota:** Es normal recibir advertencias de actualización de DNS ("No DNS domain configured") si el cliente no está utilizando un servicio DNS dinámico que pueda registrarse automáticamente en el servidor. La unión lógica a LDAP/Kerberos, sin embargo, se realiza con éxito.

```bash
root@ud101:~# net ads join -U administrator
Password for [INSTITUTO\administrator]:
get_kdc_ip_string: get_kdc_list (site-less) fail NT_STATUS_NO_LOGON_SERVERS
Using short domain name -- INSTITUTO
Joined 'UD101' to dns domain 'instituto.local'
No DNS domain configured for ud101. Unable to perform DNS Update.
DNS update failed: NT_STATUS_INVALID_PARAMETER
```

Desde el Controlador de Dominio (`dc`), listamos los equipos y verificamos que nuestro equipo Linux se ha registrado exitosamente.

```bash
root@dc:~# samba-tool computer list
W101$
UD101$
DC$
```

---

## Configuración de autenticación de cuentas de AD

Editamos el archivo de configuración del conmutador de servicio de nombres (NSS, Name Service Switch). De este modo conseguimos que, al realizar validaciones de usuarios o grupos, el sistema operativo consulte a `winbind` y por ende a Active Directory, en lugar de limitarse solo a los usuarios locales.

> **Funcionamiento del flujo NSS (por ejemplo, con `getent passwd administrator`):**
> 
> - **passwd:** El sistema necesita información de un usuario.
> - **compat:** Primero mira en los archivos locales. Si el usuario "administrator" existe en `/etc/passwd`, usa ese y se detiene.
> - **winbind:** Si no lo encuentra en local, el sistema le pregunta a Samba (`Winbind`). `Winbind` consulta al Controlador de Dominio. Si el usuario se encuentra allí, devuelve la información mapeada a Linux.

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

Reiniciamos el servicio `winbind` para que registre los cambios y cargue los módulos correspondientes del NSS.

```bash
root@ud101:~# systemctl restart winbind
```

Comprobamos si el cliente Ubuntu se ha integrado correctamente al dominio listando los usuarios y grupos extraídos desde el servidor Samba Active Directory a través de `wbinfo`.

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

Verificamos el funcionamiento integrado del módulo winbind con el NSS utilizando el comando `getent`.

> **Recuerda: Diferencias clave entre comandos de consulta:**
> - `cat /etc/passwd`: Solo muestra usuarios locales del sistema.
> - `wbinfo -u`: Solo muestra usuarios del dominio consultando directamente a Winbind.
> - `getent passwd`: Muestra TODOS (Locales + Dominio) al pasar a través del NSS, indicando que el sistema operativo ya los reconoce nativamente.

```bash
root@ud101:~# getent passwd | grep administrator
administrator:*:50002:50000::/home/INSTITUTO/administrator:/bin/bash
root@ud101:~# getent group | grep 'domain admins'
domain admins:x:50010:
root@ud101:~# id administrator
uid=50002(administrator) gid=50000(domain users) grupos=50000(domain users),50010(domain admins),50012(denied rodc password replication group),50005(schema admins),50011(enterprise admins),50013(group policy creator owners)
```

Por último, debemos configurar `pam-auth-update` para poder iniciar sesión con cuentas de dominio y permitir que el sistema cree automáticamente los directorios personales (`/home`) en el primer inicio de sesión. 

> **¿Por qué es necesario PAM?**
> PAM significa Pluggable Authentication Modules (Módulos de Autenticación Conectables). Es imprescindible porque actúa como el puente de seguridad que permite a Linux enviar la contraseña ingresada en el inicio de sesión directamente al Controlador de Dominio para que este la verifique. Sin PAM, el sistema operativo solo sabría que el usuario existe (gracias a `getent`), pero no tendría forma de validar contraseñas ni de crear carpetas.

```bash
root@ud101:~# pam-auth-update
```

*(En la interfaz que aparece, asegúrate de seleccionar la opción "Create home directory on login" y las de Winbind).*

Alternativamente o como complemento de lo anterior, podemos asegurar la creación automática de directorios añadiendo un módulo PAM específico (`pam_mkhomedir.so`) al final del archivo `/etc/pam.d/common-account`.

```bash
root@ud101:~# echo "session required pam_mkhomedir.so skel=/etc/skel/ umask=0022" >> /etc/pam.d/common-account
```

Probamos a autenticarnos directamente desde la terminal con una cuenta del dominio Samba AD, en este caso el `administrator`.

```bash
root@ud101:~# su - administrator
Creando directorio «/home/INSTITUTO/administrator».
administrator@ud101:~$
```

Para dotar a este usuario de dominio de privilegios de administración (sudo) en la máquina local, lo añadimos al grupo local `sudo`.

```bash
root@ud101:~# usermod -aG sudo administrator
```

A partir de este momento, ya podemos autenticarnos desde la Interfaz Gráfica de Usuario (GUI) utilizando credenciales como `administrator@instituto.local` o `INSTITUTO\administrator`.

Si verificamos los directorios existentes en `/home`, comprobaremos que se ha creado correctamente la estructura jerárquica para los usuarios del dominio bajo el nombre del grupo de trabajo.

```bash
root@ud101:~# ls /home
INSTITUTO  usuario
root@ud101:~# ls /home/INSTITUTO/
administrator
```
