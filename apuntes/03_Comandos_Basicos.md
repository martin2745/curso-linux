# Comandos básicos

A continuación vamos a ver un conjunto de los principales comandos de linux con su explicación.

## Comandos principales básicos

### Comando whoami

```bash
usuario@debian:~$ whoami
usuario
```

**Explicación:** El comando `whoami` muestra el nombre del usuario actual, que en este caso es `usuario`.

### Comando id

```bash
usuario@debian:~$ id
uid=1000(usuario) gid=1000(usuario) grupos=1000(usuario),24(cdrom),25(floppy),27(sudo),29(audio),30(dip),44(video),46(plugdev),100(users),106(netdev),112(bluetooth),114(lpadmin),117(scanner)
```

**Explicación:** El comando `id` muestra la información del usuario actual. En este caso, el UID y GID del usuario `usuario` son 1000, y muestra los grupos a los que pertenece.

### Comando groups

```bash
usuario@debian:~$ groups
usuario cdrom floppy sudo audio dip video plugdev users netdev bluetooth lpadmin scanner
```

**Explicación:** El comando `groups` muestra todos los grupos a los que pertenece el usuario `usuario`.

### Comando id

```bash
usuario@debian:~$ sudo id
[sudo] contraseña para usuario:
uid=0(root) gid=0(root) grupos=0(root)
```

**Explicación:** El comando `sudo id` muestra la información de usuario del `root`. El UID y GID son ambos 0, indicando que se trata del superusuario.

### Comando which

```bash
usuario@debian:~$ which whoami
/usr/bin/whoami
```

**Explicación:** El comando `which whoami` muestra la ubicación del comando `whoami` en el sistema. En este caso, se encuentra en `/usr/bin/whoami`.

### Comando cat

```bash
usuario@debian:~$ cat .profile
# ~/.profile: executed by the command interpreter for login shells.
...
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
```

**Explicación:** El comando `cat .profile` muestra la información del archivo `.profile`.

### Comando grep

```bash
usuario@debian:~$ grep usuario /etc/passwd
usuario:x:1000:1000:usuario,,,:/home/usuario:/bin/bash
```

**Explicación:** Este comando muestra el contenido del archivo `/etc/passwd` filtrado por la palabra `usuario`.

### Comando echo

```bash
usuario@debian:~$ echo $PATH
/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games

usuario@debian:~# echo -e "Hola\n que tal\t estás"
Hola
 que tal         estás
```

**Explicación:** El comando `echo $PATH` muestra la variable de entorno `PATH`, que contiene los directorios en los que el sistema busca los ejecutables de los comandos.

_*Nota*_: Muy importante es el uso de las comillas en el comando _echo_.

```bash
usuario@debian:~# echo "$PWD"
/root
usuario@debian:~# echo '$PWD'
$PWD
```

### Comando pwd

```bash
usuario@debian:~$ pwd
/home/usuario
```

**Explicación:** El comando `pwd` (print working directory) muestra el directorio de trabajo actual. En este caso, está en el directorio `/home/usuario`.

### Comando ls

```bash
usuario@debian:~$ ls
Descargas  Documentos  Escritorio  Imágenes  Música  Plantillas  Público  Vídeos
```

**Explicación:** El comando `ls` lista los archivos y directorios en el directorio actual. En este caso, muestra las carpetas del usuario `Descargas`, `Documentos`, `Escritorio`, `Imágenes`, `Música`, `Plantillas`, `Público` y `Vídeos`.

```bash
usuario@debian:~$ ls -l
total 32
drwxr-xr-x 2 usuario usuario 4096 may  2 17:03 Descargas
drwxr-xr-x 2 usuario usuario 4096 may  2 16:53 Documentos
drwxr-xr-x 2 usuario usuario 4096 may  2 16:53 Escritorio
drwxr-xr-x 2 usuario usuario 4096 may  2 16:53 Imágenes
drwxr-xr-x 2 usuario usuario 4096 may  2 16:53 Música
drwxr-xr-x 2 usuario usuario 4096 may  2 16:53 Plantillas
drwxr-xr-x 2 usuario usuario 4096 may  2 16:53 Público
drwxr-xr-x 2 usuario usuario 4096 may  2 16:53 Vídeos
```

**Explicación:** El comando `ls -l` muestra una lista detallada de los archivos y directorios en el directorio actual, incluyendo permisos, número de enlaces, propietario, grupo, tamaño y fecha de última modificación.

### Comando cd

```bash
usuario@debian:~$ cd /
usuario@debian:/$
```

**Explicación:** El comando `cd /` cambia al directorio raíz `/`, que es el directorio más alto del sistema de archivos.

```bash
usuario@debian:/$ cd ~
usuario@debian:~$
```

**Explicación:** El comando `cd ~` lleva al directorio home del usuario actual, que es `/home/usuario`.

```bash
usuario@debian:~$ cd
usuario@debian:~$
```

**Explicación:** El comando `cd` sin argumentos nuevamente lleva al directorio home del usuario actual, que es `/home/usuario`.

### Comando mkdir

```bash
usuario@debian:/tmp# mkdir uno
usuario@debian:/tmp# mkdir -p uno/dos/tres/cuatro
```

**Explicación:** El comando `mkdir` permite crear directorios de trabajo y con el parámetro `-p` se crea la estructura de directorios indicada.

### Comando cat, more, less y tac

**Explicación:** el comando `cat` muestra el archivo completo.
**Explicación:** el comando `more` muestra el archivo por páginas, solo hacia adelante.
**Explicación:** el comando `less` muestra el archivo por páginas, permite moverse hacia adelante y atrás.
**Explicación:** el comando `tac` muestra el archivo en orden inverso, desde la última línea hasta la primera.

### Comando head y tail

```bash
usuario@debian:~# head -n 3 /etc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin

usuario@debian:~# head -3 /etc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin

usuario@debian:~# tail -n 3 /etc/passwd
vboxadd:x:999:1::/var/run/vboxadd:/bin/false
_chrony:x:104:109:Chrony daemon,,,:/var/lib/chrony:/usr/sbin/nologin
usuario:x:1001:1001::/home/usuario:/bin/bash

usuario@debian:~# tail -3 /etc/passwd
vboxadd:x:999:1::/var/run/vboxadd:/bin/false
_chrony:x:104:109:Chrony daemon,,,:/var/lib/chrony:/usr/sbin/nologin
usuario:x:1001:1001::/home/usuario:/bin/bash
```

**Explicación**: Los comandos `head` y `tail` permiten mostrar por defecto las 10 primeras o últimas lineas de un fichero. Se puede ajustar el número con el parámetro _-n_ o indicandolo con el número de lineas a mostrar.

### Comando man, manpath, --help

```bash
usuario@debian:~$ manpath
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
usuario@debian:~$ w
 07:23:39 up 19 min,  2 users,  load average: 0,01, 0,01, 0,00
USER     TTY      DESDE            LOGIN@   IDLE   JCPU   PCPU WHAT
usuario  tty2     tty2             07:05   19:36   0.02s  0.02s /usr/libexec/gnome-session-binary
usuario  pts/2    10.0.2.2         07:06    0.00s  0.15s  0.01s w
```

**Explicación**: El comando `w` me muestra información de los usuarios conectados a mi sistema. Otros comandos como `loginctl` muestran las sesiones iniciadas.

### Comando tty

```bash
usuario@debian:~$ tty
/dev/pts/2
```

**Explicación**: El comando `tty` muestra la terminal o pseudoterminal abierta.

_*Nota*_: Podemos enviar mensajes a otras terminales, como por ejemplo enviarlo a la pseudoterminal `/dev/pts/0` de la siguiente manera. Si queremos cambiar entre `tty` hacemos uso de la combinación de teclas (Ctrl + Alt + Fx).

```bash
usuario@debian:~$ echo "Envio mensaje" > /dev/pts/0
```

```bash
usuario@debian:~$ Envio mensaje
```

### Comando cal

```bash
usuario@debian:~# sudo apt install ncal
usuario@debian:~# cal
  Septiembre 2025
do lu ma mi ju vi sá
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
usuario@debian:~# date
vie 05 sep 2025 07:37:29 CEST
...
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
usuario@debian:~$ uname
Linux
usuario@debian:~$ uname -a
Linux debian 6.1.0-34-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.135-1 (2025-04-25) x86_64 GNU/Linux
usuario@debian:~$ uname -r
6.1.0-34-amd64
```

**Explicación**: El comando `uname` muestra información sobre el sistema.

_*Nota*_: En la ruta `/etc/debian_version` o `/etc/redhat-release` puedo ver la versión del sistema operativo.
_*Nota*_: Con el comando `arch` se puede ver la arquitectura del sistema.

### Comando ln

```bash
usuario@debian:~$ cd /tmp
usuario@debian:/tmp$ echo "fichero test" > test
usuario@debian:/tmp$ ls test
test
usuario@debian:/tmp$ cat test
fichero test

usuario@debian:/tmp$ ln test enlace-duro-test
usuario@debian:/tmp$ ls test enlace-duro-test
enlace-duro-test  test

usuario@debian:/tmp$ cat enlace-duro-test
fichero test
```

**Explicación**: El comando `ln` sirve para crear enlaces en Linux. Aquí tenemos que explicar que existen dos tipos de enlaces.

- **Enlaces simbólicos**: La manera más sencilla de comprender que es un enlace simbólico en Linux es compararlo con el “enlace directo” o “shortcut” en Windows. El fichero o directorio se encuentra en un único punto del disco y los enlaces son un puntero contra él. Cada enlace simbólico tiene su propio número de inodo lo que permite hacer enlaces simbólicos entre distintos sistemas de ficheros. Para crear enlaces (tanto simbólicos como duros) usamos el comando ln. En este caso vamos a crear un enlace simbólico (parámetro -s) del fichero test:

```bash
usuario@debian:/tmp$ ls -li test enlace-duro-test
2359319 -rw-r--r-- 2 usuario usuario 13 sep  5 07:41 enlace-duro-test
2359319 -rw-r--r-- 2 usuario usuario 13 sep  5 07:41 test

usuario@debian:/tmp$ ln -s test enlace-simbolico-test

usuario@debian:/tmp$ ls -li test enlace*
2359319 -rw-r--r-- 2 usuario usuario 13 sep  5 07:41 test
2359319 -rw-r--r-- 2 usuario usuario 13 sep  5 07:41 enlace-duro-test
2359336 lrwxrwxrwx 1 usuario usuario  4 sep  5 07:49 enlace-simbolico-test -> test
```

_*Nota*_: Es importante entender que si borramos el fichero o directorio origen, el enlace simbólico permanece pero los datos desaparecen para siempre.

```bash
usuario@debian:/tmp$ rm test
usuario@debian:/tmp$ ls -li enlace*
2359319 -rw-r--r-- 1 usuario usuario 13 sep  5 07:41 enlace-duro-test
2359336 lrwxrwxrwx 1 usuario usuario  4 sep  5 07:49 enlace-simbolico-test -> test

usuario@debian:/tmp$ cat enlace-duro-test
fichero test
usuario@debian:/tmp$ cat enlace-simbolico-test
cat: enlace-simbolico-test: No existe el fichero o el directorio
```

- **Enlaces duros**: Los enlaces duros lo que hacen es asociar dos o más ficheros compartiendo el mismo inodo. Esto hace que cada enlace duro es una copia exacta del resto de ficheros asociados, tanto de datos como de permisos, propietario, etc. Esto implica también que cuando se realicen cambios en uno de los enlaces o en el fichero este también se realizará en el resto de enlaces.

```bash
usuario@debian:/tmp$ rm enlace*

usuario@debian:/tmp$ echo "fichero test" > test.txt
usuario@debian:/tmp$ ln test.txt enlace-duro-test

usuario@debian:/tmp$ ls -li test.txt enlace-duro-test
2359319 -rw-r--r-- 2 usuario usuario 13 sep  5 07:51 enlace-duro-test
2359319 -rw-r--r-- 2 usuario usuario 13 sep  5 07:51 test.txt
```

En la primera columna verificamos que tienen el mismo número de inodo y en la tercera se especifica cuando enlaces duros tiene el fichero. Si hacéis cambios en uno de ellos veréis que también se hacen en el resto. Si por ejemplo cambiamos los permisos al fichero test.txt:

```bash
usuario@debian:/tmp$ chmod 755 test.txt
usuario@debian:/tmp$ ls -li test.txt enlace-duro-test
2359319 -rwxr-xr-x 2 usuario usuario 13 sep  5 07:51 enlace-duro-test
2359319 -rwxr-xr-x 2 usuario usuario 13 sep  5 07:51 test.txt
```

_*Nota 2*_: Es importante entender que los enlaces duros no pueden hacerse contra directorios y tampoco fuera del propio sistema de ficheros.

| soft link                                              | hard link                                                       |
| ------------------------------------------------------ | --------------------------------------------------------------- |
| Se pueden hacer con ficheros y directorios             | Solamente se pueden hacer con ficheros                          |
| Se pueden hacer entre distintos sistemas de ficheros   | No admiten diferentes sistemas de ficheros                      |
| Tienen diferente número de inodo                       | Comparten número de inodo                                       |
| Si borramos la información original perdemos el enlace | Si borramos la información original el enlace sigue funcionando |
| Son punteros o accesos directos a memoria              | Son copias exactas del fichero de origen                        |

### Comando su –

**Explicación**: El comando `su` y `su -` en Linux se utilizan para cambiar de usuario en el sistema, pero tienen comportamientos diferentes en cuanto al entorno del usuario al que se cambia. A continuación, se explica las diferencias clave entre ambos:

- su (sin guion): Cambia de usuario sin cargar completamente el entorno de inicio de sesión del nuevo usuario. Mantiene el entorno actual del usuario que ejecuta el comando (variables de entorno, directorio actual, etc.). El directorio de trabajo permanece siendo el directorio del usuario desde el que ejecutaste su.

```bash
usuario@debian:~$ echo $PWD
/home/usuario
usuario@debian:~$ su
Contraseña:
root@debian:/home/usuario# echo $PWD
/home/usuario
```

- su - (con guion): Cambia de usuario y carga completamente el entorno de inicio de sesión del nuevo usuario (como si hubieras iniciado sesión directamente como ese usuario). Carga el entorno completo del nuevo usuario, incluyendo las variables de entorno, el directorio de inicio, y archivos de configuración como .bashrc o .profile. El directorio de trabajo cambia al directorio personal (home) del nuevo usuario.

```bash
usuario@debian:~$ echo $PWD
/home/usuario
usuario@debian:~$ su -
Contraseña:
root@debian:~# echo $PWD
/root
```
