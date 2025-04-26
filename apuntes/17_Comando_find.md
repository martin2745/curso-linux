# Comando find

Permite buscar archivos y directorios en el sistema de archivos basándose en diversos criterios como el nombre del archivo, el tipo, la fecha de modificación, etc.

Además, es muy común emplear find con `-exec` y `xargs`. Ambos son formas de ejecutar comandos en archivos encontrados por `find`, pero difieren en su funcionamiento y flexibilidad.

- **-exec con find:** Con `-exec`, `find` ejecuta el comando especificado una vez por cada archivo que encuentra.

```bash
find . -name "*.txt" -exec cp {} /ruta/de/destino \;
```

- **xargs con find:** `xargs` es un comando que toma la entrada estándar y la convierte en argumentos para otro comando.

```bash
find . -name "*.txt" | xargs -I PATTERN  cp -t PATTERN  /ruta/de/destino
```

Si se necesita ejecutar un comando simple en cada archivo encontrado por `find`, `-exec` es la opción más directa. Sin embargo, si se quiere realizar manipulaciones adicionales en la lista de archivos o si la lista de archivos es muy larga, `xargs` puede ser más apropiado.

```bash
si@si-VirtualBox:/tmp/prueba$ ls
fileModificado.tmp  file.tmp  file.tmp2  prueba.txt

si@si-VirtualBox:/tmp/prueba$ find . -name "file*" -exec ls -l {} \;
-rw-rw-r-- 1 si si 127 abr 14 16:12 ./fileModificado.tmp
-rw-rw-r-- 1 si si 114 abr 14 15:51 ./file.tmp2
-rw-rw-r-- 1 si si 112 abr 14 16:02 ./file.tmp

si@si-VirtualBox:/tmp/prueba$ find . -name "file*" | xargs -I X ls -l X;
-rw-rw-r-- 1 si si 127 abr 14 16:12 ./fileModificado.tmp
-rw-rw-r-- 1 si si 114 abr 14 15:51 ./file.tmp2
-rw-rw-r-- 1 si si 112 abr 14 16:02 ./file.tmp
```

## Parametros de find

1. **-name:**

- Utilizado para buscar archivos por su nombre exacto (distingue entre mayúsculas y minúsculas).
- Ejemplo: Buscar todos los archivos con extensión ".txt".
```bash
find /ruta -name "*.txt"
```

2. **-iname:**

- Similar a `-name`, pero no distingue entre mayúsculas y minúsculas.
- Ejemplo: Buscar archivos con cualquier extensión de texto, ignorando mayúsculas y minúsculas.
```bash
find /ruta -iname "*.txt"
```

3. **-perm:**

- Utilizado para buscar archivos por permisos.
- Ejemplo: Buscar archivos con permisos de lectura, escritura y ejecución para el propietario. El `/700` encontraría archivos con al menos todos los permisos para root y cualquier otro permiso para go.

```bash
find /ruta -perm 700
find /ruta -perm /700
```

Buscar archivos con exactamente permisos 222

```bash
$ find . -perm 222
```

Buscar archivos donde TODOS en ugo posean permisos 2, es decir, u de ugo debe poseer permiso de escritura, g de ugo debe poseer permiso de escritura y o de ugo debe poseer permiso de escritura.

```bash
$ find . -perm -222
```

Buscar archivos donde CUALQUIERA en ugo posean permisos de escritura, es decir, ya sea u de ugo, g de ugo o o de ugo deben poseer permiso de escritura.

```bash
$ find . -perm /222
```

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

$ find . -perm 222 #Buscar archivos con exactamente permisos 222
./file1
$ find . -perm -222 #Buscar archivos donde TODOS en ugo posean permisos 2, es decir, u de ugo debe poseer permiso de escritura, g de ugo debe poseer permiso de escritura y o de ugo debe poseer permiso de escritura
./file2
./file1
$ find . -perm /222 #Buscar archivos donde CUALQUIERA en ugo posean permisos de escritura, es decir, ya sea u de ugo, g de ugo o o de ugo deben poseer permiso de escritura
.
./file3
./file2
./file1
$ find . -perm +222 #La opción + está DESCONTINUADA, se debe usar find . -perm /222 en su lugar
find: modo inválido ‘+222’
```

4. **-maxdepth:**

- Especifica la profundidad máxima de búsqueda en el árbol de directorios.
- Ejemplo: Buscar archivos en el directorio actual y un nivel hacia abajo.
```bash
find . -maxdepth 1 -type f
```

5. **-type:**

- Filtra archivos por tipo (fichero regular, directorio, enlace simbólico, etc.).
- Ejemplo: Buscar todos los directorios en el sistema.
```bash
find / -type d
```

6. **-user:**

- Utilizado para buscar archivos pertenecientes a un usuario específico.
- Ejemplo: Buscar todos los archivos pertenecientes al usuario "usuario1".
```bash
find /ruta -user usuario1
```

Para combinar condiciones con `find`, puedes utilizar `-o` (OR) y `-a` (AND):

- **-o (OR):** Encuentra archivos que cumplan al menos una de las condiciones especificadas.

```bash
find / -name "*.txt" -o -name "*.jpg"
```

- **-a (AND):** Encuentra archivos que cumplan todas las condiciones especificadas.
```bash
find /ruta -name "*.txt" -a -user usuario1
```

Estos son solo ejemplos básicos de cómo usar cada parámetro y cómo combinar condiciones con `-o` y `-a` en `find`. Las posibilidades son bastante amplias y puedes construir búsquedas más complejas según las necesidades como por ejemplo:

```bash
find $HOME -type f -iname "*.png" -mtime +3 -mtime -5 -perm 644 -size +2M -user www-data -and -not -user root -and -group www-
data -a ! -group root -exec ls -lah {} \; 2>/dev/null
```

7. **atime, mtime, ctime**

- -atime: busca en la fecha del último acceso (access time). Un acceso puede ser la lectura del archivo, pero también el simple hecho de listarlo de manera específica.
- -mtime: busca en la fecha de la última modificación (modification time). Se trata de la modificación del contenido. 
- -ctime: busca en la fecha de modificación (change time, en realidad la fecha de última modificación del número de inodo).

Estos tres criterios sólo trabajan con días (periodos de 24 horas). 0 es el mismo día; 1, ayer; 2, antes de ayer, etc. El valor n colocado después del criterio corresponde, por lo tanto, a n*24 horas. Este rango no es fijo, ya que "ayer" significa entre 24 y 48 horas... 

Los signos + o - permiten precisar los términos "de más" y "de menos":
find / -type f -mtime 1: archivos modificados ayer  (entre 24 y 48 horas). 
 
-mtime -3: archivos modificados hace menos de tres días (72 horas).
-atime +4: archivos accedios hace más de cuatro días (más de 96 horas).

_*Nota*_: Para trabajar con minutos tenemos los parámetros `amin`, `-mmin` y `-cmin`.

## Diferencia entre exec y xargs

Para el siguiente caso:

```bash
┌──(kali㉿kali)-[/tmp]
└─$ find /tmp -name "hola*" 2>/dev/null | xargs -I a ls -l a
-rw-rw-r-- 1 root root 25 Feb 11 11:03 /tmp/hola.txt
-rw-rw-r-- 1 root root 0 Feb 11 11:17 /tmp/hola2.txt

┌──(kali㉿kali)-[/tmp]
└─$ find /tmp -name "hola*" 2>/dev/null | xargs ls -l
-rw-rw-r-- 1 root root 25 Feb 11 11:03 /tmp/hola.txt
-rw-rw-r-- 1 root root  0 Feb 11 11:17 /tmp/hola2.txt

┌──(kali㉿kali)-[/tmp]
└─$ find /tmp -name "hola*" -exec ls -l {} \; 2>/dev/null
-rw-rw-r-- 1 root root 25 Feb 11 11:03 /tmp/hola.txt
-rw-rw-r-- 1 root root 0 Feb 11 11:17 /tmp/hola2.txt
```

La diferencia entre los tres comandos radica en cómo pasan los resultados del comando `find` al comando `ls -l`:

1. **`find /tmp -name "hola*" 2>/dev/null | xargs -I a ls -l a`**  
   Usa `xargs` con la opción `-I a`, lo que le permite tomar cada resultado de `find` (en este caso, cada archivo que empiece con "hola") y ejecutar `ls -l` sobre cada uno de esos archivos de manera individual. Esto es eficiente para manejar muchos resultados y no requiere ejecutar `ls -l` para todos los archivos al mismo tiempo.

2. **`find /tmp -name "hola*" 2>/dev/null | xargs ls -l`**  
   Similar al anterior, pero sin la opción `-I a`. Aquí, `xargs` toma todos los resultados de `find` y los pasa todos de una vez a `ls -l`, que luego listará los archivos en conjunto. Si hay muchos archivos, `xargs` puede pasar múltiples archivos a `ls -l` en un solo comando, lo que puede ser más rápido, pero menos controlado que el caso anterior.

3. **`find /tmp -name "hola*" -exec ls -l {} \; 2>/dev/null`**  
   Usa `-exec` de `find` para ejecutar `ls -l` sobre cada archivo que encuentra. Esto ejecuta `ls -l` de forma individual para cada archivo encontrado, similar a la opción `-I` de `xargs`, pero dentro del propio comando `find`. La diferencia principal es que se ejecuta un nuevo comando `ls -l` para cada archivo encontrado, lo cual puede ser más lento que usar `xargs` con múltiples archivos a la vez.

En resumen:
- El primer y segundo comando usan `xargs` para pasar múltiples archivos a `ls -l` a la vez, pero el primero tiene un control más detallado sobre cada archivo (`-I a`).
- El tercero usa `-exec` para ejecutar `ls -l` sobre cada archivo individualmente.

_*Nota*_: Es muy común el uso de `xargs` en casos como el siguiente donde no podemos hacer la eliminación de muchos archivos ya que sobrepasamos el tamaño del buffer del comando `rm` por lo que los pasamos uno por uno al `xargs.`

```bash
ls *.logs | xargs rm -rf
```
  
_*Nota*_: A mayores de `-exec` existe el parámetro `-ok`, su diferencia es que este último es es idéntico a la opción -exec, pero, para cada coincidencia, se le requiere una confirmación al usuario.

```bash
find / -type f -name "*.mp3" -ok rm -rf {} \;
```

En el comando anterior se buscan todos los archivos con extensión .mp3 y se pide confirmación para eliminar cada ocurrencia, con independencia de que haya la opción `-f` del comando `rm`, se pedirá confirmación para eliminar cada archivo.