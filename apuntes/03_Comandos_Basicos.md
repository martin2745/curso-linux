# Comandos básicos

## Índice

1. [Identidad del usuario](#1-identidad-del-usuario)
   1. [Comando whoami](#11-comando-whoami)
   2. [Comando id](#12-comando-id)
   3. [Comando groups](#13-comando-groups)
2. [Navegación por el sistema de ficheros](#2-navegación-por-el-sistema-de-ficheros)
   1. [Comando pwd](#21-comando-pwd)
   2. [Comando cd](#22-comando-cd)
   3. [Comando ls](#23-comando-ls)
   4. [Comando mkdir](#24-comando-mkdir)
3. [Visualización del contenido de ficheros](#3-visualización-del-contenido-de-ficheros)
   1. [Comandos cat, more, less y tac](#31-comandos-cat-more-less-y-tac)
   2. [Comandos head y tail](#32-comandos-head-y-tail)
4. [Búsqueda de texto y localización de ejecutables](#4-búsqueda-de-texto-y-localización-de-ejecutables)
   1. [Comando grep](#41-comando-grep)
   2. [Comando which](#42-comando-which)
5. [Mostrar texto por pantalla](#5-mostrar-texto-por-pantalla)
6. [Ayuda y documentación del sistema](#6-ayuda-y-documentación-del-sistema)
7. [Información del sistema y de la sesión](#7-información-del-sistema-y-de-la-sesión)
   1. [Comando w](#71-comando-w)
   2. [Comando tty](#72-comando-tty)
   3. [Comando cal](#73-comando-cal)
   4. [Comando date](#74-comando-date)
   5. [Comando uname](#75-comando-uname)
8. [Enlaces duros y simbólicos](#8-enlaces-duros-y-simbólicos)
9. [Cambio de usuario](#9-cambio-de-usuario)

---

## 1. Identidad del usuario

El primer grupo de comandos responde a una pregunta básica en cualquier sesión: con qué identidad estamos trabajando y qué permisos nos otorga.

### 1.1 Comando whoami

```bash
usuario@debian:~$ whoami
usuario
```

**Explicación:** El comando `whoami` (del inglés *who am I*, "quién soy yo") muestra el nombre del usuario efectivo con el que estás operando actualmente, que en este caso es `usuario`. Es útil en scripts para verificar si se está ejecutando como `root`.

### 1.2 Comando id

```bash
usuario@debian:~$ id
uid=1000(usuario) gid=1000(usuario) grupos=1000(usuario),24(cdrom),25(floppy),27(sudo),29(audio),30(dip),44(video),46(plugdev),100(users),106(netdev),112(bluetooth),114(lpadmin),117(scanner)
```

**Explicación:** El comando `id` muestra la información detallada del usuario actual. En este caso, el UID (*User Identifier*) y GID (*Group Identifier* principal) del usuario `usuario` son 1000. También muestra todos los grupos secundarios a los que pertenece, lo cual determina a qué recursos de hardware o archivos tiene acceso por permisos de grupo.

Para revisar la información de un usuario diferente, o en este caso del superusuario mediante `sudo`, ejecutamos lo siguiente:

```bash
usuario@debian:~$ sudo id
[sudo] contraseña para usuario:
uid=0(root) gid=0(root) grupos=0(root)
```

**Explicación:** Al ejecutar `sudo id` logramos ejecutar la herramienta bajo el contexto temporal de administrador. El UID y GID de `root` son siempre 0, indicando que se trata del superusuario absoluto del sistema.

### 1.3 Comando groups

```bash
usuario@debian:~$ groups
usuario cdrom floppy sudo audio dip video plugdev users netdev bluetooth lpadmin scanner
```

**Explicación:** El comando `groups` muestra únicamente el nombre de todos los grupos (principales y secundarios) a los que pertenece el usuario `usuario` actual, sin mostrar identificadores numéricos.

---

## 2. Navegación por el sistema de ficheros

Estos comandos permiten saber dónde estamos, desplazarnos por el árbol de directorios y crear nuevas carpetas.

### 2.1 Comando pwd

```bash
usuario@debian:~$ pwd
/home/usuario
```

**Explicación:** El comando `pwd` (*Print Working Directory*) muestra la ruta absoluta del directorio de trabajo en el que te encuentras posicionado actualmente. En este caso, el usuario está en el directorio `/home/usuario`.

### 2.2 Comando cd

```bash
usuario@debian:~$ cd /
usuario@debian:/$
```

**Explicación:** El comando `cd` (*Change Directory*) nos permite navegar por el sistema de ficheros. Ejecutando `cd /` cambia de inmediato al directorio raíz `/`, la parte más alta de la jerarquía.

Para volver rápidamente a nuestra carpeta personal desde cualquier ubicación:

```bash
usuario@debian:/$ cd ~
usuario@debian:~$
```

**Explicación:** La tilde (`~`) es un atajo universal que representa el directorio *home* del usuario actual (ej. `/home/usuario`).

Una alternativa aún más rápida es simplemente ejecutar el comando sin parámetros:

```bash
usuario@debian:~$ cd
usuario@debian:~$
```

**Explicación:** El comando `cd` introducido sin argumentos siempre redirige por defecto al directorio personal del usuario.

### 2.3 Comando ls

```bash
usuario@debian:~$ ls
Descargas  Documentos  Escritorio  Imágenes  Música  Plantillas  Público  Vídeos
```

**Explicación:** El comando `ls` lista los archivos y subdirectorios presentes en el directorio de trabajo actual (o el indicado). Aquí muestra las carpetas estándar de perfil de usuario.

Para obtener más información, podemos pasarle opciones:

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

| Parámetro | Descripción |
|-----------|-------------|
| `-l`      | Muestra la lista en formato largo, incluyendo permisos, enlaces, propietario, grupo, tamaño en bytes y fecha de última modificación. |
| `-a`      | (No mostrado) Muestra también los archivos y carpetas ocultos que comienzan con un punto (`.`). |
| `-h`      | (No mostrado) Muestra el tamaño de forma legible por humanos (*human-readable*, ej. 4K, 2M) cuando se combina con `-l`. |

### 2.4 Comando mkdir

```bash
usuario@debian:/tmp$ mkdir uno
usuario@debian:/tmp$ mkdir -p uno/dos/tres/cuatro
```

**Explicación:** El comando `mkdir` (*Make Directory*) permite crear nuevas carpetas. 

| Parámetro | Descripción |
|-----------|-------------|
| `-p`      | (*Parents* o "padres") Si los directorios padre (`uno`, `dos`, `tres`) no existen, los crea automáticamente en la misma instrucción sin devolver error. |

---

## 3. Visualización del contenido de ficheros

Existen varias herramientas para leer ficheros de texto, y la elección depende sobre todo del tamaño del fichero y de si necesitamos movernos por él.

### 3.1 Comandos cat, more, less y tac

**Explicación comparativa de herramientas de lectura de texto:**
- El comando `cat` muestra o concatena el contenido del archivo completo por la salida estándar, ideal para archivos pequeños.
- El comando `more` actúa como paginador. Muestra el archivo pantalla por pantalla, avanzando con la tecla Espacio, pero solo permite moverse hacia adelante.
- El comando `less` es un paginador avanzado. Muestra el archivo por páginas y permite moverse de forma interactiva tanto hacia adelante como hacia atrás utilizando las flechas del teclado y buscar palabras internamente. ("*Less is more*").
- El comando `tac` es el inverso de `cat`. Muestra las líneas del archivo en orden inverso, leyendo desde la última línea hasta la primera (muy útil para leer *logs* cronológicos donde el final es lo más reciente).

Ejemplo de lectura de un fichero completo con `cat`:

```bash
usuario@debian:~$ cat .profile
# ~/.profile: executed by the command interpreter for login shells.
...
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
```

**Explicación:** El comando `cat .profile` vuelca el contenido completo del archivo de texto `.profile` por la salida estándar. Su nombre procede de *concatenate*, porque admite varios ficheros y los muestra encadenados uno tras otro.

### 3.2 Comandos head y tail

```bash
usuario@debian:~$ head -n 3 /etc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin

usuario@debian:~$ head -3 /etc/passwd
root:x:0:0:root:/root:/bin/bash
...
```

Y su equivalente para el final del archivo:

```bash
usuario@debian:~$ tail -n 3 /etc/passwd
vboxadd:x:999:1::/var/run/vboxadd:/bin/false
_chrony:x:104:109:Chrony daemon,,,:/var/lib/chrony:/usr/sbin/nologin
usuario:x:1001:1001::/home/usuario:/bin/bash

usuario@debian:~$ tail -3 /etc/passwd
...
```

**Explicación**: Los comandos `head` y `tail` permiten mostrar rápidamente fragmentos iniciales o finales de un documento. Por defecto muestran las 10 primeras o últimas líneas, respectivamente. 

| Parámetro | Descripción |
|-----------|-------------|
| `-n [NUM]`| Define la cantidad exacta de líneas a mostrar. También puede indicarse pasando directamente el número precedido de un guion (ej. `-3`). |
| `-f`      | (Solo `tail`) "Sigue" (*follow*) los cambios en vivo del archivo, mostrando las nuevas líneas según se van escribiendo. Es imprescindible para monitorizar ficheros de *logs*. |

---

## 4. Búsqueda de texto y localización de ejecutables

Dos herramientas complementarias: una busca dentro del contenido de los ficheros y la otra busca el fichero ejecutable de un comando.

### 4.1 Comando grep

```bash
usuario@debian:~$ grep usuario /etc/passwd
usuario:x:1000:1000:usuario,,,:/home/usuario:/bin/bash
```

**Explicación:** El comando `grep` permite buscar patrones dentro de archivos o salidas de comandos. En este ejemplo, filtra y muestra únicamente la línea del archivo `/etc/passwd` que contiene exactamente la palabra `usuario`.

### 4.2 Comando which

```bash
usuario@debian:~$ which whoami
/usr/bin/whoami
```

**Explicación:** El comando `which whoami` muestra la ubicación o ruta absoluta del ejecutable del comando `whoami` en el sistema. Para encontrarlo, la herramienta `which` lee los directorios definidos en tu variable de entorno `$PATH` y devuelve la primera coincidencia.

---

## 5. Mostrar texto por pantalla

```bash
usuario@debian:~$ echo $PATH
/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
```

**Explicación:** El comando `echo` imprime en pantalla el texto o variables que se le pasen por argumento. Aquí se emplea `echo $PATH` para mostrar el valor almacenado en la variable de entorno `$PATH`, la cual contiene los directorios en los que el sistema busca los ejecutables.

A continuación, vemos cómo usar caracteres de escape especiales añadiendo el parámetro `-e`:

```bash
usuario@debian:~$ echo -e "Hola\n que tal\t estás"
Hola
 que tal         estás
```

**Explicación:** El parámetro `-e` habilita la interpretación de secuencias de escape como `\n` (nueva línea) y `\t` (tabulación).

> **Nota:** Es muy importante tener en cuenta la diferencia del uso de las comillas dobles y simples en el comando `echo` al evaluar variables:

```bash
usuario@debian:~$ echo "$PWD"
/root
usuario@debian:~$ echo '$PWD'
$PWD
```

**Explicación:** Las comillas dobles (`" "`) permiten la expansión de variables (reemplazando `$PWD` por `/root`), mientras que las comillas simples (`' '`) interpretan todo el contenido de forma estrictamente literal.

---

## 6. Ayuda y documentación del sistema

```bash
usuario@debian:~$ manpath
/usr/local/man:/usr/local/share/man:/usr/share/man
```

**Explicación**: El comando `man` (*Manual*) invoca el manual interno del sistema. Ejecutar `man ls` nos mostraría la documentación completa sobre el comando `ls`. El comando `manpath` desvela los directorios donde se almacenan físicamente las páginas del manual. La ruta principal base suele ser `/usr/share/man`.

Para investigar un comando y sus diferentes secciones en el manual:

```bash
usuario@debian:~$ man -f passwd
sslpasswd (1ssl)     - compute password hashes
passwd (5)           - password file
passwd (1)           - update user's authentication tokens
```

La salida revela que existen **tres páginas distintas** con el mismo nombre, cada una en una sección diferente del manual. Para abrir una en concreto se indica el número de sección:

```bash
usuario@debian:~$ man 5 passwd    # sección 5: describe el formato del fichero /etc/passwd
usuario@debian:~$ man 1 passwd    # sección 1: describe el comando passwd para cambiar contraseñas
```

> **Importante:** Si se omite el número de sección, `man` muestra la primera coincidencia siguiendo su orden de búsqueda, que empieza por la sección 1. Por eso `man passwd` a secas abre la página del **comando** y no la del **fichero**, un despiste muy habitual al consultar formatos de ficheros de configuración.

Estas son las secciones en las que se divide el manual:

| Sección | Contenido |
|---|---|
| 1 | Comandos ejecutables por cualquier usuario. |
| 2 | Llamadas al sistema proporcionadas por el núcleo. |
| 3 | Funciones de las bibliotecas de C. |
| 4 | Ficheros especiales, normalmente los de `/dev`. |
| 5 | Formatos de fichero y convenios, como `/etc/passwd` o `/etc/fstab`. |
| 6 | Juegos. |
| 7 | Miscelánea: convenios, protocolos, conjuntos de caracteres. |
| 8 | Comandos de administración, reservados normalmente a `root`. |

> **Nota:** También existen otras opciones de ayuda rápida. Casi todos los comandos aceptan la flag `<comando> --help` para imprimir un resumen de uso en la consola. Asimismo, si no sabes el nombre de un comando pero sabes qué hace, puedes usar `apropos [palabra_clave]` para buscar por descripción en todo el sistema de manuales.

---

## 7. Información del sistema y de la sesión

Este grupo reúne comandos que informan sobre el estado de la máquina, la sesión activa y el núcleo en ejecución.

### 7.1 Comando w

```bash
usuario@debian:~$ w
 07:23:39 up 19 min,  2 users,  load average: 0,01, 0,01, 0,00
USER     TTY      DESDE            LOGIN@   IDLE   JCPU   PCPU WHAT
usuario  tty2     tty2             07:05   19:36   0.02s  0.02s /usr/libexec/gnome-session-binary
usuario  pts/2    10.0.2.2         07:06    0.00s  0.15s  0.01s w
```

**Explicación**: El comando `w` condensa información vital del sistema. Muestra el tiempo de actividad (*uptime*), la carga promedio y el estado detallado de todos los usuarios actualmente conectados al sistema, desde qué terminal operan y qué procesos concretos están ejecutando. Existen comandos complementarios como `loginctl` o `who` que también permiten administrar o revisar las sesiones activas.

### 7.2 Comando tty

```bash
usuario@debian:~$ tty
/dev/pts/2
```

**Explicación**: El comando `tty` (*Teletype*) imprime en pantalla el archivo de dispositivo especial que representa tu terminal o pseudoterminal actual en la que estás escribiendo. En el ejemplo anterior, estás en una pseudoterminal (`/dev/pts/2`).

Dado que cada terminal es un "archivo", podemos enviar o redirigir mensajes directamente hacia otras terminales, como se muestra a continuación enviando un texto hacia `/dev/pts/0`. 

```bash
usuario@debian:~$ echo "Envio mensaje" > /dev/pts/0
```

Si hubiese una sesión abierta en la pseudoterminal `/dev/pts/0`, su usuario vería aparecer el mensaje en pantalla:

```bash
usuario@debian:~$ Envio mensaje
```

> **Nota:** Conviene distinguir los dos tipos de terminal que aparecen en el sistema:
>
> | Dispositivo | Tipo | Origen |
> |---|---|---|
> | `/dev/tty1` … `/dev/tty6` | Consolas virtuales reales, gestionadas por el núcleo. | Se accede a ellas pulsando `Ctrl + Alt + F1` hasta `F6`. |
> | `/dev/pts/0`, `/dev/pts/1`… | Pseudoterminales, creadas bajo demanda por software. | Las genera cada ventana de un emulador de terminal gráfico, cada sesión de `ssh` y cada panel de `tmux`. |
>
> El ejemplo anterior devolvió `/dev/pts/2`, de modo que se trata de una pseudoterminal y no de una consola virtual.

> **Advertencia:** Escribir en el terminal de otro usuario requiere permiso de escritura sobre su dispositivo, algo que por defecto solo tiene `root`. Para la comunicación entre usuarios existen las herramientas `write`, `wall` y `mesg`, que respetan la preferencia de cada usuario sobre si desea o no recibir mensajes.

### 7.3 Comando cal

```bash
usuario@debian:~$ sudo apt install ncal
usuario@debian:~$ cal
  Septiembre 2025
do lu ma mi ju vi sá
    1  2  3  4  5  6
 7  8  9 10 11 12 13
14 15 16 17 18 19 20
21 22 23 24 25 26 27
28 29 30
```

**Explicación**: El comando `cal` (*Calendar*) imprime un pequeño calendario formateado en la terminal. En una instalación mínima puede no venir incluido y hay que instalarlo.

> **Nota:** El paquete que proporciona `cal` ha cambiado con las versiones de Debian. Si el comando no está disponible, lo más fiable es averiguar qué paquete lo aporta en tu sistema concreto con `apt-file search bin/cal`, o comprobar de dónde salió el que ya tienes instalado con `dpkg -S $(which cal)`.

**Sintaxis y variantes de `cal`:**

| Comando               | Resultado |
|-----------------------|-----------|
| `cal`                 | Muestra el calendario del mes actual. |
| `cal [año]`           | Muestra el calendario completo del año especificado (ej. `cal 2024`). |
| `cal [mes] [año]`     | Muestra el calendario de un mes y año concretos (ej. `cal 10 2024` para octubre). |
| `cal -y`              | Muestra todo el calendario del año en curso. |
| `cal -3`              | Muestra el mes actual, el mes anterior y el mes posterior al mismo tiempo. |

### 7.4 Comando date

```bash
usuario@debian:~$ date
vie 05 sep 2025 07:37:29 CEST
```

**Explicación**: El comando `date` sin argumentos despliega la hora y la fecha actual leída de los relojes del sistema. El formato de salida es altamente personalizable concatenando una cadena precedida por un signo de suma `+`.

El comando también sirve para configurar el reloj local, pero esto **solo** lo puede realizar el usuario `root` usando las flags `-s` o `--set`:

```bash
root@debian:~# date --set "2014-11-13 9:30:01"
root@debian:~# date -s "2014-11-13 9:30:01"
root@debian:~# date +%D
```

> **Advertencia:** En un sistema con sincronización horaria activa (`systemd-timesyncd`, `chrony` o `ntpd`), el cambio realizado con `date -s` será revertido en cuanto el servicio contacte con su servidor NTP. Para fijar la hora manualmente hay que desactivar primero la sincronización con `timedatectl set-ntp false`. Este asunto se trata en detalle en el documento 30.

A continuación, se muestra una lista de algunos especificadores útiles de formato para extraer fracciones específicas de fecha y hora (`date +%<letra>`):

- `%Y`: Año completo con siglo (ej.: 2025).
- `%m`: Mes numérico (01-12).
- `%d`: Día del mes numérico (01-31).
- `%H`: Hora en formato 24 horas (00-23).
- `%M`: Minutos (00-59).
- `%S`: Segundos (00-60).
- `%F`: Fecha estandarizada ISO 8601: `aaaa-mm-dd`.
- `%T`: Hora estandarizada: `HH:MM:SS`.

### 7.5 Comando uname

```bash
usuario@debian:~$ uname
Linux
usuario@debian:~$ uname -a
Linux debian 6.1.0-34-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.135-1 (2025-04-25) x86_64 GNU/Linux
usuario@debian:~$ uname -r
6.1.0-34-amd64
```

**Explicación**: El comando `uname` (*Unix Name*) muestra la información del propio núcleo (Kernel) en ejecución y sobre el sistema anfitrión. Con la opción `-a` (*all*) arroja todos los detalles como la arquitectura (`x86_64`), y con `-r` (*release*) devuelve concretamente la versión de compilación del núcleo de forma limpia.

> **Nota:** La información completa comercial sobre la distribución de Linux que tenemos instalada no suele figurar en `uname`. Para ello podemos inspeccionar ficheros como `cat /etc/debian_version` o `cat /etc/os-release`. Por otro lado, para confirmar rápidamente si el procesador es de 32 o 64 bits, podemos usar el comando de atajo `arch`.

---

## 8. Enlaces duros y simbólicos

```bash
usuario@debian:~$ cd /tmp
usuario@debian:/tmp$ echo "fichero test" > test
usuario@debian:/tmp$ ls test
test
usuario@debian:/tmp$ cat test
fichero test
```

A continuación creamos un **enlace duro** sobre ese fichero. Obsérvese que el enlace muestra exactamente el mismo contenido que el original:

```bash
usuario@debian:/tmp$ ln test enlace-duro-test
usuario@debian:/tmp$ ls test enlace-duro-test
enlace-duro-test  test
usuario@debian:/tmp$ cat enlace-duro-test
fichero test
```

**Explicación**: El comando `ln` (*Link*) sirve para crear enlaces en Linux. En Linux existen fundamentalmente dos tipos de enlaces con naturalezas muy distintas.

**1. Enlaces simbólicos (Soft links):**
La manera más sencilla de comprender qué es un enlace simbólico en Linux es compararlo con el "acceso directo" o *shortcut* habitual de Windows. El archivo de datos real se encuentra guardado en un único sector físico, y los enlaces son simplemente pequeños punteros o atajos que apuntan a esa ruta.
- Tienen su propio número de inodo.
- Pueden enlazar a directorios o a archivos que residan en otras particiones de disco o discos duros diferentes.
- Para crearlos, se utiliza el parámetro `-s`.

Creando un enlace simbólico partiendo de nuestro archivo anterior:

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

Observa que en la primera columna (*número de inodo*) el enlace simbólico tiene un número diferente, y en el nombre se nos indica visualmente el puntero: `enlace-simbolico-test -> test`.

> **Advertencia:** Es sumamente importante entender que si borramos el fichero origen, el enlace simbólico permanecerá existiendo como archivo, pero se convertirá en un enlace "roto" (quedará ciego y dará error de fichero no encontrado).

Procedemos a borrar el archivo `test` original para comprobarlo:

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

**2. Enlaces duros (Hard links):**
Los enlaces duros actúan asociando múltiples nombres de archivo al mismo número de inodo en el sistema de archivos físico. Un enlace duro no es un atajo, es una entrada equivalente; actúa como una copia espejo pero que no ocupa el doble de espacio. Esto implica que al alterar el contenido, permisos o metadatos de un enlace duro, los cambios se reflejan inmediatamente en el resto, ya que debajo son el mismo objeto. Borrar uno no borra los datos mientras sobreviva al menos una referencia dura.

Creamos nuevos archivos y enlaces para observarlo:

```bash
usuario@debian:/tmp$ rm enlace*
usuario@debian:/tmp$ echo "fichero test" > test.txt
usuario@debian:/tmp$ ln test.txt enlace-duro-test

usuario@debian:/tmp$ ls -li test.txt enlace-duro-test
2359319 -rw-r--r-- 2 usuario usuario 13 sep  5 07:51 enlace-duro-test
2359319 -rw-r--r-- 2 usuario usuario 13 sep  5 07:51 test.txt
```

En la primera columna de `ls -li` verificamos que ambos comparten exactamente el mismo inodo (`2359319`). La tercera columna marca un número `2`, confirmando cuántos enlaces duros apuntan actualmente a ese archivo de datos subyacente. Si cambiamos los permisos con `chmod`:

```bash
usuario@debian:/tmp$ chmod 755 test.txt
usuario@debian:/tmp$ ls -li test.txt enlace-duro-test
2359319 -rwxr-xr-x 2 usuario usuario 13 sep  5 07:51 enlace-duro-test
2359319 -rwxr-xr-x 2 usuario usuario 13 sep  5 07:51 test.txt
```

> **Nota:** Por seguridad del sistema de archivos, los enlaces duros no pueden realizarse contra directorios y tampoco pueden cruzar fronteras de sistemas de ficheros distintos (no puedes hacer un enlace duro desde un disco duro hacia un *pendrive* USB externo).

**Tabla resumen comparativa de enlaces:**

| Soft Link (Simbólico) | Hard Link (Duro) |
| --------------------- | ---------------- |
| Se pueden crear contra ficheros y directorios completos. | Solamente se permite enlazarlos contra ficheros. |
| Se pueden enlazar cruzando particiones o distintos sistemas de ficheros. | Estrictamente limitados a operar dentro del mismo disco o partición. |
| Poseen un número de inodo propio e independiente. | Comparten exactamente el mismo inodo. |
| Si borramos la información original, perdemos los datos y el enlace queda "roto". | Si borramos el archivo de origen "original", los datos siguen estando disponibles a través del enlace. |
| Actúan como simples punteros o accesos directos de ruta. | Actúan como un espejo en sincronización idéntico del fichero de origen. |

---

## 9. Cambio de usuario

**Explicación**: El comando `su` (*Substitute User* o *Switch User*) se utiliza para saltar temporalmente a la cuenta de otro usuario interactivo (generalmente `root`) aportando su contraseña, pero existen matices cruciales en su comportamiento según se acompañe o no del guion:

- **`su` (sin guion):** Cambia tus privilegios, pero **no** carga el entorno natural del nuevo usuario. Tu sesión heredará el entorno que tenías (variables como `$PATH`, alias, y lo más notorio: te quedarás en el mismo directorio de trabajo donde estabas posicionado).

```bash
usuario@debian:~$ echo $PWD
/home/usuario
usuario@debian:~$ su
Contraseña:
root@debian:/home/usuario# echo $PWD
/home/usuario
```

- **`su -` (con guion):** Simula un inicio de sesión completo y limpio (*login shell*). Carga todos los perfiles (`.profile`, `.bashrc`), renueva por completo el entorno y sitúa la sesión en el directorio personal del usuario destino, que en el caso de `root` es `/root` y no `/home`. Es la forma más predecible y recomendada de cambiar a `root` en administración de sistemas.

```bash
usuario@debian:~$ echo $PWD
/home/usuario
usuario@debian:~$ su -
Contraseña:
root@debian:~# echo $PWD
/root
```
