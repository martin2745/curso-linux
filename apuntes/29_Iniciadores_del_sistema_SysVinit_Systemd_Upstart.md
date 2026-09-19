# Iniciadores del sistema: SysVinit, Systemd, Upstart

## Índice

1. [Sistemas de inicio en Linux](#1-sistemas-de-inicio-en-linux)
2. [SysVinit y los Runlevels](#2-sysvinit-y-los-runlevels)
   1. [Comandos de gestión en SysVinit](#21-comandos-de-gestión-en-sysvinit)
3. [Systemd](#3-systemd)
   1. [Unidades (Units) y Targets](#31-unidades-units-y-targets)
   2. [Uso del comando systemctl](#32-uso-del-comando-systemctl)
4. [Comparativa: Systemd vs SysVinit](#4-comparativa-systemd-vs-sysvinit)
5. [Análisis de logs: journalctl y dmesg](#5-análisis-de-logs-journalctl-y-dmesg)
   1. [Comandos de journalctl](#51-comandos-de-journalctl)
   2. [Comando dmesg](#52-comando-dmesg)
6. [Comandos de apagado y reinicio](#6-comandos-de-apagado-y-reinicio)

---

## 1. Sistemas de inicio en Linux

Podemos encontrar tres tipos principales de procesos encargados de iniciar y gestionar los servicios o demonios en entornos Linux:

- **SysVinit**: El sistema de inicio tradicional. Utiliza scripts ubicados en `/etc/init.d/` y organiza el estado del sistema mediante "niveles de ejecución" (runlevels). La ejecución de servicios es secuencial.
- **Systemd**: El estándar moderno (adoptado masivamente desde 2015). Agrupa los servicios en "targets" en lugar de runlevels, gestionando eficientemente las dependencias, arrancando servicios en paralelo mediante sockets y centralizando los logs.
- **Upstart**: Desarrollado inicialmente por Ubuntu. Utiliza eventos para gestionar el arranque o parada de procesos de forma asíncrona (mayormente reemplazado hoy en día por systemd).

---

## 2. SysVinit y los Runlevels

En `SysVinit`, la configuración básica reside en el archivo `/etc/inittab`, donde se define el **nivel de ejecución** por defecto y las acciones iniciales del sistema.

- Se invoca al script `rc` pasándole por parámetro el nivel de ejecución (un número `N`).
- `rc` ejecuta los ficheros (enlaces simbólicos) que se encuentran en el directorio `/etc/rcN.d/` por estricto orden numérico.
- Estos ficheros enlazan a los verdaderos scripts alojados en `/etc/init.d/`.
- La nomenclatura de los enlaces dicta su comportamiento:
  - Si empieza por **S** (Start), `rc` inicia el servicio (`start`).
  - Si empieza por **K** (Kill), `rc` detiene el servicio (`stop`).

Los **Runlevels** tradicionales (a los que Systemd mantiene compatibilidad mediante alias) son:

> **Advertencia:** Solo los niveles **0**, **1** y **6** tienen un significado universal. Los niveles del 2 al 5 los define cada distribución a su gusto, y las dos grandes familias no coinciden. En **Debian**, los niveles 2, 3, 4 y 5 son **idénticos entre sí**: todos son multiusuario con red, y el entorno gráfico arranca si está instalado, sea cual sea el nivel. El nivel por defecto es el 2. En **Red Hat**, en cambio, el 3 es consola con red y el 5 añade el entorno gráfico. La tabla siguiente recoge la convención de Red Hat, que es la que suele preguntarse en los exámenes, pero conviene no aplicarla a Debian.

| Runlevel | Descripción |
|----------|-------------|
| **0** | Apagado del sistema. |
| **1** o **S** | Monousuario sin red para rescate/mantenimiento. No arranca entorno gráfico. |
| **2** | Multiusuario. En la convención de Red Hat, sin servicios de red; en Debian es el nivel por defecto y **sí** incluye red. |
| **3** | Multiusuario completo con red, en modo consola (convención de Red Hat/CentOS). |
| **4** | Reservado para uso personalizado o no utilizado. |
| **5** | Multiusuario completo con red e interfaz gráfica (convención de Red Hat/CentOS). |
| **6** | Reinicio del sistema. |

### 2.1 Comandos de gestión en SysVinit

| Comando | Función |
|---------|---------|
| `runlevel` | Muestra el nivel de ejecución previo y el actual. |
| `init N` o `telinit N` | Cambia el sistema al nivel de ejecución `N` (ej. `init 6` para reiniciar). |
| `service servicio acción` | Inicia, detiene o reinicia un servicio (ej. `service ssh restart`). |
| `update-rc.d` | Herramienta en Debian para habilitar/deshabilitar servicios en runlevels. |
| `chkconfig` | Equivalente a `update-rc.d` en distribuciones basadas en Red Hat. |

```bash
# Ejemplo de uso en Debian
update-rc.d network-manager disable 2

# Ejemplo de uso en Red Hat
chkconfig --level 3 httpd on
```

---

## 3. Systemd

Apareció en 2010 (desarrollado por ingenieros de Red Hat) para sustituir a SysVinit. Mejora drásticamente el paralelismo y el control de dependencias. 

Podemos comprobar si nuestro sistema usa Systemd viendo qué proceso tiene el PID 1:

```bash
usuario@debian:~$ ps -ef | head -2
UID          PID    PPID  C STIME TTY          TIME CMD
root           1       0  0 18:56 ?        00:00:01 /sbin/init

usuario@debian:~$ ls -l /sbin/init
lrwxrwxrwx 1 root root 20 jun 16  2024 /sbin/init -> /lib/systemd/systemd
```

### 3.1 Unidades (Units) y Targets

Systemd gestiona elementos llamados **unidades**. Las más comunes son:
- **.service**: Define un servicio (e.g., `nginx.service`, `sshd.service`).
- **.target**: Agrupaciones de unidades. Equivalente a los runlevels tradicionales.
- **.timer**: Tareas programadas (alternativa a `cron`).
- **.mount**: Controla puntos de montaje.

**Precedencia de directorios de unidades:**
1. `/etc/systemd/system/`: Máxima prioridad. Unidades creadas o modificadas por el administrador.
2. `/run/systemd/system/`: Unidades creadas dinámicamente en tiempo de ejecución.
3. `/lib/systemd/system/` (o `/usr/lib/...`): Unidades instaladas por el gestor de paquetes de la distribución.

> **Nota:** Para modificar una unidad empaquetada, nunca se edita el archivo en `/lib/systemd/system/`. En su lugar, se usa `systemctl edit nombre_servicio` (que crea un archivo *drop-in* en `/etc/`) o se copia el archivo entero a `/etc/systemd/system/`. Editar el original funcionaría, pero la siguiente actualización del paquete sobrescribiría los cambios sin avisar.

**Estructura de un fichero de unidad**

Un fichero `.service` se divide en tres secciones:

```bash
[Unit]
Description=Servidor web Apache
After=network.target
Requires=network.target

[Service]
Type=forking
ExecStart=/usr/sbin/apachectl start
ExecStop=/usr/sbin/apachectl stop
ExecReload=/usr/sbin/apachectl graceful
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
```

| Sección | Contenido |
|---|---|
| `[Unit]` | Descripción y relaciones con otras unidades: `After` y `Before` fijan el **orden**, mientras que `Requires` y `Wants` fijan la **dependencia**. Son cosas distintas: `After` no obliga a que la otra unidad exista, solo dice cuándo arrancar si existe. |
| `[Service]` | Cómo se ejecuta el servicio: las órdenes de arranque, parada y recarga, el tipo de proceso, el usuario bajo el que corre y la política de reinicio ante fallos. |
| `[Install]` | Qué ocurre al ejecutar `systemctl enable`. `WantedBy=multi-user.target` indica que el enlace se creará dentro de ese objetivo. Una unidad **sin** sección `[Install]` no puede habilitarse. |

> **Recuerda:** Tras crear o modificar a mano un fichero de unidad hay que ejecutar `systemctl daemon-reload` para que systemd lo relea. Es el olvido más frecuente, y produce el desconcertante efecto de que los cambios no surten ningún efecto.

### 3.2 Uso del comando systemctl

`systemctl` es la herramienta principal para interactuar con Systemd.

| Comando `systemctl` | Descripción |
|---------------------|-------------|
| `start servicio` | Inicia un servicio. |
| `stop servicio` | Detiene un servicio. |
| `restart servicio` | Reinicia un servicio completamente. |
| `reload servicio` | Recarga la configuración sin detener el proceso (si el servicio lo soporta). |
| `status servicio` | Muestra el estado detallado, PID y últimas líneas de log del servicio. |
| `enable servicio` | Habilita el servicio para que arranque automáticamente al iniciar el SO. |
| `disable servicio` | Deshabilita el auto-arranque del servicio. |
| `is-enabled servicio`| Verifica si un servicio arrancará automáticamente. |
| `daemon-reload` | Obliga a systemd a releer todos los ficheros de unidades tras una modificación. |
| `mask servicio` | Enmascara el servicio: lo enlaza a `/dev/null` de modo que resulte **imposible** arrancarlo, ni siquiera a mano ni como dependencia de otro. |
| `unmask servicio` | Retira el enmascaramiento. |
| `list-units --type=service` | Lista las unidades **cargadas** en memoria y su estado actual. |
| `list-unit-files --type=service` | Lista **todas** las unidades instaladas en el disco, estén cargadas o no, indicando si están habilitadas. |
| `cat servicio` | Muestra el contenido del fichero de unidad y de sus ficheros *drop-in*, indicando de dónde sale cada línea. |
| `list-dependencies servicio` | Presenta en forma de árbol las dependencias de una unidad. |

> **Importante:** No deben confundirse `disable` y `mask`. `disable` se limita a retirar los enlaces de arranque automático, de modo que el servicio no se inicia solo pero **sí puede arrancarlo cualquiera** con `systemctl start`, y también puede arrancarlo otro servicio que lo declare como dependencia. `mask` lo bloquea de raíz:
>
> ```bash
> root@debian:~# systemctl mask apache2
> Created symlink /etc/systemd/system/apache2.service -> /dev/null.
> root@debian:~# systemctl start apache2
> Failed to start apache2.service: Unit apache2.service is masked.
> ```
>
> Es el procedimiento correcto cuando se instala un paquete que arranca su servicio automáticamente y no se desea que se ejecute, por ejemplo al instalar los clientes de una base de datos sin querer el servidor.

> **Nota:** Para diagnosticar un arranque lento, `systemd-analyze` desglosa cuánto tarda cada fase y cada servicio:
>
> ```bash
> usuario@debian:~$ systemd-analyze
> Startup finished in 3.412s (kernel) + 8.905s (userspace) = 12.318s
> usuario@debian:~$ systemd-analyze blame | head -3
> 4.102s NetworkManager-wait-online.service
> 1.873s apt-daily-upgrade.service
> 892ms  snapd.service
> ```

**Gestión de targets (sustitutos de los runlevels):**

| Comando `systemctl` | Descripción |
|---------------------|-------------|
| `get-default` | Muestra el target por defecto (`graphical.target` suele ser GUI, `multi-user.target` consola). |
| `set-default target`| Cambia el target con el que arrancará el equipo permanentemente. |
| `isolate target` | Cambia dinámicamente al target especificado (ej. `isolate rescue.target`). |

```bash
root@usuario:~# systemctl status ssh
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2025-04-23 23:50:58 CEST; 3min 27s ago
     ...
```

---

## 4. Comparativa: Systemd vs SysVinit

| Característica                 | systemd                                                  | SysV (SysVinit)                                       |
| ------------------------------ | -------------------------------------------------------- | ----------------------------------------------------- |
| **Concepto principal**         | Unidades (`units`)                                       | Scripts de inicio shell                               |
| **Organización de estados**    | `Targets` (objetivos)                                    | `Runlevels` (niveles de ejecución)                    |
| **Archivos principales**       | Archivos `.service`, `.target`                           | Scripts en `/etc/init.d/` y enlaces en `/etc/rcN.d/` |
| **Ejecución de servicios**     | Basada en dependencias, asíncrona y paralela (sockets)   | Secuencial según orden numérico en scripts            |
| **Gestión de recursos**        | Soporte nativo para dependencias, cgroups, tiempos       | Limitada. Depende fuertemente de scripts manuales     |
| **Modo multiusuario (CLI)**    | `multi-user.target`                                      | `runlevel 3` (o `2` en Debian)                        |
| **Modo gráfico (GUI)**         | `graphical.target`                                       | `runlevel 5`                                          |
| **Herramienta de gestión**     | `systemctl`                                              | `service`, `chkconfig`, `update-rc.d`, `init`         |

---

## 5. Análisis de logs: journalctl y dmesg

Systemd incluye su propio demonio de registro: `journald`. Por defecto, los mensajes generados por systemd y los servicios se guardan en `/run/log/journal/` de forma binaria. 

> **Advertencia:** Si el log reside en `/run/`, se perderá tras cada reinicio. Para hacerlo persistente, se debe crear la carpeta `/var/log/journal/` y systemd automáticamente guardará allí los logs.

### 5.1 Comandos de journalctl

| Comando `journalctl` | Descripción |
|----------------------|-------------|
| `journalctl` | Visualiza todo el registro del sistema (se abre con un paginador). |
| `-u servicio.service`| Filtra los logs mostrando solo los relativos al servicio indicado. |
| `-b` | Muestra exclusivamente los logs desde el último arranque (boot). |
| `-f` | Modo seguimiento continuo (equivalente a `tail -f`). |
| `-p err` | Filtra mostrando solo mensajes de error (o mayor gravedad). |
| `--since "fecha"` | Filtra registros a partir de una fecha (`"YYYY-MM-DD HH:MM:SS"` o palabras como `"yesterday"`). |
| `-r` | Muestra el log en orden cronológico inverso (lo más reciente arriba). |
| `--vacuum-size=500M` | Operación de mantenimiento: elimina logs antiguos para que no superen los 500 MB. |
| `-k` | Muestra únicamente los mensajes del núcleo. Equivale a lo que ofrece `dmesg`. |
| `-b -1` | Muestra los registros del arranque **anterior**. Solo funciona si el registro es persistente. |
| `--disk-usage` | Informa del espacio que ocupa el registro actualmente. |
| `-n 50` | Muestra las últimas 50 entradas. |
| `_PID=1234` | Filtra por cualquier campo de los metadatos, en este caso por PID. |

> **Recuerda:** La gran ventaja de `journalctl -b -1` frente a `dmesg` es que permite investigar **por qué se cayó la máquina la vez anterior**, algo imposible con `dmesg`, cuyo búfer se vacía en cada arranque. Para ello es imprescindible haber activado antes el registro persistente creando `/var/log/journal/`.

### 5.2 Comando dmesg

`dmesg` (Diagnostic Message) lee el "ring buffer" del kernel. Es sumamente útil para detectar problemas de hardware, carga de módulos y reconocimiento de discos o USBs durante el arranque. Es equivalente a usar `journalctl -b -k`.

- `dmesg -T`: Formatea el timestamp a fechas legibles por humanos.
- `dmesg -l err`: Filtra solo por nivel de error.

---

## 6. Comandos de apagado y reinicio

Desde la terminal disponemos de herramientas clásicas para apagar el sistema operativo, las cuales modernamente son simples enlaces a funciones de `systemctl`:

- `halt`: Apaga el sistema operativo pero no envía la señal ACPI a la placa base para cortar la corriente.
- `poweroff`: Apaga el sistema enviando la señal ACPI de corte eléctrico.
- `reboot`: Reinicia el sistema.
- `shutdown`: Permite apagar de forma planificada.
  - Sintaxis: `shutdown [opción] TIEMPO [mensaje]`
  - Ejemplo: `shutdown -h +15 "Mantenimiento en 15 mins"` (apaga en 15 minutos enviando el mensaje a las terminales activas).
  - Ejemplo: `shutdown -c` (Cancela un apagado programado previamente).
- `wall`: Envía un mensaje de texto plano a todas las terminales de los usuarios logueados.
- `mesg`: Gestiona si una terminal admite o no la recepción de mensajes (como los de `wall` o `write`). Se usa con `y` (sí) o `n` (no).
