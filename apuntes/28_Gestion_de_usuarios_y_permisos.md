# Gestion de usuarios y permisos

## Archivos de configuración

Los archivos de configuración importantes en sistemas Linux referentes a la gestión de usuarios y grupos son:

- **/etc/passwd**: Almacena información sobre usuarios del sistema, como nombres de usuario, IDs de usuario, directorios de inicio y shell predeterminada.

````bash
martin:x:1000:1000:martin,23,666777888,981234567:/home/martin:/bin/bash```
````

1. `martin`: Usuario.
2. `x`: Usado antiguamente para colocar la clave. En la actualidad no se coloca la clave en este campo (se pone siempre una x) y la clave se coloca en /etc/shadow.
3. `1000`: UID.
4. `1000`: GID.
5. `martin,23,666777888,981234567`: Datos del usuario.
6. `/home/martin`: Directorio de trabajo.
7. `/bin/bash`: Shell.

- **/etc/shadow**: Contiene contraseñas encriptadas de los usuarios y datos de seguridad relacionados, como políticas de contraseñas y fechas de caducidad.

```bash
martin:$6$QeYgJjn3$WUebH8Ku2cb3ZOUVpqA3c.zrCzH38hJrM7m3cE8HQitQBr6FF/4Ussq/gnGzBomMBmCxgjyQamLE8V3GHe.rn1:18792:0:99999:7:::
```

1. `martin`: Nombre de usuario.
2. `$6$QeYgJjn3$WUebH8Ku2cb3ZOUVpqA3c.zrCzH38hJrM7m3cE8HQitQBr6FF/4Ussq/gnGzBomMBmCxgjyQamLE8V3GHe.rn1`: Contraseña cifrada (hash de la contraseña, incluye información sobre el algoritmo de cifrado y la sal).
3. `18792`: Fecha del último cambio de contraseña (en días desde el 1 de enero de 1970).
4. `0`: Días mínimos requeridos antes de poder cambiar la contraseña nuevamente.
5. `99999`: Días máximos que puede usarse la contraseña antes de que expire.
6. `7`: Días de aviso antes de que la contraseña expire.
7. ``: Días de inactividad permitidos después de que la contraseña ha expirado (vacío significa sin restricción).
8. ``: Fecha de expiración de la cuenta (vacío significa que la cuenta no expira).
9. ``: Campo reservado para uso futuro.

- **/etc/group**: Guarda información sobre los grupos del sistema, incluyendo nombres de grupo y listas de usuarios asociados a cada grupo.

```bash
dam:x:1001:martin,lucas
```

1. `dam`: Nombre del grupo.
2. `x`: Contraseña del grupo (generalmente se coloca una "x" para indicar que está encriptada en `/etc/gshadow`).
3. `1001`: GID (identificador de grupo).
4. `martin,lucas`: Lista de usuarios secundarios separados por comas.

- **/etc/gshadow**: Similar a `/etc/shadow`, pero para grupos, almacena contraseñas encriptadas para grupos y datos de seguridad relacionados.

```bash
dam:RsdRTGHtdrs:moncho:lipido,rivelora
```

1. `dam`: Nombre del grupo.
2. `RsdRTGHtdrs`: Contraseña del grupo, así un usuario podrá ingresar al grupo si conoce la contraseña.
3. `moncho`: Administrador del grupo.
4. `lipido,rivelora`: Usuarios que no se quiere que se conozca su pertenencia al grupo.

## su y sudo

```bash
martin@debian:/etc/sudoers.d$ sudo su -
martin@debian:/etc/sudoers.d$ sudo su
martin@debian:/etc/sudoers.d$ sudo -i
martin@debian:/etc/sudoers.d$ su juan
martin@debian:/etc/sudoers.d$ su - juan
martin@debian:/etc/sudoers.d$ su - juan -c "pwd"
martin@debian:/etc/sudoers.d$ su -l juan
martin@debian:/etc/sudoers.d$ su --c "pwd"
```

1. `sudo su -`: Inicia un shell interactivo como el usuario root, cargando el entorno de inicio de sesión del usuario root.
2. `sudo su`: Inicia un shell interactivo como el usuario root, heredando el entorno del usuario actual.
3. `sudo -i`: Inicia un nuevo shell interactivo como el usuario root, cargando completamente el entorno de inicio de sesión del usuario root.
4. `su juan`: Cambia al usuario "juan" iniciando un nuevo shell pero sin cargar su entorno de inicio de sesión.
5. `su - juan`: Cambia al usuario "juan" iniciando un nuevo shell y cargando su entorno de inicio de sesión.
6. `su - juan -c "pwd"`: Cambia al usuario "juan", ejecuta el comando "pwd" y luego regresa al usuario actual.
7. `su -l juan`: Cambia al usuario "juan" iniciando un nuevo shell y cargando su entorno de inicio de sesión (equivalente a `su - juan`).
8. `su --c "pwd"`: Intenta ejecutar el comando "pwd" en el shell actual, pero probablemente generaría un error ya que la opción "--c" no es válida para el comando `su`.

## visudo y sudoers

`visudo` es el editor que permite modificar el archivo sudoers.

`sudoers` es el fichero donde se especifican las reglas para poder establecer quienes pueden ejecutar que comandos en nombre de sudo y en que hosts.

```bash
# Alias
Cmnd_Alias RECARGAR_SSH = systemctl restart sshd.service
Host_Alias PC_ALEX = 192.168.1.22

# User privilege specification
root    ALL=(ALL:ALL) ALL

# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) ALL

martin 192.168.1.14,192.168.1.15=(juan:dam) NOPASSWD: /bin/pwd

%asir 192.168.1.14,192.168.1.15=(juan:dam) /bin/pwd

martin PC_ALEX=(alex) NOPASSWD: RECARGAR_SSH
```

Al final estas entradas especifican para el usuario martin (analogo para el grupo asir) lo siguiente:

- **martin**: El usuario al que se aplica la regla. En este caso, el usuario "martin" puede ejecutar el comando especificado.
- **192.168.1.14,192.168.1.15**: Las direcciones IP de los Host de la red donde el usuario "martin" puede ejecutar el comando.
- **(juan:dam)**: El usuario y el grupo sobre los que martin puede ejecutar comandos en su nombre.
- **NOPASSWD: **: Indica que se puede ejecutar el comando sin que se pregunte la contraseña.
- **/bin/pwd**: El comando permitido.

En el archivo sudoers, cuando especificas una entrada como esta:

```bash
martin 192.168.1.14,192.168.1.15=(juan:dam) /bin/pwd
```

Significa que el usuario "martin" puede ejecutar el comando `/bin/pwd` **en el host 192.168.1.14** en nombre de juan o del grupo dam. Esto no significa que el usuario "martin" pueda ejecutar el comando `pwd` en su propio sistema local desde cualquier host.

#### id, groups, passwd

**id**: Permite ver uid, gid y grupos secundarios a los que pertenece el usuario.

**groups**: Permite ver unicamente los grupos secundarios del usuario.

```bash
martin@debian:~$ id
uid=1000(martin) gid=1000(martin) grupos=1000(martin),24(cdrom),25(floppy),27(sudo),29(audio),30(dip),44(video),46(plugdev),100(users),106(netdev),113(bluetooth),116(lpadmin),119(scanner)
martin@debian:~$ groups
martin cdrom floppy sudo audio dip video plugdev users netdev bluetooth lpadmin scanner

martin@debian:~$ sudo su -
root@debian:~# id
uid=0(root) gid=0(root) grupos=0(root)
root@debian:~# groups
root
```

_*Nota*_: Nótese que el grupo root tiene el id 0.

**passwd**: Permite modificar la contraseña. Los parametros destacables son:

- l: Bloquea el acceso al sistema al usuario (usermod -L). Se pone un ! en el campo de contraseña en el `/etc/shadow`.
- u: Desbloquea el acceso al sistema del usuario (usermod -U).

```bash
martin@debian:~$ sudo passwd -l martin && sudo tail /etc/shadow | grep martin
passwd: contraseña cambiada.
martin:!$y$j9T$D1YstIGhwPXktsEmolZg./$I7fKcY0m9yE2LYgGBEn8yolExy5PLvBTIlZf5keudM3:19770:0:99999:7:::
martin@debian:~$ sudo passwd -u martin && sudo tail /etc/shadow | grep martin
passwd: contraseña cambiada.
martin:$y$j9T$D1YstIGhwPXktsEmolZg./$I7fKcY0m9yE2LYgGBEn8yolExy5PLvBTIlZf5keudM3:19770:0:99999:7:::
```

## useradd, usermod, userdel, groupadd, groupdel

**useradd**: Permite añadir nuevos usuarios al sistema.

```bash
useradd -m -d /home/juan -p "$(mkpasswd 'abc123..')" -g sistemas -G dam -s /bin/bash juan
```

```bash
usuario@debian:~$ sudo useradd -m -d /home/user1 -s /bin/bash -p $(mkpasswd -m sha-512 'abc123.') -G sudo user1
usuario@debian:~$ tail -1 /etc/passwd && sudo tail -1 /etc/shadow
user1:x:1011:1011::/home/user1:/bin/bash
user1:$6$j0kV4V7Uc2t9RDrY$XHh4NJsZA73bCXMDPkNtU.6D1TC2snGxByWwlwyyaedOd8GMPwG.6jiBxe2ecIIDbOCdBKj04oWUA.77Vrbjo/:19890:0:99999:7:::
usuario@debian:~$ ls /etc/skel/
scripts_bash
usuario@debian:~$ sudo ls /home/user1/
scripts_bash
```

```bash
usuario@debian:~$ sudo useradd -M -d /home/user2 -s /bin/bash -p $(mkpasswd -m sha-512 'abc123.') -G sudo user2
usuario@debian:~$ sudo ls /home/user2
ls: cannot access '/home/user2': No such file or directory
usuario@debian:~$ ls /home
nuevo  usuario  user1
usuario@debian:~$ tail -1 /etc/passwd
user2:x:1012:1012::/home/user2:/bin/bash
```

_*Nota: Si queremos que un usuario tenga un grupo principal con el mismo nombre, no hay que indicarlo con la opción -g, es automático.*_
_*Nota2: Podemos indicar el algoritmo de cifrado de la contraseña si queremos.*_
_*Nota3: Con el parametro `-m` estamos indicando que se copie la estructura de `/etc/skel` para el nuevo usuario.*_
_*Nota4: Con el parametro `-M` estamos indicando que el usuario no ha de tener un `/home` para el. A pesar de ello en el `/etc/passwd` si va a figurar como que existe la ruta.*_ -_Nota5: Con los parametros `-u` podemos dar un uid específico, `-g` un gid específico y con `-l` cambiar el nombre del usuario._\_
_*Nota5*_: Si quiero crear un usuario cuya cuenta caduque en un día concreto puedo hacerlo de la siguiente forma: _root@debian:~# useradd -m -p $(mkpasswd 'abc123.') -e 2025-05-10 usuario2_.

```bash
usuario@debian:~/Desktop/scripts/ejercicios/ej2$ sudo useradd -m -d /home/alumno -p $(mkpasswd 'abc123.') -s "/bin/bash" alumno

usuario@debian:~/Desktop/scripts/ejercicios/ej2$ tail -1 /etc/passwd
geoclue:x:124:131::/var/lib/geoclue:/usr/sbin/nologin
pulse:x:125:132:PulseAudio daemon,,,:/run/pulse:/usr/sbin/nologin
gnome-initial-setup:x:126:65534::/run/gnome-initial-setup/:/bin/false
hplip:x:127:7:HPLIP system user,,,:/run/hplip:/bin/false
gdm:x:128:134:Gnome Display Manager:/var/lib/gdm3:/bin/false
usuario:x:1000:1000:usuario,,,:/home/usuario:/bin/bash
vboxadd:x:999:1::/var/run/vboxadd:/bin/false
sshd:x:129:65534::/run/sshd:/usr/sbin/nologin
mysql:x:130:137:MySQL Server,,,:/nonexistent:/bin/false
alumno:x:1001:1001::/home/alumno:/bin/bash

usuario@debian:~/Desktop/scripts/ejercicios/ej2$ tail -1 /etc/group
pulse:x:132:
pulse-access:x:133:
gdm:x:134:
lxd:x:135:usuario
usuario:x:1000:
sambashare:x:136:usuario
vboxsf:x:999:
vboxdrmipc:x:998:
mysql:x:137:
alumno:x:1001:
```

_*Nota*_: Mótese que hay varios usuarios con el shell como `/bin/false` ya que están pensados para no conectarse al sistema sino ser los propios usuarios de los servicios y no precisan conectarse ni interpretar comandos. Actualmente es más común encontrarse con `/sbin/nologin`.

**usermod**: Permite modificar las propiedades de un usuario existente en el sistema.

```bash
usermod -d /home/juan_nuevo -s /bin/zsh juan
```

**userdel**: Permite eliminar un usuario del sistema.

```bash
userdel -r juan
```

- _*Nota Este comando eliminaría el usuario "juan" del sistema, junto con su directorio de inicio (`-r`), así como cualquier archivo o directorio relacionado con el usuario.*_

**groupadd**: Permite crear un nuevo grupo en el sistema.

```bash
groupadd dam
```

**groupdel**: Permite eliminar un grupo del sistema.

```bash
groupdel dam
```

#### chfn, chsh

**chage**: Permite modificar todos los datos del usuario.
**chfn**: Permite editar los datos personales del usuario.
**chsh**: Permite editar la shell del usuario.

_*Nota*_: Supongamos que creamos un usuario y queremos que en el próximo inicio de sesión, el usuario modifique su password. Para ello podemos usar los comandos `chage -d 0 usuario` o `passwd -e usuario`.

Como aportación, el comando _passwd_ permite modificar la contraseña a un usuario y parámetros y usos interesantes son los siguientes:

- _passwd -l usuario_: Bloquea la cuenta del usuario, impidiendo su acceso al sistema.
- _passwd -S usuario_: Muestra el estado de la contraseña del usuario, incluyendo si está bloqueada, la fecha del último cambio y detalles de expiración.
- _passwd -u usuario_: Desbloquea la cuenta del usuario previamente bloqueada, permitiendo nuevamente su acceso.
- _passwd -e usuario_: Fuerza a que el usuario deba cambiar su contraseña en el próximo inicio de sesión, expirando la contraseña actual de inmediato.
- _echo 000000 |passwd --stdin user1_: Asigna la contraseña “000000” al usuario user1 de forma automática, sin interacción manual.

#### /etc/nologin

El archivo `/etc/nologin` en sistemas Linux y Unix es utilizado para bloquear el acceso de usuarios regulares al sistema, especialmente durante tareas de mantenimiento o actualización. Cuando este archivo está presente, el sistema impide el inicio de sesión de los usuarios no privilegiados y muestra un mensaje que especifica que el acceso está restringido.

Para bloquear el acceso a usuarios regulares y personalizar el mensaje:
_echo "El sistema está en mantenimiento. Inténtelo más tarde." | sudo tee /etc/nologin_.

```bash
usuario@usuario:~$ ssh alex@192.168.100.3
alex@192.168.100.3's password:
Permission denied, please try again.
usuario@192.168.100.3's password:
El sistema está en mantenimiento. Inténtelo más tarde.

Connection closed by 192.168.100.3 port 22
```

Una vez completado el mantenimiento, elimina el archivo para permitir el acceso de nuevo:
_sudo rm /etc/nologin_.

`/etc/nologin` es una forma sencilla y efectiva de gestionar el acceso al sistema durante tiempos de inactividad.

#### gpasswd

Este comando establece la contraseña del grupo y lo administra pudiendo agregar o eliminar un usuario de un grupo. Los usuarios y grupos deben existir.

- _-r_: Elimina la contraseña.
- _-a_: Añade usuario al grupo.
- _-d_: Elimina usuario del grupo.
- _-A_: Añade un administrador o varios al grupo, el cual va a poder agregar o eliminar usuarios del grupo, modificar la contraseña del grupo

La contraseña de grupo le permite a los usuarios añadirse al mismo y poder usar los permisos de este, para ello pueden hacer uso del comando _newgrp_.

#### ulimit

Este comando da control sobre los recursos que dispone el shell y los procesos lanzando por ella. Se puede inicializar en `/etc/profile` o en `~/.bashrc` de cada usuario.

- _-a_: Despliega todas las limitaciones.
- _-f_: Cantidad máxima de archivos creados por la shell.
- _-n_: Cantidad máxima de archivos abiertos.
- _-u_: Cantidad máxima de procesos por usuario.

_*Nota*_: Se pueden establecer límites blandos y duros, en el caso de los blandos nos saldrá una alerta de advertencia diciendo que excedemos dicho límite.

## Campo tipo

Antes de la terna de permisos tendremos un caracter que indica el tipo de archivo en cuestión. Como resumen del campo tipo tenemos:

- -: Archivo regular.
- d: Directorio.
- l: Enlace simbólico.
- b: Dispositivo de bloque.
- c: Dispositivo de carácter.
- p: Pipe con nombre.
- s: Socket.

```bash
root@debian:~# ls
-rw-r--r--: archivo.txt              es un archivo regular.
drwxr-xr-x: directorio               carpeta es un directorio.
lrwxrwxrwx: enlace -> directorio     es un enlace simbólico que apunta a archivo.txt.
brw-rw----: /dev/sda                 es un dispositivo de bloque (probablemente un disco duro).
crw-rw-rw-: /dev/tty0                es un dispositivo de carácter (un terminal).
prw-r--r--: pipe                     es un pipe con nombre.
srwxrwxrwx: socket                   es un socket.
```

## Permisos

A continuación se van a explicar los permisos que pueden existir en un fichero o directorio y como editarlos. Supongamos que tienes un archivo llamado "documento.txt".

1. **Permisos ugo para fichero:**

   - **r (read):** Permite leer el contenido del archivo.
   - **w (write):** Permite modificar el contenido del archivo.
   - **x (execute):** Permite ejecutar el archivo como un programa o script. El propietario o los usuarios autorizados pueden ejecutar el archivo si es ejecutable.

2. **Permisos ugo para directorio:**

   - **r (read):** Permite ver el listado de archivos que contiene el directorio.
   - **w (write):** Permite modificar el contenido del directorio.
   - **x (execute):** Permite acceder al contenido del directorio.

**Ejemplo 1:**

El archivo "documento.txt" tiene permisos de lectura y escritura para el propietario, permisos de lectura para el grupo y permisos de lectura para otros usuarios.

**Representación con números:**

- Propietario: Lectura y escritura (4 + 2 = 6)
- Grupo: Lectura (4)
- Otros: Lectura (4)

Por lo tanto, el comando para establecer estos permisos sería:

```
chmod 644 documento.txt
```

**Representación con letras:**

- Propietario: Lectura y escritura (rw)
- Grupo: Lectura (r)
- Otros: Lectura (r)

El comando sería el mismo:

```
chmod u=rw,g=r,o=r documento.txt
```

**Ejemplo 2:**

El archivo "documento.txt" tiene permisos de lectura, escritura y ejecución para el propietario, permisos de lectura y ejecución para el grupo, y permisos de ejecución para otros usuarios.

**Representación con números:**

- Propietario: Lectura, escritura y ejecución (4 + 2 + 1 = 7)
- Grupo: Lectura y ejecución (4 + 1 = 5)
- Otros: Ejecución (1)

El comando sería:

```
chmod 755 documento.txt
```

**Representación con letras:**

- Propietario: Lectura, escritura y ejecución (rwx)
- Grupo: Lectura y ejecución (r-x)
- Otros: Ejecución (--x)

El comando equivalente sería:

```
chmod u=rwx,g=rx,o=x documento.txt
```

**Ejemplo 3:**

```
chmod u-r,g+rw,o=w documento.txt
```

**Ejemplo 4:**

```
chmod u=rwx,g=rw,o=w documento.txt
```

**Ejemplo 5:**

```
chmod u+wx,g-rw,a=w documento.txt
```

## Máscara de permisos en linux

En Linux, la máscara de permisos (`umask`) es un valor que determina los permisos predeterminados que se asignan a los nuevos archivos y directorios. Cuando se crea un archivo o directorio, el sistema aplica la `umask` para determinar los permisos efectivos.

### Comando `umask`

- **`umask`**: Este comando se utiliza para mostrar o establecer la máscara de permisos actual.

  - **Mostrar la máscara de permisos actual**:

    ```sh
    umask
    ```

    Esto devuelve la máscara de permisos actual en formato octal.

  - **Establecer una nueva máscara de permisos**:
    ```sh
    umask 022
    ```
    Esto establece la máscara de permisos a `022`, que significa que los archivos nuevos tendrán permisos `rw-r--r--` y los directorios `rwxr-xr-x`.

### `umask -S`

- **`umask -S`**: Este comando muestra la máscara de permisos actual en formato simbólico, que puede ser más fácil de entender que el formato octal.

  - **Ejemplo**:
    ```sh
    umask -S
    ```
    Esto podría devolver algo como `u=rwx,g=rx,o=rx`, lo que significa que los permisos de usuario son `rwx`, los permisos de grupo son `rx` y los permisos para otros son `rx`.

### Diferencia en la Asignación de Permisos entre Directorios y Archivos

- **Archivos**:
  Los archivos en Linux nunca se crean con permisos de ejecución por defecto, incluso si la `umask` lo permitiría. Esto es por razones de seguridad para evitar que los archivos de texto o de datos se ejecuten accidentalmente.

  - **Permisos predeterminados**: `666` (rw-rw-rw-)
  - **Aplicación de `umask`**:
    ```sh
    umask 022
    ```
    Resulta en permisos efectivos de `644` (rw-r--r--)

- **Directorios**:
  Los directorios requieren permisos de ejecución para permitir la navegación dentro de ellos. Por lo tanto, se crean con permisos de ejecución si la `umask` lo permite.

  - **Permisos predeterminados**: `777` (rwxrwxrwx)
  - **Aplicación de `umask`**:
    ```sh
    umask 022
    ```
    Resulta en permisos efectivos de `755` (rwxr-xr-x)

## Permisos especiales: Setuid, Setgid, Sticky Bit

### Setuid (Set User ID - SUID)

Es un mecanismo en sistemas Unix y Unix-like que permite que un programa sea ejecutado con los privilegios del propietario del archivo, en lugar de los del usuario que lo ejecuta. Se denota por la letra 's' en el lugar del bit de ejecución del propietario.

Este permiso es fundamental para que un usuario pueda hacer cosas tan simples como cambiar su contraseña de acceso. Básicamente cambiar la contraseña de un usuario distinto de root implica modificar el fichero /etc/shadow el cual tiene permisos rw-r----- y pertenece al usuario root grupo shadow. Con esta configuración de permisos sólo el usuario root puede realizar modificaciones sobre este fichero. Para realizar este cambio de contraseña se usa la herramienta passwd la cual tiene unos permisos especiales (rwsr-xr-x):

```bash
usuario@debian:~$ which passwd
/usr/bin/passwd
usuario@debian:~$ ls -la $(which passwd)
-rwsr-xr-x 1 root root 59976 feb  6 13:54 /usr/bin/passwd
usuario@debian:~$ ls -l /etc/shadow
-rw-r----- 1 root shadow 1536 abr  9 13:07 /etc/shadow
usuario@debian:~$ sudo cat /etc/shadow | grep -n usuario:
48:usuario:$y$j9T$xzdCWBCAVajtbrVsu/dPu0$7bIViJJgWzNPhkT5yk1YLQkZNhhDfdN/vlXO5LB.B49:19725:0:99999:7:::
```

El cambio está en que en los permisos del usuario propietario se ha sustituido una x por una s. Y así es como se representa el permiso Set UID en los ficheros ejecutables el cual es un acrónimo de “set user ID upon execution”. **Un ejecutable con este permiso activado se ejecuta como el usuario propietario (el usuario root en este caso) y no con los privilegios del usuario actual.**

Por último, en Linux cuando un fichero tiene permiso Set UID pero no tiene permiso de ejecución, Linux marca esta circunstancia con una “S” (mayúscula).

```bash
usuario@debian:~$ echo "Permisos" > fichero.txt
usuario@debian:~$ ls -l fichero.txt
-rw-rw-r-- 1 usuario usuario 9 jun 12 09:23 fichero.txt

usuario@debian:~$ chmod 4700 fichero.txt
usuario@debian:~$ ls -l fichero.txt
-rws------ 1 usuario usuario 9 jun 12 09:23 fichero.txt

usuario@debian:~$ chmod u-x fichero.txt
usuario@debian:~$ ls -l fichero.txt
-rwS------ 1 usuario usuario 9 jun 12 09:23 fichero.txt
```

### Setgid (Set Group ID - SGID)

Similar al setuid, el setgid es un mecanismo que permite que un programa se ejecute con los privilegios del grupo del archivo, en lugar de los del usuario que lo ejecuta. Se denota por la letra 's' en el lugar del bit de ejecución del grupo. El permiso Set GID, de forma paralela a Set UID, hace que el grupo de ejecución de un fichero sea el grupo propietario del fichero y no el grupo principal al que pertenece el usuario que lo ejecuta.

El ejemplo más conocido de este tipo de permisos está relacionado también con el fichero /etc/shadow y con /sbin/unix_chkpwd que es un programa que participa en la autentificación de los usuarios junto con PAM.

Como se puede ver en el ejemplo, el fichero /etc/shadow tiene permiso de lectura para el grupo propietario (shadow) de la misma forma que /sbin/unix_chkpwd es un ejecutable cuyo grupo propietario es shadow. Si se ejecuta este programa con el grupo shadow, se obtendrán permisos de acceso de sólo lectura a /etc/shadow y, de esta forma, será posible comprobar la contraseña.

Para asignar permisos de Set GID habrá que anteponer un 2 al permiso en formato numérico (2755) ó usar g+s. Por otra banda, es posible activar Set UID y Set GID a la vez empleando chmod con las especificaciones de permisos 6755 ó u+s g+s.

```bash
usuario@debian:~$ echo "Permisos" > fichero.txt
usuario@debian:~$ ls -l fichero.txt
-rw-rw-r-- 1 usuario usuario 9 jun 12 10:50 fichero.txt

usuario@debian:~$ chmod 2070 fichero.txt
usuario@debian:~$ ls -l fichero.txt
----rws--- 1 usuario usuario 9 jun 12 10:50 fichero.txt

usuario@debian:~$ chmod g-x fichero.txt
usuario@debian:~$ ls -l fichero.txt
----rwS--- 1 usuario usuario 9 jun 12 10:50 fichero.txt
```

### Sticky bit

El Sticky bit es un permiso especial aplicado a directorios en sistemas Unix. Cuando se establece en un directorio, **solo el propietario del archivo o superusuario puede eliminar o renombrar sus archivos**, aunque otros tengan permisos de escritura en el directorio. Se denota por la letra 't' en el lugar del bit de ejecución del otros.

Este permiso permite proteger ficheros dentro de un directorio. Concretamente evita que un usuario pueda borrar ficheros de otros usuarios que se sitúan en una carpeta pública como el directorio /tmp.

Por otro lado, indicar que con la T (mayúscula) indica que no existe el permiso de ejecución para el colectivo otros usuarios que en carpetas significa poder acceder a la carpeta.

```bash
usuario@debian:~$ sudo groupadd secundaria
usuario@debian:~$ sudo useradd -m -d /home/juan -p $(mkpasswd 'abc123.') -s /bin/bash -g secundaria -G sudo juan
usuario@debian:~$ sudo useradd -m -d /home/mateo -p $(mkpasswd 'abc123.') -s /bin/bash -g secundaria -G sudo mateo

usuario@debian:~$ id juan
uid=1001(juan) gid=1001(secundaria) groups=1001(secundaria),27(sudo)
usuario@debian:~$ id mateo
uid=1002(mateo) gid=1001(secundaria) groups=1001(secundaria),27(sudo)

usuario@debian:~$ mkdir /tmp/sticky
usuario@debian:~$ ls -ld /tmp/sticky/
drwxrwxr-x 2 usuario usuario 4096 jun 12 10:58 /tmp/sticky/

usuario@debian:~$ chmod 1777 /tmp/sticky/
usuario@debian:~$ ls -ld /tmp/sticky/
drwxrwxrwt 2 usuario usuario 4096 jun 12 10:58 /tmp/sticky/

usuario@debian:~$ su - juan -c "touch /tmp/sticky/fi1.txt"
Password:
usuario@debian:~$ su - mateo -c "rm /tmp/sticky/fi1.txt"
Password:
rm: remove write-protected regular empty file '/tmp/sticky/fi1.txt'? yes
rm: cannot remove '/tmp/sticky/fi1.txt': Operation not permitted
usuario@debian:~$ tree /tmp/sticky/
/tmp/sticky/
└── fi1.txt

0 directories, 1 file

usuario@debian:~$ chmod o-t /tmp/sticky/
usuario@debian:~$ ls -ld /tmp/sticky/
drwxrwxrwx 2 usuario usuario 4096 jun 12 11:04 /tmp/sticky/

usuario@debian:~$ su - mateo -c "rm /tmp/sticky/fi1.txt"
Password:
rm: remove write-protected regular empty file '/tmp/sticky/fi1.txt'? yes

usuario@debian:~$ ls -ld /tmp/sticky/
drwxrwxrwx 2 usuario usuario 4096 jun 12 11:08 /tmp/sticky/
usuario@debian:~$ tree /tmp/sticky/
/tmp/sticky/

0 directories, 0 files
```

_*Nota*_: Tambien podríamos hacerlo con `chmod +t`.

### Comando install

El comando `install` en Linux se utiliza para **copiar archivos y establecer permisos** en el sistema de archivos. Aunque su nombre puede ser confuso, no se utiliza para instalar paquetes, sino para mover o copiar archivos de manera controlada.

install [opciones] origen destino

- -d Crea directorios, similar a mkdir -p.
- -m Establece los permisos de archivo (por ejemplo, 755).
- -o Especifica el propietario del archivo.
- -g Especifica el grupo del archivo.
- -t Especifica el directorio de destino.
- -v Muestra información detallada del proceso.
- -p Preserva los tiempos de acceso y modificación.

1. Copiar un Archivo con Permisos Específicos:

```bash
sudo install -m 755 script.sh /usr/local/bin
```

Copia el archivo script.sh al directorio /usr/local/bin.
Establece permisos 755 (ejecutable para todos, escritura solo para el propietario).

2. Crear un Directorio con Permisos:

```bash
sudo install -d -m 755 /opt/mi_directorio
```

Crea el directorio /opt/mi_directorio con permisos 755.

3. Copiar un Archivo con Propietario y Grupo Específicos:

```bash
sudo install -o root -g root -m 644 archivo.txt /etc/mi_archivo.txt
```

Copia el archivo archivo.txt a /etc/mi_archivo.txt.
El propietario y grupo serán root, y los permisos serán 644.

4. Copiar Múltiples Archivos a un Directorio:

```bash
sudo install -v archivo1 archivo2 archivo3 -t /usr/local/bin
```

Copia varios archivos al directorio /usr/local/bin.
La opción -v muestra detalles de la copia.

#### Usos Comunes:

Instalación Manual de Scripts: Colocar scripts en directorios como /usr/local/bin.
Despliegue de Archivos de Configuración: Copiar archivos de configuración con permisos específicos.
Creación de Estructura de Directorios: Crear rutas completas para aplicaciones.

#### Ejemplo Completo: Despliegue de un Script

Imagina que tienes un script llamado mi_script.sh que deseas copiar a /usr/local/bin con permisos ejecutables para todos:

```bash
sudo install -m 755 mi_script.sh /usr/local/bin
```

### `chattr` y `lsattr`

A mayores existen en Linux a editar con los comandos `chattr` y listar con `lsattr` otros permisos. `chattr` es un comando en sistemas Unix y Linux que se utiliza para cambiar los `atributos` de un archivo en el sistema de archivos. Estos atributos pueden controlar varios aspectos del archivo, como su capacidad de modificación, eliminación o incluso si puede ser movido o renombrado. Uno de los atributos más comunes es el atributo de solo lectura.

- `a` (append only) permite solo añadir datos, útil para registros.
- `i` (immutable) hace el archivo inmutable, impidiendo modificaciones, borrados o renombrados, común en archivos críticos del sistema.

Como ejemplos tenemos:

```bash
usuario@debian:/tmp/prueba$ ls -l fichero1.txt
-rw-rw-r-- 1 usuario usuario 9 abr 13 22:42 fichero1.txt

usuario@debian:/tmp/prueba$ lsattr fichero1.txt
--------------e------- fichero1.txt

usuario@debian:/tmp/prueba$ sudo chattr +a fichero1.txt
[sudo] password for si:

usuario@debian:/tmp/prueba$ lsattr fichero1.txt
-----a--------e------- fichero1.txt

usuario@debian:/tmp/prueba$ echo "Otra linea" > fichero1.txt
-bash: fichero1.txt: Operation not permitted

usuario@debian:/tmp/prueba$ echo "Otra linea" >> fichero1.txt

usuario@debian:/tmp/prueba$ cat fichero1.txt
Fichero1
Otra linea

usuario@debian:/tmp/prueba$ sudo chattr +i fichero1.txt

usuario@debian:/tmp/prueba$ echo "Otra nueva linea" >> fichero1.txt
-bash: fichero1.txt: Operation not permitted

usuario@debian:/tmp/prueba$ sudo echo "Otra nueva linea" >> fichero1.txt
-bash: fichero1.txt: Operation not permitted

usuario@debian:/tmp/prueba$ lsattr fichero1.txt
----ia--------e------- fichero1.txt

usuario@debian:/tmp/prueba$ sudo chattr -ai fichero1.txt

usuario@debian:/tmp/prueba$ lsattr fichero1.txt
--------------e------- fichero1.txt
```

Del mismo modo, ambos comandos son aplicables tambien a directorios, no unicamente a ficheros.

```bash
usuario@debian:/tmp$ lsattr -d COMUN/
--------------e------- COMUN/

usuario@debian:/tmp$ sudo chattr +i COMUN/
usuario@debian:/tmp$ lsattr -d COMUN/
----i---------e------- COMUN/
```

## ACLs

Una ACL (Lista de Control de Acceso) es una lista detallada de permisos que se adjunta a un archivo o carpeta. Sirve para superar la limitación de los permisos básicos de Linux (que solo dejan definir permisos para el Propietario, el Grupo y el Resto).

En caso de conflicto entre el usuario propietario/otros (uo de ugo) y las ACLs, prevalecen los permisos uo de ugo.

- `Atributos` → `uo de ugo` → `ACLs`

En caso de conflicto entre el grupo propietario (g de ugo)/otros grupos distintos del propietario/otros usuarios distintos del propietario y las ACLs, prevalecen las ACLs.

- `Atributos` → `mascara` → `ACLs` → `g de ugo`

La máscara en las ACL (Listas de Control de Acceso) de Linux es un concepto fundamental que a menudo causa confusión, pero es muy útil una vez que se entiende. Puedes imaginarla como un límite de seguridad o un techo.

_Nota_: La máscara NO afecta al propietario del fichero ( user:: ) ni a los 'otros' ( other:: ). Solo afecta a los grupos y usuarios específicos añadidos vía ACL.

### Soporte de ACL en el sistema de ficheros

Hoy en día el kernel trae incorporado por defecto soporte para ACLs para distintos sistemas de ficheros. Podemos verificarlo con el siguiente comando:

```bash
root@debian:~# [ -f /boot/config-$(uname -r) ] && grep -i acl /boot/config-$(uname -r)
# CONFIG_XILINX_EMACLITE is not set
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_REISERFS_FS_POSIX_ACL=y
CONFIG_JFS_POSIX_ACL=y
CONFIG_XFS_POSIX_ACL=y
CONFIG_BTRFS_FS_POSIX_ACL=y
CONFIG_F2FS_FS_POSIX_ACL=y
CONFIG_FS_POSIX_ACL=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_JFFS2_FS_POSIX_ACL=y
CONFIG_EROFS_FS_POSIX_ACL=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFS_ACL_SUPPORT=m
CONFIG_CEPH_FS_POSIX_ACL=y
CONFIG_9P_FS_POSIX_ACL=y
```

Pero en el caso de que no sea así, debemos activar en el sistema de ficheros el soporte para las ACLs, por lo que deberíamos instalar el paquete acl y modificar el archivo `/etc/fstab`:

```bash
apt-get update && apt-get -y install acl
cat /etc/fstab | nl
...
7 #
8 # / was on /dev/sda1 during installation
9 UUID=3e1ae11e-dac7-4a58-8aec-d06a345171dc / ext4 acl,errors=remount-ro 0 1
...
```

En el cuarto campo del fichero `/etc/fstab` correspondiente a las opciones de montaje debemos agregar la opción `acl` y posteriormente debemos remontar el sistema de ficheros modificado. Para no tener que reiniciar podemos emplear cualquiera de los 2 siguientes comandos:

```bash
mount -a  #Remonta todos los sistemas de ficheros siguiendo el orden en /etc/fstab
mount -o remount /dev/sda1  #Remonta solamente el sistema de ficheros modificado en /etc/fstab (en este caso /dev/sda1)
```

### Prácticas

Generar 2 grupos: primaria y secundaria; generar 2 usuarios: ana y brais, perteneciendo ana al grupo primaria y brais al grupo secundaria.

```bash
root@debian:~# groupadd primaria
root@debian:~# groupadd secundaria

root@debian:~# useradd -m -d /home/ana -s /bin/bash -g primaria -p $(mkpasswd abc123.) ana
root@debian:~# useradd -m -d /home/brais -s /bin/bash -g secundaria -p $(mkpasswd abc123.) brais
root@debian:~# useradd -m -d /home/juan -s /bin/bash -p $(mkpasswd abc123.) juan

root@debian:~# tail -3 /etc/passwd
ana:x:1001:1002::/home/ana:/bin/bash
brais:x:1002:1003::/home/brais:/bin/bash
juan:x:1003:1004::/home/juan:/bin/bash

root@debian:~# tail -2 /etc/group
primaria:x:1002:
secundaria:x:1003:
```

#### Práctica 1: Conflicto de permisos ugo-ACL (Ver Preferencia de permisos (de mayor a menor))

En caso de conflicto entre el usuario propietario/otros ("uo" de ugo) y las ACLs, prevalecen los permisos "uo" de ugo.

Generar la carpeta /revisar perteneciente al usuario ana y grupo primaria con los permisos 550:

```bash
root@debian:~# rm -rf /revisar && mkdir /revisar && chown ana:primaria /revisar && chmod 550 /revisar

root@debian:~# ls -ld /revisar
dr-xr-x--- 2 ana primaria 4096 ene  4 15:34 /revisar
```

Con los permisos ugo el usuario ana no puede crear ficheros/carpetas dentro de /revisar, con lo cual vamos a crear la siguiente ACL:

```bash
root@debian:~# setfacl -m u:ana:rwx /revisar

root@debian:~# getfacl /revisar
getfacl: Eliminando '/' inicial en nombres de ruta absolutos
# file: revisar
# owner: ana
# group: primaria
user::r-x
user:ana:rwx
group::r-x
mask::rwx
other::---
```

Podemos ver como el usuario ana tiene los permisos ugo de lectura y ejecución sobre el directorio por lo que puede ver lo que hay dentro del directorio `/revisar` y acceder a este pero no puede crear nuevos archivos o subdirectorios. Por otra parte, tenemos un ACL que indica que ana puede leer, escribir y ejecutar. Llegados a este punto sabemos que en caso de conflicto entre permisos uo y ACL prevalecen los permisos uo.

```bash
ana@debian:~$ ls /revisar
ana@debian:~$ cd /revisar
ana@debian:/revisar$ touch prueba.txt
touch: no se puede efectuar `touch' sobre 'prueba.txt': Permiso denegado
```

_Nota_: En el momento que aplicamos un ACL y vemos los permisos vemos que tenemos un símbolo + indicando la presencia de ACLs.

```bash
root@debian:~# ls -ld /revisar
dr-xrwx---+ 2 ana primaria 4096 ene  4 15:34 /revisar
```

#### Práctica 2: Conflicto permisos ugo-ACL (Ver Preferencia de permisos (de mayor a menor))

En caso de conflicto entre el grupo propietario (g de ugo) / otros grupos distintos del propietario / otros usuarios distintos del propietario y las ACLs, prevalecen las ACLs.

Generar la carpeta /revisar perteneciente al usuario ana y grupo primaria con los permisos 550:

```bash
root@debian:~# rm -rf /revisar && mkdir /revisar && chown ana:primaria /revisar && chmod 550 /revisar

root@debian:~# ls -ld /revisar
dr-xr-x--- 2 ana primaria 4096 ene  4 15:46 /revisar
```

Con los permisos ugo otro grupo diferente del grupo propietario sobre el que se aplique una ACL prevalece la ACL. Vamos a darle permisos al grupo secundaria al que pertenece brais:

```bash
root@debian:~# setfacl -m g:secundaria:rwx /revisar

root@debian:~# getfacl /revisar
getfacl: Eliminando '/' inicial en nombres de ruta absolutos
# file: revisar
# owner: ana
# group: primaria
user::r-x
group::r-x
group:secundaria:rwx
mask::rwx
other::---
```

Ahora Brais tiene permiso de generar contenido dentro de /revisar, ya que la ACL prevalece sobre los permisos de cualquier grupo y cualquier usuario distinto del propietario de /revisar; es decir, la máscara efectiva de permisos prevalece sobre cualquier grupo o sobre cualquier usuario que no sea el propietario de /revisar (u de ugo).

```bash
root@debian:~# su - brais
brais@debian:~$ ls /revisar
brais@debian:~$ cd /revisar
brais@debian:/revisar$ touch prueba.txt
brais@debian:/revisar$ ls -l
total 0
-rw-r--r-- 1 brais secundaria 0 ene  4 15:52 prueba.txt
```

#### Ejemplos de asignación de ACLs

##### Asignar ACLs a usuario

```bash
setfacl -R -m u:mateo:rwx prueba/
```

##### Asignar ACLs a grupo

```bash
setfacl -R -m g:dam:r-x prueba/
```

##### Asignación de ACL por defecto

Son vitales en carpetas compartidas. Garantizan que cuando se cree un archivo nuevo, tenga ACLs automáticamente sobre él sin tener que ejecutar chmod manualmente cada vez.

```bash
setfacl -R -d -m g:dam:w prueba/
```

##### Máscara en ACLs

```bash
setfacl -m m::rwx prueba/
```

##### Otros en ACLs

```bash
setfacl -R -m u::x prueba/
setfacl -R -m g::r prueba/
setfacl -R -m o::w prueba/
```

##### Eliminar ACLs

```bash
setfacl -R -b -k datosEmpresa/
```

- -R: Para que el comando se aplique de forma recursiva.
- -b: Elimina las ACL.
- -k: Elimina las ACL por defecto.

##### Eliminar ACL de un usuario/grupo

```bash
setfacl -x u:carmencita prueba/
setfacl -x g:primaria prueba/
```

### Explicación con ejemplos paso por paso de ACLs

Configuramos el sistema para realizar la práctica que nos llevará a entender las ACL en Linux.

- Creamos un usuario clara con grupo principal asir y usuario juan con grupo principal daw.
- Añadimos un sistema de archivos nuevo ext4 y lo montamos en `/mnt/datos` de modo que se puedan configurar ACLs tal y como se vio en apartados anteriores.
- En la raíz del FS `/mnt/datos` creamos el directorio `/mnt/datos/deClara`.
- También creamos algún directorio y archivo dentro de dicha carpeta: `/mnt/datos/deClara/archivos/agenda.txt`.
- Ahora cambiamos al usuario clara como usuario de trabajo y accedemos a `/mnt/datos/deClara`.

#### Escenario de partida

```bash
root@debian:~# mkdir -p /mnt/datos/deClara/archivos && touch /mnt/datos/deClara/archivos/agenda.txt
root@debian:~# cd /mnt/datos/
root@debian:/mnt/datos# tree -pug
[drwxr-xr-x root     root    ]  .
└── [drwxr-xr-x root     root    ]  deClara
    └── [drwxr-xr-x root     root    ]  archivos
        └── [-rw-r--r-- root     root    ]  agenda.txt

3 directories, 1 file
```

Creamos a los usuarios clara y juan:

```bash
root@debian:/mnt/datos# groupadd asir
root@debian:/mnt/datos# groupadd daw
root@debian:/mnt/datos# tail -2 /etc/group
asir:x:1001:
daw:x:1004:
```

```bash
root@debian:/mnt/datos# useradd -m -d /home/clara -s /bin/bash -p $(mkpasswd abc123.) -g asir clara
root@debian:/mnt/datos# useradd -m -d /home/juan -s /bin/bash -p $(mkpasswd abc123.) -g daw juan
```

Los directorios anteriormente creados en `/mnt/datos` tienen que tener como usuario a clara y grupo propietario asir siendo los permisos 755.

```bash
root@debian:/mnt/datos# chown -R clara:asir /mnt/datos/deClara/
root@debian:/mnt/datos# chmod -R 755 /mnt/datos/deClara/
root@debian:/mnt/datos# tree -pug
[drwxr-xr-x root     root    ]  .
└── [drwxr-xr-x clara    asir    ]  deClara
    └── [drwxr-xr-x clara    asir    ]  archivos
        └── [-rwxr-xr-x clara    asir    ]  agenda.txt

3 directories, 1 file
```

Creamos un archivo.txt en `/mnt/datos/deClara`. Se puede ver que el archivo pertenece a clara, grupo asir y tiene permisos rw-r--r- (lectura y escritura para el dueño, y lectura solamente para los usuarios del grupo dueño y para el resto de los usuarios del sistema).

```bash
root@debian:/mnt/datos# su - clara
clara@debian:~$ cd /mnt/datos/deClara/
clara@debian:/mnt/datos/deClara$ echo "Archivo interesante" > archivo.txt
clara@debian:/mnt/datos/deClara$ ls -l archivo.txt
-rw-r--r-- 1 clara asir 20 ene  5 09:47 archivo.txt
```

#### Otorgando permisos a usuarios y grupos

Ahora iniciamos sesión con el usuario juan, accedemos al directorio `/mnt/datos/deClara` y comprobamos que sí damos leído y podemos escribir en el contenido de archivo.txt:

```bash
clara@debian:/mnt/datos/deClara$ su - juan
Contraseña:
juan@debian:~$ cd /mnt/datos/deClara/
juan@debian:/mnt/datos/deClara$ ls -l
total 8
drwxr-xr-x 2 clara asir 4096 ene  5 09:28 archivos
-rw-r--r-- 1 clara asir   20 ene  5 09:47 archivo.txt
juan@debian:/mnt/datos/deClara$ cat archivo.txt
Archivo interesante
juan@debian:/mnt/datos/deClara$ echo "Otra linea" >> archivo.txt
-bash: archivo.txt: Permiso denegado
```

Supongamos que el usuario juan necesita también acceso de lectura y escritura al archivo archivo.txt . Como comentamos antes, no podríamos darle estos permisos al usuario sin asignarlo como dueño, o cambiar el grupo del archivo. Con ACL podríamos otorgar estos permisos utilizando el comando setfacl y el atributo -m o --modify del siguiente modo:

```bash
root@debian:/mnt/datos/deClara# setfacl -m u:juan:rw- archivo.txt
```

Podemos ver ahora cómo quedan los permisos sobre el archivo.txt . Se puede apreciar también una entrada para la máscara (mask):

```bash
root@debian:/mnt/datos/deClara# ls -l archivo.txt
-rw-rw-r--+ 1 clara asir 20 ene  5 09:47 archivo.txt

root@debian:/mnt/datos/deClara# getfacl archivo.txt
# file: archivo.txt
# owner: clara
# group: asir
user::rw-
user:juan:rw-
group::r--
mask::rw-
other::r--
```

Ahora podemos comprobar como juan puede escribir una nueva linea en archivo.txt:

```bash
juan@debian:/mnt/datos/deClara$ echo "Otra linea" >> archivo.txt
juan@debian:/mnt/datos/deClara$ cat archivo.txt
Archivo interesante
Otra linea
```

_Nota_: Se pueden también otorgar varios permisos en la misma línea separando los mismos por comas, por ejemplo :

```bash
setfacl -m u:usuario1:rw-,u:usuario2:r--,g:grupo1:r-- archivo.txt
```

_Nota_: En el caso de que el destino sea un directorio y quisiéramos aplicar la ACL a todos los elementos interiores de manera recursiva, podemos utilizar el modificador -R :

```bash
setfacl -Rm u:usuario1:rw- directorio
```

#### Eliminando ACLs

Para eliminar una ACL podemos utilizar el modificador -x o --remove . Por ejemplo, si la ACL creada para el usuario juan fue creada por error, podemos eliminarla con el siguiente comando:

```bash
setfacl -x u:juan archivo.txt
```

También se pueden eliminar todas las ACLs creadas para un archivo o directorio utilizando el modificador -b ( o --remove-all ) de este modo:

```bash
setfacl -b archivo.txt
```

Por otra parte, en caso de existir ACLs por defecto, estas son elimiadas de la siguiente forma:

```bash
setfacl -k archivo.txt
```

#### ACLs por defecto para archivos y directorios

Muchas veces es necesario que todos los elementos, archivos o directorios, que sean creados dentro de un directorio, obtengan las mismas ACLs que el directorio padre. Esto puede lograrse con el modificador -d o --default del comando setfacl.
En el siguiente ejemplo retocamos los permisos del directorio deClara para que todos los usuarios que no sean clara, ni tampoco los pertenecientes al grupo asir, NO tengan ningún permiso sobre los archivos y directorios creados dentro de dicho directorio (los creados después de configurar este permiso).
Primeramente nos fijamos en que cualquier usuario (other) puede leer los archivos que se vayan a crear en el interior de deClara pues other tiene permisos de lectura.

```bash
root@debian:/mnt/datos# getfacl deClara/
# file: deClara/
# owner: clara
# group: asir
user::rwx
group::r-x
other::r-x
```

Hacemos que no aparezca ese permiso en los próximos archivos o directorios que se creen en adelante dentro del directorio deClara:

```bash
root@debian:/mnt/datos# setfacl -dm o::- deClara/
root@debian:/mnt/datos# getfacl deClara/
# file: deClara/
# owner: clara
# group: asir
user::rwx
group::r-x
other::r-x
default:user::rwx
default:group::r-x
default:other::---
```

Pero sí queremos que los archivos nuevos que se creen aquí dentro deClara, tengan permiso de lectura para el usuario juan:

```bash
root@debian:/mnt/datos# setfacl -dm u:juan:r deClara/
```

Comprobamos como van los permisos:

```bash
root@debian:/mnt/datos# getfacl deClara/
# file: deClara/
# owner: clara
# group: asir
user::rwx
group::r-x
other::r-x
default:user::rwx
default:user:juan:r--
default:group::r-x
default:mask::r-x
default:other::---
```

Ahora podemos comprobar con qué permisos por defecto quedan los nuevos archivos creados dentro de deClara:

```bash
clara@debian:/mnt/datos/deClara$ echo "Hola" > archivoX.txt
clara@debian:/mnt/datos/deClara$ getfacl archivoX.txt
# file: archivoX.txt
# owner: clara
# group: asir
user::rw-
user:juan:r--
group::r-x                      #effective:r--
mask::r--
other::---
```

En este punto es importante notar que los subdirectorios de deClara/, creados antes de configurar la ACL de default al directorio padre, no tendrán esos permisos de manera predeterminada. Para que tanto el directorio deClara/ como todos sus subdirectorios incorporen dicha ACL de manera predeterminada, deberíamos haber incorporado la opción -R en los comandos:

```bash
clara@debian:/mnt/datos$ setfacl -Rdm o::- deClara/
clara@debian:/mnt/datos$ setfacl -Rdm u:juan:r deClara/
```

Más adelante nos pararemos a explicar el funcionamiento de mask y, por lo tanto, ese effective que sale a la derecha de group.

#### Usuarios y grupos

Para comprobar cómo otorgar permisos a usuarios y grupos con más detalle, eliminemos el directorio deClara y volvamos a configurarlo como al principio:

```bash
root@debian:/mnt/datos# rm -rf deClara/
root@debian:/mnt/datos# mkdir deClara
root@debian:/mnt/datos# chown -R clara:asir /mnt/datos/deClara/
root@debian:/mnt/datos# chmod -R 755 /mnt/datos/deClara/
root@debian:/mnt/datos# getfacl deClara/
# file: deClara/
# owner: clara
# group: asir
user::rwx
group::r-x
other::r-x
```

```bash
clara@debian:/mnt/datos/deClara$ echo "Hola" > archivo.txt
clara@debian:/mnt/datos/deClara$ ls -l archivo.txt
-rw-r--r-- 1 clara asir 5 ene  5 11:10 archivo.txt
clara@debian:/mnt/datos/deClara$ getfacl archivo.txt
# file: archivo.txt
# owner: clara
# group: asir
user::rw-
group::r--
other::r--
```

Vemos que todos los usuarios del sistema tienen permiso de lectura sobre archivo.txt, por lo que vamos a empezar por quitar ese permiso:

```bash
clara@debian:/mnt/datos/deClara$ setfacl -m o::- archivo.txt
clara@debian:/mnt/datos/deClara$ getfacl archivo.txt
# file: archivo.txt
# owner: clara
# group: asir
user::rw-
group::r--
other::---
```

Podemos iniciar sesión como juan y ver que, efectivamente, el usuario juan no tiene permiso de lectura sobre archivo.txt.

```bash
juan@debian:~$ cd /mnt/datos/deClara/
juan@debian:/mnt/datos/deClara$ ls -l archivo.txt
-rw-r----- 1 clara asir 5 ene  5 11:10 archivo.txt
juan@debian:/mnt/datos/deClara$ cat archivo.txt
cat: archivo.txt: Permiso denegado
```

Vamos a poner a juan permiso de lectura, pero no directamente, si no a través de su grupo principal daw:

```bash
# Desde la sesión de clara
clara@debian:/mnt/datos/deClara$ setfacl -m g:daw:r archivo.txt
clara@debian:/mnt/datos/deClara$ getfacl archivo.txt
# file: archivo.txt
# owner: clara
# group: asir
user::rw-
group::r--
group:daw:r--
mask::r--
other::---
```

Podemos comprobar que ahora juan tiene permiso de lectura sobre archivo.txt :

```bash
juan@debian:/mnt/datos/deClara$ cat archivo.txt
Hola
```

Pero, lo que no puede es escribir en dicho archivo.txt :

```bash
juan@debian:/mnt/datos/deClara$ echo "caracola" >> archivo.txt
-bash: archivo.txt: Permiso denegado
```

Podemos probar ahora a sólo poner el permiso de escritura explícitamente al usuario juan, pensando que tiene ya lectura por pertenecer al grupo daw.

```bash
# Desde la sesión de clara
clara@debian:/mnt/datos/deClara$ setfacl -m u:juan:w archivo.txt
clara@debian:/mnt/datos/deClara$ getfacl archivo.txt
# file: archivo.txt
# owner: clara
# group: asir
user::rw-
user:juan:-w-
group::r--
group:daw:r--
mask::rw-
other::---
```

Si iniciamos sesión con juan y probamos, nos llevaremos la mala noticia de que juan sigue sin poder leer el archivo, pues "los permisos son efectivos", es decir, lo que nos devuelve getfacl son los permisos que realmente tiene juan si éste aparece explícitamente en dicha lista.

```bash
juan@debian:/mnt/datos/deClara$ cat archivo.txt
cat: archivo.txt: Permiso denegado
```

Así que, tendremos que configurar los permisos de lectura y escritura explícitamente al usuario juan (demostramos así que "son efectivos", no sirve darle sólo escritura y que lectura los obtenga de pertenecer al grupo daw):

```bash
clara@debian:/mnt/datos/deClara$ setfacl -m u:juan:rw- archivo.txt
clara@debian:/mnt/datos/deClara$ getfacl archivo.txt
# file: archivo.txt
# owner: clara
# group: asir
user::rw-
user:juan:rw-
group::r--
group:daw:r--
mask::rw-
other::---
```

Y comprobamos que juan ahora puede escribir y leer:

```bash
juan@debian:/mnt/datos/deClara$ cat archivo.txt
Hola
juan@debian:/mnt/datos/deClara$ echo "caracola" >> archivo.txt
juan@debian:/mnt/datos/deClara$ cat archivo.txt
Hola
caracola
```

#### Mask: ¿Qué es la máscara de permisos en ACLs?

Pudimos notar en el punto anterior, que en el momento de crear la ACL, apareció una nueva línea de permisos : mask.
Hay que recordar primero que las ACL no son más que una extensión de los permisos nativos del sistema. Además, todos los permisos de ACL, ya sea para usuarios o grupos nombrados, son asignados a la clase de permisos de grupo, es decir, las ACL extienden los permisos tradicionales de la terna de grupo.

En otras palabras, al agregar ACLs a la administración de permisos, los permisos de grupo POSIX se ven extendidos con nuevas clases de permisos, por lo que se redefine el significado de los permisos de grupo, tal y como se mencionó arriba.

Ahora bien, con esta perspectiva, las ACLs de usuarios o grupos nombrados podrían requerir mayor acceso al recurso de los propuestos por los permisos nativos POSIX para el grupo
dueño. Es decir, supongamos que tenemos un archivo con los siguientes permisos:

- -rw-r—r-- clara asir archivo

En este caso, el usuario clara tiene permisos rw-, mientras que el resto de los usuarios pertenecientes al grupo asir solamente tendrían permisos de lectura (r--).

Ahora, supongamos que un usuario NO perteneciente a asir (juan por ejemplo) requiere permisos de lectura y escritura (rw-). El límite superior de permisos de la clase grupo (permisos nativos de grupo y permisos de ACL de usuarios y grupos nombrados) es rw-, para abarcar los permisos nativos y los permisos del usuario nombrado juan. Este límite superior debe quedar escrito en algún sitio. Si modificamos los permisos nativos de grupo para abarcar rw- , los usuarios de grupo asir ahora empezarían a tener permisos de escritura, y eso no es conveniente, no es lo que se quiere.
Como no pueden usarse los permisos nativos de grupo como límite superior de permisos de clase de grupo, se utiliza un nuevo parámetro que es la máscara o mask.

Podemos ver un ejemplo:

Primeramente vamos a borrar todas las entradas ACL a archivo (_setfacl -b archivo_) y le configuramos los permisos rw-r--r-- clara asir a dicho archivo:

```bash
clara@debian:/mnt/datos/deClara$ touch archivo && chmod 644 archivo
clara@debian:/mnt/datos/deClara$ getfacl archivo
# file: archivo
# owner: clara
# group: asir
user::rw-
group::r--
other::r--
```

Si añadimos permisos de rw- al usuario juan mediante ACL extendida:

```bash
clara@debian:/mnt/datos/deClara$ setfacl -m u:juan:rw- archivo
clara@debian:/mnt/datos/deClara$ getfacl archivo
# file: archivo
# owner: clara
# group: asir
user::rw-
user:juan:rw-
group::r--
mask::rw-
other::r--
```

El usuario juan ahora puede leer y escribir el archivo, pero los usuarios del grupo asir siguen manteniendo su permiso de sólo lectura. A partir de la implementación de ACLs extendidas en el archivo, la máscara define el límite máximo de permisos de la clase grupo actualmente configurados, y se actualizará cada vez que carguemos una nueva ACL.

Por ejemplo, si tenemos también en el equipo un usuario diferente y, a ese usuario carlos le damos permiso de ejecución, ahora la máscara pasará a ser rwx para abarcar también ese permiso:

```bash
clara@debian:/mnt/datos/deClara$ setfacl -m u:usuario:x archivo
clara@debian:/mnt/datos/deClara$ getfacl archivo
# file: archivo
# owner: clara
# group: asir
user::rw-
user:usuario:--x
user:juan:rw-
group::r--
mask::rwx
other::r--
```

Otro dato a tener en cuenta también es el siguiente. Como sabemos, el comando chmod permite modificar los bits de permisos nativos POSIX de los archivos y directorios. Los cambios que efectuemos sobre los permisos user y other también se verán reflejados directamente sobre sus respectivas ACLs user y other. Asimismo, podríamos modificar estos bits utilizando setfacl para user omitiendo nombrar ningún usuario. Un ejemplo sería el siguiente comando:

```bash
chmod u+rwx archivo
```

Que tendría como equivalente el comando :

```bash
setfacl -m u::rwx archivo
```

Y lo mismo ocurre con los permisos asociados a other sustituyendo la letra u por o. Por supuesto, debemos recordar que la sintaxis de setfacl especifica permisos absolutos. Si queremos configurar los permisos asociados a grupo dueño, haremos lo mismo cambiando a la letra g y sin indican ningún grupo:

```bash
setfacl -m g::rwx archivo
```

Así, es de suponer el resultado en mask del siguiente ejemplo:

```bash
clara@debian:/mnt/datos/deClara$ setfacl -b archivo
clara@debian:/mnt/datos/deClara$ setfacl -m u:juan:rw archivo
clara@debian:/mnt/datos/deClara$ getfacl archivo
# file: archivo
# owner: clara
# group: asir
user::rw-
user:juan:rw-
group::r--
mask::rw-
other::r--

clara@debian:/mnt/datos/deClara$ setfacl -m g::rwx archivo
clara@debian:/mnt/datos/deClara$ getfacl archivo
# file: archivo
# owner: clara
# group: asir
user::rw-
user:juan:rw-
group::rwx
mask::rwx
other::r--
```

Ahora mask tiene los permisos rwx, lo esperado, puesto que, como se dijo antes, la máscara se recalcula especificando el límite superior de los permisos otorgados a la clase grupo.

Si quitamos ahora los permisos de escritura y ejecución de la ACL group con el siguiente comando:

```bash
clara@debian:/mnt/datos/deClara$ setfacl -m g::r archivo
clara@debian:/mnt/datos/deClara$ getfacl archivo
# file: archivo
# owner: clara
# group: asir
user::rw-
user:juan:rw-
group::r--
mask::rw-
other::r--
```

La mask se recalculó para coincidir con el límite superior de los permisos otorgados a la clase grupo.

##### Modificación de la máscara

Pero, la máscara mask también se puede manipular como un tipo de permiso más dentro de las ACLs. Podemos ver un ejemplo. Comenzamos creando archivo y configurando a clara como usuario dueño y asir como grupo dueño. También nos aseguramos que tenga los permisos 644:

```bash
clara@debian:/mnt/datos/deClara$ ls -l archivo
-rw-rw-r--+ 1 clara asir 0 ene  5 12:02 archivo
```

Configuramos también a juan con permisos rw- sobre dicho archivo :

```bash
clara@debian:/mnt/datos/deClara$ setfacl -m u:juan:rw- archivo
clara@debian:/mnt/datos/deClara$ getfacl archivo
# file: archivo
# owner: clara
# group: asir
user::rw-
user:juan:rw-
group::r--
mask::rw-
other::r--
```

Ahora vamos a cambiar los permisos de la máscara a r-- ( modificador -m ). ¿Qué pasará así con los permisos de la clase grupo?

```bash
clara@debian:/mnt/datos/deClara$ setfacl -m m::r archivo
clara@debian:/mnt/datos/deClara$ getfacl archivo
# file: archivo
# owner: clara
# group: asir
user::rw-
user:juan:rw-                   #effective:r--
group::r--
mask::r--
other::r--
```

Como se ve, la máscara mask queda con el permiso r-- . Anteriormente era rw- puesto que el usuario juan tiene permisos ACL como usuario nombrado, por lo que la máscara se había recalculado. Ahora, como redujimos los permisos de la máscara, se modificó el límite superior de permisos otorgados a todas las entidades de la clase grupo.
Particularmente en este caso, el usuario juan, si bien mantiene sus permisos de rw-, el permiso de escritura dejó de ser efectivo ya que está limitado por la máscara. Esto es indicado mediante la leyenda efective:r--, es decir juan NO podrá escribir en el archivo, solamente lo podrá leer

```bash
juan@debian:/mnt/datos/deClara$ cat archivo
juan@debian:/mnt/datos/deClara$ echo "Primera linea" > archivo
-bash: archivo: Permiso denegado
```

### Notas sobre ACLs

_*Notas: Es importante tener en cuenta que las ACL añaden tal cual los permisos que se especifican, es decir `g:dam:r-x` asigna solo permisos a dam de lectura y ejecución, igual que `g:dam:rx`. En caso de que existiera el permiso de escritura, este habría desaparecido.*_

_*Notas 2: Cuando añadimos ACLs a un fichero o directorio aparece un signo `+` al final de los permisos UGO.*_

```bash
-rw-rwx---+ 1 root root 8 abr 13 20:29 fichero1.txt
```

_*Notas 3: Es incorrecto hacer `setfacl -m u:rw prueba/` o `setfacl -m g:r-w prueba/` pero **si es correcto** hacer `setfacl -m o:rw prueba/` o `setfacl -m m:rw prueba/`.*_

_*Nota 4: Se pueden juntar los parametros de una ACL para realzar algo como lo siguiente `setfacl -Rbk prueba/`. La R indica recursividad, la b elimina las ACL y la k las ACL por defecto*_

_*Nota 5: Los permisos de otros son acumulativos, como podemos ver en el siguiente ejemplo, si no eliminamos los permisos de otros se van a añadir a los del usuario. Este es el motivo por el cual lucia que pertenece a dam puede en el primer caso listar el contenido de `/tmp/prueba` y una vez eliminamos los permisos de otros ya no puede.*_

```bash
usuario@debian:/tmp$ id lucia
uid=1001(lucia) gid=1001(lucia) groups=1001(lucia),27(sudo),1003(dam)
usuario@debian:/tmp$ getfacl prueba/ -e
# file: prueba/
# owner: usuario
# group: usuario
user::rwx
group::rwx                      #effective:---
group:dam:r-x                   #effective:---
mask::---
other::r-x

usuario@debian:/tmp$ sudo -u lucia ls -l /tmp/prueba
total 0
-rw-rw-r-- 1 usuario usuario 0 jun 11 11:29 fichero.txt
usuario@debian:/tmp$ sudo setfacl -R -m o::- prueba/
usuario@debian:/tmp$ sudo setfacl -R -m m::- prueba/
usuario@debian:/tmp$ getfacl prueba/ -e
# file: prueba/
# owner: usuario
# group: usuario
user::rwx
group::rwx                      #effective:---
group:dam:r-x                   #effective:---
mask::---
other::---

usuario@debian:/tmp$ sudo -u lucia ls -l /tmp/prueba
ls: cannot open directory '/tmp/prueba': Permission denied
```

## Capabilities

Las capabilities en GNU/Linux son un sistema más granular de control de acceso que se utiliza principalmente para elevar los privilegios de ejecución de un programa o binario específico sin otorgarle privilegios totales.

Permiten a los programas realizar operaciones específicas que normalmente requerirían privilegios elevados, pero solo durante la ejecución de ese programa en particular. En las capabilities, la cadena `=eip` se utiliza para asignar capacidades específicas a un archivo binario. Cada letra en la cadena tiene un significado particular:

- **e → "Effective" (Efectiva)**: Indica que la capacidad se aplica al usuario efectivo del proceso, es decir, al usuario que está ejecutando el programa.
- **i → "Inheritable" (Hereditaria)**: Indica que la capacidad es heredada por los procesos creados por el programa actual.
- **p → "Permitted" (Permitida)**: Indica que la capacidad está permitida para el programa actual.

Cuando se asigna `=eip` a un archivo binario, se otorgan las capabilities especificadas de la siguiente manera:

- El usuario efectivo del proceso puede utilizar la capability especificada (**Effective**).
- Los procesos creados por este programa heredan la capability (**Inheritable**).
- La capability está permitida para el programa actual (**Permitted**).

En resumen, `=eip` establece las capabilities de manera efectiva, heredable y permitida para el programa binario al que se le asigna. Este tipo de configuración puede utilizarse para permitir que un programa ejecute operaciones específicas con privilegios elevados sin otorgarle todos los privilegios de root.

Para más información, se puede consultar la página de manual referente a capabilities:

```bash
$ man capabilities
```

### Tipos de capabilities

Existen diferentes tipos de capabilities que se pueden asignar a un binario. Algunas de ellas son:

| **Capability**           | **Explicación**                                               |
| ------------------------ | ------------------------------------------------------------- |
| **CAP_CHOWN**            | Permite cambiar el propietario de archivos.                   |
| **CAP_DAC_OVERRIDE**     | Permite anular permisos de acceso a archivos.                 |
| **CAP_DAC_READ_SEARCH**  | Permite leer archivos y directorios.                          |
| **CAP_FOWNER**           | Permite eludir restricciones de control de acceso a archivos. |
| **CAP_FSETID**           | Permite establecer bits setuid y setgid en archivos.          |
| **CAP_KILL**             | Permite enviar señales a otros procesos.                      |
| **CAP_SETGID**           | Permite cambiar el grupo efectivo del proceso.                |
| **CAP_SETUID**           | Permite cambiar el usuario efectivo del proceso.              |
| **CAP_NET_BIND_SERVICE** | Permite enlazar sockets a puertos privilegiados (<1024).      |
| **CAP_NET_RAW**          | Permite usar sockets de red RAW.                              |

Este sistema proporciona un mayor control y seguridad en la ejecución de programas sin necesidad de conceder permisos root completos.

```bash
usuario@debian:~$ getcap -r / 2>/dev/null
/usr/lib/x86_64-linux-gnu/gstreamer1.0/gstreamer-1.0/gst-ptp-helper cap_net_bind_service,cap_net_admin,cap_sys_nice=ep
/usr/lib/nmap/nmap cap_net_bind_service,cap_net_admin,cap_net_raw=eip
/usr/bin/ping cap_net_raw=ep
/usr/bin/fping cap_net_raw=ep
/usr/bin/dumpcap cap_net_admin,cap_net_raw=eip
```

Como prueba vamos a otorgar capabilities a vim para que cualquier usuario modifique el /etc/passwd.

En el siguiente conjunto de comandos se inspecciona la ubicación y permisos del editor **Vim** y revisa si tiene **capabilities** asignadas:

1. `ls -l /etc/passwd` → Muestra los permisos y detalles del archivo `/etc/passwd`, donde se almacenan los usuarios del sistema.
2. `whereis vim` → Localiza los archivos relacionados con Vim.
3. `ls -l $(which vim)` → Verifica qué binario se ejecuta al usar `vim`, revelando que es un enlace simbólico.
4. `ls -l /etc/alternatives/vim` → Confirma que Vim apunta a `/usr/bin/vim.basic` mediante el sistema de alternativas.
5. `ls -l /usr/bin/vim.basic` → Muestra permisos y detalles del binario real de Vim.
6. `getcap /usr/bin/vim.basic` → Comprueba si el binario tiene **capabilities** especiales asignadas.

```bash
usuario@debian:~$ ls -l /etc/passwd
-rw-r--r-- 1 root root 3364 Feb 11 09:30 /etc/passwd

usuario@debian:~$ whereis vim
vim: /usr/bin/vim /etc/vim /usr/share/vim /usr/share/man/man1/vim.1.gz

usuario@debian:~$ ls -l $(which vim)
lrwxrwxrwx 1 root root 21 Feb 10 11:47 /usr/bin/vim -> /etc/alternatives/vim

usuario@debian:~$ ls -l /etc/alternatives/vim
lrwxrwxrwx 1 root root 18 Feb 10 11:47 /etc/alternatives/vim -> /usr/bin/vim.basic

usuario@debian:~$ ls -l /usr/bin/vim.basic
-rwxr-xr-x 1 root root 3883352 Nov 13 12:33 /usr/bin/vim.basic

usuario@debian:~$ getcap /usr/bin/vim.basic
```

En el siguiente conjunto de comandos se otorga y verifica una **capability** especial al binario de Vim:

1. `sudo setcap cap_dac_override=ep /usr/bin/vim.basic` → Asigna la capability **CAP_DAC_OVERRIDE** a Vim, permitiéndole ignorar permisos de acceso a archivos.
2. `getcap /usr/bin/vim.basic` → Verifica que la capability fue aplicada correctamente, mostrando que Vim ahora tiene **CAP_DAC_OVERRIDE** activado. 🚀

```bash
usuario@debian:~$ sudo setcap cap_dac_override=ep /usr/bin/vim.basic
[sudo] password for usuario:

usuario@debian:~$ getcap /usr/bin/vim.basic
/usr/bin/vim.basic cap_dac_override=ep
```

En el siguiente conjunto de comandos se crea un usuario, inicia sesión con él y verifica su información:

1. `sudo useradd -s /bin/bash -p $(mkpasswd 'abc123.') -m -d /home/pepe pepe` → Crea el usuario **pepe** con el shell Bash, establece su contraseña y genera su directorio home.
2. `su - pepe` → Inicia sesión como el usuario **pepe**.
3. `pwd` → Confirma que la sesión está en el directorio home del usuario (**/home/pepe**).
4. `id` → Muestra el UID, GID y grupos a los que pertenece **pepe**.
5. `exit` → Cierra la sesión del usuario **pepe** y vuelve al usuario anterior. 🚀

```bash
usuario@debian:~$ sudo useradd -s /bin/bash -p $(mkpasswd 'abc123.' ) -m -d /home/pepe pepe

usuario@debian:~$ su - pepe
Password:

pepe@debian:~$ pwd
/home/pepe

pepe@debian:~$ id
uid=1001(pepe) gid=1001(pepe) groups=1001(pepe)

pepe@debian:~$ exit
logout
```

En el siguiente conjunto de comandos se **otorga privilegios de root** al usuario **pepe** editando el archivo `/etc/passwd`:

1. `vim /etc/passwd` → Abre el archivo de usuarios del sistema para edición.
2. `cat /etc/passwd | grep ':0:'` → Busca usuarios con **UID 0**, que tienen privilegios de **root**.
   - Se observa que **pepe** tiene `0:1001`, lo que significa que ahora tiene UID 0 (equivalente a root).
3. `su - pepe` → Inicia sesión como **pepe**, pero debido a su UID 0, se convierte en **root**.
4. `whoami` → Confirma que ahora el usuario **pepe** es en realidad **root**.

Modificar `/etc/passwd` para asignar UID 0 a un usuario es un **gran riesgo de seguridad**, ya que cualquier usuario con UID 0 tiene **control total** del sistema.

```bash
usuario@debian:~$ vim /etc/passwd

usuario@debian:~$ cat /etc/passwd | grep ':0:'
root:x:0:0:root:/root:/usr/bin/zsh
pepe:x:0:1001::/home/pepe:/bin/bash

usuario@debian:~$ su - pepe

Password:

root@debian:~# whoami
root
```

En el siguiente conjunto de comandos se **elimina las capabilities de Vim**, pero el usuario **pepe** sigue teniendo privilegios de root:

1. `sudo setcap -r /usr/bin/vim.basic` → **Elimina todas las capabilities** de Vim, incluyendo `CAP_DAC_OVERRIDE`, que permitía ignorar permisos de archivos.
2. `getcap /usr/bin/vim.basic` → Verifica que Vim ya **no tiene capabilities asignadas**.
3. `su - pepe` → Inicia sesión como **pepe**, pero sigue teniendo UID `0`, es decir, aún es **root**.
4. `vim /etc/passwd` → Abre `/etc/passwd` con Vim, lo que sigue siendo posible porque **pepe sigue siendo root**, aunque ya no tenga capabilities en Vim.

\__*Nota*_: Aunque se eliminaron las capabilities de Vim, el usuario **pepe** aún es root debido a su UID 0.

```bash
usuario@debian:~$ sudo setcap -r /usr/bin/vim.basic

usuario@debian:~$ getcap /usr/bin/vim.basic

usuario@debian:~$ su - pepe
Password:

root@debian:~# vim /etc/passwd
ERROR, ya no se puede modificar de esta forma el /etc/passwd
```

Especialmente interesante es el recurso [gtfobins](https://gtfobins.github.io/) donde tenemos diferentes formas de **explotar capabilities** en un sistema.

## Comandos para ver a usuarios conectados en el sistema

| Comando        | Descripción                                                                         |
| -------------- | ----------------------------------------------------------------------------------- |
| who            | Muestra los usuarios actualmente conectados.                                        |
| w              | Muestra usuarios conectados y sus actividades actuales.                             |
| last           | Muestra el historial de inicios de sesión.                                          |
| lastlog        | Muestra el último inicio de sesión de cada usuario.                                 |
| whoami         | Muestra el nombre del usuario actual.                                               |
| id             | Muestra el UID, GID y grupos del usuario actual.                                    |
| finger         | Muestra información detallada sobre un usuario.                                     |
| uptime         | Muestra el tiempo de actividad del sistema y el número de usuarios conectados.      |
| ps aux         | Muestra todos los procesos del sistema, incluyendo los de los usuarios.             |
| watch          | Ejecuta un comando repetidamente para monitorear en tiempo real.                    |
| pkill -KILL -u | Termina todos los procesos de un usuario específico.                                |
| loginctl       | Gestiona y monitorea sesiones de usuarios en sistemas con systemd (systemd-logind). |

## Comando loginctl

El comando **loginctl** es una herramienta para gestionar y monitorizar sesiones de usuario, usuarios y asientos en sistemas Linux que usan systemd (systemd-logind).Sus principales comandos y opciones:

- **list-sessions**: Lista todas las sesiones de usuario activas en el sistema.
- **session-status ID**: Muestra información resumida sobre una sesión específica.
- **show-session ID**: Muestra información detallada y propiedades de una sesión específica.
- **terminate-session ID**: Finaliza una sesión de usuario específica de forma controlada.
- **kill-session ID**: Finaliza abruptamente una sesión y todos sus procesos asociados.
- **list-users**: Muestra los usuarios conectados actualmente al sistema.
- **user-status usuario**: Muestra todas las sesiones abiertas por un usuario específico.
- **show-user usuario**: Muestra información detallada sobre un usuario conectado.
- **terminate-user usuario**: Finaliza todas las sesiones de un usuario específico.
- **kill-user usuario**: Mata todos los procesos y sesiones de un usuario específico de forma inmediata.
