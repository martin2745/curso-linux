# Comando find

## Índice

1. [Sintaxis básica](#1-sintaxis-básica)
2. [Criterios de búsqueda](#2-criterios-de-búsqueda)
   1. [Resumen de criterios](#21-resumen-de-criterios)
   2. [Por nombre y ruta](#22-por-nombre-y-ruta)
   3. [Por tipo y tamaño](#23-por-tipo-y-tamaño)
   4. [Por permisos](#24-por-permisos)
   5. [Por propietario](#25-por-propietario)
   6. [Por tiempo (atime, mtime, ctime)](#26-por-tiempo-atime-mtime-ctime)
   7. [Por inodo y enlaces](#27-por-inodo-y-enlaces)
   8. [Limitar dónde se busca](#28-limitar-dónde-se-busca)
3. [Condiciones lógicas](#3-condiciones-lógicas)
4. [Acciones sobre lo encontrado](#4-acciones-sobre-lo-encontrado)
   1. [Mostrar y borrar: -print, -ls, -printf, -delete](#41-mostrar-y-borrar--print--ls--printf--delete)
   2. [`-exec` y `-ok`](#42--exec-y--ok)
   3. [`xargs` con find](#43-xargs-con-find)
   4. [El terminador: `\;` frente a `+`](#44-el-terminador--frente-a-)
   5. [Nombres con espacios: -print0 y xargs -0](#45-nombres-con-espacios--print0-y-xargs--0)
   6. [El error «Argument list too long»](#46-el-error-argument-list-too-long)
5. [Diferencia técnica entre exec y xargs](#5-diferencia-técnica-entre-exec-y-xargs)

---

## 1. Sintaxis básica

`find` busca ficheros y directorios **recorriendo el árbol de directorios** a partir de una o varias rutas, y comprueba en cada uno los criterios que se le indiquen. Su sintaxis general es:

```text
find [ruta...] [criterios] [acción]
```

| Parte | Qué indica | Si se omite |
|---|---|---|
| Ruta | Dónde empezar a buscar. Pueden ser varias. | Se busca en el directorio actual (`.`). |
| Criterios | Qué condiciones debe cumplir lo que se busca: nombre, tipo, tamaño, fechas... | Se muestra **todo** lo que hay bajo la ruta. |
| Acción | Qué hacer con cada resultado. | Se muestra su ruta (`-print`). |

```bash
usuario@debian:~$ find /etc -name "hosts"
find: '/etc/ssl/private': Permiso denegado
find: '/etc/sudoers.d': Permiso denegado
/etc/hosts
```

Al buscar como usuario normal en carpetas del sistema, `find` muestra un error por cada directorio que no puede leer. Como esos errores salen por la salida de errores, se pueden descartar redirigiéndola a `/dev/null` (documento 10):

```bash
usuario@debian:~$ find /etc -name "hosts" 2>/dev/null
/etc/hosts
```

> **Importante:** Los patrones con comodines, como `"*.txt"`, deben ir **siempre entre comillas**. Sin ellas, el *shell* expande el comodín **antes** de ejecutar `find` (documento 09): si en el directorio actual hay un fichero `notas.txt`, la orden `find . -name *.txt` se convierte en `find . -name notas.txt`, y solo se busca ese nombre. Si hay varios ficheros `.txt`, `find` recibe varios nombres y falla con un error de sintaxis.

> **Nota:** `find` recorre el disco en el momento, así que siempre da resultados actualizados, pero puede tardar en árboles grandes. Para buscar solo por nombre en todo el sistema existe `locate` (paquete `plocate` en Debian y Ubuntu), que consulta una base de datos y responde al instante, aunque no ve los ficheros creados desde la última vez que se actualizó la base con `updatedb`.

---

## 2. Criterios de búsqueda

### 2.1 Resumen de criterios

| Parámetro | Descripción |
|-----------|-------------|
| `-name patrón` | Busca por **nombre**, distinguiendo mayúsculas y minúsculas. Admite comodines (`*`, `?`, `[ ]`). |
| `-iname patrón` | Igual que `-name`, pero sin distinguir mayúsculas y minúsculas. |
| `-path patrón` | Busca por la **ruta completa**, no solo por el nombre. |
| `-type tipo` | Filtra por tipo: `f` fichero regular, `d` directorio, `l` enlace simbólico, `b` y `c` dispositivos, `p` tubería, `s` *socket*. |
| `-size n` | Filtra por tamaño, con sufijos `c` (bytes), `k`, `M` y `G`. Admite `+` (más de) y `-` (menos de). |
| `-empty` | Ficheros vacíos y directorios sin contenido. |
| `-perm modo` | Busca según los permisos (apartado 2.4). |
| `-user` / `-group` | Ficheros de un usuario o de un grupo concreto. |
| `-nouser` / `-nogroup` | Ficheros cuyo UID o GID no corresponde a ninguna cuenta existente. Se usa en auditorías, tras borrar usuarios. |
| `-mtime` / `-mmin` | Fecha de modificación del contenido, en días o en minutos. |
| `-atime` / `-amin` | Fecha del último acceso, en días o en minutos. |
| `-ctime` / `-cmin` | Fecha del último cambio del inodo (metadatos), en días o en minutos. |
| `-newer F` | Lo modificado más recientemente que el fichero `F`. |
| `-newermt fecha` | Lo modificado después de una fecha, por ejemplo `-newermt '2026-11-01'`. |
| `-inum n` / `-samefile F` | Lo que tiene el número de inodo `n` o el mismo inodo que el fichero `F` (enlaces duros). |
| `-links n` | Ficheros con `n` enlaces duros. |
| `-xtype l` | Enlaces simbólicos rotos. |
| `-maxdepth` / `-mindepth` | Profundidad máxima y mínima de búsqueda. `-mindepth 1` excluye del resultado el propio directorio de partida. |
| `-xdev` | No entra en otros sistemas de ficheros montados dentro de la ruta. |
| `-prune` | Impide descender por una rama del árbol. Se emplea para excluir directorios completos. |
| `!` o `-not` | Niega la condición siguiente. |

> **Advertencia:** `-maxdepth`, `-mindepth` y `-xdev` son opciones globales y deben escribirse **antes** que cualquier criterio de búsqueda. Si se ponen detrás, `find` avisa con `warning: you have specified the global option -maxdepth after the argument -name` y el resultado puede no ser el esperado. Es decir, `find . -maxdepth 1 -name "*.txt"` y no `find . -name "*.txt" -maxdepth 1`.

### 2.2 Por nombre y ruta

**Búsqueda por nombre, distinguiendo mayúsculas y minúsculas:**

```bash
find /ruta -name "*.txt"
```

**Búsqueda ignorando mayúsculas y minúsculas**, que encuentra también `INFORME.TXT` o `Notas.Txt`:

```bash
find /ruta -iname "*.txt"
```

`-name` compara solo el **nombre** del fichero, sin la carpeta. Para buscar por un trozo de la ruta se usa `-path`, que compara la ruta completa:

```bash
usuario@debian:~$ mkdir -p prueba/docs prueba/fotos
usuario@debian:~$ touch prueba/docs/lista.txt prueba/fotos/lista.txt
usuario@debian:~$ find prueba -name "lista.txt"
prueba/docs/lista.txt
prueba/fotos/lista.txt
usuario@debian:~$ find prueba -path "*docs*" -name "lista.txt"
prueba/docs/lista.txt
```

Los dos ficheros se llaman igual, así que `-name` no puede distinguirlos; `-path` sí, porque mira la carpeta en la que está cada uno.

> **Nota:** `-name "informe"` solo encuentra ficheros que se llamen exactamente `informe`. Para encontrar los que **contienen** esa palabra hay que usar comodines: `-name "*informe*"`.

### 2.3 Por tipo y tamaño

**Búsqueda por tipo (`-type`):**

```bash
find /var/log -type f      # solo ficheros regulares
find /home -type d         # solo directorios
find /usr/bin -type l      # solo enlaces simbólicos
```

**Búsqueda por tamaño (`-size`):**

```bash
find / -type f -size +100M 2>/dev/null     # ficheros de más de 100 MB
find . -type f -size -10k                  # ficheros de menos de 10 KB
find . -type f -empty                      # ficheros vacíos
```

> **Advertencia:** `-size` redondea **hacia arriba** a la unidad indicada antes de comparar. Un fichero de 300 KB cuenta como 1 M, así que `-size -1M` («menos de 1 MB») solo encuentra los ficheros **vacíos**: cualquier otro ya ocupa al menos «1 M». Para tamaños pequeños hay que usar una unidad menor: `-size -1024k`. Además, sin sufijo, la unidad son bloques de 512 bytes, no bytes; para indicar bytes se usa `c` (`-size +500c`).

### 2.4 Por permisos

El modo de `-perm` se puede escribir de tres formas:

1. Permisos exactos (Buscar archivos con permisos exactamente 644):
```bash
find . -perm 644
```

2. Al menos esos permisos (Buscar archivos que tengan **todos** los permisos indicados, aunque tengan más):
```bash
find . -perm -644
```

3. Cualquiera de esos permisos (Buscar archivos que tengan **alguno** de los permisos indicados):
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

> **Nota:** Merece la pena seguir el razonamiento con los tres ficheros del ejemplo. Con `-222` se exige que los tres grupos de permisos (usuario, grupo y otros) tengan el bit de escritura: `file1` (222) lo cumple, `file2` (766) también porque 7, 6 y 6 incluyen el 2, y `file3` (655) no, porque su 5 de grupo es `r-x` y carece de escritura. Con `/222` basta con que lo tenga uno solo, de ahí que aparezca también `file3` y hasta el propio directorio `.`.

El modo también se puede escribir en notación simbólica, como en `chmod`: `-perm -u=x` (el propietario tiene ejecución) o `-perm /o=w` (los otros pueden escribir).

Un uso muy habitual en seguridad es buscar los programas con **permisos especiales** (documento 28, sección 8), porque un ejecutable con SUID de `root` que no debería tenerlo es una vía para obtener privilegios:

```bash
usuario@debian:~$ find / -type f -perm -4000 2>/dev/null     # ficheros con SUID
usuario@debian:~$ find / -type f -perm -2000 2>/dev/null     # ficheros con SGID
usuario@debian:~$ find / -type f -perm -o=w 2>/dev/null      # ficheros que cualquiera puede modificar
```

### 2.5 Por propietario

```bash
find /ruta -user usuario1            # ficheros de usuario1
find /srv -group dam                 # ficheros del grupo dam
find / -nouser 2>/dev/null           # ficheros sin propietario válido
```

`-nouser` encuentra los ficheros de usuarios que ya se han borrado: en el listado aparecen con un número (su antiguo UID) en lugar de un nombre. Es habitual tras eliminar cuentas con `userdel` sin `-r` (documento 28).

### 2.6 Por tiempo (atime, mtime, ctime)

Cada fichero guarda tres tiempos en su inodo (documento 24), y `find` tiene una opción para cada uno:

- `-atime`: busca por la fecha del último acceso (*access time*), es decir, la última vez que se leyó el contenido del fichero.
- `-mtime`: busca por la fecha de la última modificación del contenido (*modification time*).
- `-ctime`: busca por la fecha del último cambio del inodo (*change time*): permisos, propietario, enlaces... o el propio contenido.

Estos tres criterios trabajan con **periodos de 24 horas contados hacia atrás desde el momento actual**, no con días del calendario: `-mtime 1` no significa «ayer», sino «hace entre 24 y 48 horas». El número admite un signo delante:

| Valor | Significado | Ejemplo |
|---|---|---|
| `-n` | Hace **menos** de `n` periodos de 24 horas. | `-mtime -3`: modificados en las últimas 72 horas. |
| `n` | Hace **exactamente** `n` periodos completos. | `-mtime 1`: modificados hace entre 24 y 48 horas. |
| `+n` | Hace **más** de `n` periodos completos. | `-atime +4`: no leídos desde hace 5 días o más. |

> **Advertencia:** `find` calcula cuántos periodos completos de 24 horas han pasado y **descarta las fracciones**. Un fichero modificado hace 4 días y 20 horas cuenta como de hace 4 días, así que `-mtime +4` («más de 4») no lo encuentra: hace falta que hayan pasado al menos 5 días completos. Por eso `-mtime 0` significa «en las últimas 24 horas».

```text
        ahora
          │
  ────────┼──────────┼──────────┼──────────┼─────────▶ hacia el pasado
          0 h       24 h       48 h       72 h
          └── -mtime 0 ──┘└── -mtime 1 ─┘└── -mtime 2 ─┘
          └────────── -mtime -3 ──────────────────────┘
                                                      └── -mtime +2 ──▶
```

Para trabajar con más precisión hay alternativas:

| Opción | Uso |
|---|---|
| `-amin`, `-mmin`, `-cmin` | Lo mismo, pero en **minutos**: `find ~ -mmin -30` muestra lo modificado en la última media hora. |
| `-newer fichero` | Lo modificado **después** que el fichero indicado. Muy útil para saber qué ha cambiado tras una instalación: se crea un fichero de referencia con `touch` antes de instalar y se busca después con `-newer`. |
| `-newermt 'fecha'` | Lo modificado **después de una fecha** concreta: `find /etc -newermt '2026-11-01 08:00'`. |
| `-daystart` | Hace que los días se cuenten desde el comienzo del día de hoy, como días del calendario: `find . -daystart -mtime 1` sí significa «ayer». Debe ir antes de `-mtime`. |

Para buscar entre dos fechas se combinan dos condiciones:

```bash
find /var/log -type f -mtime +3 -mtime -7     # modificados hace entre 4 y 6 días completos
find . -newermt '2026-10-01' ! -newermt '2026-11-01'   # modificados durante octubre
```

### 2.7 Por inodo y enlaces

Estos criterios se apoyan en los inodos y los enlaces, que se explican en el apartado 8 del documento 03:

```bash
usuario@debian:~/enlaces$ find ~ -samefile enlace-duro     # todos los nombres (enlaces duros) del mismo fichero
/home/usuario/enlaces/enlace-duro
/home/usuario/enlaces/otro-nombre
usuario@debian:~/enlaces$ find ~ -inum 2359319             # lo mismo, por número de inodo
/home/usuario/enlaces/enlace-duro
/home/usuario/enlaces/otro-nombre
usuario@debian:~/enlaces$ find . -type f -links +1         # ficheros con más de un enlace duro
usuario@debian:~/enlaces$ find . -xtype l                  # enlaces simbólicos rotos
```

> **Nota:** Un número de inodo solo es único dentro de su sistema de ficheros. Si la búsqueda con `-inum` recorre varios discos, conviene añadir `-xdev` para no mezclar inodos de otros sistemas de ficheros con el mismo número.

### 2.8 Limitar dónde se busca

**Profundidad (`-maxdepth` y `-mindepth`):**

```bash
find . -maxdepth 1 -type f         # solo los ficheros del directorio actual, sin entrar en subdirectorios
find . -mindepth 1 -maxdepth 1     # todo lo que hay en el directorio actual, sin incluir '.'
```

**No salir del sistema de ficheros (`-xdev`):** al buscar en `/`, `find` entra también en los discos montados, en `/proc` o en `/sys`. Con `-xdev` se queda en el sistema de ficheros de la ruta de partida:

```bash
find / -xdev -type f -size +100M 2>/dev/null
```

**Excluir directorios (`-prune`):** `-prune` impide entrar en los directorios que cumplen la condición anterior. Se combina con `-o` (apartado 3), y en este caso hay que añadir `-print` al final para que solo se muestre lo que no se ha excluido:

```bash
find . -path ./node_modules -prune -o -name "*.js" -print
```

Se lee así: «si la ruta es `./node_modules`, no entres; si no, busca los ficheros `.js` y muéstralos».

---

## 3. Condiciones lógicas

Para combinar condiciones con `find`, puedes utilizar `-a` (AND), `-o` (OR) y `!` (NOT):

- **`-a` (AND):** Encuentra archivos que cumplan todas las condiciones especificadas. Es la lógica por defecto si no se escribe ningún conector, así que `-a` se puede omitir.
```bash
find /ruta -name "*.txt" -a -user usuario1
find /ruta -name "*.txt" -user usuario1      # equivalente
```

- **`-o` (OR):** Encuentra archivos que cumplan al menos una de las condiciones especificadas.
```bash
find / -name "*.txt" -o -name "*.jpg"
```

- **`!` o `-not` (NOT):** Encuentra archivos que **no** cumplan la condición siguiente.
```bash
find . -type f ! -name "*.txt"     # todos los ficheros menos los .txt
```

> **Importante:** `-a` tiene **más prioridad** que `-o`, igual que la multiplicación frente a la suma. Por eso, en una orden como esta, el `-exec` solo se aplica a los ficheros `.jpg`:
>
> ```bash
> find . -name "*.txt" -o -name "*.jpg" -exec ls -l {} +
> ```
>
> `find` la interpreta como «`.txt`, **o bien** (`.jpg` **y** ejecutar `ls`)». Para que la acción se aplique a los dos, las condiciones del `-o` se agrupan entre **paréntesis**, que hay que escapar con `\` para que no los interprete el *shell*, y separar con espacios:
>
> ```bash
> find . \( -name "*.txt" -o -name "*.jpg" \) -exec ls -l {} +
> ```

> **Recuerda:** Las posibilidades son bastante amplias y puedes construir búsquedas muy complejas:
> ```bash
> find $HOME -type f -iname "*.png" -mtime +3 -mtime -5 -perm 644 -size +2M -user www-data ! -group root -exec ls -lah {} + 2>/dev/null
> ```

---

## 4. Acciones sobre lo encontrado

Además de mostrar la lista de resultados, `find` puede hacer algo con cada uno de ellos.

### 4.1 Mostrar y borrar: -print, -ls, -printf, -delete

| Acción | Qué hace |
|---|---|
| `-print` | Muestra la ruta de cada resultado. Es la acción por defecto. |
| `-ls` | Muestra cada resultado con un formato parecido al de `ls -dils`: inodo, permisos, propietario, tamaño, fecha y ruta. |
| `-printf formato` | Muestra solo los datos que se indiquen: `%p` ruta, `%f` nombre, `%s` tamaño, `%u` propietario, `%m` permisos en octal, `%t` fecha de modificación... Hay que terminar el formato con `\n`. |
| `-print0` | Muestra los resultados separados por el byte nulo, para encadenar con `xargs -0` (apartado 4.5). |
| `-delete` | Borra lo encontrado sin necesidad de `-exec rm`. |

```bash
usuario@debian:~$ find /var/log -maxdepth 1 -name "*.log" -printf '%s\t%p\n' 2>/dev/null
```

Muestra el tamaño en bytes y la ruta de cada fichero `.log` de `/var/log`, separados por un tabulador. Es una salida cómoda de ordenar después con `sort -n` (documento 08).

> **Advertencia:** `-delete` implica `-depth`, de modo que altera el orden en que se recorre el árbol y no puede combinarse sin más con `-prune`. Y sobre todo: **no pide confirmación**. Conviene ejecutar siempre la búsqueda sin `-delete` para comprobar qué sale en la lista, y añadirlo solo después. Además, `-delete` debe ir **al final**: `find . -delete -name "*.tmp"` borra **todo**, porque `-delete` se ejecuta antes de comprobar el nombre.

### 4.2 `-exec` y `-ok`

Con `-exec`, `find` ejecuta el comando especificado sobre cada archivo que encuentra:

```bash
find . -name "*.txt" -exec cp {} /ruta/de/destino \;
```

> **Nota:** Las llaves `{}` son un marcador de posición para el archivo actual, y `\;` indica el final del comando a ejecutar. La barra invertida es necesaria para que el *shell* no interprete el `;` como separador de órdenes.

```bash
usuario@debian:~$ ls
fileModificado.tmp  file.tmp  file.tmp2  prueba.txt

usuario@debian:~$ find . -name "file*" -exec ls -l {} \;
-rw-rw-r-- 1 usuario usuario 127 abr 14 16:12 ./fileModificado.tmp
-rw-rw-r-- 1 usuario usuario 114 abr 14 15:51 ./file.tmp2
-rw-rw-r-- 1 usuario usuario 112 abr 14 16:02 ./file.tmp
```

A mayores de `-exec` existe el parámetro `-ok`. Es idéntico a `-exec`, pero, para cada coincidencia, pide una **confirmación interactiva** al usuario por teclado (`y`/`n`) antes de ejecutarse:

```bash
find / -type f -name "*.mp3" -ok rm {} \;
```

### 4.3 `xargs` con find

`xargs` es un comando que toma la entrada estándar y la convierte en argumentos para otro comando. Recibe la lista de resultados de `find` por una tubería:

```bash
usuario@debian:~$ find . -name "file*" | xargs ls -l
-rw-rw-r-- 1 usuario usuario 127 abr 14 16:12 ./fileModificado.tmp
-rw-rw-r-- 1 usuario usuario 112 abr 14 16:02 ./file.tmp
-rw-rw-r-- 1 usuario usuario 114 abr 14 15:51 ./file.tmp2
```

Por defecto, `xargs` coloca los argumentos **al final** de la orden. Si tienen que ir en otra posición, se usa `-I` con un marcador, y entonces se ejecuta una orden por cada resultado:

```bash
find . -name "*.txt" | xargs -I PATRON cp PATRON /ruta/de/destino
```

Para copiar sin tener que ejecutar `cp` una vez por fichero, se puede usar la opción `-t` de `cp`, que permite poner el directorio de destino **antes** de los ficheros, y así `xargs` puede añadirlos todos al final:

```bash
find . -name "*.txt" -print0 | xargs -0 cp -t /ruta/de/destino
```

> **Advertencia:** La opción `-t` de `cp` recibe el **directorio de destino**, de modo que la forma correcta de usarla es `cp -t /ruta/de/destino fichero...` y no al revés. Escribirla invertida hace que `cp` intente tratar el fichero encontrado como si fuera el directorio de destino y falle.

Si se necesita ejecutar un comando simple en cada archivo encontrado por `find`, `-exec` es la opción más directa. `xargs` es útil cuando la lista de ficheros no procede de `find`, o cuando se quiere procesar la lista antes con otras órdenes de la tubería (`grep`, `sort`...).

### 4.4 El terminador: `\;` frente a `+`

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

### 4.5 Nombres con espacios: -print0 y xargs -0

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

### 4.6 El error «Argument list too long»

Supongamos un directorio con cientos de miles de ficheros:

```bash
root@debian:/tmp/prueba# ls | head -3
prueba1.txt
prueba10.txt
prueba100.txt
root@debian:/tmp/prueba# ls | wc -l
300000
```

Si se intenta borrarlos con `rm *`, el *shell* expande el comodín y genera una orden con 300.000 argumentos (`rm prueba1.txt prueba10.txt ...`), que supera el tamaño máximo que el sistema admite para los argumentos de una orden:

```bash
root@debian:/tmp/prueba# rm *
-bash: /usr/bin/rm: La lista de argumentos es demasiado larga
```

La solución es no dejar que el *shell* expanda nada y que sea `find` quien recorra el directorio:

```bash
root@debian:/tmp/prueba# find . -maxdepth 1 -name 'prueba*.txt' -delete
root@debian:/tmp/prueba# find . -maxdepth 1 -name 'prueba*.txt' -print0 | xargs -0 rm
```

`xargs` reparte la lista en varias llamadas a `rm`, cada una con tantos ficheros como caben, así que nunca supera el límite. En las dos órdenes el patrón va entre comillas simples precisamente para que lo interprete `find` y no el *shell*, tal como se explicaba en el documento 09.

> **Advertencia:** Conviene fijarse en que `ls *.txt | xargs rm` **no resuelve** el problema, sino que lo reproduce. El comodín `*.txt` lo expande el *shell* **antes** de ejecutar `ls`, de modo que es la propia orden `ls` la que se queda sin espacio para sus argumentos y falla igual que fallaba `rm *`. `ls | xargs rm`, sin comodín, sí funciona, pero falla con los nombres que tienen espacios; por eso es mejor cualquiera de las dos formas con `find`.

---

## 5. Diferencia técnica entre exec y xargs

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

root@debian:/tmp# find /tmp -name "hola*" -exec ls -l {} + 2>/dev/null
-rw-rw-r-- 1 root root 25 Feb 11 11:03 /tmp/hola.txt
-rw-rw-r-- 1 root root  0 Feb 11 11:17 /tmp/hola2.txt
```

El resultado es el mismo; la diferencia entre los cuatro comandos radica en cómo pasan los resultados del comando `find` al comando `ls -l`:

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
