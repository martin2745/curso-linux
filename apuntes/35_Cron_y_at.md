# Comando crontab y at

## Índice

1. [Cron](#1-cron)
   1. [Opciones de crontab](#11-opciones-de-crontab)
   2. [Ejemplos de uso de Cron](#12-ejemplos-de-uso-de-cron)
   3. [Control de acceso a Cron](#13-control-de-acceso-a-cron)
2. [at y atd](#2-at-y-atd)
   1. [Formato de hora en at](#21-formato-de-hora-en-at)
   2. [Control de acceso a at](#22-control-de-acceso-a-at)

---

## 1. Cron

Crond es un servicio del sistema que ejecuta mandatos en horarios determinados. Los mandatos programados pueden definirse en el archivo de configuración `/etc/crontab`. Se puede utilizar además el directorio `/etc/cron.d`, que sirve para almacenar archivos con el mismo formato del archivo `/etc/crontab`.

El sistema dispone además de varios directorios utilizados por el servicio crond:

- `/etc/cron.daily`: todo lo que se coloque dentro de este directorios, se ejecutará una vez todos los días.
- `/etc/cron.hourly`: todo lo que se coloque dentro de este directorios, se ejecutará una vez cada hora.
- `/etc/cron.monthly`: todo lo que se coloque dentro de este directorios, se ejecutará una vez al mes.
- `/etc/cron.weekly`: todo lo que se coloque dentro de este directorios, se ejecutará una vez cada semana.
- `/etc/cron.yearly`: todo lo que se coloque dentro de este directorios, se ejecutará una vez al año.

> **Nota:** Lo que se coloca en estos directorios no son líneas de crontab, sino **scripts ejecutables**. Es `/etc/crontab` quien los lanza a través de la utilidad `run-parts`, que ejecuta por orden todos los scripts de un directorio. Por eso los ficheros de estas carpetas **no llevan extensión `.sh`**: `run-parts` ignora por defecto los nombres que contienen un punto, de modo que un script llamado `copia.sh` no se ejecutaría.

> **Advertencia:** Estas tareas dependen de que el equipo esté encendido a la hora prevista. En un ordenador que se apaga por las noches, las tareas de `cron.daily` programadas de madrugada no llegarían a ejecutarse nunca. Para esos casos existe `anacron`, que no ejecuta las tareas a una hora fija sino que garantiza que se hayan ejecutado en las últimas 24 horas, un día o un mes, poniéndolas al día en el siguiente arranque si se saltó alguna.

```bash
usuario@debian:~$ systemctl status cron
● cron.service - Regular background program processing daemon
     Loaded: loaded (/lib/systemd/system/cron.service; enabled; preset: enabled)
     Active: active (running) since Thu 2025-05-08 14:21:05 CEST; 1 day 5h ago
       Docs: man:cron(8)
   Main PID: 570 (cron)
      Tasks: 1 (limit: 2303)
     Memory: 436.0K
        CPU: 434ms
     CGroup: /system.slice/cron.service
             └─570 /usr/sbin/cron -f

Warning: some journal files were not opened due to insufficient permissions.
```

Antes de ver los ficheros conviene entender el formato de una línea, que consta de cinco campos de tiempo seguidos del comando:

```text
 ┌────────── minuto        (0 - 59)
 │ ┌──────── hora          (0 - 23)
 │ │ ┌────── día del mes   (1 - 31)
 │ │ │ ┌──── mes           (1 - 12)
 │ │ │ │ ┌── día de la semana (0 - 7, donde 0 y 7 son domingo)
 │ │ │ │ │
 * * * * *  comando a ejecutar
```

Cada campo admite, además de un valor concreto, cuatro notaciones:

| Notación | Significado | Ejemplo |
|---|---|---|
| `*` | Todos los valores posibles del campo. | `* * * * *` es cada minuto. |
| `,` | Lista de valores. | `0,30` en los minutos: en el minuto 0 y en el 30. |
| `-` | Rango de valores. | `1-5` en el día de la semana: de lunes a viernes. |
| `/` | Paso o intervalo. | `*/15` en los minutos: cada quince minutos. |

> **Advertencia:** El error más frecuente al empezar es confundir el campo de los minutos con el de las horas. Una expresión como `* 3 * * *` **no** se ejecuta una vez, a las 3 de la mañana: se ejecuta **los sesenta minutos** de las 3, es decir, sesenta veces. Para las 3:00 en punto hay que fijar el minuto: `0 3 * * *`. El mismo descuido apareció en el documento 30 con la sincronización horaria.

> **Nota:** Existen además atajos que sustituyen a los cinco campos: `@reboot` (una vez, en cada arranque), `@hourly` (equivale a `0 * * * *`), `@daily` (`0 0 * * *`), `@weekly`, `@monthly` y `@yearly`. Para construir y verificar expresiones complejas resulta muy cómodo el sitio *crontab.guru*.

El archivo `/etc/crontab` es un archivo global de configuración de cron en sistemas Linux. A diferencia del `crontab -e` (que es específico por usuario), este archivo puede contener tareas programadas para cualquier usuario, ya que incluye el campo del usuario en cada línea.

```text
m h dom mon dow user command
17 * * * * usuario run-parts /etc/cron.hourly
25 6 * * * root /usr/local/bin/backup.sh
```

| Característica             | crontab -e                                          | /etc/crontab                             |
| -------------------------- | --------------------------------------------------- | ---------------------------------------- |
| Especifica usuario         | No                                                  | Sí                                       |
| Alcance                    | Usuario actual                                      | Global (multiusuario)                    |
| Ubicación física           | ~/.crontab gestionado (en /var/spool/cron/crontabs) | Archivo real: /etc/crontab               |
| Editable por               | Solo el usuario                                     | Root o sudoers                           |
| Formato de línea           | m h dom mon dow comando                             | m h dom mon dow usuario comando          |
| Recarga tras edición       | Automática al guardar                               | No requiere comando especial tras editar |
| Permite variables globales | No habitualmente                                    | Sí (SHELL, PATH, etc.)                   |

> **Nota:** Se recomienda no editar `/etc/crontab` si puedes usar `crontab -e`, para mantener las tareas separadas y más seguras. Todos los usuarios del sistema operativo pueden utilizar cron.

### 1.1 Opciones de crontab

| Parámetro | Definición |
|-----------|------------|
| `-l` | Permite mostrar la lista de las tareas del cron del usuario. |
| `-e` | Permite editar el cron del usuario en cuestión. |
| `-r` | Elimina el crontab del usuario. |

Como usuario root podemos ver las tareas programadas de otros usuarios e incluso programarles tareas.

- `crontab -l -u berto`
- `crontab -e -u berto`

### 1.2 Ejemplos de uso de Cron

```bash
## Tarea cada 5 minutos
*/5 * * * *  /sbin/service httpd reload > /dev/null 2>&1
*/5 * * * *  /usr/bin/systemctl reload httpd.service > /dev/null 2>&1
```

> **Advertencia:** `cron` ejecuta las tareas con un entorno **mínimo**, en el que la variable `PATH` se reduce normalmente a `/usr/bin:/bin`. Por eso un comando que funciona perfectamente en la terminal puede fallar en `cron` con un `command not found`: no está en esa ruta reducida. La solución es indicar siempre la **ruta absoluta** del comando (`/usr/bin/systemctl` en lugar de `systemctl`), o definir un `PATH` completo en la cabecera del crontab. Es, con diferencia, el motivo más común de que "la tarea funciona a mano pero no en cron".

> **Nota:** Como `cron` no tiene terminal, la salida de los comandos no se ve por ningún sitio: si el comando escribe algo y no se redirige, `cron` intenta enviarlo por correo local al usuario. De ahí el `> /dev/null 2>&1` con el que terminan casi todos los ejemplos, que descarta tanto la salida normal como los errores. Para depurar una tarea que falla, conviene al contrario **guardar** esa salida en un fichero: `>> /tmp/mitarea.log 2>&1`.

```bash
## A las 23h de todos los viernes
0 23 * * 5 root /usr/bin/yum -y update > /dev/null 2>&1
```

```bash
## El dia 1, 4, 7... de cada mes, cada minuto de cada hora:
* * */3 * * root /sbin/service httpd reload > /dev/null 2>&1
```

> **Advertencia:** El comentario original de este ejemplo decía "cada 3 días", pero la expresión no hace eso. `*/3` afecta al **día del mes**, y como los dos primeros campos son `*`, la tarea se ejecuta **cada minuto** de los días 1, 4, 7, 10... Además, `*/3` sobre el día del mes no da "cada 3 días" reales, porque el contador se reinicia al empezar el mes: entre el día 31 y el día 1 solo pasa un día, no tres. Para ejecutar algo una vez cada 72 horas de verdad hay que fijar los minutos y la hora: `0 4 */3 * *` lanza la tarea a las 4:00 de esos días.

```bash
## Se ejecuta cada 5 minutos, los dias laborables de lunes a viernes:
*/5 * * * 1-5 /usr/bin/rsync -av  -e ssh /datos/   usuario@192.168.33.10:/datos/
```

```bash
@reboot  mail -s "El sistema se ha reiniciado" admin@curso.local
0 22 * * * find /web -mtime 3 -print 2>&1 | mail -s "Ficheros modificados en los ultimos 3 dias" admin@curso.local
```

```bash
## Ejecuta la tarea a las 14:01 solo de lunes a viernes
1 14 * * 1-5 fulano /home/fulano/bin/tarea.sh > /dev/null
```

```bash
## Ejecución de df todos los días, todo el año, cada cuarto de hora:
0,15,30,45 * * * * /usr/bin/df > /tmp/libre
```

```bash
## Arranque de un comando cada 5 minutos a partir de 2 (2, 7, 12, etc.) a las 18 horas los días 1 y 15 de cada mes:
2-57/5 18 1,15 * * comando
```

### 1.3 Control de acceso a Cron

Se puede controlar el acceso con el comando crontab por usuario con los archivos `/etc/cron.allow` y `/etc/cron.deny`.

- En nuestro sistema por defecto existe el fichero `/etc/cron.deny` donde se puede especificar qué usuarios no pueden usar el servicio cron.
- Si creamos el archivo `/etc/cron.allow`, solamente los usuarios que estén en este archivo pueden utilizar cron. En el momento que se crea este archivo todo el mundo queda denegado para el uso del servicio cron salvo los que figuren en el archivo. Usamos `touch /etc/cron.allow && echo "usuario" >> /etc/cron.allow` para ello.
- Al usuario root no le afecta `/etc/cron.allow` ni `/etc/cron.deny`.

---

## 2. at y atd

Los mandatos `at` y `batch` se utilizan sólo para programar la ejecución de mandatos de una sola ocasión. En el caso de que se requiera programar mandatos para ser ejecutados periódicamente, se sugiere hacerlo a través de crontab.

```bash
usuario@debian:~$ sudo apt install -y atd
...
usuario@debian:~$ systemctl status atd
● atd.service - Deferred execution scheduler
     Loaded: loaded (/lib/systemd/system/atd.service; enabled; preset: enabled)
     Active: active (running) since Fri 2025-05-09 20:09:13 CEST; 20s ago
       Docs: man:atd(8)
   Main PID: 17851 (atd)
      Tasks: 1 (limit: 2303)
     Memory: 248.0K
        CPU: 35ms
     CGroup: /system.slice/atd.service
             └─17851 /usr/sbin/atd -f
```

Puedo crear una tarea de la siguiente forma con `at`, listar las tareas programadas y eliminarlas por su identificador:

```bash
usuario@debian:~$ at 23:00
warning: commands will be executed using /bin/sh
at Fri May  9 23:00:00 2025
at> ./opt/scripts/supervisamen
at> <EOT> # con Ctrl+d para finalizar
job 1 at Fri May  9 23:00:00 2025

usuario@debian:~$ atq
1       Fri May  9 23:00:00 2025 a usuario

usuario@debian:~$ atrm 1
```

Puedo crear la tarea en una sola linea:

```bash
usuario@debian:~$ at -f ./opt/scripts/supervisamen 20:15
```

### 2.1 Formato de hora en at

Se puede formatear la hora de la manera siguiente:

- `HHMM` o `HH:MM`.
- La hora puede tener el formato de 12 o 24 h. Con el formato de 12 horas, puede especificar `AM` (mañana) o `PM` (tarde).
- `midnight` (medianoche), `noon` (mediodía), `teatime` (16:00 h, típicamente inglés).
- `MMJJAA`, `MM/JJ/AA` o `JJ.MM.AA` para una fecha particular.
- `now`: ahora.
- `+ n minutes/hours/days/weeks`: la hora actual a la que se añaden n minutos/horas/días/semanas.

También permite establecer la ejecución utilizando `today` (hoy) y `tomorrow` (mañana) como argumentos. Ejemplo:

```bash
usuario@debian:~$ at 12:25 tomorrow -f /opt/scripts/supervisamem
usuario@debian:~$ at 08:25 today -f    /usr/bin/systemctl status httpd.service > /tmt/status-apache 2>&1
```

### 2.2 Control de acceso a at

Se colocan los jobs (tareas) en el directorio `/var/spool/atjobs`, a razón de un ejecutable por tarea.
Es posible controlar el acceso al comando at por usuario con los archivos `/etc/at.allow` y `/etc/at.deny`.
Todo el mundo puede utiliza `at` porque solo existe el archivo `/etc/at.deny`. Si creamos el archivo `/etc/at.allow` solamente los que están en este archivo pueden utilizar `at`.
