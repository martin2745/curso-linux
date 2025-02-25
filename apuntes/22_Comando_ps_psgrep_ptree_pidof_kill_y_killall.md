# Comando ps, psgrep, ptree, pidof, kill y killall

`ps` muestra los procesos asociados con la terminal desde la que se ejecuta el comando. Muestra el PID (identificador de proceso), la terminal asociada, tiempo desde que se lanzó el proceso y el comando que lo desencadena.

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

`ps -o` muestra la información de los procesos que se especifique por el usuario.

```bash
si@si-VirtualBox:~$ ps -eo cmd,pid,ppid,time,user,%cpu, --sort -%mem | head
CMD                             PID    PPID     TIME USER     %CPU
/usr/sbin/mysqld                761       1 00:00:18 mysql     0.7
/usr/bin/gnome-shell           3849    2516 00:00:07 si        0.4
/usr/bin/python3 /usr/bin/u    5628    2516 00:00:04 si        0.2
/snap/snap-store/959/usr/bi    4142    2516 00:00:02 si        0.1
/usr/libexec/fwupd/fwupd       4537       1 00:00:01 root      0.0
/usr/libexec/gsd-xsettings     4345    2516 00:00:00 si        0.0
/usr/libexec/evolution-data    4179    3821 00:00:00 si        0.0
/usr/bin/Xwayland :0 -rootl    4261    3849 00:00:00 si        0.0
/usr/libexec/packagekitd       3189       1 00:00:06 root      0.2
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

2. **Sintaxis BSD**: Esta es una convención utilizada principalmente en sistemas derivados de BSD (Berkeley Software Distribution), como FreeBSD, OpenBSD y macOS. En la sintaxis BSD, las opciones del comando `ps` se especifican sin guiones y pueden estar combinadas.

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

`pstree` muestra información de los procesos en forma de arbol

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

`pidof` es más simple y directo, útil para encontrar PIDs basados en nombres de procesos específicos, mientras que `pgrep` es más versátil y puede realizar búsquedas más avanzadas con una variedad de criterios. La elección entre ellos depende de las necesidades específicas de búsqueda que tengas en un momento dado.

`pgrep` muestra los IDs de proceso (PID) de los procesos sshd que están siendo ejecutados por los usuarios root y si.

```bash
si@si-VirtualBox:~$ pgrep -u root,si sshd
735
1331
2707
```

`pidof` muestra los IDs de proceso (PID) asociados con un programa específico.

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