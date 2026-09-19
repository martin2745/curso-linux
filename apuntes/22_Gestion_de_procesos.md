# Gestión de procesos

## Índice

1. [Concepto de proceso](#1-concepto-de-proceso)
   1. [Estados de un proceso](#11-estados-de-un-proceso)
2. [Comando ps](#2-comando-ps)
   1. [Estructura de la salida de ps](#21-estructura-de-la-salida-de-ps)
   2. [Sintaxis estándar (POSIX)](#22-sintaxis-estándar-posix)
   3. [Sintaxis BSD](#23-sintaxis-bsd)
3. [Comandos de monitoreo visual (pstree, top, vmstat)](#3-comandos-de-monitoreo-visual-pstree-top-vmstat)
   1. [Comando pstree](#31-comando-pstree)
   2. [Comando top](#32-comando-top)
   3. [Comando vmstat](#33-comando-vmstat)
4. [Búsqueda de procesos (pgrep, pidof)](#4-búsqueda-de-procesos-pgrep-pidof)
   1. [Comando pgrep](#41-comando-pgrep)
   2. [Comando pidof](#42-comando-pidof)
5. [Señales y comando kill](#5-señales-y-comando-kill)
   1. [Señales principales](#51-señales-principales)
   2. [Comandos kill y killall](#52-comandos-kill-y-killall)
6. [Prioridad de procesos (nice, renice)](#6-prioridad-de-procesos-nice-renice)
   1. [Comando nice](#61-comando-nice)
   2. [Comando renice](#62-comando-renice)
7. [Procesos en segundo plano (nohup, fg, bg, jobs)](#7-procesos-en-segundo-plano-nohup-fg-bg-jobs)
   1. [Comando nohup y el ampersand (&)](#71-comando-nohup-y-el-ampersand-)
   2. [Comando disown](#72-comando-disown)
   3. [Comandos jobs, fg y bg](#73-comandos-jobs-fg-y-bg)
8. [Auditoría de archivos abiertos (lsof, fuser)](#8-auditoría-de-archivos-abiertos-lsof-fuser)
   1. [Comando lsof](#81-comando-lsof)
   2. [Comando fuser](#82-comando-fuser)
9. [Otros comandos (time)](#9-otros-comandos-time)
   1. [Comando time](#91-comando-time)

---

## 1. Concepto de proceso

Un proceso representa un programa en curso de ejecución y, al mismo tiempo, todo su entorno de ejecución (memoria, estado, identificación, propietario, padre...).

Todo proceso en Linux desciende de otro, formando un árbol cuya raíz es el proceso `1`, que en los sistemas actuales es `systemd`. Un proceso nuevo nace cuando su padre se duplica mediante la llamada al sistema `fork()` y acto seguido reemplaza su propio código por el del programa deseado con `exec()`.

| Atributo | Descripción |
|---|---|
| **PID** | Identificador numérico único del proceso. |
| **PPID** | PID del proceso padre. |
| **UID / GID** | Usuario y grupo efectivos bajo los que se ejecuta, y que determinan sus permisos. |
| **Nice** | Valor de cortesía que orienta al planificador sobre su prioridad. |
| **Estado** | Situación actual del proceso dentro del planificador. |

### 1.1 Estados de un proceso

La columna `STAT` de `ps aux` (o `S` en `ps -ef`) informa del estado, y su primera letra es la que importa:

| Código | Estado | Significado |
|---|---|---|
| `R` | *Running* | En ejecución o en la cola preparado para ejecutarse. |
| `S` | *Sleeping* | Dormido a la espera de un suceso, por ejemplo de que llegue algo por la red o de una pulsación de teclado. Es el estado de la inmensa mayoría de los procesos. |
| `D` | *Uninterruptible sleep* | Dormido esperando una operación de disco y **sin poder ser interrumpido**. Un proceso en este estado no responde ni siquiera a `SIGKILL`. |
| `T` | *Stopped* | Detenido, normalmente tras recibir `SIGSTOP` o pulsar `Ctrl + Z`. |
| `Z` | *Zombie* | Ha terminado, pero su padre aún no ha recogido su código de salida, de modo que su entrada permanece en la tabla de procesos. |

A estas letras se añaden modificadores: `<` indica prioridad alta, `N` prioridad baja, `s` que es líder de sesión, `l` que tiene varios hilos y `+` que está en primer plano.

> **Advertencia:** Un proceso en estado `Z` (zombi) **no puede matarse**, porque en realidad ya está muerto: lo único que queda de él es su entrada en la tabla de procesos, esperando a que el padre lea su código de salida. Enviarle `kill -9` no surte ningún efecto. La forma de eliminarlo es actuar sobre el **proceso padre**, ya sea enviándole `SIGCHLD` o terminándolo; al morir el padre, el zombi queda adoptado por `systemd`, que sí recoge su estado y libera la entrada. Unos pocos zombis son inofensivos, pero su acumulación indica un fallo de programación en el proceso padre.

> **Nota:** Tampoco puede matarse un proceso en estado `D`, aunque por un motivo distinto: está bloqueado dentro del núcleo esperando a un dispositivo que no responde. Verlo de forma persistente suele apuntar a un disco defectuoso o a un montaje de red caído, y la única salida habitual es resolver el problema del dispositivo o reiniciar la máquina.

---

## 2. Comando ps

El comando `ps` es el que permite informar sobre el estado de los procesos. `ps` está basado en el sistema de archivos `/proc`, es decir, lee directamente la información de los archivos que se encuentran en este directorio virtual.

```bash
usuario@debian:~$ ps
    PID TTY          TIME CMD
2708 pts/1    00:00:00 bash
3716 pts/1    00:03:34 yes
3734 pts/1    00:00:00 ps
```

> **Nota:** Diferencia entre `tty` y `pty`.
> Una **TTY (Teletype Terminal)** en Linux es una consola física o virtual que permite interactuar con el sistema sin necesidad de una interfaz gráfica. Se accede con Ctrl + Alt + F1 a F6 y es útil para tareas de administración y recuperación del sistema. 
> Por otro lado, una **PTY (Pseudo-Terminal)** es una emulación de terminal utilizada en aplicaciones dentro de un entorno gráfico (GNOME Terminal, xterm, conexiones SSH).

Para ver en qué **TTY** estás, usa el comando `tty`:

```bash
tty
```

- **`/dev/tty1`** → Si estás en una consola física.
- **`/dev/pts/0`** → Si estás en una terminal virtual (PTY).

### 2.1 Estructura de la salida de ps

```bash
root@debian:~# ps -ef
UID          PID    PPID  C STIME TTY          TIME CMD
root           1       0  0 16:19 ?        00:00:04 /sbin/init
root           2       0  0 16:19 ?        00:00:00 [kthreadd]
...
```

| Campo | Significado |
|-------|-------------|
| **UID** | El ID de usuario que ejecutó el proceso. |
| **PID** | El ID del proceso (Process ID). |
| **PPID** | El ID del proceso padre (Parent Process ID). |
| **C** | Factor entero de utilización de CPU que emplea el planificador. No es un porcentaje de uso instantáneo: para eso está la columna `%CPU` de `ps aux`. |
| **STIME** | Hora en la que se inició el proceso. |
| **TTY** | El terminal asociado con el proceso. |
| **TIME** | Tiempo total de CPU que el proceso ha consumido. |
| **CMD** | El comando que inició el proceso. |

### 2.2 Sintaxis estándar (POSIX)

| Opción | Descripción |
|--------|-------------|
| `-e` | Muestra los procesos de todo el sistema en cualquier terminal. |
| `-p` | Muestra un proceso específico según su PID. |
| `-ef` | Muestra todos los procesos del sistema con mayor nivel de detalle. |
| `-efH` | Muestra los procesos detallados y en forma de árbol jerárquico. |
| `-eo` | Permite especificar y formatear qué columnas de información queremos ver (ej. `pid,user,tty,command`). |
| `-u` | Muestra los procesos asociados al usuario especificado (o al actual si no se indica). |
| `--tty` o `-t` | Muestra los procesos asociados a una terminal concreta (ej. `pts/0`). |

### 2.3 Sintaxis BSD

En sistemas derivados de BSD, las opciones se especifican sin guiones.

- `ps aux` muestra una lista detallada de todos los procesos del sistema, con columnas de CPU, memoria, estado y comando completo.

| Opción BSD | Significado |
|---|---|
| `a` | Procesos de todos los usuarios, no solo los propios. |
| `u` | Formato orientado al usuario, con las columnas `%CPU`, `%MEM`, `VSZ`, `RSS` y `STAT`. |
| `x` | Incluye también los procesos sin terminal asociada, es decir, los demonios. |

> **Advertencia:** `ps aux` y `ps -aux` **no son lo mismo**, pese a lo que pueda parecer. Con el guion delante, `ps` aplica la sintaxis POSIX y lee `-a -u x`, donde `x` pasa a interpretarse como el **nombre de un usuario**. Si por casualidad existiera una cuenta llamada `x`, se mostrarían únicamente sus procesos. Como normalmente no existe, GNU `ps` deduce la intención y avisa:
>
> ```bash
> usuario@debian:~$ ps -aux
> Warning: bad syntax, perhaps a bogus '-'? See /usr/share/doc/procps-ng/FAQ
> ```
>
> El comando funciona, pero conviene escribir `ps aux` sin guion.

> **Recuerda:** Las dos columnas de memoria de `ps aux` responden a preguntas distintas. `VSZ` (*Virtual Size*) es todo el espacio de direcciones que el proceso tiene reservado, incluyendo lo que nunca llegará a usar y las bibliotecas compartidas; `RSS` (*Resident Set Size*) es la memoria física que ocupa realmente en RAM. Para saber cuánta memoria consume un proceso, la columna que interesa es `RSS`.

Una combinación muy socorrida consiste en ordenar los procesos por consumo:

```bash
usuario@debian:~$ ps aux --sort=-%mem | head -4
USER   PID %CPU %MEM    VSZ   RSS TTY  STAT START   TIME COMMAND
usuario 1832 1.2  8.4 3284512 340120 ?  Sl  09:12   1:04 /usr/bin/gnome-shell
usuario 2104 0.6  4.1 1128440 168332 ?  Sl  09:13   0:31 /usr/lib/firefox/firefox
root     681 0.0  1.2  212344  49216 ?  Ss  09:12   0:02 /usr/sbin/apache2
```

---

## 3. Comandos de monitoreo visual (pstree, top, vmstat)

### 3.1 Comando pstree

Muestra información de los procesos estructurada visualmente en forma de árbol.

```bash
usuario@debian:~$ pstree -u si | head
gdm-wayland-ses-+-gnome-session-b---2*[{gnome-session-b}]
                `-2*[{gdm-wayland-ses}]
...
```

### 3.2 Comando top

Lista en tiempo real los procesos actualmente en ejecución, con columnas avanzadas que incluyen memoria virtual (`VIRT`), memoria residente (`RES`) y prioridad (`PR`).

```bash
root@debian:~# top
```

### 3.3 Comando vmstat

Proporciona información sobre el rendimiento general del sistema, mostrando estadísticas relacionadas con la memoria, los procesos, la CPU y el uso de I/O (entrada/salida).

```bash
root@debian:~# vmstat
```

> **Recuerda:** En `vmstat`, la columna `swpd` te indica cuánta memoria SWAP estás usando, muy útil para detectar cuellos de botella por falta de RAM física.

---

## 4. Búsqueda de procesos (pgrep, pidof)

### 4.1 Comando pgrep

Muestra los IDs de proceso (PID) de los procesos que coincidan con el nombre y parámetros pasados.

```bash
usuario@debian:~$ pgrep -u root,si sshd
735
1331
```

### 4.2 Comando pidof

Muestra estrictamente los PIDs asociados con un nombre de programa específico.

```bash
usuario@debian:~$ pidof yes
3716
```

| Parámetro | Comando | Descripción |
|---|---|---|
| `-u USUARIO` | `pgrep` | Limita la búsqueda a los procesos de uno o varios usuarios. |
| `-l` | `pgrep` | Muestra también el nombre del proceso junto al PID. |
| `-a` | `pgrep` | Muestra la línea de órdenes completa. |
| `-f` | `pgrep` | Busca el patrón en la línea de órdenes entera y no solo en el nombre del ejecutable. |
| `-x` | `pgrep` | Exige coincidencia exacta del nombre. |
| `-c` | `pgrep` | Devuelve únicamente el número de coincidencias. |

> **Importante:** Sin `-x`, `pgrep` busca **subcadenas**. Un `pgrep ssh` devuelve también los PID de `sshd`, y un `pkill ssh` mataría el servidor SSH junto con los clientes. Conviene comprobar siempre con `pgrep -a` antes de ejecutar el `pkill` correspondiente.

> **Nota:** `pkill` es el equivalente de `pgrep` para enviar señales, y acepta los mismos criterios de búsqueda. Así, `pkill -u usuario -f "python servidor.py"` termina exactamente ese proceso de ese usuario. La diferencia con `killall` es que este último exige el nombre exacto del ejecutable.

---

## 5. Señales y comando kill

En sistemas operativos basados en Unix, las señales son mecanismos de comunicación entre procesos y el kernel. 

Para listar todas las señales disponibles:

```bash
usuario@debian:~$ kill -l
```

### 5.1 Señales principales

| Señal | Número | Función |
|-------|--------|---------|
| **SIGHUP** | 1 | Hangup, recarga configuración en algunos demonios/procesos. |
| **SIGINT** | 2 | Interrupción del usuario (equivalente a presionar `Ctrl + C`). Permite limpieza. |
| **SIGKILL** | 9 | Mata un proceso de forma forzada e inmediata. No puede ser interceptada ni ignorada. |
| **SIGTERM** | 15 | Terminación elegante de proceso (por defecto al usar `kill`). Permite limpieza. |
| **SIGSTOP** | 19 | Detiene (pausa) un proceso forzosamente. |
| **SIGTSTP** | 20 | Detiene un proceso desde la terminal (`Ctrl + Z`). |
| **SIGCONT** | 18 | Continúa un proceso previamente detenido con STOP o TSTP. |

> **Importante:** Usa **SIGTERM (15)** por defecto para cerrar procesos. Recurre a **SIGKILL (9)** únicamente cuando un proceso esté totalmente colgado, ya que puede dejar bases de datos o archivos en estados inconsistentes.

### 5.2 Comandos kill y killall

El comando `kill` envía señales a procesos mediante su `PID`, mientras que `killall` envía señales a todos los procesos que coincidan con un **nombre**.

Ejemplos con `kill`:
```bash
kill -9 5678                   # Fuerza el cierre (SIGKILL)
kill -15 $(pidof yes)          # Cierre ordenado (SIGTERM)
kill -18 7890                  # Reanuda proceso pausado (SIGCONT)
```

Ejemplos con `killall`:
```bash
killall yes                    # Termina (SIGTERM) todos los procesos llamados 'yes'
killall -s INT yes             # Envía SIGINT a todos los 'yes'
```

---

## 6. Prioridad de procesos (nice, renice)

### 6.1 Comando nice

Lanza un proceso con una prioridad específica (valor `nice`). Por defecto es 0. El rango va de **-20 (máxima prioridad)** a **+19 (mínima prioridad)**. Solo `root` puede asignar prioridades negativas.

```bash
nice -n -5 comando
nice -n -5 yes
```

> **Advertencia:** El valor `nice` funciona al revés de lo que sugiere la intuición: cuanto **más alto** es el número, **menos** prioridad recibe el proceso, porque es "más amable" y cede la CPU a los demás. Un `nice` de -20 es la máxima prioridad y +19 la mínima.

> **Importante:** Un usuario sin privilegios solo puede **bajar** la prioridad de sus procesos, es decir, aumentar el valor `nice`. La operación es además irreversible para él: una vez subido a +10, no puede volver a bajarlo, y el intento falla con `renice: fallo al establecer prioridad: Permiso denegado`. Solo `root` puede asignar valores negativos o reducir uno ya asignado.

Para consultar la prioridad de los procesos en marcha se emplea una salida con formato:

```bash
usuario@debian:~$ ps -eo pid,ni,comm --sort=ni | head -4
    PID  NI COMMAND
    981 -10 yes
      1   0 systemd
   1832   0 gnome-shell
```

### 6.2 Comando renice

Altera la prioridad de un proceso que **ya está en ejecución** en tiempo real.

```bash
root@debian:~# renice -n -10 -p 981
981 (process ID) prioridad anterior -5, nueva prioridad -10
```

> **Nota:** La forma antigua `renice -10 981`, sin `-n` ni `-p`, sigue aceptándose por compatibilidad, pero resulta ambigua de leer y está desaconsejada. `renice` admite además actuar sobre todos los procesos de un usuario con `-u` o de un grupo con `-g`.

---

## 7. Procesos en segundo plano (nohup, fg, bg, jobs)

### 7.1 Comando nohup y el ampersand (&)

El símbolo `&` ejecuta un proceso en segundo plano (*background*), liberando la terminal. Sin embargo, al cerrar la terminal el proceso suele morir.

> **Importante:** El motivo no es que desaparezca su proceso padre. Cuando un padre muere, sus hijos no mueren con él: quedan **huérfanos** y `systemd` los adopta, de modo que siguen ejecutándose con normalidad. Lo que realmente los mata es que, al cerrarse la terminal de control, el núcleo envía la señal **`SIGHUP`** a todos los procesos de esa sesión, y el comportamiento por defecto ante `SIGHUP` es terminar.
>
> Entender esta diferencia importa porque explica por qué la solución consiste precisamente en **ignorar esa señal**, y no en cambiar de padre.

El comando `nohup` (_no hang up_) lanza el proceso con `SIGHUP` ignorada, de modo que sobrevive al cierre de la terminal:

```bash
root@debian:~# nohup yes > /dev/null &
```

> **Nota:** Si no se redirige la salida, `nohup` la desvía automáticamente a un fichero `nohup.out` en el directorio actual y lo advierte por pantalla con `nohup: se descarta la entrada y se anexa la salida a 'nohup.out'`. Es necesario porque el proceso ya no tendrá terminal donde escribir.

### 7.2 Comando disown

`nohup` hay que decidirlo **antes** de lanzar el proceso. Si el comando ya está en marcha y nos damos cuenta tarde, la solución es `disown`, que retira el trabajo de la tabla de la shell para que esta no le envíe `SIGHUP` al cerrarse:

```bash
root@debian:~# yes > /dev/null &
[1] 4127
root@debian:~# disown -h %1
```

| Parámetro | Descripción |
|---|---|
| `disown %N` | Elimina el trabajo `N` de la lista de la shell. Deja de aparecer en `jobs`. |
| `disown -h %N` | Lo mantiene en la lista pero lo marca para que no reciba `SIGHUP`. |
| `disown -a` | Aplica la operación a todos los trabajos. |

> **Recuerda:** Para tareas largas en servidores remotos, la solución más cómoda no es `nohup` ni `disown`, sino un multiplexor de terminal como `tmux` o `screen`, que permite además **volver a conectarse** a la sesión y ver cómo va el proceso. El documento 39 trata `tmux`.

### 7.3 Comandos jobs, fg y bg

- **`jobs`**: Muestra una lista de los trabajos activos en la sesión actual del shell. Con `-l` añade el PID de cada uno.
- **`fg`** (*foreground*): Trae un trabajo suspendido o en segundo plano al primer plano.
- **`bg`** (*background*): Retoma un trabajo suspendido y lo envía al segundo plano para que siga ejecutándose.

El flujo habitual empieza con `Ctrl + Z`, que envía `SIGTSTP` al proceso en primer plano y lo deja detenido:

| Acción | Orden |
|---|---|
| Detener el proceso en primer plano | `Ctrl + Z` |
| Reanudarlo en segundo plano | `bg %1` |
| Traerlo de vuelta al primer plano | `fg %1` |
| Terminarlo | `kill %1` |

> **Nota:** Los trabajos se referencian con `%` y su número, que **no es el PID** sino un contador propio de esa shell. Además, `%%` o `%+` designan el trabajo actual y `%-` el anterior. Para conocer el PID real hay que consultar `jobs -l`.

> **Advertencia:** La lista de trabajos pertenece a cada shell por separado. Un proceso lanzado con `&` desde una terminal no aparece en el `jobs` de otra, aunque ambas sean del mismo usuario. Para verlo desde cualquier sitio hay que recurrir a `ps` o `pgrep`.

```bash
root@debian:~# jobs
[1]+  Detenido                sleep 100000
root@debian:~# bg 1
[1]+ sleep 100000 &
root@debian:~# jobs
[1]+  Ejecutando              sleep 100000 &
```

---

## 8. Auditoría de archivos abiertos (lsof, fuser)

### 8.1 Comando lsof

_List Open Files_. Determina qué procesos están utilizando qué archivos o puertos en el sistema.

| Opciones comunes | Descripción |
|------------------|-------------|
| `lsof /directorio` | Muestra qué proceso está bloqueando un directorio o punto de montaje. |
| `lsof -i` | Visualiza los puertos TCP/UDP activos. |
| `lsof -i TCP:22` | Busca procesos que usan un puerto específico (ej. puerto 22). |
| `lsof -u usuario` | Lista los archivos en uso por un usuario específico. |

### 8.2 Comando fuser

Identifica los PIDs de los procesos que acceden a un archivo o socket, y permite forzar su parada (muy útil al desmontar unidades atascadas).

```bash
fuser -km /backup
```

> **Advertencia:** El modificador `-k` envía una señal `SIGKILL` a todos los procesos que estén usando la ruta indicada. Úsalo con extrema precaución.

---

## 9. Otros comandos (time)

### 9.1 Comando time

Permite medir cuánto tiempo de reloj (`real`), de CPU en espacio de usuario (`user`) y de CPU en el kernel (`sys`) tardó en ejecutarse un proceso.

```bash
root@debian:~# time sleep 10

real    0m10,012s
user    0m0,009s
sys     0m0,001s
```
