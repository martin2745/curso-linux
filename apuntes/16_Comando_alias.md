# Comando alias

## Índice

1. [Creación y uso de alias temporales](#1-creación-y-uso-de-alias-temporales)
2. [Recarga de configuración (persistente)](#2-recarga-de-configuración-persistente)
3. [Listar y eliminar alias](#3-listar-y-eliminar-alias)
4. [Limitaciones de los alias](#4-limitaciones-de-los-alias)
   1. [Los alias no admiten parámetros](#41-los-alias-no-admiten-parámetros)
   2. [Los alias no funcionan dentro de los scripts](#42-los-alias-no-funcionan-dentro-de-los-scripts)
   3. [Cómo saltarse un alias puntualmente](#43-cómo-saltarse-un-alias-puntualmente)

---

## 1. Creación y uso de alias temporales

Considerando que en el archivo `~/.bashrc` existe el alias `alias listar='ls -ltr'`, si se ejecuta en la terminal el comando `alias listar='ls -lahi --color'`, el alias temporal sobreescribirá al del archivo mientras dure la sesión. 

Si por consola lanzamos en ese momento el comando obtenemos:

```bash
usuario@debian:~$ alias listar='ls -lahi --color'
usuario@debian:~$ listar
total 156K
392450 drwx------ 16 usuario usuario 4,0K abr 12 16:29 .
392449 drwxr-xr-x  3 root   root   4,0K feb 17 18:08 ..
392746 -rw-------  1 usuario usuario 1,5K mar  5 16:11 .bash_history
392451 -rw-r--r--  1 usuario usuario  220 feb  2 17:57 .bash_logout
392453 -rw-r--r--  1 usuario usuario 3,5K feb  2 17:57 .bashrc
392470 drwxr-xr-x  8 usuario usuario 4,0K feb  2 18:11 .cache
392460 drwx------  7 usuario usuario 4,0K feb  2 18:10 .config
```

> **Nota:** Los alias creados directamente en la consola solo persisten en la sesión actual. Una vez que se cierre la terminal, estos alias desaparecerán.

---

## 2. Recarga de configuración (persistente)

Si en ese momento ejecutamos el comando `source ~/.bashrc && listar`, se recarga el `.bashrc` y por lo tanto el alias vuelve a ser el original `listar='ls -ltr'`.

```bash
usuario@debian:~$ source ~/.bashrc && listar
total 36
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Vídeos
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Público
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Plantillas
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Música
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Imágenes
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Escritorio
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Documentos
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Descargas
drwxr-xr-x 2 usuario usuario 4096 mar  4 09:58 d1
-rw-r--r-- 1 usuario usuario    0 abr 12 16:29 fichero.txt
```

> **Importante:** Para que un alias sea permanente en todas las sesiones futuras de Bash, debe definirse escribiendo `alias nombre_atajo='comando'` dentro del archivo `~/.bashrc` (o `~/.zshrc` si usas Zsh).

> **Nota:** En Debian existe además el fichero `~/.bash_aliases`, pensado precisamente para esto. El `~/.bashrc` que se crea por defecto lo invoca si existe:
>
> ```bash
> if [ -f ~/.bash_aliases ]; then
>     . ~/.bash_aliases
> fi
> ```
>
> Separar los alias en su propio fichero mantiene limpio el `~/.bashrc` y facilita llevarse la configuración de una máquina a otra.

> **Recuerda:** Los alias se leen de `~/.bashrc`, que solo se ejecuta en las shells **interactivas sin login**, tal como se detallaba en el documento 02. Por eso un alias definido ahí puede no estar disponible nada más conectarse por SSH si el `~/.profile` no invoca al `~/.bashrc`.

---

## 3. Listar y eliminar alias

El comando `alias` ejecutado sin parámetros muestra la lista completa de alias activos en tu entorno. El comando `unalias` permite eliminarlos.

```bash
usuario@debian:~$ alias listar='ls -lhai'
usuario@debian:~$ alias directorioTrabajo='pwd'
usuario@debian:~$ alias
alias directorioTrabajo='pwd'
alias listar='ls -lhai'
usuario@debian:~$ unalias directorioTrabajo
usuario@debian:~$ alias
alias listar='ls -lhai'
usuario@debian:~$ unalias -a
usuario@debian:~$ alias
```

> **Recuerda:** 
> - `unalias nombre_alias` elimina un alias específico.
> - `unalias -a` elimina todos los alias actuales del entorno de ejecución (de manera temporal).

---

## 4. Limitaciones de los alias

Los alias son un mecanismo deliberadamente simple: el intérprete se limita a sustituir la primera palabra del comando por su definición. De esa simplicidad nacen tres limitaciones que conviene conocer.

### 4.1 Los alias no admiten parámetros

Un alias no puede recibir argumentos ni colocarlos en un lugar concreto de la orden. Lo que se escriba detrás se añade siempre **al final**:

```bash
usuario@debian:~$ alias buscar='grep -rn'
usuario@debian:~$ buscar patron /etc
```

Aquí funciona porque el orden coincide, pero en cuanto el argumento deba ir en medio, el alias se queda corto. Para esos casos hay que recurrir a una **función**, que sí recibe parámetros posicionales:

```bash
usuario@debian:~$ mkcd() { mkdir -p "$1" && cd "$1"; }
usuario@debian:~$ mkcd /tmp/proyecto/nuevo
usuario@debian:/tmp/proyecto/nuevo$
```

> **Nota:** Las funciones se definen en los mismos ficheros que los alias (`~/.bashrc` o `~/.bash_aliases`) y se listan con `declare -F`. Como regla práctica: si el atajo necesita argumentos en cualquier posición que no sea la final, hace falta una función.

### 4.2 Los alias no funcionan dentro de los scripts

Bash solo expande alias en las sesiones **interactivas**. Un script que invoque un alias definido en `~/.bashrc` fallará con `orden no encontrada`, porque el script se ejecuta en una shell no interactiva que ni siquiera lee ese fichero. Es una decisión de diseño deliberada: un script debe comportarse igual con independencia de cómo tenga cada usuario personalizada su terminal.

### 4.3 Cómo saltarse un alias puntualmente

Cuando un alias estorba y se necesita el comando original, hay tres formas de esquivarlo sin borrarlo:

```bash
usuario@debian:~$ \ls          # la barra invertida inhibe la expansión
usuario@debian:~$ command ls   # ejecuta el programa, ignorando alias y funciones
usuario@debian:~$ /usr/bin/ls  # ruta absoluta
```

> **Advertencia:** Es una práctica extendida definir alias protectores como `alias rm='rm -i'`, que pide confirmación antes de borrar. El riesgo está en acostumbrarse a esa red de seguridad: en cualquier otra máquina, dentro de un script o ejecutando `\rm`, el alias no existirá y `rm` borrará sin preguntar. Conviene tenerlo presente.

> **Nota:** Un alias que termine en **espacio** hace que el intérprete intente expandir también la palabra siguiente. Es el truco que permite que `alias sudo='sudo '` deje funcionar el resto de alias detrás de `sudo`, algo que de otro modo no ocurriría, ya que `sudo` recibiría el nombre del alias en lugar de un ejecutable real.

El documento 26 profundiza en el orden de precedencia que sigue Bash al resolver un nombre: primero alias, luego palabras reservadas, funciones, comandos internos y, por último, los ejecutables del `$PATH`.
