# Comando find

## Índice

1. [Uso básico con exec y xargs](#1-uso-básico-con-exec-y-xargs)
   1. [`-exec` con find](#11--exec-con-find)
   2. [`xargs` con find](#12-xargs-con-find)
   3. [El terminador: `\;` frente a `+`](#13-el-terminador--frente-a-)
   4. [Nombres con espacios: -print0 y xargs -0](#14-nombres-con-espacios--print0-y-xargs--0)
2. [Parámetros principales de find](#2-parámetros-principales-de-find)
   1. [Ejemplos de uso de parámetros](#21-ejemplos-de-uso-de-parámetros)
   2. [Condiciones lógicas](#22-condiciones-lógicas)
   3. [Búsqueda por tiempo (atime, mtime, ctime)](#23-búsqueda-por-tiempo-atime-mtime-ctime)
3. [Diferencia técnica entre exec y xargs](#3-diferencia-técnica-entre-exec-y-xargs)

---

## 1. Uso básico con exec y xargs

Además de buscar, es muy común emplear `find` con `-exec` o pasarlo a través de `xargs`. Ambos son formas de ejecutar comandos en archivos encontrados por `find`, pero difieren en su funcionamiento y flexibilidad.

### 1.1 `-exec` con find

Con `-exec`, `find` ejecuta el comando especificado una vez por cada archivo que encuentra.

```bash
find . -name "*.txt" -exec cp {} /ruta/de/destino \;
```

> **Nota:** Las llaves `{}` son un marcador de posición para el archivo actual, y `\;` indica el final del comando a ejecutar.

### 1.2 `xargs` con find

`xargs` es un comando que toma la entrada estándar y la convierte en argumentos para otro comando.

```bash
find . -name "*.txt" | xargs -I PATTERN cp PATTERN /ruta/de/destino
```

> **Advertencia:** La opción `-t` de `cp` recibe el **directorio de destino**, de modo que la forma correcta de usarla es `cp -t /ruta/de/destino fichero` y no al revés. Escribirla invertida hace que `cp` intente tratar el fichero encontrado como si fuera el directorio de destino y falle. Cuando el destino va al final, como en el ejemplo anterior, no hace falta `-t` en absoluto.

Si se necesita ejecutar un comando simple en cada archivo encontrado por `find`, `-exec` es la opción más directa. Sin embargo, si se quiere realizar manipulaciones adicionales en la lista de archivos o si la lista de archivos es muy larga, `xargs` puede ser más apropiado.

### 1.3 El terminador: `\;` frente a `+`

El carácter que cierra un `-exec` determina cómo se invoca el comando, y la diferencia es importante:

| Terminador | Comportamiento |
|---|---|
| `\;` | Ejecuta **una invocación del comando por cada fichero** encontrado. Si hay 5.000 ficheros, se lanzan 5.000 procesos. |
| `+` | Acumula todos los ficheros que quepan y ejecuta el comando con **todos ellos de una vez**, igual que hace `xargs`. Si no caben, `find` reparte el trabajo en varias invocaciones. |

```bash
usuario@debian:~$ find . -name "*.txt" -exec ls -l {} \;    # un proceso ls por fichero
usuario@debian:~$ find . -name "*.txt" -exec ls -l {} +     # un solo proceso ls con todos
```

> **Recuerda:** La forma `-exec ... +` es la que conviene usar por defecto. Reúne la eficiencia de `xargs` con la seguridad de `-exec`, y evita por completo la tubería. Solo hay que recurrir a `\;` cuando el comando deba recibir los ficheros de uno en uno, o cuando `{}` tenga que aparecer en medio de la orden y no al final.

### 1.4 Nombres con espacios: -print0 y xargs -0

Encadenar `find` con `xargs` a través de una tubería tiene un problema serio: `find` separa los resultados con saltos de línea y `xargs` interpreta además los espacios como separadores. Un fichero llamado `informe anual.txt` llega a `xargs` como **dos** argumentos, `informe` y `anual.txt`:

```bash
usuario@debian:~$ touch "informe anual.txt"
usuario@debian:~$ find . -name "*.txt" | xargs ls -l
ls: no se puede acceder a './informe': No existe el fichero o el directorio
ls: no se puede acceder a 'anual.txt': No existe el fichero o el directorio
```

La solución consiste en separar los nombres con el **byte nulo**, que es el único carácter que no puede aparecer dentro de un nombre de fichero. `find` lo genera con `-print0` y `xargs` lo espera con `-0`:

```bash
usuario@debian:~$ find . -name "*.txt" -print0 | xargs -0 ls -l
-rw-r--r-- 1 usuario usuario 0 sep 18 11:02 ./informe anual.txt
```

> **Advertencia:** Esta pareja `-print0` / `-0` debe considerarse obligatoria siempre que se combine `find` con `xargs`. No es una precaución teórica: en cuanto la orden de la tubería sea destructiva (`rm`, `chmod`, `chown`), un nombre con espacios deja de ser una molestia y pasa a ser un borrado de ficheros equivocados. La alternativa más segura y sencilla sigue siendo prescindir de la tubería y usar `-exec ... +`.

> **Nota:** Otras herramientas entienden el mismo convenio: `grep -z`, `sort -z`, `du --files0-from=-` o `tar --null -T -`.

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
| `-group`  | Busca ficheros pertenecientes a un grupo concreto. |
| `-size`   | Filtra por tamaño, con sufijos `c` (bytes), `k`, `M` y `G`. Admite `+` y `-`: `-size +100M`. |
| `-empty`  | Selecciona ficheros vacíos y directorios sin contenido. |
| `-newer F` | Selecciona lo modificado más recientemente que el fichero `F`. Resulta más práctico que contar días. |
| `-mindepth` | Profundidad mínima. `-mindepth 1` excluye del resultado el propio directorio de partida. |
| `-nouser` / `-nogroup` | Ficheros cuyo UID o GID no corresponde a ninguna cuenta existente. Se usa en auditorías, tras borrar usuarios. |
| `-delete` | Borra lo encontrado sin necesidad de `-exec rm`. |
| `-print0` | Imprime los resultados separados por el byte nulo, para encadenar con `xargs -0`. |
| `-prune`  | Impide descender por una rama del árbol. Se emplea para excluir directorios completos de la búsqueda. |
| `!` o `-not` | Niega la condición siguiente. |

> **Advertencia:** `-maxdepth` y `-mindepth` son opciones globales y deben escribirse **antes** que cualquier criterio de búsqueda. Si se ponen detrás, `find` avisa con `warning: you have specified the -maxdepth option after a non-option argument` y el resultado puede no ser el esperado. Es decir, `find . -maxdepth 1 -name "*.txt"` y no `find . -name "*.txt" -maxdepth 1`.

> **Advertencia:** `-delete` implica `-depth`, de modo que altera el orden en que se recorre el árbol y no puede combinarse sin más con `-prune`. Y sobre todo: **no pide confirmación**. Conviene ejecutar siempre la búsqueda sin `-delete` para comprobar qué sale en la lista, y añadirlo solo después.

### 2.1 Ejemplos de uso de parámetros

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
usuario@debian:~$ touch file1 file2 file3
usuario@debian:~$ chmod 222 file1
usuario@debian:~$ chmod 766 file2
usuario@debian:~$ chmod 655 file3

usuario@debian:~$ ls -l
total 0
--w--w--w- 1 usuario usuario 0 jun 16 13:20 file1
-rwxrw-rw- 1 usuario usuario 0 jun 16 13:20 file2
-rw-r-xr-x 1 usuario usuario 0 jun 16 13:20 file3

usuario@debian:~$ find . -perm 222      # exactamente los permisos 222
./file1
usuario@debian:~$ find . -perm -222     # TODOS (u, g y o) tienen permiso de escritura
./file2
./file1
usuario@debian:~$ find . -perm /222     # ALGUNO (u, g u o) tiene permiso de escritura
.
./file3
./file2
./file1
```

> **Nota:** Merece la pena seguir el razonamiento con los tres ficheros del ejemplo. Con `-222` se exige que los tres triádicos tengan el bit de escritura: `file1` (222) lo cumple, `file2` (766) también porque 7, 6 y 6 incluyen el 2, y `file3` (655) no, porque su 5 de grupo es `r-x` y carece de escritura. Con `/222` basta con que lo tenga uno solo, de ahí que aparezca también `file3` y hasta el propio directorio `.`.

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

### 2.2 Condiciones lógicas

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

### 2.3 Búsqueda por tiempo (atime, mtime, ctime)

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
2. **`... | xargs ls -l`**: `xargs` agrupa los resultados de `find` y se los pasa a `ls -l` como **muchos argumentos en una sola invocación**. No se trata de "un argumento enorme": son argumentos independientes, y si no caben todos en una sola orden, `xargs` no falla, sino que reparte el trabajo en varias llamadas sucesivas hasta agotar la lista. Es la forma más eficiente cuando hay muchos ficheros, porque arranca un proceso en lugar de miles.
3. **`... -exec ls -l {} \;`**: Usa `-exec` de `find` para ejecutar un proceso de `ls -l` distinto sobre cada archivo de forma individual, similar a `-I` de `xargs`, pero dentro del propio comando `find` sin tuberías.
4. **`... -exec ls -l {} +`**: Combina lo mejor de las dos opciones anteriores. Agrupa los ficheros como `xargs` pero sin tubería de por medio, de modo que no le afectan los espacios en los nombres. **Es la forma recomendada.**

> **Recuerda:** El criterio práctico para elegir es sencillo:
>
> | Situación | Forma recomendada |
> |---|---|
> | Caso general | `-exec comando {} +` |
> | El comando necesita los ficheros de uno en uno | `-exec comando {} \;` |
> | `{}` debe ir en medio de la orden, no al final | `xargs -0 -I {} comando {} destino` |
> | La lista no procede de `find` | `xargs` |
> | Solo hay que borrar lo encontrado | `find ... -delete` |

> **Importante:** Es muy común el uso de `xargs` sin el flag `-I` en casos donde sobrepasamos el límite de argumentos del sistema, como en un borrado masivo.

> **Advertencia:** Conviene fijarse en que `ls *.logs | xargs rm -rf` **no resuelve** el problema de "Argument list too long", sino que lo reproduce. El comodín `*.logs` lo expande el shell **antes** de ejecutar `ls`, de modo que es la propia orden `ls` la que se queda sin espacio para sus argumentos y falla igual que fallaba `rm *`. Las formas que sí funcionan son las que evitan que el shell expanda nada:
>
> ```bash
> root@debian:/tmp/prueba# ls | xargs rm                    # 'ls' sin comodin
> root@debian:/tmp/prueba# find . -name '*.logs' -delete    # el patron va entrecomillado
> root@debian:/tmp/prueba# find . -name '*.logs' -print0 | xargs -0 rm
> ```
>
> Nótese que en las dos últimas el patrón va entre comillas simples precisamente para que lo interprete `find` y no el shell, tal como se explicaba en el documento 09.

> **Nota:** A mayores de `-exec` existe el parámetro `-ok`. Su diferencia es que `-ok` es idéntico a `-exec`, pero, para cada coincidencia, requerirá una **confirmación interactiva** al usuario por teclado (y/n) antes de ejecutarse.
> ```bash
> find / -type f -name "*.mp3" -ok rm -rf {} \;
> ```
