# El sistema de logs

## Índice

1. [rsyslog: Conceptos generales](#1-rsyslog-conceptos-generales)
2. [Configurar rsyslog como servidor remoto (recepción por UDP)](#2-configurar-rsyslog-como-servidor-remoto-recepcion-por-udp)
3. [Configuración del cliente Linux para enviar logs (UDP)](#3-configuracion-del-cliente-linux-para-enviar-logs-udp)
4. [Configuración del cliente Linux para enviar logs por TCP](#4-configuracion-del-cliente-linux-para-enviar-logs-por-tcp)
5. [Notas sobre el uso de `@` y `@@`](#5-notas-sobre-el-uso-de--y-)
6. [Probando los logs locales](#6-probando-los-logs-locales)
7. [journalctl y almacenamiento persistente](#7-journalctl-y-almacenamiento-persistente)
8. [Facilidades en rsyslog](#8-facilidades-en-rsyslog)
9. [logrotate](#9-logrotate)
   1. [Comandos básicos](#91-comandos-basicos)
   2. [Opciones de configuración](#92-opciones-de-configuracion)
   3. [Parámetros size, minsize y maxsize](#93-parametros-size-minsize-y-maxsize)
   4. [Verificar la configuración](#94-verificar-la-configuracion)
10. [Archivo de marca de tiempo en logrotate](#10-archivo-de-marca-de-tiempo-en-logrotate)

---

## 1. rsyslog: Conceptos generales

Cuando el sistema se inicia o efectúa cualquier tipo de acción, se registran sus acciones y las de la mayoría de sus servicios en diferentes ficheros. Dos servicios están especializados en la recepción de los mensajes que tienen como destino estos ficheros.

- `syslogd`: gestiona los logs del sistema. Distribuye los mensajes a archivos, tuberías, destinos remotos, terminales o usuarios, usando las indicaciones especificadas en su archivo de configuración `/etc/syslog.conf`, donde se indica qué se loguea y a dónde se envían estos logs. Por otro lado, es posible configurar el servicio `rsyslog.service` para que equipos remotos puedan escribir sus mensajes de log en el propio servidor que ejecuta el servicio syslog remoto.
- `klogd`: se encarga de los logs del kernel. Lo normal es que `klogd` envíe sus mensajes a syslogd pero no siempre es así, sobre todo en los eventos de alta prioridad, que salen directamente por pantalla.

Los logs se guardan en archivos ubicados en el directorio `/var/log`, aunque muchos programas manejan sus propios logs y los guardan en `/var/log/<programa>`. Algunos de los logs más importantes son:

| Archivo | Descripción |
|---------|-------------|
| `/var/log/messages` | Logs con prioridad `info`, `notice` o `warn`. |
| `/var/log/kern.log` | Logs del kernel, generados por `klogd`. |
| `/var/log/auth.log` | Registro de logins, intentos fallidos (`invalid password`, `authentication failure`), uso de `su`, etc. |
| `/var/log/dmesg` | Información generada por el kernel durante el arranque del sistema. |

---

## 2. Configurar rsyslog como servidor remoto (recepción por UDP)

Edita el archivo de configuración:

```bash
vi /etc/rsyslog.conf
```

Agrega o descomenta las siguientes líneas para habilitar la recepción por UDP:

```bash
# Provides UDP syslog reception
$ModLoad imudp
$UDPServerRun 514

# Provides TCP syslog reception
#$ModLoad imtcp
#$InputTCPServerRun 514
```

Reinicia el servicio rsyslog para aplicar los cambios:

```bash
systemctl restart rsyslog.service
```

Verifica que rsyslog esté escuchando en el puerto 514:

```bash
netstat -putan | grep 514
```

La salida esperada debe mostrar algo similar a:

```bash
udp        0      0 0.0.0.0:514             0.0.0.0:*                           1220/rsyslogd
```

---

## 3. Configuración del cliente Linux para enviar logs (UDP)

Edita `/etc/rsyslog.conf` y agrega las siguientes líneas para enviar los logs por UDP (un solo `@`) al servidor `192.168.33.10`:

```bash
# Log anything (except mail) of level info or higher.
# Don't log private authentication messages!
*.info;mail.none;authpriv.none;cron.none                /var/log/messages
                                                        @192.168.33.10

# The authpriv file has restricted access.
authpriv.*                                              @192.168.33.10
```

Reinicia el servicio rsyslog:

```bash
systemctl restart rsyslog.service
```

---

## 4. Configuración del cliente Linux para enviar logs por TCP

Edita el archivo de configuración:

```bash
vi /etc/rsyslog.conf
```

Agrega las siguientes líneas para enviar los logs por TCP (doble `@@`):

```bash
# Log anything (except mail) of level info or higher.
# Don't log private authentication messages!
*.info;mail.none;authpriv.none;cron.none                /var/log/messages
                                                        @@192.168.33.10

# The authpriv file has restricted access.
authpriv.*                                              /var/log/secure
                                                        @@192.168.33.10

# Log all the mail messages in one place.
mail.info                                               -/var/log/maillog
```

Reinicia el servicio rsyslog:

```
systemctl restart rsyslog.service
```

| Notación | Protocolo | Descripción |
|----------|-----------|-------------|
| `@host` | UDP | Envía los mensajes al servidor syslog remoto por UDP. |
| `@@host` | TCP | Envía los mensajes al servidor syslog remoto por TCP. |

> **Nota:** Se recomienda usar `@@` (TCP) en entornos donde la integridad y la fiabilidad de los registros son críticas. TCP garantiza la entrega, el orden correcto y la retransmisión ante pérdida de paquetes, a diferencia de UDP.

---

## 6. Probando los logs locales

El comando _logger_ en Linux se utiliza para enviar mensajes al sistema de registro de eventos (syslog o rsyslog). Es una forma conveniente de generar mensajes de registro directamente desde la línea de comandos o desde scripts.

Para probar nuestro sistema de forma local, vamos a simular un error en una aplicación  
de correo. Los logs no se escriben a mano sino a través de la orden “logger”. La sintaxis  
la puedes consultar con:

```bash
man logger
```

Entrada en el rsyslog.conf, para los logs de mail:

```bash
# Log all the mail messages in one place.
mail.*                                                  -/var/log/maillog
```

En nuestro caso vamos a usar la orden:

```bash
logger -p mail.info "Esto es una prueba"
logger -p mail.emerg "Esto es una prueba de emergencia"

tail -f /var/log/maillog
```

La opción -p imprime el mensaje “Esto es una prueba” en el subsitema llamado “mail.err”

Equivalente para systemd al comando logger de syslog:
El comando systemd-cat es una utilidad en Linux que permite enviar mensajes de registro directamente al journal de systemd. Es una alternativa a logger, pero en lugar de enviar los mensajes a syslog o rsyslog, los envía directamente al Journal de systemd.

```bash
systemd-cat
```

Execute process with stdout/stderr connected to the journal.

```bash
systemd-cat

journalctl -f

echo 'hello1' | systemd-cat -p info
echo 'hello2' | systemd-cat -p warning
echo 'hello3' | systemd-cat -p emerg
```

---

## 7. journalctl y almacenamiento persistente

El comando `journalctl` en sistemas Linux se utiliza para ver y analizar los logs del sistema generados por `systemd`. Es muy útil para depurar problemas y obtener información detallada sobre los eventos del sistema.

> **Nota:** Por defecto, el journal almacena los archivos de log solo en memoria o en un pequeño buffer en `/run/log/journal/`. Para hacerlo persistente entre reinicios, sigue los pasos a continuación.

```bash
mkdir -p /var/log/journal/
systemd-tmpfiles --create --prefix /var/log/journal
chown root:systemd-journal /var/log/journal
chmod 2775 /var/log/journal
```

Then, restart journald to apply the change:

```bash
systemctl restart systemd-journald
```

Comandos journalctl:

```bash
journalctl                      # Ver todos los logs
journalctl -f                   # Seguir los logs en tiempo real
journalctl -b                   # Ver logs desde el último arranque
journalctl -u nombre_servicio   # Ver los logs de un servicio específico
journalctl -p err               # Ver solo logs de nivel de error
journalctl --since "YYYY-MM-DD HH:MM:SS"   # Ver logs desde un tiempo específico
journalctl --vacuum-size=500M   # Limpiar logs antiguos que excedan un tamaño
journalctl -r                   # Ver los logs en orden inverso (más reciente primero)
```

Limpiar registros reteniendo como máximo 2GB:

```bash
journalctl --vacuum-size=2G
```

Limpiar registros y retener sólo los 2 últimos años:

```bash
journalctl --vacuum-time=2years
```

Ver los logs del service sshd del último minuto:

```bash
journalctl --since '1 min ago' -u sshd
```

¿Quién puede ver los registros que va recopilando journald?  
Solo root

Para que un usuario nominal pueda utilizar el comando journalctl, tiene que estar en el grupo systemd-journal:

```bash
adduser operador
passwd operador
usermod -G systemd-journal operador
```

---

## 8. Facilidades en rsyslog

En rsyslog, las **facilidades** (*facilities*) son categorías que identifican el origen o tipo de los mensajes de log. Permiten clasificar y gestionar los logs de manera eficiente. Cada facilidad tiene un nombre predefinido y un código numérico asociado.

Las facilidades más comunes son:

| Facilidad | Código Numérico | Descripción                                            |
| --------- | --------------- | ------------------------------------------------------ |
| auth      | 4               | Mensajes relacionados con la autenticación del sistema |
| authpriv  | 10              | Mensajes de autenticación privados, como SSH           |
| cron      | 9               | Mensajes relacionados con el servicio cron             |
| daemon    | 3               | Mensajes de procesos del sistema (como servicios)      |
| kern      | 0               | Mensajes del kernel                                    |
| lpr       | 6               | Mensajes de impresión                                  |
| mail      | 2               | Mensajes relacionados con correo electrónico           |
| news      | 7               | Mensajes de servidores de noticias (NNTP)              |
| syslog    | 5               | Mensajes generados por el propio servicio syslog       |
| user      | 1               | Mensajes generados por procesos de usuario             |
| uucp      | 8               | Mensajes de protocolos UUCP                            |

## Facilidades Locales (local0 a local7)

Las facilidades local0 a local7 están reservadas para uso personalizado o privado. No están asignadas a ningún servicio en particular, lo que permite a los administradores y desarrolladores utilizarlas para registrar mensajes específicos de sus aplicaciones o procesos personalizados.

| Facilidad | Código Numérico |
| --------- | --------------- |
| local0    | 16              |
| local1    | 17              |
| local2    | 18              |
| local3    | 19              |
| local4    | 20              |
| local5    | 21              |
| local6    | 22              |
| local7    | 23              |

## Ejemplos de Uso de Facilidades Locales

**Configuración en rsyslog:**

```bash
vi /etc/rsyslog.conf
```

**Añadimos en rules:**

```bash
local0.*    /var/log/local0.log
local1.*    /var/log/local1.log
local7.*    /var/log/local7.log
```

```bash
systemctl restart rsyslog.service
```

**Generar mensajes de log con logger, los ficheros se crean cuando lanzamos el comando logger:**

```bash
logger -p local0.info "Mensaje de prueba en local0"
logger -p local1.warn "Advertencia en local1"
logger -p local7.error "Error crítico en local7"
```

**Verificar los logs:**

```bash
tail -f /var/log/local0.log
tail -f /var/log/local1.log
tail -f /var/log/local7.log
```

## Recomendaciones para el Uso de Facilidades Locales

1. Organización y Documentación:

   - Define claramente el propósito de cada facilidad en tus aplicaciones.
   - Mantén una convención consistente.

2. Rotación de Logs:

   - Configura la rotación de logs para evitar que los archivos crezcan sin control.

3. Centralización de Logs:
   - Si tienes varios servidores o dispositivos de red, considera enviar los logs locales a un servidor central.

---

## 9. logrotate

`logrotate` es una herramienta en sistemas Linux utilizada para la gestión y rotación de archivos de registro (logs). Su objetivo principal es archivar, comprimir, eliminar o enviar archivos de registro antiguos para mantener el almacenamiento bajo control y garantizar que los archivos de log no crezcan indefinidamente.

### ¿Por qué usar logrotate?

- **Gestión de espacio en disco:** Evita que los archivos de log ocupen todo el almacenamiento.
- **Automatización:** Realiza la rotación, compresión y eliminación de logs automáticamente.
- **Mantenimiento de históricos:** Guarda archivos antiguos comprimidos para referencia futura.
- **Flexibilidad:** Soporta configuraciones personalizadas para diferentes aplicaciones y servicios.

### Arquitectura de logrotate

`logrotate` utiliza archivos de configuración para definir la frecuencia de rotación (diaria, semanal, mensual), la cantidad de archivos a retener, la compresión de logs y las acciones posteriores (como reiniciar servicios).

| Ruta | Descripción |
|------|-------------|
| `/var/log` | Directorio principal de logs del sistema. |
| `/etc/logrotate.conf` | Archivo de configuración global de logrotate. |
| `/etc/logrotate.d/` | Directorio con configuraciones específicas por servicio. |

### 9.1. Comandos básicos

```bash
logrotate
cat /etc/logrotate.conf
ls -l /etc/logrotate.d/
cat /etc/logrotate.d/httpd
```

Ejemplo de configuración `/etc/logrotate.d/httpd`:

```bash
/var/log/httpd/*log {
    missingok
    notifempty
    sharedscripts
    delaycompress
    postrotate
        /bin/systemctl reload httpd.service > /dev/null 2>/dev/null || true
    endscript
}
```

### Descripción de las opciones

- `/var/log/httpd/*log`: Indica que todos los archivos de logs dentro de `/var/log/httpd/` que terminen en log serán rotados.
- `missingok`: No muestra errores si los archivos de log no existen.
- `notifempty`: No rota el archivo si está vacío.
- `sharedscripts`: Ejecuta los scripts solo una vez por rotación, sin importar cuántos archivos de log se hayan rotado.
- `delaycompress`: No comprime los logs inmediatamente después de la rotación. La compresión se hace en la siguiente rotación (útil si el servicio aún escribe en el log después de la rotación).
- `postrotate / endscript`:
  - `systemctl reload httpd.service`: Recarga Apache (httpd) para que comience a escribir en los nuevos archivos de log.
  - `> /dev/null 2>/dev/null`: Silencia la salida estándar y los errores.
  - `|| true`: Evita que un fallo en el comando detenga logrotate.

### 9.2. Opciones de configuración

Ejemplo de configuración global `/etc/logrotate.conf`:

```bash
# Rotación global
weekly               # Rotar semanalmente
rotate 4             # Mantener 4 archivos de respaldo
create               # Crear un nuevo archivo de log vacío después de rotar
compress             # Comprimir logs rotados con gzip
include /etc/logrotate.d/ # Incluir configuraciones adicionales
```

#### Modificar la rotación de syslog por tamaño y frecuencia

```bash
cat /etc/logrotate.d/syslog
```

```bash
/var/log/cron /var/log/maillog /var/log/messages /var/log/secure /var/log/spooler /var/log/supervisamem.log {
    missingok
    sharedscripts
    postrotate
    /bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true
    endscript
    maxsize 100M
}
```

Con esto debe generar un archivo compreso en la carpeta `/var/log/` (si es que no cambiamos la ruta de los log).

```bash
logrotate -f /etc/logrotate.conf
```

### 9.3. Parámetros size, minsize y maxsize

- **size**: Define el tamaño mínimo que un archivo debe alcanzar para rotarse. No se basa en la frecuencia, solo en el tamaño.

  ```bash
  /var/log/app.log {
      size 10M
      rotate 5
      compress
  }
  ```

  Se rotará cuando `app.log` alcance 10MB, sin importar el tiempo transcurrido.

- **minsize**: Similar a size, pero considera la frecuencia (daily, weekly, monthly). Se rotará solo si el tamaño supera minsize en el periodo definido.

  ```bash
  /var/log/app.log {
      daily
      minsize 5M
      rotate 7
      compress
  }
  ```

  El log se rotará si tiene al menos 5MB al finalizar el día.

- **maxsize**: Forza la rotación cuando el log supera un tamaño determinado. Ignora la frecuencia y se ejecuta en la próxima verificación.
  ```bash
  /var/log/app.log {
      weekly
      maxsize 50M
      rotate 4
      compress
  }
  ```
  El log se rotará automáticamente si supera 50MB, incluso antes de cumplirse la semana.

#### Tamaño o día, lo que ocurra primero

```bash
vi /etc/logrotate.d/tomcat
```

```bash
/tomcat-9/logs/*.log {
    daily
    missingok
    copytruncate
    rotate 7
    compress
    size 50M
}
```

### Descripción de las opciones

- `/tomcat-9/logs/*.log`: Aplica la configuración a todos los archivos de log en el directorio `/tomcat-9/logs/` que terminen con `.log`.
- `daily`: Realiza la rotación diariamente.
- `missingok`: Si alguno de los archivos de log no existe, logrotate no mostrará un error.
- `copytruncate`: Hace una copia del archivo actual y luego lo trunca (lo vacía) en lugar de renombrarlo y crear uno nuevo.
- `rotate 7`: Conserva los últimos 7 archivos de log rotados.
- `compress`: Comprime los archivos rotados para ahorrar espacio en disco.
- `size 50M`: Si el archivo de log alcanza los 50MB antes de que se cumpla el ciclo diario, se rotará el archivo.

**Funcionamiento en conjunto:**  
Este bloque de configuración rotará los archivos de log de Tomcat diariamente o cuando el archivo alcance 50MB, lo que ocurra primero. Mantendrá los últimos 7 archivos rotados y comprimidos, eliminando los más antiguos. Además, el uso de `copytruncate` permite que el archivo de log sea truncado sin tener que reiniciar el servicio de Tomcat.

### 9.4. Verificar la configuración

```bash
logrotate -f /etc/logrotate.d/tomcat
```

Este comando se utiliza para forzar la rotación manual de los archivos de log según la configuración especificada.

```bash
logrotate -f /etc/logrotate.conf
```

El flag `-d` (o `--debug`) en logrotate se utiliza para ejecutar una simulación de rotación sin realizar ninguna acción real.

```bash
logrotate -d -v /etc/logrotate.conf
```

### ¿Cuándo usar logrotate -d?

- Verificar la Configuración: Para comprobar si el archivo de configuración de logrotate está correcto.
- Depuración de Problemas: Si los archivos de log no se están rotando correctamente, puedes usar el modo de depuración para ver qué está pasando.
- Simulación de Rotación: Útil para entender cómo se comportará el sistema antes de hacer cambios permanentes.

#### Salida de ejemplo

```
reading config file /etc/logrotate.conf
including /etc/logrotate.d
reading config file nginx
reading config info for /var/log/nginx/*.log
logrotate debug: state file /var/lib/logrotate/status reads:
logrotate debug: keyword 'weekly' seen in config file... logrotate debug: keyword 'rotate' seen in config file
logrotate debug: keyword 'compress' seen in config file
logrotate debug: keyword 'delaycompress' seen in config file
logrotate debug: keyword 'missingok' seen in config file
logrotate debug: keyword 'notifempty' seen in config file
logrotate debug: keyword 'create' seen in config file
logrotate debug: keyword 'postrotate' seen in config file
logrotate debug: keyword 'endscript' seen in config file

considering log /var/log/nginx/access.log
  log needs rotating (log has been rotated at Mon Mar 17 00:00:00 2024, rotation count 7)
```

> **Nota:** Siempre prueba la configuración con `-d` antes de ejecutar rotaciones reales. Combínalo con `-v` para obtener el máximo nivel de detalle.

---

## 10. Archivo de marca de tiempo en logrotate

En logrotate, el archivo de marca de tiempo es utilizado para registrar la última vez que se rotaron los logs. Este archivo permite que logrotate decida si debe realizar una nueva rotación basándose en la configuración especificada (como diaria, semanal o mensual).

**Ubicación del fichero de marca de tiempo**  
El archivo de marca de tiempo por defecto se encuentra en:

```
/var/lib/logrotate/status
```

Este archivo contiene la información sobre la última rotación de cada archivo de log gestionado por logrotate.

**Formato del archivo de marca de tiempo**

```
logrotate state -- version 2
"/var/log/nginx/access.log" 2025-03-23-03:15:01
"/var/log/nginx/error.log" 2025-03-23-03:15:01
"/var/log/syslog" 2025-03-23-03:15:01
"/var/log/auth.log" 2025-03-23-03:15:01
"/var/log/cron.log" 2025-03-23-03:15:01
```

- Ruta del archivo de log: Entre comillas dobles.
- Marca de tiempo: Fecha y hora de la última rotación en formato AAAA-MM-DD-HH:MM:SS.

### Eliminar el archivo de marca de tiempo

Si deseas forzar que todos los logs se roten la próxima vez que se ejecute logrotate, puedes eliminar el archivo de estado:

```bash
rm /var/lib/logrotate/status
```

Luego, ejecuta manualmente:

```bash
logrotate -f /etc/logrotate.conf
```

### Cambiar la ubicación del archivo de estado

Puedes cambiar la ubicación del archivo de estado en el archivo de configuración global:

```bash
vi /etc/logrotate.conf
statefile /var/lib/logrotate/mi_estado
```

**¿Qué pasa si se borra el archivo de estado?**

- Logrotate rotará todos los archivos en la próxima ejecución, ya que no tiene registros previos.
- Se creará un nuevo archivo de estado después de la rotación.
- Esto puede provocar rotación doble si se ejecuta manualmente poco después de una rotación automática.
