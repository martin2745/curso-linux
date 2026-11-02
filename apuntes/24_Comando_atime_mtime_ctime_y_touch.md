# Marcas de tiempo: atime, mtime, ctime y touch

## Índice

1. [Tiempos en archivos (atime, mtime, ctime)](#1-tiempos-en-archivos-atime-mtime-ctime)
2. [Qué operación cambia cada tiempo](#2-qué-operación-cambia-cada-tiempo)
3. [Comando stat](#3-comando-stat)
4. [Listar según tiempo de modificación (ls)](#4-listar-según-tiempo-de-modificación-ls)
5. [Comando touch](#5-comando-touch)
6. [Buscar ficheros por sus tiempos (find)](#6-buscar-ficheros-por-sus-tiempos-find)

---

## 1. Tiempos en archivos (atime, mtime, ctime)

En sistemas de archivos de Linux, todos los archivos o directorios mantienen un registro del tiempo de tres eventos clave. Estas fechas se guardan en el **inodo** del fichero, junto al resto de sus metadatos (documento 03, apartado 8.1):

- **`atime` (Access Time)**: Indica la última vez que se leyó el contenido del archivo.
- **`mtime` (Modified Time)**: Representa la última vez que el contenido interno del archivo fue modificado (edición de texto, por ejemplo).
- **`ctime` (Change Time)**: Refleja el tiempo en que se cambiaron los **metadatos** del archivo (cambio a nivel de permisos, propietario, enlace, etc.). Como los metadatos están en el inodo, el `ctime` es la fecha del último cambio **del inodo**. Cambiar el contenido también lo actualiza, porque modifica el tamaño y el `mtime`, que también están en el inodo.

> **Importante:** La `c` de `ctime` es de *change* («cambio»), **no de *creation*** («creación»). Es la confusión más habitual con estos tiempos, y una pregunta típica de examen: el `ctime` no indica cuándo se creó el fichero, sino cuándo cambió su inodo por última vez. La fecha de creación es otro tiempo distinto, el *birth time*, que se explica más abajo.

> **Advertencia:** El `atime` **no se actualiza en cada lectura** en los sistemas actuales. Hacerlo obligaría a escribir en disco cada vez que se lee un fichero, lo que arruinaría el rendimiento y desgastaría innecesariamente los discos SSD. Por eso Linux monta los sistemas de ficheros con la opción `relatime`, que solo refresca el `atime` en dos casos: cuando el valor anterior es más antiguo que el `mtime` o el `ctime`, o cuando han pasado más de 24 horas desde la última actualización.
>
> ```bash
> usuario@debian:~$ findmnt -no OPTIONS /
> rw,relatime,errors=remount-ro
> ```
>
> La consecuencia práctica es que el `atime` sirve para saber si un fichero se ha usado **últimamente**, pero no para auditar accesos concretos. Las opciones de montaje relacionadas son `strictatime` (comportamiento clásico, actualiza siempre), `noatime` (no actualiza nunca, la más rápida) y `nodiratime` (no actualiza el de los directorios).

> **Recuerda:** Existe un cuarto tiempo, el de **creación** o *birth time*, que aparece en la salida de `stat` como `Creación`. Lo soportan `ext4`, `xfs` y `btrfs`, pero, a diferencia de los otros tres, **ningún comando puede modificarlo**, ni siquiera `touch`. En sistemas de ficheros que no lo registran, `stat` muestra un guion.

**Los tiempos de un directorio**

Los directorios también tienen sus tres tiempos, pero hay que recordar que el contenido de un directorio es la **tabla de nombres** de los ficheros que contiene (documento 03, apartado 8.1). Por eso:

- El **`mtime` de un directorio** cambia cuando se **crea, borra o renombra** algo dentro de él, no cuando se modifica el contenido de un fichero que ya estaba.
- El **`atime` de un directorio** cambia cuando se **lista** su contenido, por ejemplo con `ls`.

Así, si en una carpeta se edita un fichero existente, cambia el `mtime` de ese fichero, pero no el de la carpeta; si se crea un fichero nuevo, cambia el `mtime` de la carpeta.

---

## 2. Qué operación cambia cada tiempo

| Operación | `atime` | `mtime` | `ctime` |
|---|:-:|:-:|:-:|
| Leer el fichero (`cat`, `less`, `grep`) | Sí (*) | No | No |
| Escribir en el fichero (editor, `>`, `>>`) | No | Sí | Sí |
| Cambiar permisos o propietario (`chmod`, `chown`) | No | No | Sí |
| Renombrar o mover dentro del mismo disco (`mv`) | No | No | Sí |
| Crear o borrar un enlace duro (`ln`, `rm` de otro nombre) | No | No | Sí |
| `touch fichero` | Sí | Sí | Sí |
| `touch -a fichero` | Sí | No | Sí |
| `touch -m fichero` | No | Sí | Sí |

(*) Con las limitaciones de `relatime` que se explican en el apartado 1.

Hay dos reglas que se deducen de la tabla: **todo lo que cambia el `mtime` cambia también el `ctime`**, y **el `ctime` no se puede cambiar sin que cambie algo más**. Por eso el `ctime` siempre es igual o posterior al `mtime`.

Al copiar un fichero, la copia es un fichero nuevo con su propio inodo, así que sus tres tiempos son los del momento de la copia. Con `cp -p` o `cp -a`, la copia conserva el `atime` y el `mtime` del original, pero no su `ctime`, que siempre es el del momento de la copia.

**Ejemplo: seguir los tiempos de un fichero**

Se crea un fichero y se le hacen varias operaciones, dejando un minuto entre cada una para ver qué tiempo cambia:

| Hora | Orden | `atime` | `mtime` | `ctime` |
|---|---|:-:|:-:|:-:|
| 10:00 | `echo hola > notas.txt` | 10:00 | 10:00 | 10:00 |
| 10:01 | `cat notas.txt` | **10:01** | 10:00 | 10:00 |
| 10:02 | `chmod 600 notas.txt` | 10:01 | 10:00 | **10:02** |
| 10:03 | `echo adios >> notas.txt` | 10:01 | **10:03** | **10:03** |
| 10:04 | `cat notas.txt` | **10:04** | 10:03 | 10:03 |

Al final, `stat` muestra los tres tiempos con la última hora de cada uno:

```bash
usuario@debian:~$ stat --printf='atime: %x\nmtime: %y\nctime: %z\n' notas.txt
atime: 2026-11-02 10:04:12.523184031 +0100
mtime: 2026-11-02 10:03:05.871203450 +0100
ctime: 2026-11-02 10:03:05.871203450 +0100
```

---

## 3. Comando stat

El comando `stat` permite visualizar el estado completo de un archivo, incluyendo detalladamente sus atributos y fechas. Muestra toda la información de su inodo.

Ejemplo analizando la evolución del tiempo de un fichero tras modificar sus permisos:

```bash
usuario@debian:/tmp/temporal$ stat fichero1.txt
  Fichero: fichero1.txt
  Tamaño: 11            Bloques: 8          Bloque E/S: 4096   fichero regular
Dispositivo: 8,1        Nodo-i: 1700631     Enlaces: 1
Acceso: (0644/-rw-r--r--)  Uid: ( 1000/  usuario)   Gid: ( 1000/  usuario)
      Acceso: 2024-04-13 10:12:22.169098495 +0200
Modificación: 2024-04-13 10:12:36.010174997 +0200
      Cambio: 2024-04-13 10:12:36.010174997 +0200
    Creación: 2024-04-13 09:23:48.618999425 +0200

usuario@debian:/tmp/temporal$ chmod 777 fichero1.txt
usuario@debian:/tmp/temporal$ stat fichero1.txt
...
      Cambio: 2024-04-13 10:12:59.494427849 +0200  <-- Se actualiza el ctime al cambiar permisos
...
```

Para ver por separado los parámetros de fecha de forma filtrada en `stat`, tenemos las opciones de formateo de salida de cadena (`-c`):

| Parámetro | Significado |
|-----------|-------------|
| `%x`      | Tiempo de último acceso (`atime`). |
| `%y`      | Tiempo de última modificación de contenido (`mtime`). |
| `%z`      | Tiempo de último cambio de metadatos (`ctime`). |
| `%w`      | Tiempo de creación (*birth time*), si el sistema de ficheros lo registra. |
| `%X` / `%Y` / `%Z` / `%W` | Los mismos cuatro tiempos, en segundos desde el 1 de enero de 1970. Es el formato más cómodo para compararlos o restarlos en un *script*. |
| `%n`      | Muestra el nombre del archivo. |
| `%s`      | Tamaño en bytes. |
| `%i`      | Número de inodo. |
| `%a` / `%A` | Permisos en notación octal y en notación simbólica. |
| `%U` / `%G` | Nombre del propietario y del grupo. |
| `%h`      | Número de enlaces duros. |

> **Nota:** Añadiendo `-t` (*terse*), `stat` imprime todos los datos en una sola línea separada por espacios, lo que facilita procesarlos con `cut` o `awk` desde un script.

```bash
usuario@debian:/tmp/temporal$ stat -c '%z, %n' fichero1.txt
2024-04-13 10:12:59.494427849 +0200, fichero1.txt
```

---

## 4. Listar según tiempo de modificación (ls)

También se puede ordenar por los diferentes tiempos usando el comando de listado `ls`. Por defecto, `ls -l` muestra el `mtime`.

| Comando | Equivalente corto | Funcionalidad |
|---------|-------------------|---------------|
| `ls --time=atime` | `ls -u` | Usa la fecha de último **acceso** (`atime`). |
| `ls --time=mtime` (por defecto) | `ls -t` para ordenar | Usa la fecha de **modificación** del contenido (`mtime`). |
| `ls --time=ctime` | `ls -c` | Usa la fecha de **cambio** de metadatos (`ctime`). |
| `ls --time=birth` | | Usa la fecha de **creación**, si el sistema de ficheros la registra. |

> **Nota:** Los valores admitidos por `--time` son `atime` (o `access`, `use`), `mtime` (o `modification`), `ctime` (o `status`) y `birth` (o `creation`). Los valores `mtime` y `modification` se añadieron en versiones recientes de `ls`, como la de Debian 13; en versiones antiguas daban el error `argumento inválido 'mtime' para '--time'`, porque el `mtime` es el que se usa por defecto y no había que pedirlo. Para ordenar por `mtime`, en cualquier versión, basta con `ls -t`.

> **Importante:** Las opciones `-u` y `-c` hacen dos cosas a la vez, **elegir qué fecha se usa** y **ordenar por ella**, pero solo ordenan si no se combinan de forma que lo impida. Su comportamiento exacto depende de con qué se acompañen:
>
> | Orden | Resultado |
> |---|---|
> | `ls -u` | Ordena por `atime`, del más reciente al más antiguo. |
> | `ls -lu` | **Muestra** el `atime` pero ordena **por nombre**. |
> | `ls -lut` | Muestra el `atime` y ordena por él. Esta es la combinación que normalmente se busca. |
>
> Lo mismo se aplica a `-c` con `ctime`: la forma útil es `ls -lct`. Es un detalle poco intuitivo que está documentado en `man ls` y que suele caer en los exámenes.

---

## 5. Comando touch

El comando `touch` se utiliza en Linux no solo para crear archivos vacíos si no existen, sino principalmente para actualizar intencionalmente las marcas de tiempo de los archivos existentes (su "atime" y "mtime") sin alterar el contenido del archivo.

| Parámetro | Descripción |
|-----------|-------------|
| `-a`      | Cambia únicamente la fecha de acceso (`atime`). |
| `-m`      | Cambia únicamente la fecha de modificación (`mtime`). |
| `-r archivo` | Toma la fecha del archivo referenciado y se la copia al objetivo. |
| `--date=cadena` | Permite introducir una fecha formateada de manera textual (ej: '2023-04-29 17:53'). |
| `-t fecha` | Permite dar la fecha en formato numérico `[[SS]AA]MMDDhhmm[.ss]`: año (opcional), mes, día, hora, minutos y, opcionalmente, segundos. Por ejemplo, `touch -t 202304291753.03 fichero.txt` equivale a `--date='2023-04-29 17:53:03'`. |
| `-c`      | (*No-create*) Actualiza las fechas solo si el fichero ya existe. Si no existe, no lo crea ni da error. |
| `-d cadena` | Sinónimo de `--date`. Admite expresiones relativas como `'-2 days'`, `'yesterday'` o `'2 hours ago'`. |
| `-h`      | Actúa sobre el propio enlace simbólico en lugar de sobre el fichero al que apunta (documento 03, apartado 8.4). |

> **Nota:** La opción `-d` admite el lenguaje de fechas de GNU, lo que permite construcciones muy cómodas al preparar pruebas: `touch -d '-10 days' viejo.txt` o `touch -d 'next friday' futuro.txt`.

> **Advertencia:** Para crear un fichero cuyo nombre empiece por guion, `touch -fichero` no funciona porque el guion se interpreta como el inicio de una opción. Hay que usar `touch -- -fichero` o `touch ./-fichero`.

**Ejemplo 1: Creación de un archivo vacío**
```bash
usuario@debian:/tmp/temporal$ touch fichero.txt
usuario@debian:/tmp/temporal$ ls -l fichero.txt
-rw-r--r-- 1 usuario usuario 0 abr 13 11:01 fichero.txt
```

**Ejemplo 2: Llevar al pasado el `atime` y el `mtime` a la vez**

Sin `-a` ni `-m`, `touch` cambia los dos tiempos. El `ctime` no se puede llevar al pasado: queda con la hora actual.
```bash
usuario@debian:/tmp/temporal$ touch --date='2022-03-29 17:53:03' fichero.txt
usuario@debian:/tmp/temporal$ ls -l fichero.txt
-rw-r--r-- 1 usuario usuario 0 mar 29  2022 fichero.txt
```

**Ejemplo 3: Modificando únicamente el `atime` al pasado**
```bash
usuario@debian:/tmp/temporal$ touch -a --date='2023-04-29 17:53:03' fichero.txt
usuario@debian:/tmp/temporal$ stat fichero.txt
...
      Acceso: 2023-04-29 17:53:03.000000000 +0200
Modificación: 2022-03-29 17:53:03.000000000 +0200
```

> **Importante:** Fíjate que cualquier ejecución de `touch` siempre acabará cambiando internamente la fecha `ctime`, porque alterar el `atime` o `mtime` ya supone de por sí una manipulación de los metadatos. Y lo que es más relevante: el `ctime` se fija **al momento actual** y no puede falsearse con ninguna opción de `touch`.
>
> Esta imposibilidad tiene una consecuencia práctica en análisis forense. Si alguien manipula un fichero y después intenta disimularlo devolviendo el `mtime` a su valor anterior, el `ctime` delata la maniobra al quedar muy por delante del `mtime`. Un `mtime` de hace seis meses junto a un `ctime` de esta mañana es una señal clara de que el fichero ha sido tocado, aunque solo fuera para cambiar sus permisos. La única forma de falsear el `ctime` es que `root` cambie el reloj del sistema antes de tocar el fichero, algo que a su vez suele dejar rastro en los registros.

> **Recuerda:** Los tres tiempos se resumen bien con una pregunta cada uno:
>
> | Tiempo | Pregunta a la que responde | Qué lo actualiza |
> |---|---|---|
> | `atime` | ¿Cuándo se leyó por última vez? | `cat`, `less`, `grep` (sujeto a `relatime`). |
> | `mtime` | ¿Cuándo cambió su contenido? | Escribir en él con un editor, `>`, `>>`. |
> | `ctime` | ¿Cuándo cambió su inodo? | `chmod`, `chown`, `mv`, crear un enlace duro y también cualquier cambio de contenido. |

---

## 6. Buscar ficheros por sus tiempos (find)

Los tres tiempos se usan sobre todo para **buscar ficheros** con `find`, que tiene una opción para cada uno. Se explica con más detalle en el documento 17.

| Opción | Busca por | Unidad |
|---|---|---|
| `-atime n` / `-amin n` | `atime` | Días / minutos |
| `-mtime n` / `-mmin n` | `mtime` | Días / minutos |
| `-ctime n` / `-cmin n` | `ctime` | Días / minutos |
| `-newer fichero` | `mtime` posterior al del fichero indicado | |

El número admite un signo delante:

| Valor | Significado | Ejemplo |
|---|---|---|
| `-n` | Hace **menos** de `n` | `find /var/log -mtime -1`: modificados en las últimas 24 horas. |
| `+n` | Hace **más** de `n` | `find /tmp -atime +30`: no leídos en más de 30 días. |
| `n` | Hace exactamente `n` | `find . -mmin 5`: modificados hace 5 minutos. |

```bash
usuario@debian:~$ find ~ -mmin -10
usuario@debian:~$ find /etc -ctime -1
```

La primera orden muestra lo que se ha modificado en la carpeta personal en los últimos 10 minutos; la segunda, los ficheros de `/etc` cuyo inodo ha cambiado en el último día, por ejemplo porque alguien ha cambiado sus permisos.

> **Nota:** En `-atime`, `-mtime` y `-ctime`, `find` cuenta **días completos** y descarta las fracciones. Un fichero modificado hace 7 días y 20 horas cuenta como de hace 7 días, así que `-mtime +7` no lo encuentra: solo encuentra los de 8 días o más. Para búsquedas precisas conviene usar los minutos (`-mmin`).
