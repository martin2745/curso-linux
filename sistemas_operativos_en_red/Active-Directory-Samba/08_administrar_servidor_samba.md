# 08 Administrar servidor Samba

## Comandos principales

A continuación vemos varias formas de realizar tareas de administración del servidor.

1. Ayuda de Samba.

```bash
root@dc:~# samba-tool -h
```

2. Añadir un usuario nuevo.

```bash
root@dc:~# samba-tool user add juan
New Password:
Retype Password:
User 'juan' added successfully
```

3. Eliminar un usuario.

```bash
root@dc:~# samba-tool user delete juan
Deleted user juan
```

3. Listar usuarios.

Volvemos a añadir a juan y listamos los usuarios.

```bash
root@dc:~# samba-tool user list
alumno
prueba
Guest
juan
Administrator
krbtgt
```

4. Cambar contraseña del usuario.

```bash
root@dc:~# samba-tool user setpassword juan
New Password:
Retype Password:
Changed password OK
```

5. Deshabilitar y habilitar un usuario.

```bash
root@dc:~# samba-tool user disable juan
```

```bash
root@dc:~# samba-tool user enable juan
Enabled user 'juan'
```

6. Crear un grupo.

```bash
root@dc:~# samba-tool group add alumnos
Added group alumnos
```

7. Listar grupos.

```bash
root@dc:~# samba-tool group list
```

8. Añadir un usuario a un grupo.

```bash
root@dc:~# samba-tool group addmembers alumnos juan
Added members to group alumnos
```

9.  Mostrar miembros de un grupo.

```bash
root@dc:~# samba-tool group listmembers alumnos
juan
```

10. Política de contraseñas.

```bash
root@dc:~# samba-tool domain passwordsettings show
Password information for domain 'DC=instituto,DC=local'

Password complexity: on
Store plaintext passwords: off
Password history length: 24
Minimum password length: 7
Minimum password age (days): 1
Maximum password age (days): 42
Account lockout duration (mins): 30
Account lockout threshold (attempts): 0
Reset account lockout after (mins): 30
```

## Autenticación local con cuentas de Samba AD

1. Vamos a permitir la autenticación de usuarios del dominio para lo que tenemos que modificar el apartado global de `/etc/samba/smb.conf`.

```bash
root@dc:~# cat /etc/samba/smb.conf
# Global parameters
[global]
        dns forwarder = 8.8.8.8
        netbios name = DC
        realm = INSTITUTO.LOCAL
        server role = active directory domain controller
        workgroup = INSTITUTO
        template shell = /bin/bash
        winbind use default domain = true
        winbind offline logon = false
        winbind enum users = yes
        winbind enum groups = yes

[sysvol]
        path = /var/lib/samba/sysvol
        read only = No

[netlogon]
        path = /var/lib/samba/sysvol/instituto.local/scripts
        read only = No
```

2. Comprobamos que la configuración es correcta y reiniciamos samba.

```bash
root@dc:~# testparm
Load smb config files from /etc/samba/smb.conf
Loaded services file OK.
```

```bash
root@dc:~# systemctl restart samba-ad-dc.service
```

3. Configurar PAM y NSSWITCH

Actualizamos la configuración PAM (marcamos las opciones necesarias):

```bash
root@dc:~# pam-auth-update
```

Marcamos: _Create home directory on login_.

Modificamos el fichero `/etc/nsswitch.conf`.

```bash
root@dc:~# cat /etc/nsswitch.conf
# /etc/nsswitch.conf
#
# Example configuration of GNU Name Service Switch functionality.
# If you have the `glibc-doc-reference' and `info' packages installed, try:
# `info libc "Name Service Switch"' for information about this file.

passwd:         compat winbind
group:          compat winbind
shadow:         compat
gshadow:        files systemd

hosts:          files dns
networks:       files

protocols:      db files
services:       db files
ethers:         db files
rpc:            db files

netgroup:       nis
```

4. Modificar common-password.

Este fichero nos permite que cuando accedemos al AD con los usuarios creados en samba podamos modificar su contraseña. Este paso requiere editar con cuidado los cambios a realizar dentro del archivo:

- Comenta (pon un # delante) las líneas que contengan pam_krb5.so y la primera de pam_winbind.so.
- Busca la línea de pam_unix.so y elimina la opción use_authtok.
- Añade al final la nueva línea para winbind.

```bash
root@dc:~# cat /etc/pam.d/common-password
#
# /etc/pam.d/common-password - password-related modules common to all services
#
# This file is included from other service-specific PAM config files,
# and should contain a list of modules that define the services to be
# used to change user passwords.  The default is pam_unix.

# Explanation of pam_unix options:
# The "yescrypt" option enables
#hashed passwords using the yescrypt algorithm, introduced in Debian
#11.  Without this option, the default is Unix crypt.  Prior releases
#used the option "sha512"; if a shadow password hash will be shared
#between Debian 11 and older releases replace "yescrypt" with "sha512"
#for compatibility .  The "obscure" option replaces the old
#`OBSCURE_CHECKS_ENAB' option in login.defs.  See the pam_unix manpage
#for other options.

# As of pam 1.0.1-6, this file is managed by pam-auth-update by default.
# To take advantage of this, it is recommended that you configure any
# local modules either before or after the default block, and use
# pam-auth-update to manage selection of other modules.  See
# pam-auth-update(8) for details.

# here are the per-package modules (the "Primary" block)
password        [success=2 default=ignore]      pam_unix.so obscure try_first_pass yescrypt
password        [success=1 default=ignore]      pam_winbind.so try_first_pass
# here's the fallback if no module succeeds
password        requisite                       pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
password        required                        pam_permit.so
# and here are more per-package modules (the "Additional" block)
# end of pam-auth-update config
```

5. Deshabilitar servicio winbind

Como el servicio samba-ad-dc ya gestiona el winbind internamente, debemos parar el servicio independiente para evitar conflictos.

```bash
root@dc:~# systemctl disable winbind.service
Synchronizing state of winbind.service with SysV service script with /usr/lib/systemd/systemd-sysv-install.
Executing: /usr/lib/systemd/systemd-sysv-install disable winbind
root@dc:~# systemctl stop winbind.service
```

6. Recuperar información de usuarios y grupos de AD.

Comandos para comprobar que el sistema ve los usuarios del dominio correctamente.

```bash
root@dc:~# wbinfo -g
INSTITUTO\cert publishers
INSTITUTO\ras and ias servers
INSTITUTO\allowed rodc password replication group
INSTITUTO\denied rodc password replication group
INSTITUTO\dnsadmins
INSTITUTO\enterprise read-only domain controllers
INSTITUTO\domain admins
INSTITUTO\domain users
INSTITUTO\domain guests
INSTITUTO\domain computers
INSTITUTO\domain controllers
INSTITUTO\schema admins
INSTITUTO\enterprise admins
INSTITUTO\group policy creator owners
INSTITUTO\read-only domain controllers
INSTITUTO\protected users
INSTITUTO\dnsupdateproxy
INSTITUTO\alumnos
```

```bash
root@dc:~# wbinfo -u
INSTITUTO\administrator
INSTITUTO\guest
INSTITUTO\krbtgt
INSTITUTO\alumno
INSTITUTO\prueba
INSTITUTO\juan
```

```bash
root@dc:~# wbinfo -i juan
INSTITUTO\juan:*:3000023:100::/home/INSTITUTO/juan:/bin/bash
```

```bash
root@dc:~# getent passwd | grep juan
INSTITUTO\juan:*:3000023:100::/home/INSTITUTO/juan:/bin/bash
```

```bash
root@dc:~# getent group | grep alumnos
INSTITUTO\alumnos:x:3000051:
```

Podemos intentar acceder como usuario anteriormente creado.

```bash
root@dc:~# su - juan
Creating directory '/home/INSTITUTO/juan'.
```

```bash
INSTITUTO\juan@dc:~$ id
uid=3000023(INSTITUTO\juan) gid=100(users) groups=100(users),3000009(BUILTIN\users),3000023(INSTITUTO\juan),3000051(INSTITUTO\alumnos)
```

Editamos su contraseña.

```bash
INSTITUTO\juan@dc:~$ passwd
Changing password for INSTITUTO\juan
(current) NT password:
Enter new NT password:
Retype new NT password:
Your password must be at least 7 characters; cannot repeat any of your previous 24 passwords; must contain capitals, numerals or punctuation; and cannot contain your account or full name; Please type a different password. Type a password which meets these requirements in both text boxes.
passwd: Authentication token manipulation error
passwd: password unchanged
```
