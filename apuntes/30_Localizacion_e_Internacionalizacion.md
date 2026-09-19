# Localización e internacionalización

## Índice

1. [Sincronización de hora (NTP, chrony y hwclock)](#1-sincronización-de-hora-ntp-chrony-y-hwclock)
2. [Gestión de hora con timedatectl](#2-gestión-de-hora-con-timedatectl)
3. [Configuración regional (localectl y locale)](#3-configuración-regional-localectl-y-locale)
   1. [Variables LC de localización](#31-variables-lc-de-localización)
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
0 * * * *  /usr/sbin/ntpdate es.pool.ntp.org
```

> **Advertencia:** El primer campo de una línea de `crontab` son los **minutos**. Una expresión como `* */1 * * *` no se ejecuta una vez por hora, sino **una vez por minuto**, porque el asterisco inicial abarca los sesenta minutos y `*/1` en el campo de las horas equivale simplemente a "todas". Para ejecutarla una sola vez cada hora hay que fijar el minuto, como en el `0 * * * *` del ejemplo. El documento 35 detalla el formato de `crontab`.

> **Advertencia:** El uso de `ntpdate` está obsoleto en distribuciones modernas con `systemd`, recomendándose en su lugar el uso de `timedatectl` o `chronyd`.

---

## 2. Gestión de hora con timedatectl

El comando `timedatectl` en Linux se utiliza para consultar y cambiar la configuración relacionada con la fecha y hora del sistema, así como para gestionar la sincronización con servidores de tiempo mediante NTP. Es parte del ecosistema de `systemd` y sustituye a herramientas más antiguas como `ntpdate` o la edición manual de `/etc/timezone`. No sustituye a `date`, que sigue siendo la herramienta para **mostrar y formatear** la fecha, tal como se vio en el documento 03; lo que `timedatectl` reemplaza es el uso de `date -s` para fijarla.

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
| `timedatectl set-local-rtc 0\|1` | Indica si el reloj hardware guarda la hora en UTC (`0`, recomendado) o en hora local (`1`). |
| `timedatectl timesync-status` | Muestra con qué servidor NTP se está sincronizando y con qué desviación. |
| `timedatectl show` | Presenta los mismos datos en formato `clave=valor`, apto para procesar desde un script. |

> **Nota:** La línea `RTC in local TZ: no` de la salida anterior merece atención en equipos con arranque dual. Linux guarda en el reloj de la placa base la hora **UTC** y aplica después el desfase de la zona horaria, mientras que Windows escribe en él la hora **local**. Al alternar entre ambos sistemas, cada uno reinterpreta lo que dejó el otro y el reloj aparece desplazado justo las horas del huso, dos en verano en la España peninsular. La solución limpia es configurar Windows para que use UTC; la rápida, `timedatectl set-local-rtc 1` en Linux, aunque introduce problemas propios con el cambio de horario estacional.

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
localectl set-locale LANG=es_ES.UTF-8
localectl set-keymap es
localectl

cat /etc/locale.conf
LANG="es_ES.UTF-8"
```

Por otro lado, el comando `locale` permite recuperar información sobre los elementos de regionalización soportados por el sistema y ver los valores de las variables de entorno `LC_*`.

### 3.1 Variables LC de localización

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

> **Importante:** Un *locale* no puede usarse si no ha sido **generado** previamente en la máquina. Asignar `LANG=es_ES.UTF-8` cuando ese locale no está compilado no produce un error visible, sino que el sistema recae en silencio sobre el locale `C` y los mensajes vuelven al inglés, o aparece el aviso `setlocale: LC_ALL: cannot change locale`. El procedimiento en Debian es descomentar la línea correspondiente en `/etc/locale.gen` y ejecutar `locale-gen`:
>
> ```bash
> root@debian:~# sed -i 's/^# *es_ES.UTF-8/es_ES.UTF-8/' /etc/locale.gen
> root@debian:~# locale-gen
> Generating locales (this might take a while)...
>   es_ES.UTF-8... done
> Generation complete.
> ```

Para consultar qué locales hay disponibles y cuáles están activos:

| Comando | Descripción |
|---|---|
| `locale` | Muestra el valor efectivo de todas las variables `LC_*`. |
| `locale -a` | Lista los locales **generados** y disponibles en el sistema. |
| `locale -m` | Lista las codificaciones de caracteres conocidas. |
| `locale -k LC_TIME` | Muestra el detalle de una categoría concreta, como los nombres de los meses y los formatos de fecha. |

> **Recuerda:** El orden de prioridad entre las variables es estricto y conviene tenerlo claro, porque explica por qué a veces un cambio no surte efecto:
>
> 1. **`LC_ALL`** se impone sobre todo lo demás. Está pensada para forzar un comportamiento puntual, como en `LC_ALL=C sort`, y no debería fijarse de forma permanente.
> 2. Las variables **`LC_*`** concretas (`LC_TIME`, `LC_NUMERIC`...) para su categoría.
> 3. **`LANG`** actúa como valor por defecto de todas las categorías que no se hayan fijado.
>
> Si alguien deja `LC_ALL` definida en su perfil, ningún cambio posterior de `LANG` tendrá efecto alguno, lo que resulta muy desconcertante.

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
iconv -f WINDOWS-1252 -t UTF-8 nombre_archivo
```

> **Advertencia:** `iconv` escribe el resultado en la **salida estándar** y no modifica el fichero original. La orden anterior se limita a volcar el texto convertido por pantalla. Para conservarlo hay que usar la opción `-o` o redirigir:
>
> ```bash
> usuario@debian:~$ iconv -f WINDOWS-1252 -t UTF-8 entrada.txt -o salida.txt
> ```
>
> Y en ningún caso debe redirigirse sobre el propio fichero de entrada (`iconv ... fichero > fichero`), porque el shell lo vacía antes de que `iconv` llegue a leerlo, tal como se explicaba en el documento 10.

> **Nota:** Para averiguar en qué codificación está un fichero antes de convertirlo, `file` ofrece una estimación:
>
> ```bash
> usuario@debian:~$ file -i entrada.txt
> entrada.txt: text/plain; charset=iso-8859-1
> ```

Para solucionar problemas de saltos de línea al transferir ficheros entre sistemas operativos, existe la herramienta `dos2unix`, que convierte los saltos de línea de un archivo de texto del formato Windows/DOS (`\r\n`) al formato Unix (`\n`) y viceversa.

```bash
apt install dos2unix -y
dos2unix /opt/supervisamem
dos2unix fichero
```

> **Nota:** `dos2unix` modifica el fichero **en el propio sitio**, a diferencia de `iconv`. La conversión inversa la realiza `unix2dos`. Sin instalar nada se consigue lo mismo con `tr -d '\r'`, tal como se vio en el documento 20, o con `sed -i 's/\r$//' fichero`.
