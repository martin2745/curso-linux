# Comando atime, mtime, ctime y touch

## Índice

1. [Tiempos en archivos (atime, mtime, ctime)](#1-tiempos-en-archivos-atime-mtime-ctime)
2. [Comando stat](#2-comando-stat)
3. [Listar según tiempo de modificación (ls)](#3-listar-según-tiempo-de-modificación-ls)
4. [Comando touch](#4-comando-touch)

---

## 1. Tiempos en archivos (atime, mtime, ctime)

En sistemas de archivos de Linux, todos los archivos o directorios mantienen un registro del tiempo de tres eventos clave:

- **`atime` (Access Time)**: Indica la última vez que se accedió (leyó) al contenido del archivo.
- **`mtime` (Modified Time)**: Representa la última vez que el contenido interno del archivo fue modificado (edición de texto, por ejemplo).
- **`ctime` (Change Time)**: Refleja el tiempo en que se cambiaron los **metadatos** del archivo (cambio a nivel de permisos, propietario, enlace, etc.). Podemos verlo como cambios a nivel de inodo.

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
| `%n`      | Muestra el nombre del archivo. |

```bash
usuario@debian:/tmp/temporal$ stat -c '%z, %n' fichero1.txt
2024-04-13 10:12:59.494427849 +0200, fichero1.txt
```

---

## 3. Listar según tiempo de modificación (ls)

También se puede ordenar por los diferentes tiempos usando el comando de listado `ls`.

| Comando | Equivalente corto | Funcionalidad |
|---------|-------------------|---------------|
| `ls --time=atime` | `ls -u` | Ordena archivos por fecha de último **acceso** (`atime`). |
| `ls --time=mtime` | `ls -t` | Ordena archivos por fecha de **modificación** de datos (`mtime`). |
| `ls --time=ctime` | `ls -c` | Ordena archivos por fecha de **cambio** de metadatos (`ctime`). |

> **Recuerda:** Combinar estos flags de ordenación con `ls -l` mostrará visualmente las fechas y el orden. (Ej: `ls -lt`).

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

> **Importante:** Fíjate que cualquier ejecución de `touch` siempre acabará cambiando internamente la fecha `ctime`, porque alterar el `atime` o `mtime` ya supone de por sí una manipulación de los metadatos.
