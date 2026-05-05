# Gestión de procesos

## Índice

1. [Concepto de Proceso](#1-concepto-de-proceso)
2. [Comando ps](#2-comando-ps)
3. [Comandos de monitoreo visual (pstree, top, vmstat)](#3-comandos-de-monitoreo-visual)
4. [Búsqueda de procesos (pgrep, pidof)](#4-búsqueda-de-procesos)
5. [Señales y comando kill](#5-señales-y-comando-kill)
6. [Prioridad de procesos (nice, renice)](#6-prioridad-de-procesos)
7. [Procesos en segundo plano (nohup, fg, bg, jobs)](#7-procesos-en-segundo-plano)
8. [Auditoría de archivos abiertos (lsof, fuser)](#8-auditoría-de-archivos-abiertos)
9. [Otros comandos (time)](#9-otros-comandos)

---

## 1. Concepto de Proceso

Un proceso representa un programa en curso de ejecución y, al mismo tiempo, todo su entorno de ejecución (memoria, estado, identificación, propietario, padre...).

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

### Estructura de la salida de ps

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
| **C** | Porcentaje de utilización del CPU. |
| **STIME** | Hora en la que se inició el proceso. |
| **TTY** | El terminal asociado con el proceso. |
| **TIME** | Tiempo total de CPU que el proceso ha consumido. |
| **CMD** | El comando que inició el proceso. |

### Sintaxis Estándar (POSIX)

| Opción | Descripción |
|--------|-------------|
| `-e` | Muestra los procesos de todo el sistema en cualquier terminal. |
| `-p` | Muestra un proceso específico según su PID. |
| `-ef` | Muestra todos los procesos del sistema con mayor nivel de detalle. |
| `-efH` | Muestra los procesos detallados y en forma de árbol jerárquico. |
| `-eo` | Permite especificar y formatear qué columnas de información queremos ver (ej. `pid,user,tty,command`). |
| `-u` | Muestra los procesos asociados al usuario especificado (o al actual si no se indica). |
| `--tty` o `-t` | Muestra los procesos asociados a una terminal concreta (ej. `pts/0`). |

### Sintaxis BSD

En sistemas derivados de BSD, las opciones se especifican sin guiones.

- `ps aux` o `ps -aux` muestra una lista detallada de todos los procesos en el sistema, mostrando CPU, MEM, etc.

---

## 3. Comandos de monitoreo visual

### Comando pstree

Muestra información de los procesos estructurada visualmente en forma de árbol.

```bash
usuario@debian:~$ pstree -u si | head
gdm-wayland-ses-+-gnome-session-b---2*[{gnome-session-b}]
                `-2*[{gdm-wayland-ses}]
...
```

### Comando top

Lista en tiempo real los procesos actualmente en ejecución, con columnas avanzadas que incluyen memoria virtual (`VIRT`), memoria residente (`RES`) y prioridad (`PR`).

```bash
root@debian:~# top
```

### Comando vmstat

Proporciona información sobre el rendimiento general del sistema, mostrando estadísticas relacionadas con la memoria, los procesos, la CPU y el uso de I/O (entrada/salida).

```bash
root@debian:~# vmstat
```

> **Recuerda:** En `vmstat`, la columna `swpd` te indica cuánta memoria SWAP estás usando, muy útil para detectar cuellos de botella por falta de RAM física.

---

## 4. Búsqueda de procesos

### Comando pgrep

Muestra los IDs de proceso (PID) de los procesos que coincidan con el nombre y parámetros pasados.

```bash
usuario@debian:~$ pgrep -u root,si sshd
735
1331
```

### Comando pidof

Muestra estrictamente los PIDs asociados con un nombre de programa específico.

```bash
usuario@debian:~$ pidof yes
3716
```

---

## 5. Señales y comando kill

En sistemas operativos basados en Unix, las señales son mecanismos de comunicación entre procesos y el kernel. 

Para listar todas las señales disponibles:

```bash
usuario@debian:~$ kill -l
```

### Señales principales

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

### Comandos kill y killall

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

## 6. Prioridad de procesos

### Comando nice

Lanza un proceso con una prioridad específica (valor `nice`). Por defecto es 0. El rango va de **-20 (máxima prioridad)** a **+19 (mínima prioridad)**. Solo `root` puede asignar prioridades negativas.

```bash
nice -n -5 comando
nice -n -5 yes
```

### Comando renice

Altera la prioridad de un proceso que **ya está en ejecución** en tiempo real.

```bash
root@debian:~# renice -10 981
981 (process ID) prioridad anterior -5, nueva prioridad -10
```

---

## 7. Procesos en segundo plano

### Comando nohup y el ampersand (&)

El símbolo `&` ejecuta un proceso en segundo plano (background), liberando la terminal. Sin embargo, si cierras la terminal, el proceso morirá porque su proceso padre desaparece.

El comando `nohup` (_no hang up_) permite ejecutar un proceso de tal forma que ignore la señal de cierre de terminal, permitiendo que siga vivo tras desloguearse.

```bash
root@debian:~# nohup yes > /dev/null &
```

### Comandos jobs, fg y bg

- **`jobs`**: Muestra una lista de los trabajos activos en la sesión actual del shell.
- **`fg`** (foreground): Trae un trabajo suspendido o en segundo plano al primer plano.
- **`bg`** (background): Retoma un trabajo suspendido y lo envía al segundo plano para que siga ejecutándose.

```bash
root@debian:~# jobs
[1]+  Detenido                sleep 100000
root@debian:~# bg 1
[1]+ sleep 100000 &
root@debian:~# jobs
[1]+  Ejecutando              sleep 100000 &
```

---

## 8. Auditoría de archivos abiertos

### Comando lsof

_List Open Files_. Determina qué procesos están utilizando qué archivos o puertos en el sistema.

| Opciones comunes | Descripción |
|------------------|-------------|
| `lsof /directorio` | Muestra qué proceso está bloqueando un directorio o punto de montaje. |
| `lsof -i` | Visualiza los puertos TCP/UDP activos. |
| `lsof -i TCP:22` | Busca procesos que usan un puerto específico (ej. puerto 22). |
| `lsof -u usuario` | Lista los archivos en uso por un usuario específico. |

### Comando fuser

Identifica los PIDs de los procesos que acceden a un archivo o socket, y permite forzar su parada (muy útil al desmontar unidades atascadas).

```bash
fuser -km /backup
```

> **Advertencia:** El modificador `-k` envía una señal `SIGKILL` a todos los procesos que estén usando la ruta indicada. Úsalo con extrema precaución.

---

## 9. Otros comandos

### Comando time

Permite medir cuánto tiempo de reloj (`real`), de CPU en espacio de usuario (`user`) y de CPU en el kernel (`sys`) tardó en ejecutarse un proceso.

```bash
root@debian:~# time sleep 10

real    0m10,012s
user    0m0,009s
sys     0m0,001s
```
