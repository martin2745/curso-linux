# Iniciadores del sistema: SysVinit, Systemd, Upstart

Podemos encontrar tres tipos de procesos encargados de iniciar y gestionar los servicios o demonios de entornos Linux.

- **SysVinit**: Utiliza Script y niveles de ejecución para controlar el inicio, apagado y gestión de los procesos del sistema.
- **Systemd**: Desde el 2015, las principales distribuciones de Linux lo han adoptado como su sistema de inicio. Agrupa los servicios en "target" en lugar de runlevel, estableciendo en ellos dependencias y el orden de ejecución de los procesos.
- **Upstar**: Utiliza eventos para gestionar el arranque o parada de los procesos.

En SysVinit el fichero `/etc/inittab` tiene la configuración básica como el nivel de ejecución por defecto y las acciones a tomar en determinadas situaciones. 

- Se definen niveles de ejecución y qué se hará en cada uno de ellos. Se invoca al script rc que puede estar en `/etc/rc.d/` , `/etc/init.d/` (depende de la distribución), pasándole por parámetro el nivel de ejecución.
- rc ejecuta los ficheros que hay en el directorio `/etc/rcN.d/` por orden numérico (siendo N el nivel de ejecución). Estos ficheros serán enlaces que empiezan por S o K y que apuntan a script que están en `/etc/init.d/`
- Si el enlace empieza por S, rc le pasará el comando start y si empieza por K le pasará stop.
- Los runlevels (niveles de ejecución) son una característica del sistema init de Unix y  Linux que determinan qué servicios y procesos se ejecutan en un momento dado. En sistemas modernos basados en systemd, que es el caso de muchas distribuciones recientes, los runlevels tradicionales han sido reemplazados por "targets". Sin embargo, la idea general sigue siendo la misma: diferentes niveles de ejecución representan diferentes configuraciones del sistema.

A continuación se adjunta una descripción general de los runlevels tradicionales en sistemas que utilizan System V init:

- **Runlevel 0**: Apagado del sistema.
- **Runlevel 1**: Monousuario sin red para rescate del sistema operativo. Solo se ejecuta un conjunto mínimo de servicios y no se inicia el entorno gráfico.
- **Runlevel 2**: Multiusuario sin red. Similar al nivel de ejecución 3, pero sin servicios de red.
- **Runlevel 3**: Multiusuario con red. El sistema arranca en modo multiusuario y se inician todos los servicios necesarios para permitir conexiones de red.
- **Runlevel 4**: Reservado para un uso personalizado. Por lo general, no se utiliza en las distribuciones estándar de Linux.
- **Runlevel 5**: Multiusuario con interfaz gráfica (GUI). Similar al nivel de ejecución 3, pero también inicia el entorno gráfico.
- **Runlevel 6**: Reinicio del sistema.

## `SysVinit`

En SysVinit partiendo de la configuración del `/etc/inittab`.

El script `rc` ejecuta los ficheros que existen en `/etc/rcN.d` siendo `N` el nivel de ejecución. Estos ficheros serán enlaces a /etc/init.d que comenzarán por `S` para iniciar el servicio o `K` para terminar con el servicio.

```bash
root@debian12:/# ls -ld /etc/rc*
drwxr-xr-x 2 root root 4096 abr 13 14:05 /etc/rc0.d
drwxr-xr-x 2 root root 4096 abr 13 14:05 /etc/rc1.d
drwxr-xr-x 2 root root 4096 abr 13 14:05 /etc/rc2.d
drwxr-xr-x 2 root root 4096 abr 13 14:05 /etc/rc3.d
drwxr-xr-x 2 root root 4096 abr 13 14:05 /etc/rc4.d
drwxr-xr-x 2 root root 4096 abr 13 14:05 /etc/rc5.d
drwxr-xr-x 2 root root 4096 abr 13 14:05 /etc/rc6.d
drwxr-xr-x 2 root root 4096 feb  2 17:52 /etc/rcS.d

root@debian12:/# ls -l /etc/rc*

/etc/rc0.d:
total 0
lrwxrwxrwx 1 root root 20 feb  2 17:52 K01alsa-utils -> ../init.d/alsa-utils
lrwxrwxrwx 1 root root 19 feb  2 17:52 K01bluetooth -> ../init.d/bluetooth
lrwxrwxrwx 1 root root 20 feb  2 17:52 K01cryptdisks -> ../init.d/cryptdisks
lrwxrwxrwx 1 root root 26 feb  2 17:52 K01cryptdisks-early -> ../init.d/cryptdisks-early
lrwxrwxrwx 1 root root 22 feb  2 17:52 K01cups-browsed -> ../init.d/cups-browsed
lrwxrwxrwx 1 root root 15 feb  2 17:52 K01exim4 -> ../init.d/exim4
lrwxrwxrwx 1 root root 20 feb  2 17:52 K01hwclock.sh -> ../init.d/hwclock.sh
lrwxrwxrwx 1 root root 17 feb  2 17:52 K01lightdm -> ../init.d/lightdm
lrwxrwxrwx 1 root root 20 feb  2 17:52 K01live-tools -> ../init.d/live-tools
lrwxrwxrwx 1 root root 15 feb  2 17:52 K01mdadm -> ../init.d/mdadm
lrwxrwxrwx 1 root root 24 feb  2 17:52 K01mdadm-waitidle -> ../init.d/mdadm-waitidle
lrwxrwxrwx 1 root root 20 feb  2 17:52 K01networking -> ../init.d/networking
lrwxrwxrwx 1 root root 18 feb  2 17:52 K01plymouth -> ../init.d/plymouth
lrwxrwxrwx 1 root root 37 feb  2 17:52 K01pulseaudio-enable-autospawn -> ../init.d/pulseaudio-enable-autospawn
lrwxrwxrwx 1 root root 15 feb  2 17:52 K01saned -> ../init.d/saned
lrwxrwxrwx 1 root root 23 feb  2 17:52 K01smartmontools -> ../init.d/smartmontools
lrwxrwxrwx 1 root root 27 feb  2 17:52 K01speech-dispatcher -> ../init.d/speech-dispatcher
lrwxrwxrwx 1 root root 14 feb  2 17:52 K01udev -> ../init.d/udev
lrwxrwxrwx 1 root root 15 feb  2 17:52 K01uuidd -> ../init.d/uuidd

/etc/rc1.d:
total 0
lrwxrwxrwx 1 root root 20 feb  2 17:52 K01alsa-utils -> ../init.d/alsa-utils
lrwxrwxrwx 1 root root 19 feb  2 17:52 K01bluetooth -> ../init.d/bluetooth
lrwxrwxrwx 1 root root 14 feb  2 17:52 K01cups -> ../init.d/cups
lrwxrwxrwx 1 root root 22 feb  2 17:52 K01cups-browsed -> ../init.d/cups-browsed
lrwxrwxrwx 1 root root 15 feb  2 17:52 K01exim4 -> ../init.d/exim4
lrwxrwxrwx 1 root root 17 feb  2 17:52 K01lightdm -> ../init.d/lightdm
lrwxrwxrwx 1 root root 15 feb  2 17:52 K01mdadm -> ../init.d/mdadm
lrwxrwxrwx 1 root root 37 feb  2 17:52 K01pulseaudio-enable-autospawn -> ../init.d/pulseaudio-enable-autospawn
lrwxrwxrwx 1 root root 15 feb  2 17:52 K01saned -> ../init.d/saned
lrwxrwxrwx 1 root root 23 feb  2 17:52 K01smartmontools -> ../init.d/smartmontools
lrwxrwxrwx 1 root root 27 feb  2 17:52 K01speech-dispatcher -> ../init.d/speech-dispatcher
lrwxrwxrwx 1 root root 15 feb  2 17:52 K01uuidd -> ../init.d/uuidd

/etc/rc2.d:
total 0
lrwxrwxrwx 1 root root 27 feb  2 17:52 K01speech-dispatcher -> ../init.d/speech-dispatcher
lrwxrwxrwx 1 root root 17 feb  2 17:52 S01anacron -> ../init.d/anacron
lrwxrwxrwx 1 root root 19 feb  2 17:52 S01bluetooth -> ../init.d/bluetooth
lrwxrwxrwx 1 root root 26 feb  2 17:52 S01console-setup.sh -> ../init.d/console-setup.sh
lrwxrwxrwx 1 root root 14 feb  2 17:52 S01cron -> ../init.d/cron
lrwxrwxrwx 1 root root 14 feb  2 17:52 S01cups -> ../init.d/cups
lrwxrwxrwx 1 root root 22 feb  2 17:52 S01cups-browsed -> ../init.d/cups-browsed
lrwxrwxrwx 1 root root 14 feb  2 17:52 S01dbus -> ../init.d/dbus
lrwxrwxrwx 1 root root 15 feb  2 17:52 S01exim4 -> ../init.d/exim4
lrwxrwxrwx 1 root root 17 feb  2 17:52 S01lightdm -> ../init.d/lightdm
lrwxrwxrwx 1 root root 15 feb  2 17:52 S01mdadm -> ../init.d/mdadm
lrwxrwxrwx 1 root root 18 feb  2 17:52 S01plymouth -> ../init.d/plymouth
lrwxrwxrwx 1 root root 37 feb  2 17:52 S01pulseaudio-enable-autospawn -> ../init.d/pulseaudio-enable-autospawn
lrwxrwxrwx 1 root root 15 feb  2 17:52 S01rsync -> ../init.d/rsync
lrwxrwxrwx 1 root root 15 feb  2 17:52 S01saned -> ../init.d/saned
lrwxrwxrwx 1 root root 23 feb  2 17:52 S01smartmontools -> ../init.d/smartmontools
lrwxrwxrwx 1 root root 13 abr 12 19:14 S01ssh -> ../init.d/ssh
lrwxrwxrwx 1 root root 14 feb  2 17:52 S01sudo -> ../init.d/sudo
lrwxrwxrwx 1 root root 17 feb  2 17:52 S01sysstat -> ../init.d/sysstat
lrwxrwxrwx 1 root root 15 feb  2 17:52 S01uuidd -> ../init.d/uuidd

/etc/rc3.d:
...

/etc/rc4.d:
...

/etc/rc5.d:
...

/etc/rc6.d:
...
```

Como comandos destacamos:
- El comando **runlevel** muestra el nivel de ejecución.
```bash
root@usuario:/etc# runlevel
N 5
```
- Para cambiar entre niveles puedo usar los comandos **init** o **telinit**.
```bash
root@usuario:/etc# init 6
Connection to localhost closed by remote host.
Connection to localhost closed.
```

```bash
root@usuario:~# telinit 6
Connection to localhost closed by remote host.
Connection to localhost closed.
```
- Con el comando **update-rc.d** puedo indicar si quiero habilitar o deshabilitar un servicio concreto para un runlevel.
```bash
update-rc.d network-manager disable 2
```

## `systemd`

- Se ejecuta un único programa `systemd` que utilizará ficheros de configuración para cada elemento a gestionar llamados `unidades`, que pueden ser de diversos tipos: automount, device, mount, path, **service**, snapshot, socket y target.
- Las `unidades`, es decir, los ficheros de configuración, se agrupan en diferentes `target`, donde también podemos definir el orden de ejecución y las dependencias con otros target o services. Son los equivalentes a los runlevels en SysVinit (hay target compatibles con estos). A continuación se adjunta una equivalencia aproximada entre los runlevels en SysVinit y los targets en systemd:

- **Runlevel 0**: Apagado del sistema.
  - **Systemd Target**: `poweroff.target`.

- **Runlevel 1**: Modo de rescate o de un solo usuario.
  - **Systemd Target**: `rescue.target`.

- **Runlevel 2**: Multiusuario sin red.
  - **Systemd Target**: `multi-user.target`.

- **Runlevel 3**: Multiusuario con red.
  - **Systemd Target**: `multi-user.target`.

- **Runlevel 4**: Reservado para un uso personalizado.
  - **Systemd Target**: No tiene un equivalente directo, se puede personalizar según las necesidades.

- **Runlevel 5**: Multiusuario con interfaz gráfica (GUI).
  - **Systemd Target**: `graphical.target`.

- **Runlevel 6**: Reinicio del sistema.
  - **Systemd Target**: `reboot.target`.

![sysvinit vs systemd](../imagenes/recursos/sysvinit_vs_systemd/sysvinit_vs_systemd.png)

- Es importante tener en cuenta que, aunque hay una cierta correspondencia entre los runlevels de SysVinit y los targets de systemd, systemd es más flexible y puede tener una configuración diferente en diferentes distribuciones y sistemas. Además, systemd introduce conceptos adicionales como "targets especiales" (`default.target`, `emergency.target`, etc.) que no tienen un equivalente directo en SysVinit.
- Cada unidad se define en un fichero con el nombre de dicha unidad y en la extensión se indica el tipo de unidad, por ejemplo ssh.service que se encuentra en `/etc/systemd/system`. Destacamos `/usr/lib/systemd/system`, `/lib/systemd/system` y `/etc/systemd/system`.

```bash
root@debian12:/# cat /etc/systemd/system/sshd.service

# Define la unidad
[Unit]
Description=OpenBSD Secure Shell server
Documentation=man:sshd(8) man:sshd_config(5)
After=network.target auditd.service
ConditionPathExists=!/etc/ssh/sshd_not_to_be_run

# Define el servicio
[Service]
EnvironmentFile=-/etc/default/ssh
ExecStartPre=/usr/sbin/sshd -t --> Comando concreto que ejecuta la unidad.
ExecStart=/usr/sbin/sshd -D $SSHD_OPTS
ExecReload=/usr/sbin/sshd -t
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartPreventExitStatus=255
Type=notify
RuntimeDirectory=sshd
RuntimeDirectoryMode=0755

# Que ocurre cuando se carga el servicio.
[Install]
WantedBy=multi-user.target --> Cuando se cargue esta unidad, carga otra unidad de tipo target.
Alias=sshd.service --> Alias del servicio.
```

Aquí podemos ver la correspondencia entre los diferentes`target`actuales y el`runlevel`. Podemos ver que mediante enlaces simbólicos se mantiene la relación con los antiguos `runlevel`.

```bash
root@debian12:/# ls -ld /usr/lib/systemd/system/
drwxr-xr-x 29 root root 20480 abr 13 14:05 /usr/lib/systemd/system/
root@debian12:/# ls -ld /usr/lib/systemd/system/runlevel*
lrwxrwxrwx 1 root root   15 feb  2 17:48 /usr/lib/systemd/system/runlevel0.target -> poweroff.target
lrwxrwxrwx 1 root root   13 feb  2 17:48 /usr/lib/systemd/system/runlevel1.target -> rescue.target
drwxr-xr-x 2 root root 4096 nov 10 01:25 /usr/lib/systemd/system/runlevel1.target.wants
lrwxrwxrwx 1 root root   17 feb  2 17:48 /usr/lib/systemd/system/runlevel2.target -> multi-user.target
drwxr-xr-x 2 root root 4096 nov 10 01:25 /usr/lib/systemd/system/runlevel2.target.wants
lrwxrwxrwx 1 root root   17 feb  2 17:48 /usr/lib/systemd/system/runlevel3.target -> multi-user.target
drwxr-xr-x 2 root root 4096 nov 10 01:25 /usr/lib/systemd/system/runlevel3.target.wants
lrwxrwxrwx 1 root root   17 feb  2 17:48 /usr/lib/systemd/system/runlevel4.target -> multi-user.target
drwxr-xr-x 2 root root 4096 nov 10 01:25 /usr/lib/systemd/system/runlevel4.target.wants
lrwxrwxrwx 1 root root   16 feb  2 17:48 /usr/lib/systemd/system/runlevel5.target -> graphical.target
drwxr-xr-x 2 root root 4096 nov 10 01:25 /usr/lib/systemd/system/runlevel5.target.wants
lrwxrwxrwx 1 root root   13 feb  2 17:48 /usr/lib/systemd/system/runlevel6.target -> reboot.target
```

## systemctl

**systemctl** es la herramienta principal para gestionar la mayoría de los aspectos de  *systemd*. A continuación se describen algunos de los comandos más utilizados:

- **get-default**: Muestra el *target* (objetivo) por defecto que se utiliza al iniciar el sistema. A continuación podemos ver que el target por defecto es graphical.target que equivale al runlevel 5.

```bash
root@usuario:~# systemctl get-default
graphical.target
```

- **start/stop/status/etc... unit[.service]**: Permite iniciar, detener, reiniciar, recargar o consultar el estado de una unidad de servicio.  

```bash
root@usuario:~# systemctl status ssh
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2025-04-23 23:50:58 CEST; 3min 27s ago
       Docs: man:sshd(8)
             man:sshd_config(5)
    Process: 773 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
   Main PID: 789 (sshd)
      Tasks: 1 (limit: 9438)
     Memory: 7.4M
        CPU: 1.454s
     CGroup: /system.slice/ssh.service
             └─789 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

abr 23 23:50:56 usuario systemd[1]: Starting OpenBSD Secure Shell server...
abr 23 23:50:58 usuario sshd[789]: Server listening on 0.0.0.0 port 22.
abr 23 23:50:58 usuario systemd[1]: Started OpenBSD Secure Shell server.
abr 23 23:50:58 usuario sshd[789]: Server listening on :: port 22.
abr 23 23:51:26 usuario sshd[1295]: Accepted password for usuario from 10.0.2.2 port 49974 ssh2
abr 23 23:51:27 usuario sshd[1295]: pam_unix(sshd:session): session opened for user usuario(uid=1000)
```

- **isolate unit.target**: Cambia el sistema al *target* especificado, deteniendo los servicios no requeridos por ese target.

```bash
root@usuario:~# systemctl isolate rescue.target --> Este comando cambia al modo de rescate o runlevel 1.
```

- **list-units [--type=service]**: Lista todas las unidades cargadas actualmente.  
  Puedes filtrar por tipo, por ejemplo, solo servicios.

```bash
root@usuario:~# systemctl list-units --type=service
  UNIT                                                  LOAD   ACTIVE SUB     DESCRIPTION                                          
  accounts-daemon.service                               loaded active running Accounts Service
  acpid.service                                         loaded active running ACPI event daemon
  alsa-restore.service                                  loaded active exited  Save/Restore Sound Card State
  apparmor.service                                      loaded active exited  Load AppArmor profiles
  apport.service                                        loaded active exited  LSB: automatic crash report generation
```

- **enable/disable**: Habilita o deshabilita una unidad para que se inicie automáticamente al arrancar el sistema. Ejemplo:  
  
```bash
systemctl enable apache2
systemctl disable apache2
```

- **cat**: Muestra el contenido del archivo de definición de la unidad.  

```bash
root@usuario:~# systemctl cat ssh
# /lib/systemd/system/ssh.service
[Unit]
Description=OpenBSD Secure Shell server
Documentation=man:sshd(8) man:sshd_config(5)
After=network.target auditd.service
ConditionPathExists=!/etc/ssh/sshd_not_to_be_run

[Service]
EnvironmentFile=-/etc/default/ssh
ExecStartPre=/usr/sbin/sshd -t
ExecStart=/usr/sbin/sshd -D $SSHD_OPTS
ExecReload=/usr/sbin/sshd -t
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartPreventExitStatus=255
Type=notify
RuntimeDirectory=sshd
RuntimeDirectoryMode=0755

[Install]
WantedBy=multi-user.target
Alias=sshd.service
```

- **list-dependencies**: Muestra un árbol con las dependencias de una unidad específica.  
  
```bash
root@usuario:~# systemctl list-dependencies
default.target
● ├─accounts-daemon.service
● ├─apport.service
● ├─gdm.service
● ├─power-profiles-daemon.service
● ├─switcheroo-control.service
○ ├─systemd-update-utmp-runlevel.service
● ├─udisks2.service
● └─multi-user.target
○   ├─anacron.service
●   ├─apport.service
●   ├─avahi-daemon.service
●   ├─console-setup.service
●   ├─cron.service
●   ├─cups-browsed.service
●   ├─cups.path
●   ├─cups.service
●   ├─dbus.service
○   ├─dmesg.service
○   ├─e2scrub_reap.service
○   ├─grub-common.service
○   ├─grub-initrd-fallback.service
●   ├─irqbalance.service
```

## Comando journalctl

El comando **journalctl** consultar los log del sistema.

- **-S -U** : permite especificar desde (since) y/o hasta cuando (until)
  - Formatos válidos: YYYY-MM-DD [HH:MM:SS], yesterday, today, tomorrow, N day ago, -/+ NhMmin (-1h15min)
  - Ejemplos:
    - `journalctl --since "2025-04-23 12:00:00" --until "2025-04-24 00:00:00"`
    - `journalctl --since yesterday`
    - `journalctl --since -1h15min`  
```bash
root@usuario:~# journalctl -S "2025-04-24 00:00:00" -U "2025-04-24 00:00:17"
Journal file /var/log/journal/ccc919360d074cafa07dd54cccbd0c8d/system@000628ff2354e91e-7bd4b14e740efb67.journal~ is truncated, ignoring file.
abr 24 00:00:16 usuario systemd[1]: Starting Daily dpkg database backup service...
abr 24 00:00:16 usuario systemd[1]: Starting Rotate log files...
abr 24 00:00:16 usuario systemd[1]: Stopping Make remote CUPS printers available locally...
abr 24 00:00:16 usuario systemd[1]: cups-browsed.service: Deactivated successfully.
abr 24 00:00:16 usuario systemd[1]: Stopped Make remote CUPS printers available locally.
abr 24 00:00:16 usuario systemd[1]: Stopping CUPS Scheduler...
abr 24 00:00:16 usuario systemd[1]: cups.service: Deactivated successfully.
abr 24 00:00:16 usuario systemd[1]: Stopped CUPS Scheduler.
abr 24 00:00:16 usuario systemd[1]: cups.path: Deactivated successfully.
abr 24 00:00:16 usuario systemd[1]: Stopped CUPS Scheduler.
abr 24 00:00:16 usuario systemd[1]: Stopping CUPS Scheduler...
abr 24 00:00:16 usuario systemd[1]: Started CUPS Scheduler.
abr 24 00:00:16 usuario systemd[1]: cups.socket: Deactivated successfully.
abr 24 00:00:16 usuario systemd[1]: Closed CUPS Scheduler.
abr 24 00:00:16 usuario systemd[1]: Stopping CUPS Scheduler...
abr 24 00:00:16 usuario systemd[1]: Listening on CUPS Scheduler.
abr 24 00:00:16 usuario systemd[1]: Starting CUPS Scheduler...
abr 24 00:00:16 usuario kernel: audit: type=1400 audit(1745445616.781:64): apparmor="DENIED" operation="capable" class="cap" profile="/usr/sbin/cupsd" pid=3097 comm="cupsd" capability=12  capname="net_admin"
abr 24 00:00:16 usuario audit[3097]: AVC apparmor="DENIED" operation="capable" class="cap" profile="/usr/sbin/cupsd" pid=3097 comm="cupsd" capability=12  capname="net_admin"
abr 24 00:00:16 usuario systemd[1]: Started CUPS Scheduler.
abr 24 00:00:16 usuario systemd[1]: Started Make remote CUPS printers available locally.
abr 24 00:00:16 usuario systemd[1]: logrotate.service: Deactivated successfully.
abr 24 00:00:16 usuario systemd[1]: Finished Rotate log files.
```

- **-u unit** : muestra los mensajes de una unidad en concreto  
  - Ejemplo: `journalctl -u apache2.service`
```bash
root@usuario:~# journalctl -u ssh.service
Journal file /var/log/journal/ccc919360d074cafa07dd54cccbd0c8d/system@000628ff2354e91e-7bd4b14e740efb67.journal~ is truncated, ignoring file.
dic 10 22:52:39 usuario systemd[1]: Starting OpenBSD Secure Shell server...
dic 10 22:52:39 usuario sshd[34262]: Server listening on 0.0.0.0 port 22.
dic 10 22:52:39 usuario sshd[34262]: Server listening on :: port 22.
dic 10 22:52:39 usuario systemd[1]: Started OpenBSD Secure Shell server.
-- Boot b8dff8ef5d344b2fa2308933a4b80166 --
dic 11 15:08:56 usuario systemd[1]: Starting OpenBSD Secure Shell server...
dic 11 15:08:56 usuario sshd[798]: Server listening on 0.0.0.0 port 22.
dic 11 15:08:56 usuario sshd[798]: Server listening on :: port 22.
```
- **-k** : muestra solo los mensajes del kernel  
  - Ejemplo: `journalctl -k`
- **-p** : filtra por tipo de prioridad (emerg, alert, crit, err, warning, notice, info, debug)
  - Ejemplo: `journalctl -p err`
- **PARAM=VALUE** : permite filtrar por parámetros como _PID, _UID, _COMM, etc.
  - Ejemplo: `journalctl _PID=1234`
  - Para ver todos los campos disponibles: `man systemd.journal-fields`

## Comando dmesg
Al arrancar el sistema se muestran mensajes según se van cargando controladores o funciones del sistema. Para revisarlos se usa dmesg y es equivalente a journalctl -b -k Opciones:
- T : Muestra las marcas de tiempo más claramente
- k : Sólo mensajes del kernel
- l : filtra por niveles de aviso (warn, err, etc..)