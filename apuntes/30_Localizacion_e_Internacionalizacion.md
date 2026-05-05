# Localización e internacionalización

## Índice

1. [Sincronización de hora (NTP, chrony y hwclock)](#1-sincronización-de-hora-ntp-chrony-y-hwclock)
2. [Gestión de hora con timedatectl](#2-gestión-de-hora-con-timedatectl)
3. [Configuración regional (localectl y locale)](#3-configuración-regional-localectl-y-locale)
4. [Conversión de codificación y formatos](#4-conversión-de-codificación-y-formatos)

---

## 1. Sincronización de hora (NTP, chrony y hwclock)

**NTP (Network Time Protocol)** es un protocolo utilizado para sincronizar la hora de los sistemas en una red con precisión. Permite que servidores y clientes mantengan una hora exacta, lo que es esencial para registros de auditoría, transacciones financieras, autenticación y coordinación de eventos en sistemas distribuidos.

El paquete `chrony` reemplaza al clásico `ntpd`, proporcionando un binario más eficiente y adaptado para mantener la hora sincronizada con servidores NTP modernos.

El comando `hwclock` permite interrogar y manipular directamente el reloj hardware de la placa base (RTC - Real Time Clock). Es diferente del tiempo del sistema que proviene de NTP o del sistema operativo, permitiendo sincronizar ambas horas en las dos direcciones.

> **Nota:** Por defecto, la ejecución de `hwclock` con la opción `--show` visualiza la fecha actual del hardware.

```bash
root@debian:~# hwclock
2025-05-12 09:08:42.381776+02:00
```

Para sincronizar la hora física del hardware tomando como referencia la hora del sistema operativo:

```bash
root@debian:~# hwclock --systohc
```

Para realizar la operación inversa (el sistema copia la hora del hardware):

```bash
root@debian:~# hwclock --hctosys
```

Es posible forzar una sincronización manual con el comando `ntpdate`. Este comando utiliza como parámetro un nombre de servidor NTP. Si no se desea utilizar un demonio constante de NTP, se puede programar este comando en un trabajo de `cron` todos los días o todas las horas.

```bash
# Tarea cada 1 hora en crontab
* */1 * * *  /usr/sbin/ntpdate es.pool.ntp.org
```

> **Advertencia:** El uso de `ntpdate` está obsoleto en distribuciones modernas con `systemd`, recomendándose en su lugar el uso de `timedatectl` o `chronyd`.

---

## 2. Gestión de hora con timedatectl

El comando `timedatectl` en Linux se utiliza para consultar y cambiar la configuración relacionada con la fecha y hora del sistema, así como para gestionar la sincronización con servidores de tiempo mediante NTP. Es parte del ecosistema de `systemd` y reemplaza a herramientas más antiguas como `date` y `ntpdate`.

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

| Comando | Descripción |
|---------|-------------|
| `timedatectl list-timezones` | Lista todas las zonas horarias disponibles. |
| `timedatectl set-timezone Europe/Madrid` | Establece la zona horaria del sistema. |
| `timedatectl set-ntp false` | Deshabilita la sincronización NTP. |
| `timedatectl set-ntp true` | Habilita la sincronización NTP. |
| `timedatectl set-time "HH:MM:SS"` | Cambia la hora manualmente (solo posible si NTP está apagado). |

Si intentamos sincronizar la hora manualmente con el comando `timedatectl set-time` mientras tenemos el valor NTP activo (`enabled: yes`), el sistema no nos lo permitirá. Hay que desactivarlo temporalmente:

```bash
# Apagar NTP y cambiar hora
timedatectl set-ntp no
timedatectl set-time 18:00
timedatectl

# Volver a activar la sincronización NTP por red
timedatectl set-ntp yes
```

---

## 3. Configuración regional (localectl y locale)

El comando `localectl` en Linux se utiliza para gestionar la configuración de localización del sistema, como la distribución del teclado, el idioma del sistema y otros parámetros relacionados con la configuración regional. Es parte de `systemd` y evita tener que editar manualmente archivos como `/etc/locale.conf` o `/etc/vconsole.conf`.

```bash
localectl
localectl set-locale LANG=es_ES.utf8
localectl set-keymap es
localectl

cat /etc/locale.conf
LANG="es_ES.UTF-8"
```

Por otro lado, el comando `locale` permite recuperar información sobre los elementos de regionalización soportados por el sistema y ver los valores de las variables de entorno `LC_*`.

### Variables LC de localización

| Variable | Descripción |
|----------|-------------|
| `LC_CTYPE` | Clase de caracteres y conversión (ej. acentos, formato UTF-8). |
| `LC_NUMERIC` | Formato numérico por defecto (separadores de miles y decimales). |
| `LC_TIME` | Formato por defecto de la fecha y la hora. |
| `LC_COLLATE` | Reglas de comparación y ordenación alfabética. |
| `LC_MONETARY` | Formato de moneda. |
| `LC_MESSAGES` | Idioma de los mensajes informativos del sistema, errores y diagnósticos. |
| `LC_PAPER` | Formato de papel por defecto para impresión (ej. A4). |
| `LC_NAME` | Formato para el nombre de una persona. |
| `LC_ALL` | Sobrescribe de forma forzosa todas las demás variables `LC_*`. |

> **Nota:** En sistemas Debian antiguos sin `systemd` (o para reconfigurar a bajo nivel los locales compilados), se usa el comando interactivo: `dpkg-reconfigure locales`.

Ejemplo: Un usuario `oracle` que trabaja con una base de datos codificada en `iso88591`, mientras que el sistema Linux trabaja por defecto en `UTF-8`. Se pueden adaptar las variables de entorno de ese usuario en su perfil:

```bash
vi /home/oracle/.bash_profile
LANG=es_ES.iso88591
LC_CTYPE="es_ES.iso88591"
export LANG LC_CTYPE
```

---

## 4. Conversión de codificación y formatos

Es posible convertir un archivo de texto codificado en una tabla de caracteres concreta hacia otra distinta con la herramienta `iconv`.

El parámetro `-l` lista todas las codificaciones soportadas:

```bash
iconv -l
```

Para convertir un archivo desde `WINDOWS-1252` a `UTF-8`:

```bash
iconv -f WINDOWS-1252 -t UTF8 nombre_archivo
```

Para solucionar problemas de saltos de línea al transferir ficheros entre sistemas operativos, existe la herramienta `dos2unix`, que convierte los saltos de línea de un archivo de texto del formato Windows/DOS (`\r\n`) al formato Unix (`\n`) y viceversa.

```bash
yum install dos2unix -y
dos2unix /opt/supervisamem
dos2unix fichero
```
