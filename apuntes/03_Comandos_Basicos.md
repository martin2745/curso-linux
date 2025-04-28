# Comandos básicos

A continuación vamos a ver un conjunto de los principales comandos de linux con su explicación.

## Comandos principales básicos

### Comando whoami

```bash
┌──(kali㉿kali)-[~]
└─$ whoami
kali
```
**Explicación:** El comando `whoami` muestra el nombre del usuario actual, que en este caso es `kali`.

### Comando id

```bash
┌──(kali㉿kali)-[~]
└─$ id
uid=1000(kali) gid=1000(kali) groups=1000(kali),4(adm),20(dialout),24(cdrom),25(floppy),27(sudo),29(audio),30(dip),44(video),46(plugdev),100(users),101(netdev),118(bluetooth),120(vboxsf),124(wireshark),126(lpadmin),134(scanner),139(kaboxer)
```
**Explicación:** El comando `id` muestra la información del usuario actual. En este caso, el UID y GID del usuario `kali` son 1000, y muestra los grupos a los que pertenece.

### Comando groups

```bash
┌──(kali㉿kali)-[~]
└─$ groups
kali adm dialout cdrom floppy sudo audio dip video plugdev users netdev bluetooth vboxsf wireshark lpadmin scanner kaboxer
```
**Explicación:** El comando `groups` muestra todos los grupos a los que pertenece el usuario `kali`.

### Comando sudo su

```bash
┌──(kali㉿kali)-[~]
└─$ sudo su
[sudo] password for kali: 
```
**Explicación:** El comando `sudo su` permite al usuario cambiar a la cuenta de `root` (superusuario) después de ingresar la contraseña.

### Comando exit

```bash
┌──(root㉿kali)-[/home/kali]
└─# exit
```
**Explicación:** El comando `exit` termina la sesión de superusuario y vuelve al usuario anterior (`kali`).

### Comando id

```bash
┌──(kali㉿kali)-[~]
└─$ sudo id
uid=0(root) gid=0(root) groups=0(root)
```
**Explicación:** El comando `sudo id` muestra la información de usuario del `root`. El UID y GID son ambos 0, indicando que se trata del superusuario.

### Comando which

```bash
┌──(kali㉿kali)-[~]
└─$ which whoami
/usr/bin/whoami
```
**Explicación:** El comando `which whoami` muestra la ubicación del comando `whoami` en el sistema. En este caso, se encuentra en `/usr/bin/whoami`.

### Comando cat

```bash
┌──(kali㉿kali)-[~]
└─$ which cat
/usr/bin/cat
```
**Explicación:** El comando `which cat` muestra la ubicación del comando `cat`, que está en `/usr/bin/cat`.

### Comando grep

```bash
┌──(kali㉿kali)-[~]
└─$ /usr/bin/cat /etc/group | grep 27
sudo:x:27:kali
inetsim:x:127:
```
**Explicación:** Este comando muestra el contenido del archivo `/etc/group` filtrado por el número 27. Se encuentra que el grupo `sudo` tiene el identificador 27, y el usuario `kali` pertenece a ese grupo.

### Comando echo

```bash
┌──(kali㉿kali)-[~]
└─$ echo $PATH
/home/kali/.local/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/home/kali/.dotnet/tools
```
**Explicación:** El comando `echo $PATH` muestra la variable de entorno `PATH`, que contiene los directorios en los que el sistema busca los ejecutables de los comandos. Aquí, se muestra una lista de directorios como `/home/kali/.local/bin`, `/usr/bin`, etc.

### Comando pwd

```bash
┌──(kali㉿kali)-[~]
└─$ pwd
/home/kali
```
**Explicación:** El comando `pwd` (print working directory) muestra el directorio de trabajo actual. En este caso, está en el directorio `/home/kali`.

### Comando ls

```bash
┌──(kali㉿kali)-[~]
└─$ ls
Desktop  Documents  Downloads  Music  Pictures  Public  Templates  Videos
```
**Explicación:** El comando `ls` lista los archivos y directorios en el directorio actual. En este caso, muestra las carpetas del usuario `kali`: `Desktop`, `Documents`, `Downloads`, `Music`, `Pictures`, `Public`, `Templates`, y `Videos`.

```bash
┌──(kali㉿kali)-[~]
└─$ ls -l
total 32
drwxr-xr-x 2 kali kali 4096 Feb 10 11:54 Desktop
drwxr-xr-x 2 kali kali 4096 Feb 10 11:52 Documents
drwxr-xr-x 2 kali kali 4096 Feb 10 11:52 Downloads
drwxr-xr-x 2 kali kali 4096 Feb 10 11:52 Music
drwxr-xr-x 2 kali kali 4096 Feb 10 11:52 Pictures
drwxr-xr-x 2 kali kali 4096 Feb 10 11:52 Public
drwxr-xr-x 2 kali kali 4096 Feb 10 11:52 Templates
drwxr-xr-x 2 kali kali 4096 Feb 10 11:52 Videos
```
**Explicación:** El comando `ls -l` muestra una lista detallada de los archivos y directorios en el directorio actual, incluyendo permisos, número de enlaces, propietario, grupo, tamaño y fecha de última modificación.

### Comando cd

```bash
┌──(kali㉿kali)-[~]
└─$ cd /
```
**Explicación:** El comando `cd /` cambia al directorio raíz `/`, que es el directorio más alto del sistema de archivos.

```bash
┌──(kali㉿kali)-[/]
└─$ cd ~
```
**Explicación:** El comando `cd ~` lleva al directorio home del usuario actual, que es `/home/kali`.

```bash
┌──(kali㉿kali)-[~]
└─$ cd
```
**Explicación:** El comando `cd` sin argumentos nuevamente lleva al directorio home del usuario actual, que es `/home/kali`.

### Comando mkdir

```bash
root@debian:/tmp# mkdir uno
root@debian:/tmp# mkdir -p uno/dos/tres/cuatro
```

**Explicación:** El comando `mkdir` permite crear directorios de trabajo y con el parámetro `-p` se crea la estructura de directorios indicada.

### Comando cat, more, less y tac

**Explicación:** el comando `cat` muestra el archivo completo.
**Explicación:** el comando `more` muestra el archivo por páginas, solo hacia adelante.
**Explicación:** el comando `less` muestra el archivo por páginas, permite moverse hacia adelante y atrás.
**Explicación:** el comando `tac` muestra el archivo en orden inverso, desde la última línea hasta la primera.

### Comando man, manpath, --help

```bash
vagrant@debian:~$ manpath
/usr/local/man:/usr/local/share/man:/usr/share/man
```

**Explicación**: El comando `man ls` nos mostraría ayuda sobre el comando ls y la información de las páginas del comando man se encuentra en la ruta `/usr/share/man` y el resto de rutas son enlaces simbólicos a esta ruta.

```bash
manpath          # donde se encuentran las paginas del comando man
man -f  passwd   # vemos las secciones asociadas
man -f  passwd
sslpasswd (1ssl) # - compute password hashes
passwd (5)       # - password file
passwd (1)       # - update user's authentication tokens
man -f  passwd   #  Descripción: Muestra una breve descripción de las secciones del manual donde se menciona el comando passwd
man -s 5 passwd  # Descripción: Muestra la página del manual para passwd en la sección 5, que trata sobre los archivos de configuración relacionados con el comando, en este caso el archivo
man -s 1 passwd  # Descripción: Muestra la página del manual para passwd en la sección 1, que trata sobre los comandos de usuario. Aquí se explica cómo usar el comando passwd para cambiar las contraseñas de usuarios.
```

_*Nota*_: Tambien existen otras opciones como `<comando> --help` o `apropos [palabra_clave]` que aportan información del comando en cuestión.

### Comando w

```bash
[vagrant@rockylinux8 ~]$ w
 13:10:15 up  1:25,  1 user,  load average: 0,08, 0,07, 0,02
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
vagrant  pts/0    192.168.33.1     11:46    2.00s  0.15s  0.00s w
```

**Explicación**: El comando `w` me muestra información de los usuarios conectados a mi sistema. Otros comandos como `loginctl` muestran las sesiones iniciadas.

### Comando tty

```bash
[vagrant@rockylinux8 ~]$ tty
/dev/tty/0
```

**Explicación**: El comando `tty` muestra la terminal o pseudoterminal abierta. 

_*Nota*_: Podemos enviar mensajes a otras terminales, como por ejemplo enviarlo a la pseudoterminal /dev/pts/0 de la siguiente manera.

```bash
[vagrant@rockylinux8 ~]$ echo "Envio mensaje" > /dev/pts/0
```

```bash
[vagrant@rockylinux8 ~]$ Envio mensaje
```

### Comando wall

El comando `wall` en Linux se utiliza para enviar un mensaje a todos los usuarios que están conectados al sistema. Es una forma sencilla de difundir un mensaje, generalmente utilizado por los administradores del sistema para advertencias, notificaciones o mensajes importantes.

```bash
[vagrant@rockylinux8 ~]$ wall hola

Mensaje de difusión general (broadcast) de vagrant@rockylinux8 (pts/0) (Sat Ap

hola
```

### Comando cal

```bash
[root@rockylinux8 ~]# cal
     abril 2025     
lu ma mi ju vi sá do
    1  2  3  4  5  6
 7  8  9 10 11 12 13
14 15 16 17 18 19 20
21 22 23 24 25 26 27
28 29 30
```

**Explicación**: El comando `cal` muestra el calendario.

Resumen de comandos:
- cal: Muestra el calendario del mes actual.
- cal [año]: Muestra el calendario del año especificado.
- cal [mes] [año]: Muestra el calendario de un mes y año específicos.
- cal -y: Muestra el calendario del año actual.
- cal -3: Muestra el mes actual y los meses anterior y posterior.
- cal 2024: Calendario todo el año
- cal 10 2024: Muestra el mes de octure del 2024

### Comando date

```bash
date
date --set "2014-11-13 9:30:01"
date -s "2014-11-13 9:30:01"
date +%D
```

El comando `date` sin argumentos, despliega la fecha en la salida estándar del sistema. El formato de salida se puede especificar precedido por un +. La opción -u es para utilizar la hora universal (Greenwich). El único
usuario que puede cambiar la fecha del sistema es root.

A continuación, se muestra una lista completa de los especificadores de formato que puedes utilizar con el comando date para personalizar la salida:

- %a: Nombre abreviado del día de la semana (ej.: "lun").
- %A: Nombre completo del día de la semana (ej.: "lunes").
- %b: Nombre abreviado del mes (ej.: "ene").
- %B: Nombre completo del mes (ej.: "enero").
- %c: Fecha y hora completas según la configuración regional.
- %C: Siglo (los dos primeros dígitos del año, ej.: "20" para 2025).
- %d: Día del mes con dos dígitos (01-31).
- %D: Fecha en formato mm/dd/aa (equivalente a %m/%d/%y).
- %e: Día del mes sin cero a la izquierda (espacio en lugar de cero).
- %F: Fecha en formato ISO 8601: aaaa-mm-dd (equivalente a %Y-%m-%d).
- %g: Últimos dos dígitos del año correspondiente a la semana ISO.
- %G: Año correspondiente a la semana ISO.
- %h: Equivalente a %b.
- %H: Hora en formato 24 horas (00-23).
- %I: Hora en formato 12 horas (01-12).
- %j: Día del año (001-366).
- %k: Hora en formato 24 horas sin cero a la izquierda (espacio en lugar de cero).
- %l: Hora en formato 12 horas sin cero a la izquierda.
- %m: Mes (01-12).
- %M: Minutos (00-59).
- %n: Salto de línea.
- %N: Nanosegundos (000000000-999999999).
- %p: Indicador AM/PM en mayúsculas.
- %P: Indicador am/pm en minúsculas.
- %r: Hora en formato de 12 horas (equivalente a %I:%M:%S %p).
- %R: Hora en formato 24 horas con minutos (equivalente a %H:%M).
- %s: Segundos transcurridos desde 1970-01-01 00:00:00 UTC (Epoch).
- %S: Segundos (00-60, incluyendo segundos intercalados).
- %t: Carácter de tabulación.
- %T: Hora en formato 24 horas con segundos (equivalente a %H:%M:%S).
- %u: Día de la semana (1-7), donde 1 es lunes.
- %U: Número de semana del año (00-53), considerando el domingo como primer día de la semana.
- %V: Número de semana ISO (01-53).
- %w: Día de la semana (0-6), donde 0 es domingo.
- %W: Número de semana del año (00-53), considerando el lunes como primer día de la semana.
- %x: Fecha en formato local.
- %X: Hora en formato local.
- %y: Año sin siglo (00-99).
- %Y: Año completo con siglo (ej.: 2025).
- %z: Desplazamiento respecto a UTC en formato +hhmm (ej.: -0500).
- %Z: Zona horaria (ej.: CET, EST).
- %%: Carácter de porcentaje literal (%).

### Comando uname

```bash
root@debian:~# uname
Linux
root@debian:~# uname -a
Linux debian 6.1.0-23-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.99-1 (2024-07-15) x86_64 GNU/Linux
root@debian:~# uname -r
6.1.0-23-amd64
```

**Explicación**: El comando `uname` muestra información sobre el sistema.

_*Nota*_: En la ruta `/etc/debian_version` o `/etc/redhat-release` puedo ver la versión del sistema operativo.
_*Nota*_: Con el comando `arch` se puede ver la arquitectura del sistema.

### Comando ln

```bash

```

**Explicación**: El comando `ln` sirve para crear enlaces en Linux. Aquí tenemos que explicar que existen dos tipos de enlaces.

- Enlaces simbólicos: La manera más sencilla de comprender que es un enlace simbólico en Linux es compararlo con el “enlace directo” o “shortcut” en Windows. El fichero o directorio se encuentra en un único punto del disco y los enlaces son un puntero contra él. Cada enlace simbólico tiene su propio número de inodo lo que permite hacer enlaces simbólicos entre distintos sistemas de ficheros. 
Para crear enlaces (tanto simbólicos como duros) usamos el comando ln. En este caso vamos a crear un enlace simbólico (parámetro -s) del fichero test:
```bash
root@debian:/tmp# ln -s test/ enlace-simbolico-test
root@debian:/tmp# ls -l enlace*
lrwxrwxrwx 1 root root 5 abr 28 17:47 enlace-simbolico-test -> test/
root@debian:/tmp# ls -li enlace-simbolico-test
2883610 lrwxrwxrwx 1 root root 5 abr 28 17:47 enlace-simbolico-test -> test/
root@debian:/tmp# ls -lid test
2883599 drwxr-xr-x 2 root root 4096 abr 28 17:08 test
```
_*Nota*_: Es importante entender que si borramos el fichero o directorio origen, el enlace simbólico permanece pero los datos desaparecen para siempre.

- Enlaces duros: Los enlaces duros lo que hacen es asociar dos o más ficheros compartiendo el mismo inodo. Esto hace que cada enlace duro es una copia exacta del resto de ficheros asociados, tanto de datos como de permisos, propietario, etc. Esto implica también que cuando se realicen cambios en uno de los enlaces o en el fichero este también se realizará en el resto de enlaces. 

```bash
root@debian:/tmp# echo "fichero test" > test.txt

root@debian:/tmp# ls -li test.txt enlace-duro-test 
2883611 -rw-r--r-- 2 root root 13 abr 28 17:51 enlace-duro-test
2883611 -rw-r--r-- 2 root root 13 abr 28 17:51 test.txt
```

En la primera columna verificamos que tienen el mismo número de inodo y en la tercera se especifica cuando enlaces duros tiene el fichero. Si hacéis cambios en uno de ellos veréis que también se hacen en el resto.  Si por ejemplo cambiamos los permisos al fichero test.txt:

```bash
root@debian:/tmp# chmod 755 test.txt 
root@debian:/tmp# ls -li test.txt enlace-duro-test 
2883611 -rwxr-xr-x 2 root root 13 abr 28 17:52 enlace-duro-test
2883611 -rwxr-xr-x 2 root root 13 abr 28 17:52 test.txt
```

_*Nota*_: Es importante entender que los enlaces duros no pueden hacerse contra directorios y tampoco fuera del propio sistema de ficheros.

| soft link | hard link |  
| --------- | --------- |
| Se pueden hacer con ficheros y directorios | Solamente se pueden hacer con ficheros |
| Se pueden hacer entre distintos sistemas de ficheros | No admiten diferentes sistemas de ficheros |
| Tienen diferente número de inodo | Comparten número de inodo |
| Si borramos la información original perdemos el enlace | Si borramos la información original el enlace sigue funcionando |
| Son punteros o accesos directos a memoria | Son copias exactas del fichero de origen |