# Localizacion e internacionalización

_NTP_ (Network Time Protocol) es un protocolo utilizado para sincronizar la hora de los sistemas en una red con precisión. Permite que servidores y clientes mantengan una hora exacta, lo que es esencial para registros de auditoría, transacciones financieras, autenticación y coordinación de eventos en sistemas distribuidos.

El paquete _chrony_ remplaza al ntpd, un binario que nos ofrece la posibilidad de mantener la hora sincronizada con servidores NTP.

El comando _hwclock_ permite interrogar directamente al reloj hardware RTC. El parámetro --show (por defecto) visualiza la fecha actual. Es diferente del tiempo del sistema que proviene de ntp o fecha. Puede sincronizar la hora del sistema y la hora física en los dos sentidos.

```bash
root@debian:~# hwclock
2025-05-12 09:08:42.381776+02:00
```

- Para que se sincronice la hora física desde la hora del sistema.

```bash
root@debian:~# hwclock --systohc
```

- Para realizar lo contrario.

```bash
root@debian:~# hwclock --hctosys
```

Es posible forzar una sincronización manual con el comando _ntpdate_. Este comando utiliza como parámetro un nombre de servidor ntp. Si no desea utilizar el servicio ntp, puede colocar este comando en crontab todos los días o todas las horas.

```bash
Tarea cada 1 hora
* */1 * * *  /usr/sbin/ntpdate es.pool.ntp.org
```

El comando _timedatectl_ en Linux se utiliza para consultar y cambiar la configuración relacionada con la fecha y hora del sistema, así como para gestionar la sincronización con servidores de tiempo mediante NTP (Network Time Protocol). Es parte de systemd y reemplaza herramientas más antiguas como date y ntpdate.

```bash
root@debian:~# timedatectl
               Local time: lun 2025-05-12 09:14:23 CEST
           Universal time: lun 2025-05-12 07:14:23 UTC
                 RTC time: lun 2025-05-12 07:14:23
                Time zone: Europe/Madrid (CEST, +0200)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
```

Entre sus opciones tenemos:

- timedatectl list-timezones
- timedatectl set-timezone Europe/Madrid
- timedatectl set-ntp false
- timedatectl set-ntp true

Sincronizar la hora manualmente con el comando timedatectl, si tenemos el valor NTP enabled: yes no permite el cambio de hora manualmente:

```bash
timedatectl set-time 18:00
timedatectl set-ntp no
timedatectl
timedatectl set-time 18:00
timedatectl
##Para que tengamos la hora a traves de nuetro cliente de ntp:
timedatectl set-ntp yes
```

El comando _localectl_ en Linux se utiliza para gestionar la configuración de localización del sistema, como la distribución del teclado, el idioma del sistema, y otros parámetros relacionados con la configuración regional. Es parte de systemd y reemplaza la necesidad de editar manualmente archivos como /etc/locale.conf o /etc/vconsole.conf.

```bash
localectl
localectl set-locale LANG=es_ES.utf8
localectl set-keymap es
localectl

cat /etc/locale.conf
LANG="es_ES.UTF-8"
```

El comando _locale_ permite recuperar información sobre los elementos de regionalización soportados por su sistema locale. Se puede modificar y adaptar cada una de las variables LC. Veamos su significado:

- LC_CTYPE: clase de caracteres y conversión, como pueden ser los acentos.
- LC_NUMERIC: formato numérico por defecto, diferente del de la moneda.
- LC_TIME: formato por defecto de la fecha y la hora.
- LC_COLLATE: reglas de comparación y de ordenación (por ejemplo, los caracteres acentuados).
- LC_MONETARY: formato monetario.
- LC_MESSAGES: formato de los mensajes informativos, interactivos y de diagnóstico.
- LC_PAPER: formato de papel por defecto (por ejemplo, A4).
- LC_NAME: formato del nombre de una persona.
- LC_ADDRESS: igual para una dirección.
- LC_TELEPHONE: igual para el teléfono.
- LC_ALL: reglas para todas las demás variables LC.

Para debian sin systemd.

```bash
dpkg-reconfigure locales
```

Ejemplo: usuario oracle donde trabaja con una base de datos de oracle codificada a iso88591, los sistemas de linux por defecto trabajar en utf8:

```bash
vi /home/oracle/.bash_profile
LANG=es_ES.iso88591
LC_CTYPE="es_ES.iso88591"
export LANG LC_CTYPE
```

Es posible convertir un archivo codificado en una tabla dada hacia otra tabla con el programa _iconv_. El parámetro -l le da todas las tablas soportadas:

```bash
iconv -l
```

Para convertir un archivo, utilice la sintaxis siguiente:

```bash
iconv -f WINDOWS-1252 -t UTF8 nombre_archivo
```

Herramienta para convertir saltos de línea en un archivo de texto del formato Unix al formato DOS y viceversa:

```bash
yum install dos2unix -y
dos2unix /opt/supervisamem
dos2unix fichero
```
