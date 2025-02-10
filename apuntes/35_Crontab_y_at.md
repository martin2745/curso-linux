# crontab y at

## rontab

`Crontab` es un archivo de configuración en sistemas operativos basados en Unix, como Linux, situado en la ruta `/etc/crontab` y que se utiliza para programar tareas periódicas para que se ejecuten automáticamente en momentos específicos. La estructura básica de un archivo crontab consta de siete campos y es la siguiente:

```bash
30 2 * * * (usuario) /ruta/al/script/backup.sh
```

- **Minuto**: El minuto en que se ejecutará la tarea, especificado como un número de 0 a 59.
- **Hora**: La hora en que se ejecutará la tarea, especificada como un número de 0 a 23 (formato de 24 horas).
- **DíaDelMes**: El día del mes en que se ejecutará la tarea, especificado como un número de 1 a 31.
- **Mes**: El mes en que se ejecutará la tarea, especificado como un número de 1 a 12 o como los nombres abreviados en inglés (jan, feb, mar, etc.).
- **DíaDeLaSemana**: El día de la semana en que se ejecutará la tarea, especificado como un número de 0 a 7 donde 0 y 7 representan domingo, o como los nombres abreviados en inglés (sun, mon, tue, etc.).
- **Usuario**: El usuario que se pretende que ejecute el comando o ejecutable.
- **Comando**: El comando que se ejecutará.

En la ruta `/etc/crontab` tenemos la siguiente información.

```bash
# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name command to be executed

17 *    * * *   root    cd / && run-parts --report /etc/cron.hourly

25 6    * * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )

47 6    * * 7   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )

52 6    1 * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )

50 13 17 04 4 si touch /home/si/contab.txt
```

Accedemos al archivo donde introducimos las reglas `/var/spool/cron/crontabs/usuario` gracias al comando `crontab -e` y podemos listar sus reglas con `crontab -l`.

```bash
# m h  dom mon dow   command
30 17 10 5 0 touch /tmp/hola.txt
```

Tambien se pueden utilizar las notaciones:

- `@yearly / @annually`: Es equivalente a poner en el crontab:

```bash
0 0 1 1 * root /bin/bash /tmp/ejecutable.sh
```

- `@monthly`: Es equivalente a poner en el crontab:

```bash
0 0 1 * * root /bin/bash /tmp/ejecutable.sh
```

- `@weakly`: Es equivalente a poner en el crontab:

```bash
0 0 * * 0 root /bin/bash /tmp/ejecutable.sh
```

_*Nota: Fijate que significa todos los domingos y podría ser un 7 en el último caracter.*_

- `@dayly / @midnight`: Es equivalente a poner en el crontab:

```bash
0 0 * * * root /bin/bash /tmp/ejecutable.sh
```

- `@hourly`: Es equivalente a poner en el crontab:

```bash
0 * * * * root /bin/bash /tmp/ejecutable.sh
```

- Una `L` al final de un campo de día del mes tiene un significado especial. Indica "el último día" del mes.

```bash
0 0 L * * your_command
```

- Otros casos:

```bash
30 8,15 20 6 *  prof    /home/prof/check.sh
```

Se ejecuta como usuario prof el script /home/prof/check.sh a las 8:30 y a las 15:30 el día 20 de junio.

```bash
*/10 * * * 1-5  alu     /home/alu/test.sh >> /home/alu/wlog
```

Se ejecuta como usuario alu el script /home/alu/test.sh redireccionando la salida de la consola (canal 1) al archivo /home/alu wlog, el cual se crea en caso de no existir, y en caso de existir se añade contenido. Este script se ejecuta cada 10 minutos (intervalos de 10 minutos) de lunes a viernes (todas las semanas y meses).

## at

El comando `at` en Linux es una herramienta que te permite ejecutar comandos o scripts en un momento específico en el futuro.

1. **Programación de tareas**: Puedes usar el comando `at` seguido de la hora en la que deseas que se ejecute el comando.

2. **Ejecución de comandos**: Después de especificar el tiempo, puedes escribir los comandos que deseas ejecutar en ese momento. Puedes escribir múltiples comandos, uno por línea.

3. **Envío de comandos**: Una vez que hayas escrito los comandos que deseas ejecutar, presionas `Ctrl+D` para finalizar la entrada. En este punto, el sistema registrará estos comandos para ejecutarlos en el tiempo especificado.

4. **Confirmación y salida**: Una vez que hayas enviado los comandos, el sistema te mostrará un mensaje que confirma la programación de las tareas.

5. **Ejecución de tareas**: Cuando llegue el momento especificado, el sistema ejecutará los comandos que programaste con `at`.

Aquí tienes un ejemplo de cómo programar un comando para ejecutarse a una hora específica:

```bash
si@si-VirtualBox:~$ at now + 2 minute
warning: commands will be executed using /bin/sh
at Wed Apr 17 14:22:00 2024
at> touch /home/si/at.txt
at> <EOT>
job 8 at Wed Apr 17 14:22:00 2024

si@si-VirtualBox:~$ ls
Desktop  Documents  Downloads  Music  Pictures  Public  snap  Templates  Videos

si@si-VirtualBox:~$ ls
at.txt  Desktop  Documents  Downloads  Music  Pictures  Public  snap  Templates  Videos
```

Luego, puedes escribir los comandos que deseas ejecutar y presionar `Ctrl+D` para enviarlos.

Por otra parte, el parámetro `-f` de `at` se utiliza para especificar un archivo que contiene los comandos que deseas ejecutar en lugar de escribir los comandos directamente en la línea de comandos. Esto puede ser útil cuando tienes una serie de comandos complejos o largos que deseas ejecutar en un momento específico.

La sintaxis básica de `at` con el parámetro `-f` es la siguiente:

```
at [hora] -f archivo.sh
```

- `[hora]` es el momento en el que deseas que se ejecuten los comandos.
- `archivo` es el nombre del archivo que contiene los comandos que deseas ejecutar.

```
at 10:00 PM -f script.txt
```
