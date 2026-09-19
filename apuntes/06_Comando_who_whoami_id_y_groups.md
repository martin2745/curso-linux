# Comandos de identidad de usuario: who, whoami, id y groups

## Índice

1. [Comando who](#1-comando-who)
2. [Comando whoami](#2-comando-whoami)
3. [Comando id y sus variantes](#3-comando-id-y-sus-variantes)
   1. [Obtener el identificador numérico de usuario (UID)](#31-obtener-el-identificador-numérico-de-usuario-uid)
   2. [Obtener el identificador numérico de grupo principal (GID)](#32-obtener-el-identificador-numérico-de-grupo-principal-gid)
   3. [Resumen de parámetros de id](#33-resumen-de-parámetros-de-id)
4. [Comando groups](#4-comando-groups)

---

## 1. Comando who

El comando `who` muestra información en tiempo real sobre los usuarios que están actualmente conectados al sistema (sesiones activas). Es una herramienta rápida y esencial para control de sesiones concurrentes y auditoría de accesos.

```bash
usuario@debian:~$ who
nuevo    pts/0        2024-04-25 18:46 (10.0.2.2)
usuario  pts/1        2024-04-25 17:44 (10.0.2.2)
```

**Explicación:** En este caso, la salida muestra dos usuarios conectados: `nuevo` y `usuario`. También informa de la pseudoterminal desde la que operan (`pts/0` y `pts/1` respectivamente), la fecha y hora de conexión y la dirección IP desde la que se conectaron (`10.0.2.2`).

La información no la calcula `who`, sino que la lee del fichero binario `/var/run/utmp`, donde el sistema anota las sesiones abiertas. Por eso `who` no puede consultarse con `cat` y por eso una sesión que termine de forma anormal puede quedar reflejada como activa.

| Parámetro | Descripción |
|---|---|
| `-a` | (*All*) Activa prácticamente todas las opciones a la vez. Es la salida más completa. |
| `-b` | (*Boot*) Muestra la fecha y hora del último arranque del sistema. |
| `-r` | (*Runlevel*) Muestra el nivel de ejecución actual y el anterior. |
| `-q` | (*Quick*) Muestra solo los nombres de usuario y el recuento total de sesiones. |
| `-H` | Imprime una línea de cabecera identificando cada columna. |
| `-u` | Añade el tiempo de inactividad de cada sesión y el PID de su shell. |

```bash
usuario@debian:~$ who -b
         system boot  2026-09-18 08:12
usuario@debian:~$ who -q
nuevo usuario
# users=2
```

> **Nota:** Comandos emparentados con `who` son `w`, que añade la carga del sistema y el proceso que ejecuta cada usuario; `users`, que devuelve únicamente los nombres en una línea; y `last`, que consulta `/var/log/wtmp` para mostrar el **histórico** de conexiones en lugar de las sesiones activas.

---

## 2. Comando whoami

El comando `whoami` imprime el nombre del usuario efectivo que invoca el comando.

```bash
usuario@debian:~$ whoami
usuario
```

**Explicación:** Simplemente devuelve el nombre de la cuenta actual en formato texto plano, que en este caso es `usuario`. En la administración de sistemas y creación de *scripts* (*bash scripting*), se utiliza frecuentemente para hacer comprobaciones de seguridad condicionales, por ejemplo, averiguando si el script está siendo ejecutado como administrador antes de proseguir con operaciones delicadas.

> **Importante:** No debe confundirse `whoami` con `who am i`, que pese al nombre casi idéntico responden a preguntas distintas:
>
> - `whoami` devuelve el usuario **efectivo**, es decir, la identidad con la que se están ejecutando los comandos en este momento.
> - `who am i` consulta `/var/run/utmp` y devuelve el usuario que **inició la sesión** originalmente.
>
> La diferencia se aprecia justo después de un `su`:
>
> ```bash
> usuario@debian:~$ su -
> Contraseña:
> root@debian:~# whoami
> root
> root@debian:~# who am i
> usuario  pts/1        2026-09-18 09:14 (10.0.2.2)
> ```
>
> Es el mecanismo en el que se apoyan las auditorías para saber **quién** está actuando como `root`, y la razón de que `sudo` se prefiera a compartir la contraseña de `root`: deja rastro de la identidad real en `/var/log/auth.log`.

---

## 3. Comando id y sus variantes

El comando `id` imprime por pantalla la identidad completa de usuario y grupo del usuario actual, proporcionando información pormenorizada sobre el identificador numérico de usuario (UID) y del grupo (GID), así como la lista completa de todos los grupos secundarios a los que pertenece.

```bash
usuario@debian:~$ id
uid=1000(usuario) gid=1000(usuario) grupos=1000(usuario),24(cdrom),25(floppy),27(sudo),29(audio),30(dip),44(video),46(plugdev),100(users),106(netdev),112(bluetooth),114(lpadmin),117(scanner)
```

**Explicación:** Muestra el UID y GID del usuario `usuario` como `1000`. En sistemas Linux como Debian, los usuarios convencionales humanos inician típicamente su numeración de UID en el `1000`. A continuación, se detalla la lista de identificadores numéricos y nombres de los grupos asociados a dicha cuenta.

### 3.1 Obtener el identificador numérico de usuario (UID)

Podemos aislar partes de esta información utilizando parámetros. El comando `id -u` devuelve exclusivamente el número de UID.

```bash
usuario@debian:~$ id -u
1000
```

Si le pasamos como parámetro adicional el nombre de otro usuario, podemos consultar su identificador sin necesidad de iniciar sesión con esa cuenta. Por ejemplo, consultando al administrador supremo `root`:

```bash
usuario@debian:~$ id -u root
0
```

**Explicación:** El número `0` siempre es asignado de forma inmutable a la cuenta `root` en cualquier sistema basado en Linux.

### 3.2 Obtener el identificador numérico de grupo principal (GID)

De manera análoga, el comando `id -g` se utiliza para imprimir de forma aislada el número del GID (Group ID) primario del usuario actual.

```bash
usuario@debian:~$ id -g
1000
```

> **Nota:** Se prefieren extraer los identificadores de este modo (`id -u` o `id -g`) al programar *scripts* automatizados, ya que resulta mucho más sencillo de gestionar e introducir en variables (ya que solo devuelve el número limpio) frente a intentar extraer ese dato procesando texto de la salida larga del comando original `id`.

### 3.3 Resumen de parámetros de id

| Parámetro | Descripción |
|---|---|
| `-u` | Devuelve solo el UID efectivo. |
| `-g` | Devuelve solo el GID del grupo primario. |
| `-G` | Devuelve los GID de **todos** los grupos, primario y secundarios, separados por espacios. |
| `-n` | Modificador que convierte los números en nombres. Solo tiene sentido acompañando a `-u`, `-g` o `-G`. |
| `-r` | Devuelve el identificador **real** en lugar del efectivo. La diferencia aflora en programas con el bit SUID activado. |

```bash
usuario@debian:~$ id -G
1000 24 25 27 29 30 44 46 100 106 112 114 117
usuario@debian:~$ id -Gn
usuario cdrom floppy sudo audio dip video plugdev users netdev bluetooth lpadmin scanner
usuario@debian:~$ id -un
usuario
```

La comprobación canónica de privilegios dentro de un script se apoya precisamente en `id -u`, porque compara un número y no depende del idioma ni del formato de la salida:

```bash
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ejecutarse como root." >&2
    exit 1
fi
```

> **Advertencia:** Comprobar el privilegio con `[ "$(whoami)" = "root" ]` es menos fiable. Puede existir más de una cuenta con UID 0 y un nombre distinto de `root`, en cuyo caso la comparación por nombre fallaría mientras que la comparación por UID acertaría.

---

## 4. Comando groups

El comando `groups` sirve para listar todos los grupos (tanto el principal como los secundarios) a los que pertenece un usuario.

```bash
usuario@debian:~$ groups
usuario cdrom floppy sudo audio dip video plugdev users netdev bluetooth lpadmin scanner
```

**Explicación:** Devuelve de forma clara y limpia la lista de los grupos en los que está inscrito el usuario actual (o el usuario especificado por argumento). En GNU/Linux, `groups` es en la práctica un atajo de `id -Gn`, y el primer grupo de la lista (`usuario`) es el **grupo primario** o predeterminado de la cuenta, mientras que el resto son **grupos secundarios**, encargados de otorgar privilegios puntuales de acceso a hardware, permisos y ciertos ficheros.

> **Recuerda:** El grupo primario es el que se asigna automáticamente a cada fichero nuevo que crea el usuario, y es el que figura en el cuarto campo de su línea en `/etc/passwd`. Los grupos secundarios se definen en `/etc/group`, donde el usuario aparece listado en el último campo de la línea del grupo correspondiente.

> **Advertencia:** Al añadir un usuario a un grupo nuevo con `usermod -aG grupo usuario`, el cambio **no** afecta a las sesiones ya abiertas. La pertenencia a grupos se fija en el momento del inicio de sesión, de modo que hay que cerrar sesión y volver a entrar (o abrir una shell nueva con `newgrp grupo`) para que `groups` refleje la novedad. Es una de las causas más frecuentes de "le he dado permisos y sigue sin funcionar".
