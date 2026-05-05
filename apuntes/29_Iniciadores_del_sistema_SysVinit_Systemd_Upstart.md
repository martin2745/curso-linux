# Iniciadores del sistema: SysVinit, Systemd, Upstart

## Índice

1. [Sistemas de inicio en Linux](#1-sistemas-de-inicio-en-linux)
2. [SysVinit y los Runlevels](#2-sysvinit-y-los-runlevels)
3. [Systemd](#3-systemd)
   1. [Unidades (Units) y Targets](#unidades-units-y-targets)
   2. [Uso del comando systemctl](#uso-del-comando-systemctl)
4. [Comparativa: Systemd vs SysVinit](#4-comparativa-systemd-vs-sysvinit)
5. [Análisis de logs: journalctl y dmesg](#5-análisis-de-logs-journalctl-y-dmesg)
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

| Runlevel | Descripción |
|----------|-------------|
| **0** | Apagado del sistema. |
| **1** o **S** | Monousuario sin red para rescate/mantenimiento. No arranca entorno gráfico. |
| **2** | Multiusuario sin servicios de red (común en Debian como multiusuario estándar). |
| **3** | Multiusuario completo con red (modo consola en sistemas Red Hat/CentOS). |
| **4** | Reservado para uso personalizado o no utilizado. |
| **5** | Multiusuario completo con red e interfaz gráfica (GUI). |
| **6** | Reinicio del sistema. |

### Comandos de gestión en SysVinit

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

### Unidades (Units) y Targets

Systemd gestiona elementos llamados **unidades**. Las más comunes son:
- **.service**: Define un servicio (e.g., `nginx.service`, `sshd.service`).
- **.target**: Agrupaciones de unidades. Equivalente a los runlevels tradicionales.
- **.timer**: Tareas programadas (alternativa a `cron`).
- **.mount**: Controla puntos de montaje.

**Precedencia de directorios de unidades:**
1. `/etc/systemd/system/`: Máxima prioridad. Unidades creadas o modificadas por el administrador.
2. `/run/systemd/system/`: Unidades creadas dinámicamente en tiempo de ejecución.
3. `/lib/systemd/system/` (o `/usr/lib/...`): Unidades instaladas por el gestor de paquetes de la distribución.

> **Nota:** Para modificar una unidad empaquetada, nunca se edita el archivo en `/lib/systemd/system/`. En su lugar, se usa `systemctl edit nombre_servicio` (que crea un archivo *drop-in* en `/etc/`) o se copia el archivo entero a `/etc/systemd/system/`.

### Uso del comando systemctl

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

**Gestión de Targets (Sustitutos de Runlevels):**

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

### Comandos de journalctl

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

### Comando dmesg

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
