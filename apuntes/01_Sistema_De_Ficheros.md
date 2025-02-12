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
Directorio estático que incluye los archivos necesarios para el proceso de arranque del sistema. Deberían ser utilizados antes de que el kernel comience a dar las instrucciones de arranque de los diferentes módulos del sistema.
- **/boot/**: núcleo Linux y otros archivos necesarios para las primeras etapas del proceso de arranque.

# /dev
Incluye todos los dispositivos de almacenamiento conectados al sistema y que este entienda como un volumen lódigo de almacenamiento.
- **/dev/**: archivos de dispositivo.

# /etc
Almacena los archivos de configuración tanto a nivel de componentes del sistema operativo como de los programas instalados a posteriori. Debería tener unicamente archivos de configuración y no debería contener binarios.
- **/etc/**: archivos de configuración.

# /home y /root
Directorios destinados a almacenar los archivos de los usuarios. Tambien incluye archivos temporales de aplicaciones ejecutadas en modo usuario que sirven para guardar las configuraciones de programas.
- **/home/**: archivos personales de los usuarios.
- **/root/**: archivos personales del administrador (root).

# /lib
Incluye las bibliotecas esenciales para que se puedan ejecutar correctamente todos los binarios de los directorios /bin y /sbin así como los módulos propios del kernel. Tenemos tambien los /lib32 y /lib64 para aquellas bibliotecas propias de arquitecturas de 32 y 64 bits respectivamente.
- **/lib/**: bibliotecas básicas.
```bash
lrwxrwxrwx   1 root root     7 Feb 10 11:41 lib -> usr/lib
lrwxrwxrwx   1 root root     9 Feb 10 11:41 lib32 -> usr/lib32
lrwxrwxrwx   1 root root     9 Feb 10 11:41 lib64 -> usr/lib64
```

# /media y /mnt
Punto de montaje de los volumenes lógicos que se montan en el sistema de forma temporal.
- **/media/**: puntos de montaje para dispositivos removibles (CD-ROM, llaves USB, etc.).
- **/mnt/**: punto de montaje temporal.

# /usr y /opt
Para almacenar archivos del sistema y aplicaciones de terceros.
- **/usr**: Es donde se almacenan los archivos del sistema que son compartidos entre todos los usuarios, como bibliotecas, programas y documentación. Es la ubicación estándar para software que se instala desde los repositorios del sistema o por el administrador del sistema.Este directorio está subdividido en bin, sbin, lib siendo estos enlaces débiles somo se mostraba anteriormente. Su nombre viene de _user system resources_.
- **/opt**: Se utiliza para instalar software adicional que no forma parte del sistema base. Aquí suelen ir programas o aplicaciones de terceros que no siguen la estructura estándar del sistema. Es común en aplicaciones grandes que se instalan por fuera del gestor de paquetes del sistema. 

# /proc y /sys
**/sys** se enfoca en la configuración y el hardware del sistema, mientras que **/proc** contiene información de los procesos y aplicaciones que se están ejecutando en un momento dado en el sitema.
- **/sys**: Contiene información y configuraciones del sistema y del núcleo (kernel), expuestas en tiempo real. Permite interactuar con parámetros del hardware y configuraciones del sistema.
- **/proc**: Es un sistema de archivos virtual que proporciona información sobre procesos en ejecución y el estado del sistema, como la memoria, CPU y demás recursos en uso.

# /srv
Almacena información propia de servidores en forma de archivo que puedan estar instalados en el sistema.
- **/srv/**: datos utilizados por los servidores en este sistema.

# /tmp
Su uso está enfocado en almacenar contenido temporal de poca duración.
- **/tmp/**: archivos temporales. Generalmente se vacía este directorio durante el arranque.

# /var
Contiene información del sistema actuando a modo de registro del sistema.
- **/var/**: datos variables administrados por demonios. Esto incluye archivos de registro, colas, cachés, bases de datos y otros archivos que cambian con el tiempo. El contenido de esta carpeta puede cambiar con la actividad del sistema, y su tamaño puede aumentar debido a la acumulación de registros y otros datos generados dinámicamente.
Ejemplos comunes:
  - **/var/log**: contiene archivos de registro del sistema, donde se guardan los mensajes del sistema, errores y eventos importantes.
  - **/var/cache**: almacena archivos de caché de aplicaciones y servicios.
  - **/var/spool**: contiene colas de trabajos que se van a procesar, como correos electrónicos o trabajos de impresión.
  - **/var/tmp**: archivos temporales que deberían sobrevivir a reinicios del sistema.

# /run
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