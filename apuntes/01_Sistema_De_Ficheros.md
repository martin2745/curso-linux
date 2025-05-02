# Sistema de ficheros

## /bin y /sbin
Directorios estáticos donde se encuentran los binarios propios del usuario y sistema.
- **/bin/**: Programas básicos. Almacena todos los binarios necesarios para garantizar las funciones básicas a nivel de usuario.
- **/sbin/**: Programas de sistema. Almacena los binarios necesarios para tareas administrativas del sistema y solo pueden ser gestionadas por el usuario root.
Actualmente son enlaces débiles a **/usr/bin** y **/usr/sbin**
```bash
lrwxrwxrwx   1 root root     7 Feb 10 11:41 bin -> usr/bin
lrwxrwxrwx   1 root root     8 Feb 10 11:41 sbin -> usr/sbin
```

## /boot
Directorio estático que incluye los archivos necesarios para el proceso de arranque del sistema. Deberían ser utilizados antes de que el kernel comience a dar las instrucciones de arranque de los diferentes módulos del sistema. En este directorio podemos encontrar archivos como los `/boot/vmlinuz`, los cuales son archivos *Linux kernel x86 boot executable bzImage*.
- **/boot/**: núcleo Linux y otros archivos necesarios para las primeras etapas del proceso de arranque.
- Destacamos el directorio `/boot/grub` donde se contiene la información del GRUB y existen archivos como el `grub.cnf` donde está la información del menú del gestor de arranque.

```bash
root@usuario:/boot/grub# ls
fonts             grubenv  unicode.pf2
gfxblacklist.txt  i386-pc  x86_64-efi
grub.cfg          locale
root@usuario:/boot/grub# ls -l grub.cfg
-rw-rw-r-- 1 root root 9986 dic 10 22:36 grub.cfg
```

## /etc
Almacena los archivos de configuración tanto a nivel de componentes del sistema operativo como de los programas instalados a posteriori. Debería tener unicamente archivos de configuración y no debería contener binarios.
- **/etc/**: archivos de configuración.

## /home y /root
Directorios destinados a almacenar los archivos de los usuarios. Tambien incluye archivos temporales de aplicaciones ejecutadas en modo usuario que sirven para guardar las configuraciones de programas.
- **/home/**: archivos personales de los usuarios.
- **/root/**: archivos personales del administrador (root).

## /lib
Incluye las bibliotecas esenciales para que se puedan ejecutar correctamente todos los binarios de los directorios /bin y /sbin así como los módulos propios del kernel que están en la ruta `/lib/modules`. Tenemos tambien los /lib32 y /lib64 para aquellas bibliotecas propias de arquitecturas de 32 y 64 bits respectivamente.
- **/lib/**: bibliotecas básicas.
```bash
lrwxrwxrwx   1 root root     7 Feb 10 11:41 lib -> usr/lib
lrwxrwxrwx   1 root root     9 Feb 10 11:41 lib32 -> usr/lib32
lrwxrwxrwx   1 root root     9 Feb 10 11:41 lib64 -> usr/lib64
```
- Para ver los módulos del kernel podemos ver la ruta `/lib/modules` y para saber nuestro kernel disponemos del comando **uname -r**.
```bash
root@usuario:~# uname -r
6.8.0-49-generic
root@usuario:~# cd /lib/modules/6.8.0-49-generic/
root@usuario:/lib/modules/6.8.0-49-generic# ls
build          modules.alias.bin          modules.builtin.modinfo  modules.order        vdso
initrd         modules.builtin            modules.dep              modules.softdep
kernel         modules.builtin.alias.bin  modules.dep.bin          modules.symbols
modules.alias  modules.builtin.bin        modules.devname          modules.symbols.bin
```

Por otra parte, existe la posibilidad de tener librerias compartidas a utilizar por diferentes programas o binarios del sistema. Para poder acceder a ellas se tienen que configurar en el fichero de configuración `/etc/ld.so.conf` o preferiblemente en el directorio `/etc/ld.so.conf.d` mediante ficheros con extensión `.conf`. Posteriormente tenemos que hacer uso del comando **ldconfig** para que la cache de librerias se actualice y los programas sepan que hay una nueva ruta con diferentes librerias.

Por otra parte, existe la variable de entorno *$LD_LIBRARY_PATH* donde se pueden asignar la ruta de las librerias compartidas. La información de esta variable tiene preferencia sobre la información del fichero de configuración.

Para saber las librerias de un ejecutable concreto tenemos el comando *ldd*.

```bash
root@usuario:/usr# which ls
/usr/bin/ls
root@usuario:/usr# ldd $(which ls)
        linux-vdso.so.1 (0x00007ffe2911e000)
        libselinux.so.1 => /lib/x86_64-linux-gnu/libselinux.so.1 (0x000078f496675000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x000078f496400000)
        libpcre2-8.so.0 => /lib/x86_64-linux-gnu/libpcre2-8.so.0 (0x000078f496369000)
        /lib64/ld-linux-x86-64.so.2 (0x000078f4966d6000)
```

## /media y /mnt
Punto de montaje de los volumenes lógicos que se montan en el sistema de forma temporal.
- **/media/**: puntos de montaje para dispositivos removibles (CD-ROM, llaves USB, etc.).
- **/mnt/**: punto de montaje temporal.

## /usr y /opt
Para almacenar archivos del sistema y aplicaciones de terceros.
- **/usr**: Es donde se almacenan los archivos del sistema que son compartidos entre todos los usuarios, como bibliotecas, programas y documentación. Es la ubicación estándar para software que se instala desde los repositorios del sistema o por el administrador del sistema.Este directorio está subdividido en bin, sbin, lib siendo estos enlaces débiles somo se mostraba anteriormente. Su nombre viene de _user system resources_.
- **/opt**: Se utiliza para instalar software adicional que no forma parte del sistema base. Aquí suelen ir programas o aplicaciones de terceros que no siguen la estructura estándar del sistema. Es común en aplicaciones grandes que se instalan por fuera del gestor de paquetes del sistema. 

## /dev
Incluye todos los dispositivos de almacenamiento conectados al sistema y que este entienda como un volumen lódigo de almacenamiento.
- **/dev/**: archivos de dispositivo.
- El demonio que se encarga de crear y eliminar los ficheros que representan los dispositivos según estén disponibles o no se conoce como **udev**, es decir, detecta cuando un dispositivo se conecta o desconecta y actua en consecuencia.
- Ejemplos de dispositivos en esta ruta serían:
  - /dev/fd0: Disqueteras.
  - /dev/hda: Controladoras de disco IDE
  - /dev/sda: Disco controladoras scsi
  - /dev/sr0: Dvd scsci
  - /dev/eth0 o /dev/enp0s3: Interfaz de red

## /proc y /sys
**/sys** se enfoca en la configuración y el hardware del sistema, mientras que **/proc** contiene información de los procesos y aplicaciones que se están ejecutando en un momento dado en el sitema.
- **/sys**: Contiene información y configuraciones del sistema a nivel de hardware y del núcleo (kernel), expuestas en tiempo real. Permite interactuar con parámetros del hardware y configuraciones del sistema.
- **/proc**: Es un sistema de archivos temporal que proporciona información sobre procesos en ejecución y el estado del sistema, como la memoria, CPU y demás recursos hardware del sistema. El demonio encargado de generar el tiempo de ejecución el contenido de `/proc` es *procfs*.
  - **/proc/interrupts**: Información que corresponde a los IRQ o interrupciones del sistema, es decir, canales (presentan un identificador numérico) que necesitan los dispositivos hardware para comunicarse con la CPU. En el directorio `/proc/interrupts` podemos ver la relación entre dispositivo hardware e interrupción.
  - **/proc/ioports**: Directorio donde se encuentran las localizaciones en memoria reservadas para la comunicación entre CPU y dispositivos hardware.
  - **/proc/dma**: Canales de acceso directo a memoria.
  - **/proc/sys**: Contiene información del Kernel, contiene información similar al propio directior `/sys`.
  - **/proc/meminfo**: Muestra detalles sobre el uso de la memoria del sistema.
  - **/proc/cpuinfo**: Muestra información sobre el procesador.
  - **/proc/partitions**: Lista las particiones de discos.
  - **/proc/mounts**: Muestra los sistemas de archivos montados actualmente.
  - **/proc/swaps**: Muestra información sobre las áreas de intercambio (swap) activas.

A continuación podemos ver un ejemplo del fichero speed de la tarjeta de red enp0s3 de una máquina linux. Podemos ver que es una tarjeta  Ethenet ya que su velocidad es de 1000. La información de los dispositivos de red está en la ruta `/sys/class/net`.

```bash
usuario@usuario:/sys/class/net$ ls
enp0s3  lo
usuario@usuario:/sys/class/net$ cat enp0s3/speed
1000
```

Por otra parte, podemos ver que si hacemos un listado del directorio `/proc` encontraremos una gran cantidad de directorios numéricos creados en tiempo de ejecución, estos números corresponden con el PID de los procesos.

```bash
usuario@usuario:/proc$ ls
1     21    2350  2525  2747  4183  59   66   92             fs             partitions
10    22    2355  2542  28    4188  592  68   94             interrupts     pressure
11    2236  2361  2553  2802  4194  593  69   95             iomem          schedstat
111   2241  2365  2555  281   4234  598  691  96             ioports        scsi
...
```

_*Nota*_: Estos directorios `/proc`, `/sys` y `/dev` son cruciales para la administración de sistemas y proporcionan interfaces muy poderosas para la gestión de procesos, hardware, y recursos del sistema. A modo de resumen podemos decir que los archivos dentro del directorio /sys tienen roles similares a los de /proc. Sin embargo, el directorio /sys tiene el propósito específico de almacenar información del dispositivo y datos del núcleo del sistema operativo relacionados con el dispositivo, mientras que /proc también contiene información sobre varias estructuras de datos  del núcleo del sistema operativo, incluidos los procesos en ejecución y la configuración.

## /srv
Almacena información propia de servidores en forma de archivo que puedan estar instalados en el sistema.
- **/srv/**: datos utilizados por los servidores en este sistema.

## /tmp
Su uso está enfocado en almacenar contenido temporal de poca duración.
- **/tmp/**: archivos temporales. Generalmente se vacía este directorio durante el arranque.

## /var
Contiene información del sistema actuando a modo de registro del sistema.
- **/var/**: datos variables administrados por demonios. Esto incluye archivos de registro, colas, cachés, bases de datos y otros archivos que cambian con el tiempo. El contenido de esta carpeta puede cambiar con la actividad del sistema, y su tamaño puede aumentar debido a la acumulación de registros y otros datos generados dinámicamente.
Ejemplos comunes:
  - **/var/log**: contiene archivos de registro del sistema, donde se guardan los mensajes del sistema, errores y eventos importantes.
  - **/var/cache**: almacena archivos de caché de aplicaciones y servicios.
  - **/var/spool**: contiene colas de trabajos que se van a procesar, como correos electrónicos o trabajos de impresión.
  - **/var/tmp**: archivos temporales que deberían sobrevivir a reinicios del sistema.

## /run
Para almacenar en tiempo de ejecución datos no persistemtes para el funcionamiento del sistema.
- **/run/**: datos volátiles en tiempo de ejecución que no persisten entre reinicios. Los archivos dentro de esta carpeta son necesarios para el funcionamiento del sistema mientras está en ejecución, pero no se mantienen después de un reinicio. Esta carpeta contiene información crítica sobre el estado del sistema, como identificadores de procesos (PID), información de red, sesiones de usuario, y otros archivos temporales que se recrean después de reiniciar el sistema.
Ejemplos comunes:
  - **/run/lock**: archivos de bloqueo que previenen la ejecución simultánea de procesos que podrían interferir entre sí.
  - **/run/user/**: directorios específicos para cada usuario, donde se almacenan datos temporales relacionados con las sesiones de usuario.
  - **/run/systemd/**: contiene información sobre el sistema de inicio (systemd) y su estado durante el arranque.

```bash
┌──(kali㉿kali)-[/]
└─$ ls -l
total 64
lrwxrwxrwx   1 root root     7 Feb 10 11:41 bin -> usr/bin
drwxr-xr-x   3 root root  4096 Feb 10 11:51 boot
drwxr-xr-x  18 root root  3300 Feb 12 12:06 dev
drwxr-xr-x 187 root root 12288 Feb 12 12:06 etc
drwxr-xr-x   4 root root  4096 Feb 12 09:34 home
lrwxrwxrwx   1 root root    28 Feb 10 11:41 initrd.img -> boot/initrd.img-6.11.2-amd64
lrwxrwxrwx   1 root root     7 Feb 10 11:41 lib -> usr/lib
lrwxrwxrwx   1 root root     9 Feb 10 11:41 lib32 -> usr/lib32
lrwxrwxrwx   1 root root     9 Feb 10 11:41 lib64 -> usr/lib64
drwx------   2 root root 16384 Feb 10 11:41 lost+found
drwxr-xr-x   3 root root  4096 Nov 30 09:39 media
drwxr-xr-x   2 root root  4096 Nov 30 09:39 mnt
drwxr-xr-x   3 root root  4096 Feb 10 11:41 opt
dr-xr-xr-x 230 root root     0 Feb 12 12:06 proc
drwx------   5 root root  4096 Feb 12 12:06 root
drwxr-xr-x  38 root root  1000 Feb 12 12:07 run
lrwxrwxrwx   1 root root     8 Feb 10 11:41 sbin -> usr/sbin
drwxr-xr-x   3 root root  4096 Feb 10 11:41 srv
dr-xr-xr-x  13 root root     0 Feb 12 12:08 sys
drwxrwxrwt  14 root root   340 Feb 12 12:06 tmp
drwxr-xr-x  15 root root  4096 Feb 10 11:47 usr
drwxr-xr-x  12 root root  4096 Feb 10 11:51 var
lrwxrwxrwx   1 root root    25 Feb 10 11:47 vmlinuz -> boot/vmlinuz-6.11.2-amd64
```

_*Nota*_: Directorios como el `/etc`, `/bin`, `/sbin`, `/lib` y `/dev` nunca deberían asignarse a una partición separada de la del sistema. 
_*Nota*_: Directorios separables serían:
- `/boot`: Se tiene que separar si usamos LVM.
- `/boot/efi`: Partición ESP para UEFI, recomendable que esté formateada en FAT.
- `/usr`: Si se van a instalar muchos programas que no son parte del sistema.
- `/var`, `/tmp` y `/home`: En sistemas multiusuario.