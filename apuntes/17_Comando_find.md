# Comando find

## Índice

1. [Uso básico con exec y xargs](#1-uso-básico-con-exec-y-xargs)
2. [Parámetros principales de find](#2-parámetros-principales-de-find)
3. [Diferencia técnica entre exec y xargs](#3-diferencia-técnica-entre-exec-y-xargs)

---

El comando `find` permite buscar archivos y directorios en el sistema de archivos basándose en diversos criterios como el nombre del archivo, el tipo, la fecha de modificación, etc.

---

## 1. Uso básico con exec y xargs

Además de buscar, es muy común emplear `find` con `-exec` o pasarlo a través de `xargs`. Ambos son formas de ejecutar comandos en archivos encontrados por `find`, pero difieren en su funcionamiento y flexibilidad.

### `-exec` con find

Con `-exec`, `find` ejecuta el comando especificado una vez por cada archivo que encuentra.

```bash
find . -name "*.txt" -exec cp {} /ruta/de/destino \;
```

> **Nota:** Las llaves `{}` son un marcador de posición para el archivo actual, y `\;` indica el final del comando a ejecutar.

### `xargs` con find

`xargs` es un comando que toma la entrada estándar y la convierte en argumentos para otro comando.

```bash
find . -name "*.txt" | xargs -I PATTERN cp -t PATTERN /ruta/de/destino
```

Si se necesita ejecutar un comando simple en cada archivo encontrado por `find`, `-exec` es la opción más directa. Sin embargo, si se quiere realizar manipulaciones adicionales en la lista de archivos o si la lista de archivos es muy larga, `xargs` puede ser más apropiado.

```bash
usuario@debian:~$ ls
fileModificado.tmp  file.tmp  file.tmp2  prueba.txt

usuario@debian:~$ find . -name "file*" -exec ls -l {} \;
-rw-rw-r-- 1 usuario usuario 127 abr 14 16:12 ./fileModificado.tmp
-rw-rw-r-- 1 usuario usuario 114 abr 14 15:51 ./file.tmp2
-rw-rw-r-- 1 usuario usuario 112 abr 14 16:02 ./file.tmp

usuario@debian:~$ find . -name "file*" | xargs -I X ls -l X;
-rw-rw-r-- 1 usuario usuario 127 abr 14 16:12 ./fileModificado.tmp
-rw-rw-r-- 1 usuario usuario 114 abr 14 15:51 ./file.tmp2
-rw-rw-r-- 1 usuario usuario 112 abr 14 16:02 ./file.tmp
```

Por otra parte, el uso de `xargs` está enfocado en convertir la entrada estándar en argumentos masivos, lo cual es muy útil en Linux si quisiéramos eliminar una gran cantidad de archivos:

```bash
root@debian:/tmp/prueba# ls -l
total 0
-rw-r--r-- 1 root root 0 may  6 19:50 prueba1.txt
-rw-r--r-- 1 root root 0 may  6 19:50 prueba2.txt
...
-rw-r--r-- 1 root root 0 may  6 19:50 prueba987654321.txt
```

> **Advertencia:** Si nosotros hiciéramos uso del comando `rm *`, el proceso de expansión del shell generaría una orden tan grande (`rm prueba1.txt prueba2.txt...`) que excedería el tamaño del buffer reservado para los comandos (error "Argument list too long"). La solución para este tipo de operaciones es el uso de `xargs`.

```bash
root@debian:/tmp/prueba# ls | xargs rm
```

---

## 2. Parámetros principales de find

| Parámetro | Descripción |
|-----------|-------------|
| `-name`   | Buscar archivos por su nombre exacto (distingue entre mayúsculas y minúsculas). |
| `-iname`  | Similar a `-name`, pero no distingue entre mayúsculas y minúsculas. |
| `-perm`   | Buscar archivos según sus permisos numéricos. |
| `-maxdepth` | Especifica la profundidad máxima de búsqueda en el árbol de directorios. |
| `-type`   | Filtra archivos por tipo (`f` para fichero regular, `d` para directorio, `l` enlace). |
| `-user`   | Busca archivos pertenecientes a un usuario específico. |
| `-mtime`  | Modificación de contenido (días). |
| `-atime`  | Último acceso (días). |
| `-ctime`  | Modificación de inodos (días). |

### Ejemplos de uso de parámetros

**Búsqueda por nombre (distinguiendo mayúsculas y minúsculas)**:
```bash
find /ruta -name "*.txt"
```

**Búsqueda ignorando mayúsculas y minúsculas**:
```bash
find /ruta -iname "*.txt"
```

**Búsqueda por permisos (`-perm`)**:

1. Permisos exactos (Buscar archivos con permisos exactamente 644):
```bash
find . -perm 644
```

2. Al menos esos permisos (Buscar archivos con al menos permisos 644):
```bash
find . -perm -644
```

3. Cualquiera de esos permisos (Buscar archivos que tengan alguno de los permisos indicados):
```bash
find . -perm /644
```

Ejemplo de cómo funciona la búsqueda por permisos en la práctica:
```bash
$ touch file1 file2 file3
$ chmod 222 file1
$ chmod 766 file2
$ chmod 655 file3

$ ls -l
total 0
--w--w--w- 1 kali kali 0 jun 16 13:20 file1
-rwxrw-rw- 1 kali kali 0 jun 16 13:20 file2
-rw-r-xr-x 1 kali kali 0 jun 16 13:20 file3

$ find . -perm 222 # Buscar archivos con exactamente permisos 222
./file1
$ find . -perm -222 # Buscar archivos donde TODOS en ugo posean permisos 2 (escritura)
./file2
./file1
$ find . -perm /222 # Buscar archivos donde CUALQUIERA en ugo posean permisos de escritura
.
./file3
./file2
./file1
```

**Búsqueda limitando profundidad (`-maxdepth`)**:
```bash
find . -maxdepth 1 -type f
```

**Búsqueda por tipo (`-type`)**:
```bash
find / -type d
```

**Búsqueda por usuario (`-user`)**:
```bash
find /ruta -user usuario1
```

### Condiciones Lógicas

Para combinar condiciones con `find`, puedes utilizar `-o` (OR) y `-a` (AND):

- **`-o` (OR):** Encuentra archivos que cumplan al menos una de las condiciones especificadas.
```bash
find / -name "*.txt" -o -name "*.jpg"
```

- **`-a` (AND):** Encuentra archivos que cumplan todas las condiciones especificadas (esta es la lógica por defecto si no se especifica un conector).
```bash
find /ruta -name "*.txt" -a -user usuario1
```

> **Recuerda:** Las posibilidades son bastante amplias y puedes construir búsquedas muy complejas:
> ```bash
> find $HOME -type f -iname "*.png" -mtime +3 -mtime -5 -perm 644 -size +2M -user www-data -and -not -user root -and -group www-data -a ! -group root -exec ls -lah {} \; 2>/dev/null
> ```

### Búsqueda por tiempo (atime, mtime, ctime)

- `-atime`: busca en la fecha del último acceso (access time). Un acceso puede ser la lectura del archivo, pero también listarlo.
- `-mtime`: busca en la fecha de la última modificación (modification time). Se trata de la modificación del contenido.
- `-ctime`: busca en la fecha de modificación (change time, fecha de última modificación del número de inodo o permisos).

Estos tres criterios sólo trabajan con días (periodos de 24 horas). `0` es el mismo día; `1`, ayer; `2`, antes de ayer, etc. El valor `n` colocado después del criterio corresponde a `n*24` horas.

Los signos `+` o `-` permiten precisar los términos "de más de" y "de menos de":
- `find / -type f -mtime 1`: archivos modificados ayer (entre 24 y 48 horas).
- `-mtime -3`: archivos modificados hace menos de tres días (72 horas).
- `-atime +4`: archivos accedidos hace más de cuatro días (más de 96 horas).

> **Nota:** Para trabajar con minutos exactos en lugar de días, tenemos los parámetros equivalentes `-amin`, `-mmin` y `-cmin`.

---

## 3. Diferencia técnica entre exec y xargs

Para el siguiente caso:

```bash
root@debian:/tmp# find /tmp -name "hola*" 2>/dev/null | xargs -I a ls -l a
-rw-rw-r-- 1 root root 25 Feb 11 11:03 /tmp/hola.txt
-rw-rw-r-- 1 root root  0 Feb 11 11:17 /tmp/hola2.txt

root@debian:/tmp# find /tmp -name "hola*" 2>/dev/null | xargs ls -l
-rw-rw-r-- 1 root root 25 Feb 11 11:03 /tmp/hola.txt
-rw-rw-r-- 1 root root  0 Feb 11 11:17 /tmp/hola2.txt

root@debian:/tmp# find /tmp -name "hola*" -exec ls -l {} \; 2>/dev/null
-rw-rw-r-- 1 root root 25 Feb 11 11:03 /tmp/hola.txt
-rw-rw-r-- 1 root root  0 Feb 11 11:17 /tmp/hola2.txt
```

La diferencia entre los tres comandos radica en cómo pasan los resultados del comando `find` al comando `ls -l`:

1. **`... | xargs -I a ls -l a`**: Usa `xargs` con la opción `-I a`, lo que le permite tomar cada resultado de `find` y ejecutar `ls -l` sobre cada uno de esos archivos de manera individual. 
2. **`... | xargs ls -l`**: `xargs` toma **todos** los resultados de `find` y los pasa todos de una vez como un único argumento enorme a `ls -l`. Si hay muchos archivos, es la forma más eficiente.
3. **`... -exec ls -l {} \;`**: Usa `-exec` de `find` para ejecutar un proceso de `ls -l` distinto sobre cada archivo de forma individual, similar a `-I` de `xargs`, pero dentro del propio comando `find` sin tuberías.

> **Importante:** Es muy común el uso de `xargs` sin el flag `-I` en casos donde sobrepasamos el buffer del sistema (por ejemplo borrado masivo):
> ```bash
> ls *.logs | xargs rm -rf
> ```

> **Nota:** A mayores de `-exec` existe el parámetro `-ok`. Su diferencia es que `-ok` es idéntico a `-exec`, pero, para cada coincidencia, requerirá una **confirmación interactiva** al usuario por teclado (y/n) antes de ejecutarse.
> ```bash
> find / -type f -name "*.mp3" -ok rm -rf {} \;
> ```
