# Redirecciones

## Índice

1. [Conceptos básicos](#1-conceptos-básicos)
2. [Redirección de canales de salida y error](#2-redirección-de-canales-de-salida-y-error)
   1. [El orden de las redirecciones importa](#21-el-orden-de-las-redirecciones-importa)
   2. [La tubería solo transporta stdout](#22-la-tubería-solo-transporta-stdout)
   3. [Los canales como ficheros en /dev y /proc](#23-los-canales-como-ficheros-en-dev-y-proc)
3. [Tabla de ejemplo de las principales redirecciones](#3-tabla-de-ejemplo-de-las-principales-redirecciones)
4. [Ejemplo guiado: descriptores de archivo personalizados](#4-ejemplo-guiado-descriptores-de-archivo-personalizados)
5. [Diferencia entre operadores && y ||](#5-diferencia-entre-operadores--y-)

---

## 1. Conceptos básicos

Se puede considerar un canal como un archivo que posee su propio descriptor por defecto, y en el cual se puede leer o escribir. En sistemas Linux/Unix existen tres canales principales:

- El canal de entrada estándar se llama `stdin` y lleva el descriptor `0`.
- El canal de salida estándar se llama `stdout` y lleva el descriptor `1`.
- El canal de error estándar se llama `stderr` y lleva el descriptor `2`.

> **Recuerda:** En los sistemas Unix, "todo es un archivo", por lo que los descriptores de archivo (`fd`) son simplemente números que el sistema operativo utiliza para rastrear archivos abiertos o canales de entrada/salida.

---

## 2. Redirección de canales de salida y error

Se puede redireccionar el canal de error hacia otro archivo. También se pueden enviar los dos canales de salida (`stdout` y `stderr`) a un único archivo poniéndolos en relación. Para ello se utiliza la sintaxis `>&`.

A continuación se muestran ejemplos básicos de redirección a archivos:

```bash
usuario@debian:~$ ls -l > fichero.txt
usuario@debian:~$ ls -l >> fichero.txt
usuario@debian:~$ ls -li > fichero.txt 2>&1
usuario@debian:~$ ls -li &> fichero.txt
usuario@debian:~$ cat < fichero.txt
```

> **Nota:** El operador `>` sobrescribe el archivo si ya existe, mientras que `>>` añade el contenido al final del archivo existente. La expresión `2>&1` indica que el descriptor 2 (`stderr`) debe redirigirse al mismo lugar que el descriptor 1 (`stdout`).

### 2.1 El orden de las redirecciones importa

El intérprete de comandos procesa las redirecciones **de izquierda a derecha**, en el orden exacto en el que están escritas. Y `2>&1` no significa "manda `stderr` al mismo sitio que `stdout` pase lo que pase", sino algo mucho más literal: **copia ahora mismo el destino que tiene `stdout` en este instante** y dáselo a `stderr`.

De esa literalidad nace la trampa clásica de las redirecciones:

```bash
usuario@debian:~$ lss > salida.txt 2>&1
usuario@debian:~$ cat salida.txt
bash: lss: orden no encontrada
```

```bash
usuario@debian:~$ lss 2>&1 > salida.txt
bash: lss: orden no encontrada
usuario@debian:~$ cat salida.txt
usuario@debian:~$
```

Los dos comandos contienen exactamente los mismos elementos, pero el resultado es opuesto. Paso a paso:

| Orden escrito | Qué ocurre |
|---|---|
| `> salida.txt 2>&1` | Primero `stdout` pasa a apuntar al fichero. Después `2>&1` copia ese destino, de modo que `stderr` también acaba en el fichero. **Ambos canales quedan capturados.** |
| `2>&1 > salida.txt` | Primero `2>&1` copia el destino que `stdout` tiene en ese momento, que sigue siendo la pantalla, y `stderr` queda apuntando a la pantalla. Después `> salida.txt` mueve `stdout` al fichero, pero `stderr` ya no le sigue. **Los errores acaban en pantalla y el fichero se queda vacío.** |

> **Importante:** La regla práctica es sencilla: **`2>&1` siempre va al final**, detrás de la redirección de `stdout`. La forma abreviada `&> fichero` hace lo mismo sin riesgo de equivocarse, aunque es una extensión de Bash y no funciona en shells estrictamente POSIX como `dash`, por lo que en scripts con `#!/bin/sh` hay que seguir escribiendo `> fichero 2>&1`.

> **Advertencia:** El fichero de destino se crea y se **vacía antes** de que el comando llegue a ejecutarse. Por eso `sort fichero.txt > fichero.txt` no ordena nada: destruye el fichero y deja un resultado vacío. Para operar sobre el mismo fichero hay que usar una copia intermedia, la opción propia de la herramienta (`sort -o fichero.txt fichero.txt`) o utilidades como `sponge`.

> **Nota:** Bash dispone de la opción `noclobber` para protegerse de sobrescrituras accidentales. Con `set -o noclobber`, el operador `>` se niega a machacar un fichero existente y hay que forzarlo expresamente con `>|`.
>
> ```bash
> usuario@debian:~$ set -o noclobber
> usuario@debian:~$ echo hola > fichero.txt
> bash: fichero.txt: no se puede sobreescribir el fichero existente
> usuario@debian:~$ echo hola >| fichero.txt
> ```

El comando `cat` con `<<` (Here Document) permite ingresar texto multilinea hasta encontrar un delimitador:

```bash
usuario@debian:~$ cat > fichero.txt << VAI
> hola
> Que
> Tal?
> VAI
usuario@debian:~$ cat fichero.txt
hola
Que
Tal?
```

El uso del comando `tee` permite dividir la salida: una parte va a la salida estándar (pantalla) y la otra se guarda en un archivo:

```bash
usuario@debian:~$ cat /etc/passwd | tail -2 | tee /tmp/pass.tmp
usuario:x:1000:1000:usuario,,,:/home/usuario:/bin/bash
vboxadd:x:999:1::/var/run/vboxadd:/bin/false

usuario@debian:~$ cat /tmp/pass.tmp
usuario:x:1000:1000:usuario,,,:/home/usuario:/bin/bash
vboxadd:x:999:1::/var/run/vboxadd:/bin/false

usuario@debian:~$ sudo cat /etc/shadow | tail -2 | tee -a /tmp/pass.tmp
usuario:$y$j9T$XXXXXXXXXXXXXXXXXXXXXX$XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX:19770:0:99999:7:::
vboxadd:!:19755::::::

usuario@debian:~$ cat /tmp/pass.tmp
usuario:x:1000:1000:usuario,,,:/home/usuario:/bin/bash
vboxadd:x:999:1::/var/run/vboxadd:/bin/false
usuario:$y$j9T$XXXXXXXXXXXXXXXXXXXXXX$XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX:19770:0:99999:7:::
vboxadd:!:19755::::::
```

> **Advertencia:** El ejemplo anterior vuelca el contenido de `/etc/shadow`, que contiene los hashes de las contraseñas de todas las cuentas del sistema. Los hashes que aparecen aquí han sido sustituidos por texto de relleno. Al practicar con este comando conviene tener presente que el fichero resultante (`/tmp/pass.tmp`) se crea con los permisos por defecto del usuario y queda legible para cualquiera, de modo que se acaba de copiar información sensible a una ubicación desprotegida. Es un descuido que se comete con facilidad al depurar y una de las razones por las que `/etc/shadow` solo es legible por `root`.

Ejemplo de cómo los errores también pueden ser redirigidos y cómo afectan al contenido del archivo final:

```bash
usuario@debian:~$ ls > prueba.txt 2>&1
usuario@debian:~$ cat prueba.txt
Desktop
Documents
Downloads
Music
Pictures
prueba.txt
Public
snap
Templates
Videos
usuario@debian:~$ lss > prueba.txt 2>&1
usuario@debian:~$ cat prueba.txt
Command 'lss' not found, but there are 15 similar ones.
```

### 2.2 La tubería solo transporta stdout

Una confusión habitual consiste en dar por hecho que el operador `|` traslada al siguiente comando todo lo que produce el anterior. No es así: **la tubería conecta únicamente `stdout`**. Los mensajes de error siguen su camino hacia la pantalla y no pasan por el filtro:

```bash
usuario@debian:~$ ls /etc /carpeta_inexistente | grep carpeta
ls: no se puede acceder a '/carpeta_inexistente': No existe el fichero o el directorio
```

El error aparece pese a que `grep` debería haberlo filtrado, sencillamente porque nunca llegó a `grep`. Para que también entre en la tubería hay que unir los canales antes:

```bash
usuario@debian:~$ ls /etc /carpeta_inexistente 2>&1 | grep carpeta
ls: no se puede acceder a '/carpeta_inexistente': No existe el fichero o el directorio
```

> **Nota:** Bash ofrece la forma abreviada `|&`, equivalente a `2>&1 |`. El comando anterior podría escribirse como `ls /etc /carpeta_inexistente |& grep carpeta`.

> **Recuerda:** Este detalle explica por qué `comando | tee registro.log` deja los errores fuera del registro, y por qué la forma habitual de capturarlo todo es `comando 2>&1 | tee registro.log`.

---

### 2.3 Los canales como ficheros en /dev y /proc

Las salidas de información de `stdin`, `stdout` y `stderr` acaban apuntando al mismo terminal, y son los descriptores `fd/num` los que se emplean para redirigir la información a través de las rutas de `/dev/` y `/proc/`.

```bash
usuario@debian:~/Downloads$ ls -l /dev/stdin
lrwxrwxrwx 1 root root 15 jun 15 09:12 /dev/stdin -> /proc/self/fd/0
usuario@debian:~/Downloads$ ls -l /dev/stdout
lrwxrwxrwx 1 root root 15 jun 15 09:12 /dev/stdout -> /proc/self/fd/1
usuario@debian:~/Downloads$ ls -l /dev/stderr
lrwxrwxrwx 1 root root 15 jun 15 09:12 /dev/stderr -> /proc/self/fd/2
usuario@debian:~/Downloads$ ls -l /proc/self/fd/0
lrwx------ 1 si si 64 jun 15 13:16 /proc/self/fd/0 -> /dev/pts/1
usuario@debian:~/Downloads$ ls -l /proc/self/fd/1
lrwx------ 1 si si 64 jun 15 13:16 /proc/self/fd/1 -> /dev/pts/1
usuario@debian:~/Downloads$ ls -l /proc/self/fd/2
lrwx------ 1 si si 64 jun 15 13:16 /proc/self/fd/2 -> /dev/pts/1
usuario@debian:~/Downloads$ ls -l /dev/pts/1
crw--w---- 1 si tty 136, 1 jun 15 13:17 /dev/pts/1
```

---

## 3. Tabla de ejemplo de las principales redirecciones

| Comando                         | Descripción                                                                                                   |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| `cmd > archivo`                 | Redirige la salida estándar (`stdout`) de `cmd` a un archivo.                                                   |
| `cmd 1> archivo`                | Igual que `cmd > archivo`. El descriptor de archivo (`fd`) predeterminado para `stdout` es `1`.                   |
| `cmd 2> archivo`                | Redirige la salida de error estándar (`stderr`) de `cmd` a un archivo. `2` es el `fd` predeterminado para `stderr`. |
| `cmd >> archivo`                | Agrega la salida estándar de `cmd` a un archivo (sin sobrescribir).                                                              |
| `cmd 2>> archivo`               | Agrega la salida de error estándar de `cmd` a un archivo (sin sobrescribir).                                                     |
| `cmd &> archivo`                | Redirige `stdout` y `stderr` de `cmd` a un archivo simultáneamente.                                                               |
| `cmd > archivo 2>&1`            | Otra forma de redirigir `stdout` y `stderr` de `cmd` a un archivo. ¡El orden de redirección importa!              |
| `cmd > /dev/null`               | Descarta la salida estándar de `cmd` mandándola al agujero negro del sistema.                                                                         |
| `cmd 2> /dev/null`              | Descarta la salida de error estándar de `cmd`.                                                                |
| `cmd &> /dev/null`              | Descarta `stdout` y `stderr` de `cmd`.                                                                            |
| `cmd < archivo`                 | Redirige el contenido del archivo a la entrada estándar (`stdin`) de `cmd`.                                     |
| `cmd <<< "texto"`               | Redirige una única línea de texto a `stdin` de `cmd`. Se llama _here-string_.                                   |
| `exec 2> archivo`               | Redirige `stderr` de todos los comandos a un archivo de manera permanente en esa sesión.                                      |
| `exec 3< archivo`               | Abre un archivo para lectura usando un descriptor de archivo personalizado (por ejemplo, `3`).                                   |
| `exec 3> archivo`               | Abre un archivo para escritura usando un descriptor de archivo personalizado.                                 |
| `exec 3<> archivo`              | Abre un archivo para lectura y escritura usando un descriptor de archivo personalizado.                       |
| `exec 3>&-`                     | Cierra el descriptor de archivo `3`.                                                                              |
| `exec 4>&3`                     | Hace que el descriptor de archivo `4` sea una copia del descriptor de archivo `3`.                            |
| `exec 4>&3-`                    | Copia el descriptor de archivo `3` en `4` y cierra `3`.                                                       |
| `echo "foo" >&3`                | Escribe texto directamente en un descriptor de archivo personalizado.                                                            |
| `cat <&3`                       | Lee desde un descriptor de archivo personalizado.                                                             |
| `(cmd1; cmd2) > archivo`        | Redirige `stdout` de múltiples comandos a un archivo (usando un sub-shell).                                     |
| `{ cmd1; cmd2; } > archivo`     | Redirige `stdout` de múltiples comandos a un archivo sin usar un sub-shell (más eficiente).                     |
| `exec 3<> /dev/tcp/host/puerto` | Abre una conexión TCP a `host:puerto`. (Funcionalidad de Bash, no estándar de Unix).                                  |
| `exec 3<> /dev/udp/host/puerto` | Abre una conexión UDP a `host:puerto`. (Funcionalidad de Bash, no estándar de Unix).                                  |
| `cmd <(cmd1)`                   | Redirige `stdout` de `cmd1` a un FIFO anónimo y pasa el FIFO como argumento a `cmd`.                            |
| `cmd < <(cmd1)`                 | Redirige `stdout` de `cmd1` a un FIFO anónimo y lo redirige a `stdin` de `cmd`. |
| `cmd <(cmd1) <(cmd2)`           | Redirige `stdout` de `cmd1` y `cmd2` a dos FIFOs anónimos y los pasa como argumentos a `cmd`.                   |
| `cmd1 >(cmd2)`                  | Ejecuta `cmd2` con su `stdin` conectado a un FIFO anónimo y pasa el nombre del FIFO como argumento a `cmd1`.    |
| `cmd1 > >(cmd2)`                | Ejecuta `cmd2` con su `stdin` conectado a un FIFO anónimo y redirige `stdout` de `cmd1` a este FIFO.              |
| `exec {fd}> archivo`            | Abre un archivo para escritura usando un descriptor de archivo nombrado `{fd}` (Bash 4.1+).                   |
| `cmd 3>&1 1>&2 2>&3`            | Intercambia `stdout` y `stderr` de `cmd`.                                                                         |
| `cmd > >(cmd1) 2> >(cmd2)`      | Envía `stdout` de `cmd` a `cmd1` y `stderr` de `cmd` a `cmd2`.                                                    |

---

## 4. Ejemplo guiado: descriptores de archivo personalizados

El siguiente es un flujo guiado para entender cómo usar descriptores de archivo personalizados mediante `exec`:

Primero creamos un descriptor de archivo `3` apuntando al archivo `file`:

```bash
usuario@debian:~$ exec 3<> file
```

> **Nota:** Se abre el archivo `file` y se asigna al descriptor de archivo `3` en modo lectura y escritura. No se muestra ninguna salida en terminal.

A continuación, verificamos si se creó el archivo:

```bash
usuario@debian:~$ ls
Descargas  Documentos  Escritorio  file  Imágenes  Música  Plantillas  Público  Vídeos
```

> **Nota:** Lista los archivos y directorios en el directorio actual. Se observa que el archivo `file` ya existe.

Podemos verificar su tipo y contenido inicial:

```bash
usuario@debian:~$ file file
file: empty
```

> **Nota:** Muestra que `file` existe pero está vacío.

Intentamos leer su contenido:

```bash
usuario@debian:~$ cat file
```

> **Nota:** Sin salida, porque `file` está vacío. Intenta mostrar el contenido de `file`, pero no hay nada en él.

Ahora redirigimos la salida de un comando hacia nuestro descriptor de archivo `3`:

```bash
usuario@debian:~$ whoami >&3
```

> **Nota:** No hay salida en la terminal porque se redirigió al descriptor de archivo `3`. El comando `whoami` imprime el nombre del usuario (`usuario`), pero la salida se guarda en `file` en lugar de mostrarse en pantalla.

Verificamos el contenido del archivo de nuevo:

```bash
usuario@debian:~$ cat file
usuario
```

> **Nota:** Ahora `file` contiene `usuario`, que fue la salida del comando `whoami`.

Ejecutamos otro comando y lo redirigimos al mismo descriptor de archivo:

```bash
usuario@debian:~$ pwd >&3
```

> **Nota:** No hay salida en la terminal porque se redirigió al descriptor de archivo `3`. El comando `pwd` imprime el directorio actual (`/home/usuario`), pero la salida se guarda en `file`.

Volvemos a verificar el archivo:

```bash
usuario@debian:~$ cat file
usuario
/home/usuario
```

> **Nota:** `file` ahora contiene `usuario` y `/home/usuario` porque las salidas de `whoami` y `pwd` se guardaron secuencialmente en él.

Finalmente, cerramos el descriptor de archivo:

```bash
usuario@debian:~$ exec 3>&-
```

> **Importante:** Cierra el descriptor de archivo `3`. Una vez cerrado, ya no se puede usar.

Intentamos usar el descriptor cerrado:

```bash
usuario@debian:~$ whoami >&3
bash: 3: Mal descriptor de fichero
```

> **Advertencia:** Como el descriptor de archivo `3` se cerró previamente, ya no se puede escribir en él, y el sistema arroja un error (`bad file descriptor`).

---

## 5. Diferencia entre operadores && y ||

En Linux, el operador `&&` (AND lógico) permite que se ejecute la siguiente instrucción solo si la previa ha sido exitosa (retorna un código de estado `0`).

```bash
root@debian:/tmp# id ; pwd
uid=0(root) gid=0(root) grupos=0(root)
/tmp

root@debian:/tmp# id && pwd
uid=0(root) gid=0(root) grupos=0(root)
/tmp

root@debian:/tmp# idesdfg ; pwd
-bash: idesdfg: orden no encontrada
/tmp

root@debian:/tmp# idesdfg && pwd
-bash: idesdfg: orden no encontrada
```

Por otra parte, el operador `||` (OR lógico) permite que se ejecute una u otra instrucción en función de si la previa falla o no. La segunda instrucción solo se ejecuta si la primera falló (retorna un código de estado distinto de `0`).

```bash
root@debian:/tmp# id || pwd
uid=0(root) gid=0(root) grupos=0(root)

root@debian:/tmp# idhj || pwd
-bash: idhj: orden no encontrada
/tmp
```

> **Recuerda:** Combinando estos operadores (`comando1 && comando2 || comando3`), puedes construir estructuras condicionales simples de estilo if-then-else en una sola línea.
