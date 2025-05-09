# Gestión de procesos

Un proceso representa un programa en curso de ejecución y, al mismo tiempo, todo su entorno de ejecución
(memoria, estado, identificación, propietario, padre...).

## Comando ps
El comando *ps* es el que permite informar sobre el estado de los procesos. ps esta basado en el sistema de archivos /proc, es decir, lee directamente la información de los archivos que se encuentran en este directorio


```bash
si@si-VirtualBox:~$ ps
    PID TTY          TIME CMD
2708 pts/1    00:00:00 bash
3716 pts/1    00:03:34 yes
3734 pts/1    00:00:00 ps
```

_*Nota*_: Diferencia entre `tty` y `pty`.
Una TTY (Teletype Terminal) en Linux es una consola física o virtual que permite interactuar con el sistema sin necesidad de una interfaz gráfica. Se accede con Ctrl + Alt + F1 a F6 y es útil para tareas de administración, recuperación del sistema y trabajo en entornos sin GUI. Por otro lado, una PTY (Pseudo-Terminal) es una emulación de terminal utilizada en aplicaciones dentro de un entorno gráfico, como GNOME Terminal, xterm o conexiones SSH, permitiendo múltiples sesiones sin depender de una TTY física. En resumen, la TTY es una terminal real del sistema, mientras que la PTY es una terminal virtual utilizada en entornos gráficos o remotos.

Para ver en qué **TTY** estás en Linux, usa el siguiente comando en la terminal:  

```bash
tty
```

🔹 Esto mostrará una salida como:  
- **`/dev/tty1`** → Si estás en una consola física (Ctrl + Alt + F1-F6).  
- **`/dev/pts/0`** → Si estás en una terminal virtual dentro de un entorno gráfico (PTY).  

Si necesitas cambiar entre **TTYs**, usa **Ctrl + Alt + F1-F6** (en algunas distros modernas, el entorno gráfico puede estar en F2 o F7).

La salida que muestras es el formato típico de la información obtenida a través del comando ps en sistemas Unix o Linux. A continuación, te explico lo que significa cada campo.
```bash
root@debian:~# ps -ef
UID          PID    PPID  C STIME TTY          TIME CMD
root           1       0  0 16:19 ?        00:00:04 /sbin/init
root           2       0  0 16:19 ?        00:00:00 [kthreadd]
root           3       2  0 16:19 ?        00:00:00 [rcu_gp]
root           4       2  0 16:19 ?        00:00:00 [rcu_par_gp]
root           5       2  0 16:19 ?        00:00:00 [slub_flushwq]
root           6       2  0 16:19 ?        00:00:00 [netns]
root           8       2  0 16:19 ?        00:00:00 [kworker/0:0H-events_highpri]
root          10       2  0 16:19 ?        00:00:00 [mm_percpu_wq]
root          11       2  0 16:19 ?        00:00:00 [rcu_tasks_kthread]
...
```

Aquí podemos ver lo siguiente:
- **UID**: El ID de usuario que ejecutó el proceso.
- **PID**: El ID del proceso (Process ID).
- **PPID**: El ID del proceso padre (Parent Process ID), que indica qué proceso inició el proceso actual.
- **C**: Porcentaje de utilización del CPU (en un valor relativo).
- **STIME**: Hora en la que se inició el proceso.
- **TTY**: El terminal asociado con el proceso.
- **TIME**: Tiempo total de CPU que el proceso ha consumido.
- **CMD**: El comando que inició el proceso.

1. **Sintaxis Estándar**: Esta es una convención comúnmente utilizada en sistemas que siguen las especificaciones de POSIX (Portable Operating System Interface), como la mayoría de las distribuciones de Linux.

`ps -e` muestra los procesos de todo el sistema en cualquier terminal. La información que obtenemos por pantalla es la misma que con `ps` pero para todas las terminales, ya que por si solo, `ps` muestra los procesos de la terminal actual.

```bash
si@si-VirtualBox:~$ ps -e
    PID TTY          TIME CMD
        1 ?        00:00:02 systemd
        2 ?        00:00:00 kthreadd
        3 ?        00:00:00 rcu_gp
        4 ?        00:00:00 rcu_par_gp
        5 ?        00:00:00 slub_flushwq
        6 ?        00:00:00 netns
        8 ?        00:00:00 kworker/0:0H-events_highpri
        9 ?        00:00:01 kworker/0:1-events
```

`ps -p` muestra el proceso según su pid.

```bash
si@si-VirtualBox:~$ ps -p `pidof bash`
    PID TTY          TIME CMD
    1457 pts/1    00:00:00 bash

```

`ps -ef` muestra todos los procesos del sistema con mayor nivel de detalle que `ps -e`.

```bash
si@si-VirtualBox:~$ ps -ef
UID          PID    PPID  C STIME TTY          TIME CMD
root           1       0  0 16:07 ?        00:00:02 /sbin/init splash
root           2       0  0 16:07 ?        00:00:00 [kthreadd]
root           3       2  0 16:07 ?        00:00:00 [rcu_gp]
root           4       2  0 16:07 ?        00:00:00 [rcu_par_gp]
root           5       2  0 16:07 ?        00:00:00 [slub_flushwq]
root           6       2  0 16:07 ?        00:00:00 [netns]
root           8       2  0 16:07 ?        00:00:00 [kworker/0:0H-events_highpri]
root           9       2  0 16:07 ?        00:00:01 [kworker/0:1-events]
root          11       2  0 16:07 ?        00:00:00 [mm_percpu_wq]
root          12       2  0 16:07 ?        00:00:00 [rcu_tasks_kthread]
```

`ps -efH` muestra todos los procesos del sistema con mayor nivel de detalle que `ps -e` y en forma de arbol.

```bash
si@si-VirtualBox:~$ ps -efH
UID          PID    PPID  C STIME TTY          TIME CMD
root           2       0  0 16:07 ?        00:00:00 [kthreadd]
root           3       2  0 16:07 ?        00:00:00   [rcu_gp]
root           4       2  0 16:07 ?        00:00:00   [rcu_par_gp]
root           5       2  0 16:07 ?        00:00:00   [slub_flushwq]
root           6       2  0 16:07 ?        00:00:00   [netns]
root           8       2  0 16:07 ?        00:00:00   [kworker/0:0H-events_highpri]
root           9       2  0 16:07 ?        00:00:01   [kworker/0:1-events]
root          11       2  0 16:07 ?        00:00:00   [mm_percpu_wq]
root          12       2  0 16:07 ?        00:00:00   [rcu_tasks_kthread]
```

`ps -eo` muestra la información de los procesos que se especifique por el usuario.
```bash
root@debian:~# ps -eo pid,user,tty,command 
    PID USER     TT       COMMAND
      1 root     ?        /sbin/init
      2 root     ?        [kthreadd]
      3 root     ?        [rcu_gp]
      4 root     ?        [rcu_par_gp]
      5 root     ?        [slub_flushwq]
      6 root     ?        [netns]
      8 root     ?        [kworker/0:0H-events_highpri]
     10 root     ?        [mm_percpu_wq]
     11 root     ?        [rcu_tasks_kthread]
...
```

`ps -u` muestra los procesos asociados al usuario que ejecuta el comando.

```bash
si@si-VirtualBox:~$ ps -u
    PID TTY          TIME CMD
   1457 pts/1    00:00:00 bash
   1832 pts/1    00:00:00 ps
```

`ps -u usuario1,usuario2` muestra los procesos que están ejecutando los usuarios especificados.

```bash
si@si-VirtualBox:~$ ps -u si,root
    PID TTY          TIME CMD
   1457 pts/1    00:00:00 bash
   1832 pts/1    00:00:00 ps
      1 ?        00:00:02 systemd
      2 ?        00:00:00 kthreadd
      3 ?        00:00:00 rcu_gp
```

`ps -aux` muestra todos los procesos en ejecución en el sistema con detalles adicionales, incluyendo información sobre el usuario propietario, el uso de CPU y memoria, el tiempo de ejecución y el comando asociado.

```bash
si@si-VirtualBox:~$ ps -aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.3 167892  9420 ?        Ss   16:07   0:02 /sbin/init splash
root         2  0.0  0.0      0     0 ?        S    16:07   0:00 [kthreadd]
root         3  0.0  0.0      0     0 ?        I    16:07   0:00 [rcu_gp]
root         4  0.0  0.0      0     0 ?        I    16:07   0:00 [rcu_par_gp]
```

`ps --tty pts/0` muestra los procesos asociados a la terminal `pts/0`.

```bash
si@si-VirtualBox:~$ ps --tty pts/0
    PID TTY          TIME CMD
   1501 pts/0    00:00:00 bash
   1532 pts/0    00:00:00 vim
```

`ps -t pts/0` es otra forma de mostrar los procesos que están siendo ejecutados en la terminal `pts/0`.

```bash
si@si-VirtualBox:~$ ps -t pts/0
    PID TTY          TIME CMD
   1501 pts/0    00:00:00 bash
   1532 pts/0    00:00:00 vim
```

Ambos comandos (`ps --tty pts/0` y `ps -t pts/0`) son equivalentes y se utilizan para ver qué procesos están activos en una terminal específica.

1. **Sintaxis BSD**: Esta es una convención utilizada principalmente en sistemas derivados de BSD (Berkeley Software Distribution), como FreeBSD, OpenBSD y macOS. En la sintaxis BSD, las opciones del comando `ps` se especifican sin guiones y pueden estar combinadas.

`ps aux` o `ps -aux` muestra una lista detallada de todos los procesos en el sistema.

```bash
si@si-VirtualBox:~$ ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.2  0.3 168064 13252 ?        Ss   16:07   0:02 /sbin/init splash
root           2  0.0  0.0      0     0 ?        S    16:07   0:00 [kthreadd]
root           3  0.0  0.0      0     0 ?        I<   16:07   0:00 [rcu_gp]
root           4  0.0  0.0      0     0 ?        I<   16:07   0:00 [rcu_par_gp]
root           5  0.0  0.0      0     0 ?        I<   16:07   0:00 [slub_flushwq]
root           6  0.0  0.0      0     0 ?        I<   16:07   0:00 [netns]
root           8  0.0  0.0      0     0 ?        I<   16:07   0:00 [kworker/0:0H-events_highpri]
root           9  0.1  0.0      0     0 ?        I    16:07   0:01 [kworker/0:1-events]
root          11  0.0  0.0      0     0 ?        I<   16:07   0:00 [mm_percpu_wq]
root          12  0.0  0.0      0     0 ?        I    16:07   0:00 [rcu_tasks_kthread]
```

## Comando pstree

*pstree*: Muestra información de los procesos en forma de arbol

```bash
si@si-VirtualBox:~$ pstree -u si | head
gdm-wayland-ses-+-gnome-session-b---2*[{gnome-session-b}]
                `-2*[{gdm-wayland-ses}]

gnome-keyring-d---3*[{gnome-keyring-d}]

sshd---bash-+-head
            |-pstree
            `-yes

systemd-+-(sd-pam)
```

## Comando pgrep

*pgrep*: Muestra los IDs de proceso (PID) de los procesos sshd que están siendo ejecutados por los usuarios root y si.

```bash
si@si-VirtualBox:~$ pgrep -u root,si sshd
735
1331
2707
```

## Comando pidof

*pidof*: Muestra los IDs de proceso (PID) asociados con un programa específico.

```bash
si@si-VirtualBox:~$ pidof yes
3716
```

Tambien existen otros comando como `top`, `htop` y `uptime` que muestran información del sistema relativa a los procesos que se están ejecutando.

## Señales

En sistemas operativos basados en Unix, incluyendo Linux, las señales son mecanismos de comunicación entre procesos y entre el kernel y los procesos. Estas señales se utilizan para notificar a un proceso de eventos importantes, solicitar la terminación de un proceso, manejar errores, y para una variedad de otras funciones.

```bash
si@si-VirtualBox:~$ kill -l
 1) SIGHUP       2) SIGINT       3) SIGQUIT      4) SIGILL       5) SIGTRAP
 6) SIGABRT      7) SIGBUS       8) SIGFPE       9) SIGKILL     10) SIGUSR1
11) SIGSEGV     12) SIGUSR2     13) SIGPIPE     14) SIGALRM     15) SIGTERM
16) SIGSTKFLT   17) SIGCHLD     18) SIGCONT     19) SIGSTOP     20) SIGTSTP
21) SIGTTIN     22) SIGTTOU     23) SIGURG      24) SIGXCPU     25) SIGXFSZ
26) SIGVTALRM   27) SIGPROF     28) SIGWINCH    29) SIGIO       30) SIGPWR
31) SIGSYS      34) SIGRTMIN    35) SIGRTMIN+1  36) SIGRTMIN+2  37) SIGRTMIN+3
38) SIGRTMIN+4  39) SIGRTMIN+5  40) SIGRTMIN+6  41) SIGRTMIN+7  42) SIGRTMIN+8
43) SIGRTMIN+9  44) SIGRTMIN+10 45) SIGRTMIN+11 46) SIGRTMIN+12 47) SIGRTMIN+13
48) SIGRTMIN+14 49) SIGRTMIN+15 50) SIGRTMAX-14 51) SIGRTMAX-13 52) SIGRTMAX-12
53) SIGRTMAX-11 54) SIGRTMAX-10 55) SIGRTMAX-9  56) SIGRTMAX-8  57) SIGRTMAX-7
58) SIGRTMAX-6  59) SIGRTMAX-5  60) SIGRTMAX-4  61) SIGRTMAX-3  62) SIGRTMAX-2
63) SIGRTMAX-1  64) SIGRTMAX
```

 1)  SIGHUP       - Hangup, recarga configuración en algunos procesos.
 2)  SIGINT       - Interrupción del usuario (Ctrl + C).
 3)  SIGQUIT      - Termina un proceso y genera un core dump.
 4)  SIGILL       - Instrucción ilegal.
 5)  SIGTRAP      - Punto de interrupción o trampa.
 6)  SIGABRT      - Abortado, generado por abort().
 7)  SIGBUS       - Error de acceso a memoria.
 8)  SIGFPE       - Error de punto flotante (división por cero, etc.).
 9)  SIGKILL      - Mata un proceso inmediatamente (no se puede ignorar o manejar).
10)  SIGUSR1      - Señal de usuario 1, definida por la aplicación.
11)  SIGSEGV      - Error de segmentación (acceso inválido a memoria).
12)  SIGUSR2      - Señal de usuario 2, definida por la aplicación.
13)  SIGPIPE      - Intento de escribir en una tubería sin lector.
14)  SIGALRM      - Señal de alarma, generada por alarm().
15)  SIGTERM      - Terminación de proceso de manera elegante.
16)  SIGSTKFLT    - Falla en la pila, rara vez usada.
17)  SIGCHLD      - Proceso hijo terminó.
18)  SIGCONT      - Continúa un proceso detenido.
19)  SIGSTOP      - Detiene un proceso sin posibilidad de ser ignorado.
20)  SIGTSTP      - Detiene un proceso desde terminal (Ctrl + Z).
21)  SIGTTIN      - Proceso en segundo plano intenta leer de la terminal.
22)  SIGTTOU      - Proceso en segundo plano intenta escribir en la terminal.
23)  SIGURG       - Datos urgentes en un socket.
24)  SIGXCPU      - Límite de tiempo de CPU excedido.
25)  SIGXFSZ      - Límite de tamaño de archivo excedido.
26)  SIGVTALRM    - Alarma de tiempo virtual.
27)  SIGPROF      - Señal de profiling.
28)  SIGWINCH     - Cambio de tamaño de la ventana del terminal.
29)  SIGIO        - Entrada/salida asíncrona disponible.
30)  SIGPWR       - Advertencia de fallo de energía.
31)  SIGSYS       - Llamada de sistema inválida.

Señales en tiempo real (usadas por el kernel y aplicaciones específicas):
34)  SIGRTMIN     - Señal en tiempo real mínima.
35-50) SIGRTMIN+X - Variaciones de SIGRTMIN.
50-64) SIGRTMAX-X - Variaciones de SIGRTMAX.
64)  SIGRTMAX     - Señal en tiempo real máxima.

Notas:
- SIGKILL (9) y SIGSTOP (19) no pueden ser ignoradas ni manejadas.
- SIGTERM (15) es la forma recomendada de terminar procesos, excepto si están bloqueados.

Estas señales son parte del mecanismo de gestión de señales en Linux y se utilizan para diversos propósitos, desde el control de procesos hasta la notificación de eventos importantes.

El comando `kill` en Linux se utiliza para enviar señales a procesos en ejecución, mientras que `killall` se usa para enviar señales a todos los procesos que coincidan con un nombre determinado. Aquí tienes ejemplos de cómo usar estos comandos con las señales mencionadas:

1. **SIGINT (2)**:

- La señal SIGINT (2) se emplea cuando deseas dar al proceso una oportunidad para terminar de forma ordenada, como cuando presionas `Ctrl+C` en la consola. Con esta señal los procesos pueden interceptar y gestionar la señal para realizar tareas de limpieza antes de finalizar.

```bash
kill -2 1234
kill -INT $(pidof yes)
kill -s INT $(pidof yes)
```

2. **SIGKILL (9)**:

- La señal SIGKILL (9) se emplea cuando un proceso está atascado y no responde y necesitas asegurarte de que termine de inmediato. Con esta señal los procesos no pueden interceptarla, gestionarla ni ignorarla. Puede causar que los procesos padres o relacionados queden en un estado inconsistente si no se gestionan adecuadamente los recursos y la sincronización entre procesos.

```bash
kill -9 5678
kill -KILL $(pidof yes)
kill -s KILL $(pidof yes)
```

3. **SIGCONT (18)**:

- Indica al sistema operativo que continúe la ejecución de un proceso que previamente ha sido detenido (por ejemplo, con SIGSTOP).

```bash
kill -18 7890
kill -CONT $(pidof yes)
kill -s CONT $(pidof yes)
```

4. **SIGSTOP (19)**:

- La señal SIGSTOP (19) es una señal de parada no atrapable ni ignorada, que detiene el proceso de forma inmediata y no puede ser gestionada por el proceso, garantizando así que el proceso se detenga inmediatamente.

```bash
kill -19 2345
kill -STOP $(pidof yes)
kill -s STOP $(pidof yes)
```

5. **SIGTSTP (20)**:

- La señal SIGTSTP (20) es una señal de parada que puede ser atrapada y gestionada por el proceso. Comúnmente se genera cuando se presiona `Ctrl+Z` en la consola, suspendiendo el proceso en primer plano y devolviendo el control a la consola. Esta suspensión es temporal y el proceso puede ser reanudado posteriormente con el comando fg (foreground) o bg (background).

```bash
kill -20 3456
kill -TSTP $(pidof yes)
kill -s TSTP $(pidof yes)
```

Todo lo mencionado sobre señales se puede ralizar tanto con `kill` como con `killall`.

```bash
si@si-VirtualBox:~$ ps
    PID TTY          TIME CMD
    2708 pts/1    00:00:00 bash
    13649 pts/1    00:00:00 ps
si@si-VirtualBox:~$ yes >/dev/null &
[1] 13650
si@si-VirtualBox:~$ ps
    PID TTY          TIME CMD
    2708 pts/1    00:00:00 bash
    13650 pts/1    00:00:00 yes
    13651 pts/1    00:00:00 ps
si@si-VirtualBox:~$ killall yes
[1]+  Terminated              yes > /dev/null
si@si-VirtualBox:~$ ps
    PID TTY          TIME CMD
    2708 pts/1    00:00:00 bash
    13653 pts/1    00:00:00 ps
si@si-VirtualBox:~$ yes >/dev/null &
[1] 13654
si@si-VirtualBox:~$ killall -s INT yes
[1]+  Interrupt               yes > /dev/null
si@si-VirtualBox:~$ ps
    PID TTY          TIME CMD
    2708 pts/1    00:00:00 bash
    13656 pts/1    00:00:00 ps
```

## Comando nice

Lanza un proceso con una prioridad. Por defecto, todos los procesos tienen una prioridad igual ante el CPU que es de 0. Prioridad -20 siendo los negativos establecidos por root y los de mayor prioridad, hasta +19 como priridad establecida para un proceso, las prioridades positivas las puede establecer cualquier usuario.

```bash
nice -n -5 comando
nice -n -5 yes
```

## Comando renice
Asi como *nice* establece la prioridad de un proceso cuando se incia su ejecución, *renice*, permite alterarla en tiempo real, sin necesidad de detener el proceso.

```bash
root@debian:~# yes > /dev/null &
[1] 956
root@debian:~# ps -el | grep yes
F S   UID     PID    PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
0 R     0     956     951 97  80   0 -  2000 -      pts/1    00:00:01 yes
...


root@debian:~# nice -n -5 yes > /dev/null &
root@debian:~# ps -el | grep yes
F S   UID     PID    PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
4 R     0     981     951 99  75  -5 -  2000 -      pts/1    00:00:03 yes
```

## Comando renice

El comando *renice* sirve para que durante la ejecución de un proceso ya iniciado se modifice la prioridad (nice) de uno o varios procesos que ya están en ejecución y permitirle competir por más o menos CPU.

```bash
root@debian:~# renice -10 981
981 (process ID) prioridad anterior -5, nueva prioridad -10
root@debian:~# ps -el | grep yes
F S   UID     PID    PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
4 R     0     981     951 99  70 -10 -  2000 -      pts/1    00:01:44 yes
```

## Comando nohup

Asi se evita que el proceso se "cuelgue" al cerrar la consola, es decir, matar el proceso padre. El comando *nohup* (abreviatura de "no hang up") en sistemas basados en Unix y Linux permite ejecutar un comando o proceso de tal forma que no se detenga, incluso si cierras la sesión o el terminal desde el cual fue iniciado. Es especialmente útil cuando quieres ejecutar tareas de larga duración en segundo plano sin que se interrumpan si pierdes la conexión o cierras la terminal.

El símbolo & en Linux y sistemas Unix se utiliza para ejecutar un comando o proceso en segundo plano. Esto significa que el comando se ejecutará de manera independiente y no bloqueará la terminal o sesión actual, permitiéndote seguir usando la terminal para otras tareas mientras el proceso continúa ejecutándose.

```bash
root@debian:~# nohup yes > /dev/null &
```

Cierro la terminal y vuelvo a iniciar sesión:

```bash
root@debian:~# ps -el | grep yes
0 R     0    1008       1 99  80   0 -  2000 -      ?        00:02:04 yes
```

## Comandos fg y bg

Los comandos *bg* y *fg* permiten actuar en estos *jobs* tomando como parámetro su número. Se ejecuta el comando *bg* en un job parado para iniciarlo de nuevo en segundo plano jobs *fg* (foreground) y *bg* background. 
- **jobs**: Muestra una lista de los trabajos activos en la sesión actual del shell.
- **fg**: Trae un trabajo suspendido/segundo plano al primer plano.
- **bg**: Retoma un trabajo suspendido y lo envía al segundo plano (background).

```bash
root@debian:~# jobs
[1]+  Ejecutando              sleep 100000 &
root@debian:~# pidof sleep
1068
root@debian:~# kill -19 1068
root@debian:~# jobs
[1]+  Detenido                sleep 100000
root@debian:~# bg 1
[1]+ sleep 100000 &
root@debian:~# jobs
[1]+  Ejecutando              sleep 100000 &
```
Supongamos tres procesos diferentes:

```bash
root@debian:~# jobs
[2]   Ejecutando              sleep 600 &
[3]-  Ejecutando              sleep 300 &
[4]+  Ejecutando              sleep 200 &
```

- **[2] [3] [4]**	Número de trabajo asignado por el shell. Se usa para referenciar el proceso con %N.
- **Ejecutando**	Indica que el proceso está activo en segundo plano.
- **sleep 600 &, etc.**	Comando ejecutado en background.
- **+**	Indica el trabajo más reciente en segundo plano ([4]).
- **-**	Indica el segundo más reciente ([3]).

## Comando time

Permite medir el tiempo que tarda en ejecutarse un proceso.
```bash
root@debian:~# time sleep 10

real    0m10,012s
user    0m0,009s
sys     0m0,001s
```

## Comando top

Lista de procesos mostrando los procesos actualmente en ejecución, con columnas que incluyen:

- **PID**: Identificador del proceso.
- **USER**: Usuario que ejecuta el proceso.
- **PR**: Prioridad del proceso.
- **NI**: Valor de nice (prioridad ajustada del proceso).
- **VIRT**: Cantidad total de memoria virtual utilizada por el proceso.
- **RES**: Cantidad de memoria física utilizada por el proceso.
- **SHR**: Cantidad de memoria compartida usada.
- **%CPU**: Porcentaje de uso de CPU por el proceso.
- **%MEM**: Porcentaje de uso de la memoria RAM por el proceso.
- **TIME+**: Tiempo total de CPU consumido por el proceso.
- **COMMAND**: El nombre del comando o proceso.

```bash
root@debian:~# jobs
top - 17:10:11 up 59 min,  2 users,  load average: 0,00, 0,05, 0,35
Tareas: 123 total,   2 running, 121 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0,2 us,  0,2 sy,  0,0 ni, 99,5 id,  0,0 wa,  0,0 hi,  0,2 si,  0,0 st
MiB Mem :   1967,0 total,   1716,0 free,    265,0 used,    119,8 buff/cache
MiB Intercambio:    980,0 total,    980,0 free,      0,0 used.   1702,0 avail Mem

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND                                                                                                                                                            
     22 root      20   0       0      0      0 R   0,3   0,0   0:06.27 kworker/1:0-events                                                                                                                                                 
    124 root      20   0       0      0      0 I   0,3   0,0   0:09.62 kworker/0:2-events
    678 root      20   0  223240   3268   1088 S   0,3   0,2   0:02.38 VBoxDRMClient
    699 root      20   0    6576   5100   3780 S   0,3   0,3   0:00.86 apache2
   1024 vagrant   20   0   17988   6940   5076 S   0,3   0,3   0:00.97 sshd
   1076 root      20   0   14196   5220   3320 R   0,3   0,3   0:00.04 top                       
...   
```

## Comando vmstat

El comando **vmstat** en Linux y sistemas Unix proporciona información sobre el rendimiento del sistema, mostrando estadísticas relacionadas con la memoria, los procesos, la CPU y el uso de I/O (entrada/salida). Es una herramienta útil para monitorizar el estado del sistema y diagnosticar problemas de rendimiento.

Campos importantes en la salida de vmstat:
Procesos (procs):
- r: Número de procesos en cola de ejecución (running o waiting).
- b: Número de procesos bloqueados, esperando recursos de I/O.

Memoria (memory):
- swpd: Cantidad de memoria usada en el espacio de intercambio (swap) en KB.
- free: Memoria libre disponible en KB.
- buff: Memoria utilizada como buffers (normalmente para escritura en disco).
- cache: Memoria utilizada como caché de disco.

Swap:
- si: Cantidad de memoria intercambiada desde el disco (swap-in) en KB/s.
- so: Cantidad de memoria intercambiada hacia el disco (swap-out) en KB/s.

I/O:
- bi: Cantidad de bloques de entrada desde dispositivos de bloque (lecturas de disco) en bloques/s.
- bo: Cantidad de bloques de salida hacia dispositivos de bloque (escrituras en disco) en bloques/s.

Sistema (system):
- in: Número de interrupciones por segundo, incluyendo las de hardware.
- cs: Número de cambios de contexto por segundo (cuando el CPU cambia de un proceso a otro).

CPU:
- us: Porcentaje de tiempo de CPU usado por procesos en espacio de usuario.
- sy: Porcentaje de tiempo de CPU usado por el sistema (procesos del kernel).
- id: Porcentaje de tiempo que la CPU está inactiva.
- wa: Porcentaje de tiempo que la CPU está esperando operaciones de I/O.
- st: Porcentaje de tiempo robado a una máquina virtual por el hipervisor.

## Comando lsof
El término *lsof* es la abreviatura de List Open Files que como lo indica su nombre lista los archivos abiertos. El comando lsof le ayuda a determinar qué proceso está utilizando un archivo del punto de montaje en el momento de iniciar el comando.