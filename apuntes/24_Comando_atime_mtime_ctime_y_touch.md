# Comando atime, mtime, ctime y touch

## Índice

1. [Tiempos en archivos (atime, mtime, ctime)](#1-tiempos-en-archivos-atime-mtime-ctime)
2. [Comando stat](#2-comando-stat)
3. [Listar según tiempo de modificación (ls)](#3-listar-según-tiempo-de-modificación-ls)
4. [Comando touch](#4-comando-touch)

---

## 1. Tiempos en archivos (atime, mtime, ctime)

En sistemas de archivos de Linux, todos los archivos o directorios mantienen un registro del tiempo de tres eventos clave:

- **`atime` (Access Time)**: Indica la última vez que se leyó el contenido del archivo.
- **`mtime` (Modified Time)**: Representa la última vez que el contenido interno del archivo fue modificado (edición de texto, por ejemplo).
- **`ctime` (Change Time)**: Refleja el tiempo en que se cambiaron los **metadatos** del archivo (cambio a nivel de permisos, propietario, enlace, etc.). Podemos verlo como cambios a nivel de inodo.

> **Advertencia:** El `atime` **no se actualiza en cada lectura** en los sistemas actuales. Hacerlo obligaría a escribir en disco cada vez que se lee un fichero, lo que arruinaría el rendimiento y desgastaría innecesariamente los discos SSD. Por eso Linux monta los sistemas de ficheros con la opción `relatime`, que solo refresca el `atime` en dos casos: cuando el valor anterior es más antiguo que el `mtime` o el `ctime`, o cuando han pasado más de 24 horas desde la última actualización.
>
> ```bash
> usuario@debian:~$ findmnt -no OPTIONS /
> rw,relatime,errors=remount-ro
> ```
>
> La consecuencia práctica es que el `atime` sirve para saber si un fichero se ha usado **últimamente**, pero no para auditar accesos concretos. Las opciones de montaje relacionadas son `strictatime` (comportamiento clásico, actualiza siempre), `noatime` (no actualiza nunca, la más rápida) y `nodiratime` (no actualiza el de los directorios).

> **Recuerda:** Existe un cuarto tiempo, el de **creación** o *birth time*, que aparece en la salida de `stat` como `Creación`. Lo soportan `ext4`, `xfs` y `btrfs`, pero, a diferencia de los otros tres, **ningún comando puede modificarlo**, ni siquiera `touch`. En sistemas de ficheros que no lo registran, `stat` muestra un guion.

> **Nota:** El inodo en Linux es una estructura de datos vital. Cada archivo y directorio está asociado con un inodo único que contiene sus metadatos (permisos, propietario, tipo, fechas de acceso/modificación, y punteros a los bloques de datos). Quedarse sin inodos disponibles puede impedir la creación de nuevos archivos aunque haya espacio en el disco duro.

---

## 2. Comando stat

El comando `stat` permite visualizar el estado completo de un archivo, incluyendo detalladamente sus atributos y fechas.

Ejemplo analizando la evolución del tiempo de un fichero tras modificar sus permisos:

```bash
usuario@debian:/tmp/temporal$ stat fichero1.txt
  Fichero: fichero1.txt
  Tamaño: 11            Bloques: 8          Bloque E/S: 4096   fichero regular
Device: 8,1     Inode: 1700631     Links: 1
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

## 3. Listar según tiempo de modificación (ls)

También se puede ordenar por los diferentes tiempos usando el comando de listado `ls`.

| Comando | Equivalente corto | Funcionalidad |
|---------|-------------------|---------------|
| `ls --time=atime` | `ls -u` | Usa la fecha de último **acceso** (`atime`). |
| (por defecto) | `ls -t` | Usa la fecha de **modificación** del contenido (`mtime`). |
| `ls --time=ctime` | `ls -c` | Usa la fecha de **cambio** de metadatos (`ctime`). |
| `ls --time=birth` | | Usa la fecha de **creación**, si el sistema de ficheros la registra. |

> **Advertencia:** No existe `ls --time=mtime`. El tiempo de modificación es el que `ls` emplea por defecto, de modo que no hace falta pedirlo, y escribirlo devuelve un error:
>
> ```bash
> usuario@debian:~$ ls --time=mtime /tmp
> ls: argumento inválido 'mtime' para '--time'
> ```
>
> Los valores admitidos son `atime` (o `access`, `use`), `ctime` (o `status`) y `birth` (o `creation`). Para ordenar por `mtime` basta con `ls -t`.

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

## 4. Comando touch

El comando `touch` se utiliza en Linux no solo para crear archivos vacíos si no existen, sino principalmente para actualizar intencionalmente las marcas de tiempo de los archivos existentes (su "atime" y "mtime") sin alterar el contenido del archivo.

| Parámetro | Descripción |
|-----------|-------------|
| `-a`      | Cambia únicamente la fecha de acceso (`atime`). |
| `-m`      | Cambia únicamente la fecha de modificación (`mtime`). |
| `-r archivo` | Toma la fecha del archivo referenciado y se la copia al objetivo. |
| `--date=cadena` | Permite introducir una fecha formateada de manera textual (ej: '2023-04-29 17:53'). |
| `-t time` | Permite dar un valor numérico explícito en formato `aaaaMMddHHmm.ss`. |
| `-c`      | (*No-create*) Actualiza las fechas solo si el fichero ya existe. Si no existe, no lo crea ni da error. |
| `-d cadena` | Sinónimo de `--date`. Admite expresiones relativas como `'-2 days'`, `'yesterday'` o `'2 hours ago'`. |
| `-h`      | Actúa sobre el propio enlace simbólico en lugar de sobre el fichero al que apunta. |

> **Nota:** La opción `-d` admite el lenguaje de fechas de GNU, lo que permite construcciones muy cómodas al preparar pruebas: `touch -d '-10 days' viejo.txt` o `touch -d 'next friday' futuro.txt`.

> **Advertencia:** Para crear un fichero cuyo nombre empiece por guion, `touch -fichero` no funciona porque el guion se interpreta como el inicio de una opción. Hay que usar `touch -- -fichero` o `touch ./-fichero`.

**Ejemplo 1: Creación de un archivo vacío**
```bash
usuario@debian:/tmp/temporal$ touch fichero.txt
usuario@debian:/tmp/temporal$ ls -l fichero.txt
-rw-r--r-- 1 usuario usuario 0 abr 13 11:01 fichero.txt
```

**Ejemplo 2: Modificar todas las fechas al pasado simultáneamente**
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
> Esta imposibilidad tiene una consecuencia práctica en análisis forense. Si alguien manipula un fichero y después intenta disimularlo devolviendo el `mtime` a su valor anterior, el `ctime` delata la maniobra al quedar muy por delante del `mtime`. Un `mtime` de hace seis meses junto a un `ctime` de esta mañana es una señal inequívoca de que el fichero ha sido tocado.

> **Recuerda:** Los tres tiempos se resumen bien con una pregunta cada uno:
>
> | Tiempo | Pregunta a la que responde | Qué lo actualiza |
> |---|---|---|
> | `atime` | ¿Cuándo se leyó por última vez? | `cat`, `less`, `grep` (sujeto a `relatime`). |
> | `mtime` | ¿Cuándo cambió su contenido? | Escribir en él con un editor, `>`, `>>`. |
> | `ctime` | ¿Cuándo cambió su inodo? | `chmod`, `chown`, `mv`, crear un enlace duro y también cualquier cambio de contenido. |
