# 08 Administrar servidor Samba

## Índice

1. [Comandos principales](#comandos-principales)
2. [Autenticación local con cuentas de Samba AD](#autenticación-local-con-cuentas-de-samba-ad)

---

## Comandos principales

A continuación vemos varias formas de realizar tareas de administración básicas del servidor desde la línea de comandos mediante la utilidad `samba-tool`.

1. **Ayuda de Samba.** Nos proporciona un listado de los subcomandos disponibles.

```bash
root@dc:~# samba-tool -h
```

2. **Añadir un usuario nuevo.** Crea una cuenta de dominio interactiva.

```bash
root@dc:~# samba-tool user add juan
New Password:
Retype Password:
User 'juan' added successfully
```

3. **Eliminar un usuario.** Borra la cuenta de Active Directory de forma permanente.

```bash
root@dc:~# samba-tool user delete juan
Deleted user juan
```

4. **Listar usuarios.** Muestra todos los usuarios presentes en el dominio, incluidos los integrados por defecto (`Administrator`, `krbtgt`, `Guest`).

```bash
root@dc:~# samba-tool user list
alumno
prueba
Guest
juan
Administrator
krbtgt
```

5. **Cambiar contraseña del usuario.** Permite al administrador forzar un cambio de contraseña sin conocer la anterior.

```bash
root@dc:~# samba-tool user setpassword juan
New Password:
Retype Password:
Changed password OK
```

6. **Deshabilitar y habilitar un usuario.** Cambia el estado de la cuenta sin eliminarla. Útil para bajas temporales.

Para deshabilitar:
```bash
root@dc:~# samba-tool user disable juan
```

Para volver a habilitar:
```bash
root@dc:~# samba-tool user enable juan
Enabled user 'juan'
```

7. **Crear un grupo de seguridad.** Crea un grupo organizativo para la asignación de permisos.

```bash
root@dc:~# samba-tool group add alumnos
Added group alumnos
```

8. **Listar grupos.** Muestra todos los grupos del dominio.

```bash
root@dc:~# samba-tool group list
```

9. **Añadir un usuario a un grupo.** Añade un usuario (ej. `juan`) a un grupo específico (ej. `alumnos`).

```bash
root@dc:~# samba-tool group addmembers alumnos juan
Added members to group alumnos
```

10. **Mostrar miembros de un grupo.** Permite auditar qué usuarios forman parte del grupo.

```bash
root@dc:~# samba-tool group listmembers alumnos
juan
```

11. **Política de contraseñas.** Permite visualizar (y posteriormente modificar) las reglas estrictas impuestas a las contraseñas del dominio (longitud, caducidad, historial y bloqueos).

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

---

## Autenticación local con cuentas de Samba AD

En ocasiones, puede ser útil permitir que los administradores o usuarios del dominio inicien sesión por consola o SSH *directamente en el propio servidor Linux* (`Ubuntu Server`) que actúa como Controlador de Dominio. 

1. Vamos a permitir la autenticación de usuarios del dominio. Para ello, tenemos que modificar el bloque `[global]` en el archivo `/etc/samba/smb.conf`, habilitando la enumeración de usuarios y configurando `winbind`.

```bash
root@dc:~# cat /etc/samba/smb.conf
# Global parameters
[global]
        dns forwarder = 8.8.8.8
        netbios name = DC
        realm = INSTITUTO.LOCAL
        server role = active directory domain controller
        workgroup = INSTITUTO
        
        # Parámetros Winbind añadidos para integración local
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

2. Comprobamos que la sintaxis de la configuración es correcta usando `testparm` y reiniciamos el servicio `samba-ad-dc` para aplicar los parámetros.

```bash
root@dc:~# testparm
Load smb config files from /etc/samba/smb.conf
Loaded services file OK.
```

```bash
root@dc:~# systemctl restart samba-ad-dc.service
```

3. **Configurar PAM y NSSWITCH**: 

Actualizamos la configuración PAM utilizando la herramienta interactiva.

```bash
root@dc:~# pam-auth-update
```

*(En la interfaz, marcamos obligatoriamente la opción: **Create home directory on login**).*

A continuación, modificamos el fichero `/etc/nsswitch.conf` para indicar al sistema operativo que debe consultar a `winbind` para resolver usuarios y contraseñas.

```bash
root@dc:~# cat /etc/nsswitch.conf
...
passwd:         compat winbind
group:          compat winbind
shadow:         compat
gshadow:        files systemd

hosts:          files dns
...
```

4. **Modificar `common-password`**:

Este fichero nos permite que cuando accedemos al AD con los usuarios del dominio, podamos modificar su contraseña de Samba utilizando el comando estándar `passwd` de Linux. Este paso requiere editar con extremo cuidado las directivas dentro del archivo `/etc/pam.d/common-password`:

- Comenta (pon un `#` delante) las líneas que contengan `pam_krb5.so` y la primera declaración de `pam_winbind.so`.
- Busca la línea de `pam_unix.so` y elimina la directiva `use_authtok`.
- Añade una nueva línea para invocar a `pam_winbind.so` justo debajo de `pam_unix.so`.

```bash
root@dc:~# cat /etc/pam.d/common-password
#
# /etc/pam.d/common-password - password-related modules common to all services
#
...
# here are the per-package modules (the "Primary" block)
password        [success=2 default=ignore]      pam_unix.so obscure try_first_pass yescrypt
password        [success=1 default=ignore]      pam_winbind.so try_first_pass
# here's the fallback if no module succeeds
password        requisite                       pam_deny.so
...
```

> **Advertencia:** Errores en la edición de módulos PAM pueden causar bloqueos de acceso totales al servidor. Presta especial atención a la sintaxis.

5. **Deshabilitar el servicio `winbind` independiente**:

Como el superservicio `samba-ad-dc` ya instancía y gestiona internamente su propio demonio de Winbind optimizado para Active Directory, debemos parar y deshabilitar el servicio de Winbind independiente proporcionado por Ubuntu para evitar conflictos de sockets.

```bash
root@dc:~# systemctl disable winbind.service
Synchronizing state of winbind.service with SysV service script with /usr/lib/systemd/systemd-sysv-install.
Executing: /usr/lib/systemd/systemd-sysv-install disable winbind

root@dc:~# systemctl stop winbind.service
```

6. **Verificar la integración de usuarios y grupos**:

Lanzamos los comandos de `wbinfo` para comprobar que el sistema (vía Winbind) se comunica internamente con la base de datos LDAP del dominio.

Para listar todos los grupos de dominio:
```bash
root@dc:~# wbinfo -g
INSTITUTO\cert publishers
INSTITUTO\domain admins
...
INSTITUTO\alumnos
```

Para listar todos los usuarios del dominio:
```bash
root@dc:~# wbinfo -u
INSTITUTO\administrator
INSTITUTO\guest
INSTITUTO\juan
```

Para extraer la información de sistema operativo (UID, GID, shell) de un usuario específico de dominio:
```bash
root@dc:~# wbinfo -i juan
INSTITUTO\juan:*:3000023:100::/home/INSTITUTO/juan:/bin/bash
```

Verificamos que la capa superior (NSS) también reconozca correctamente a los usuarios del dominio utilizando `getent`. Esto confirma que el enlace entre Linux y Samba funciona de forma transparente.

```bash
root@dc:~# getent passwd | grep juan
INSTITUTO\juan:*:3000023:100::/home/INSTITUTO/juan:/bin/bash

root@dc:~# getent group | grep alumnos
INSTITUTO\alumnos:x:3000051:
```

7. **Prueba final de inicio de sesión local**:

Podemos intentar acceder como el usuario del dominio `juan` directamente desde la terminal de root:

```bash
root@dc:~# su - juan
Creating directory '/home/INSTITUTO/juan'.
```

Verificamos su identidad generada por Winbind:

```bash
INSTITUTO\juan@dc:~$ id
uid=3000023(INSTITUTO\juan) gid=100(users) groups=100(users),3000009(BUILTIN\users),3000023(INSTITUTO\juan),3000051(INSTITUTO\alumnos)
```

Si intentamos editar su contraseña, comprobaremos que interactúa directamente con la política de contraseñas de Active Directory (como vimos con `samba-tool domain passwordsettings show`), lo que significa que el sistema aplica los bloqueos y validaciones de complejidad de Microsoft:

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

> **Nota:** El error "Authentication token manipulation error" ocurre de forma controlada porque la contraseña propuesta no cumple con la estricta política de complejidad o longitud mínima de Active Directory definida en nuestro entorno.
