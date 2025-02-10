# Sistema de ficheros

- **/etc/**: archivos de configuración.
- **/bin/**: programas básicos.
- **/lib/**: bibliotecas básicas.
- **/sbin/**: programas de sistema.
- **/usr/**: aplicaciones. Este directorio está subdividido en bin, sbin, lib.
- **/tmp/**: archivos temporales. Generalmente se vacía este directorio durante el arranque.
- **/root/**: archivos personales del administrador (root).
- **/home/**: archivos personales de los usuarios.
- **/dev/**: archivos de dispositivo.
- **/mnt/**: punto de montaje temporal.
- **/media/**: puntos de montaje para dispositivos removibles (CD-ROM, llaves USB, etc.).

- **/opt/**: aplicaciones adicionales provistas por terceros.
- **/run/**: datos volátiles en tiempo de ejecución que no persisten entre reinicios.
- **/srv/**: datos utilizados por los servidores en este sistema.
- **/var/**: datos variables administrados por demonios. Esto incluye archivos de registro, colas, cachés, etc.
- **/boot/**: núcleo Linux y otros archivos necesarios para las primeras etapas del proceso de arranque.
- **/proc/** y **/sys/** son específicos del núcleo Linux (y no son parte del FHS). El núcleo los utiliza para exportar datos a espacio de usuario.