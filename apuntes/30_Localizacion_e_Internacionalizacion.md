# Localización e internacionalización

## Índice

1. [Sincronización de hora (NTP, chrony y hwclock)](#1-sincronización-de-hora-ntp-chrony-y-hwclock)
2. [Gestión de hora con timedatectl](#2-gestión-de-hora-con-timedatectl)
3. [Práctica: servidor y cliente NTP con chrony (modelo de dominio)](#3-práctica-servidor-y-cliente-ntp-con-chrony-modelo-de-dominio)
   1. [Topología y direccionamiento](#31-topología-y-direccionamiento)
   2. [Configuración de la red interna](#32-configuración-de-la-red-interna)
   3. [Configuración del servidor (autoridad de tiempo)](#33-configuración-del-servidor-autoridad-de-tiempo)
   4. [Configuración del cliente](#34-configuración-del-cliente)
   5. [Comprobación de la sincronización](#35-comprobación-de-la-sincronización)
   6. [Relación con los dominios (Samba y Active Directory)](#36-relación-con-los-dominios-samba-y-active-directory)
4. [Configuración regional (localectl y locale)](#4-configuración-regional-localectl-y-locale)
   1. [Variables LC de localización](#41-variables-lc-de-localización)
5. [Conversión de codificación y formatos](#5-conversión-de-codificación-y-formatos)

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

## 3. Práctica: servidor y cliente NTP con chrony (modelo de dominio)

En esta práctica se montan dos máquinas virtuales: un **servidor** Ubuntu Server que expone la hora a la red y un **cliente** Debian 13 que se sincroniza con él. Es exactamente el modelo de un dominio: el controlador (Samba o Active Directory) hace de **autoridad de tiempo** y todos los equipos miembros ajustan su reloj al suyo.

Se usa **chrony** en las dos máquinas porque es el demonio que emplean hoy los servidores de dominio reales (sustituye al antiguo `ntpd`) y ofrece un diagnóstico muy claro con `chronyc`. El laboratorio es **aislado**: el servidor no toma la hora de Internet, sino que actúa como referencia con su propio reloj, lo que además permite fijar la hora en el servidor y comprobar cómo el cliente le sigue.

### 3.1 Topología y direccionamiento

| Máquina | Sistema | Rol | Adaptador 1 (NAT) | Adaptador 2 (Red interna `intnet-ntp`) |
|---|---|---|---|---|
| Servidor | Ubuntu Server | Autoridad de tiempo (chrony) | DHCP, solo para instalar | `192.168.100.1/24` |
| Cliente | Debian 13 | Cliente NTP (chrony) | DHCP, solo para instalar | `192.168.100.2/24` |

> **Nota:** Se usan dos adaptadores en cada VM. El **Adaptador 1 en modo NAT** sirve únicamente para tener Internet mientras se instala `chrony` con `apt`; una vez instalado, puede desactivarse. El **Adaptador 2 en Red interna** (con el mismo nombre en las dos VMs, por ejemplo `intnet-ntp`) es la red aislada por la que viajará el tráfico NTP. Los nombres reales de las interfaces (`enp0s3`, `enp0s8`...) pueden variar según la máquina; se consultan con `ip a` (documento 31).

### 3.2 Configuración de la red interna

En el **servidor** (Ubuntu Server usa Netplan, documento 31):

```yaml
# /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    enp0s8:            # Adaptador de la red interna del laboratorio
      dhcp4: false
      addresses:
        - 192.168.100.1/24
```

```bash
usuario@ubuntu-srv:~$ sudo chmod 600 /etc/netplan/01-netcfg.yaml
usuario@ubuntu-srv:~$ sudo netplan apply
```

En el **cliente** (Debian usa `/etc/network/interfaces`, documento 31):

```bash
# /etc/network/interfaces
auto enp0s8
iface enp0s8 inet static        # Adaptador de la red interna del laboratorio
    address 192.168.100.2
    netmask 255.255.255.0
```

```bash
root@debian:~# systemctl restart networking
```

Comprobar que las dos máquinas se ven entre sí, desde el cliente:

```bash
root@debian:~# ping -c 2 192.168.100.1
```

### 3.3 Configuración del servidor (autoridad de tiempo)

Instalar chrony (con el adaptador NAT activo para tener Internet):

```bash
usuario@ubuntu-srv:~$ sudo apt update && sudo apt install chrony -y
```

Editar `/etc/chrony/chrony.conf` y añadir al final estas dos líneas:

```bash
# Autorizar a los clientes de la red interna a pedir la hora
allow 192.168.100.0/24

# Actuar como fuente de tiempo válida aunque no haya servidor externo
local stratum 10
```

> **Importante:** La directiva `local stratum 10` es la clave del laboratorio aislado. Sin ella, chrony se considera "no sincronizado" (porque no alcanza los servidores de Internet) y **se niega a servir** la hora a nadie. Con `local`, se declara a sí mismo una referencia de tiempo válida —de *stratum* 10, deliberadamente alto para no competir con servidores reales— y ya puede atender a los clientes. La directiva `allow` define desde qué red se aceptan las peticiones.

Reiniciar el servicio y comprobar que escucha en el puerto NTP (UDP 123):

```bash
usuario@ubuntu-srv:~$ sudo systemctl restart chrony
usuario@ubuntu-srv:~$ sudo ss -putan | grep 123
udp   UNCONN 0      0               0.0.0.0:123       0.0.0.0:*    users:(("chronyd",pid=2012,fd=6))
```

> **Nota:** Si el servidor tuviera activo el cortafuegos `ufw` (documento 44), habría que permitir el tráfico NTP: `sudo ufw allow from 192.168.100.0/24 to any port 123 proto udp`. En una instalación estándar de Ubuntu Server, `ufw` viene inactivo.

### 3.4 Configuración del cliente

Instalar chrony. Al hacerlo, **sustituye automáticamente a `systemd-timesyncd`**, que es el cliente NTP por defecto de Debian (ambos no pueden convivir):

```bash
root@debian:~# apt update && apt install chrony -y
```

Editar `/etc/chrony/chrony.conf`: comentar las líneas `pool ...` que trae por defecto y añadir el servidor del laboratorio como única fuente:

```bash
# pool 2.debian.pool.ntp.org iburst      <- comentar esta línea
server 192.168.100.1 iburst
```

> **Nota:** `iburst` hace que, al arrancar, el cliente envíe una ráfaga inicial de peticiones para sincronizarse en pocos segundos, en lugar de tardar varios minutos.

Reiniciar el servicio:

```bash
root@debian:~# systemctl restart chrony
```

### 3.5 Comprobación de la sincronización

En el cliente, ver la fuente de tiempo y su estado:

```bash
root@debian:~# chronyc sources -v
MS Name/IP address        Stratum Poll Reach LastRx Last sample
===============================================================
^* 192.168.100.1               10    6   377     17    +2us[  +9us] +/-  312us
```

El símbolo `^*` indica que ese servidor es la fuente **seleccionada y activa**. Con `chronyc tracking` se ven los detalles:

```bash
root@debian:~# chronyc tracking
Reference ID    : C0A86401 (192.168.100.1)
Stratum         : 11
System time     : 0.000012 seconds fast of NTP time
...
```

> **Nota:** El cliente aparece como *stratum* 11, justo uno más que el servidor (10): cada salto en la cadena de tiempo incrementa el *stratum* en una unidad. El `Reference ID` confirma que su reloj procede de `192.168.100.1`.

Para demostrar que el cliente **sigue** al servidor, se le pone a propósito una hora errónea y se fuerza la corrección:

```bash
root@debian:~# systemctl stop chrony
root@debian:~# date -s "2020-01-01 00:00:00"
root@debian:~# date                      # hora completamente incorrecta
mié ene  1 00:00:00 CET 2020
root@debian:~# systemctl start chrony
root@debian:~# chronyc makestep          # aplica de golpe la corrección
root@debian:~# date                      # el reloj vuelve a la hora del servidor
```

> **Nota:** Por defecto, chrony corrige la hora poco a poco (*slew*, acelerando o frenando el reloj) para no dar saltos bruscos que confundan a los programas en ejecución. `chronyc makestep` fuerza un ajuste inmediato de golpe, muy útil para ver el efecto al instante durante la clase.

### 3.6 Relación con los dominios (Samba y Active Directory)

En un dominio gestionado por Active Directory, o por Samba actuando como controlador de dominio, esta sincronización no es opcional sino **obligatoria**. El protocolo de autenticación **Kerberos** incluye marcas de tiempo en sus *tickets* y rechaza cualquiera cuyo reloj difiera del servidor en más de **5 minutos** (tolerancia por defecto). Por eso el controlador de dominio hace de autoridad de tiempo de toda la red —el mismo papel que el servidor de esta práctica— y los equipos miembros se sincronizan con él.

En un Samba AD real se da un paso más: chrony se configura en el controlador con la directiva `ntpsigndsocket /var/lib/samba/ntp_signd`, que le permite **firmar** las respuestas NTP (extensión MS-SNTP) para que los clientes Windows puedan verificar que la hora procede realmente del dominio y no de un impostor.

---

## 4. Configuración regional (localectl y locale)

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

### 4.1 Variables LC de localización

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

## 5. Conversión de codificación y formatos

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
