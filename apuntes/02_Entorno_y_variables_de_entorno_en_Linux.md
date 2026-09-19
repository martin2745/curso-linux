# Entorno y variables de entorno en Linux

## Índice

1. [Variables de shell y variables de entorno](#1-variables-de-shell-y-variables-de-entorno)
2. [Listado de variables de entorno interesantes](#2-listado-de-variables-de-entorno-interesantes)
3. [Configuración de archivos de entorno en Linux](#3-configuración-de-archivos-de-entorno-en-linux)
   1. [Ficheros con aplicación a todo el sistema (todos los usuarios del sistema)](#31-ficheros-con-aplicación-a-todo-el-sistema-todos-los-usuarios-del-sistema)
   2. [Ficheros con aplicación a un usuario específico](#32-ficheros-con-aplicación-a-un-usuario-específico)
4. [Archivos de configuración de Bash y su orden de ejecución](#4-archivos-de-configuración-de-bash-y-su-orden-de-ejecución)
5. [¿Por qué tantos archivos?](#5-por-qué-tantos-archivos)

---

## 1. Variables de shell y variables de entorno

Antes de repasar los ficheros de configuración conviene distinguir los dos tipos de variables que conviven en una sesión, porque se declaran igual pero se comportan de forma muy distinta.

| Tipo | Alcance | Cómo se crea |
|---|---|---|
| Variable de shell (local) | Existe únicamente en la shell donde se declara. Los procesos hijos **no** la heredan. | `VARIABLE=valor` |
| Variable de entorno | Se copia al entorno de todos los procesos hijos que se lancen desde esa shell. | `export VARIABLE=valor` |

La asignación no admite espacios alrededor del `=`, y si el valor contiene espacios debe entrecomillarse:

```bash
usuario@debian:~$ CURSO=linux
usuario@debian:~$ echo $CURSO
linux
usuario@debian:~$ CENTRO="IES Monte da Vila"
usuario@debian:~$ echo $CENTRO
IES Monte da Vila
```

La diferencia entre ambos tipos se aprecia al lanzar una shell hija. La variable local se pierde, mientras que la exportada sobrevive:

```bash
usuario@debian:~$ LOCAL=soy_local
usuario@debian:~$ export GLOBAL=soy_global
usuario@debian:~$ bash
usuario@debian:~$ echo "local=[$LOCAL] global=[$GLOBAL]"
local=[] global=[soy_global]
usuario@debian:~$ exit
```

> **Importante:** La herencia va siempre de padre a hijo y nunca al revés. Un script que se ejecuta de forma normal (`./script.sh`) arranca en una shell hija, de modo que las variables que defina **no** afectarán a la shell desde la que se lanzó. Si se quiere que el script modifique el entorno actual hay que ejecutarlo en la propia shell con `source script.sh` o `. script.sh`.

Una variable exportada puede devolverse al ámbito local con `export -n`, y eliminarse por completo con `unset`:

```bash
usuario@debian:~$ export -n GLOBAL
usuario@debian:~$ unset CURSO
usuario@debian:~$ echo "[$CURSO]"
[]
```

También es posible definir una variable de entorno **solo para un comando concreto**, anteponíendola a la llamada. Al terminar el comando, la variable desaparece:

```bash
usuario@debian:~$ LANG=C date
Thu Sep 18 10:24:11 CEST 2026
usuario@debian:~$ date
jue 18 sep 2026 10:24:14 CEST
```

Estos son los comandos que permiten inspeccionar y manipular el entorno:

| Comando | Descripción |
|---|---|
| `set` | Lista **todas** las variables (locales y de entorno) y también las funciones definidas. Es el listado más completo y también el más largo. |
| `env` / `printenv` | Listan **solo** las variables de entorno, es decir, las que heredarán los procesos hijos. |
| `printenv VARIABLE` | Muestra el valor de una única variable de entorno. |
| `export` | Sin argumentos, lista las variables marcadas para exportación. Con `-n`, retira la marca. |
| `unset VARIABLE` | Elimina la variable, tanto si es local como de entorno. |
| `env -i COMANDO` | Ejecuta un comando con el entorno **vacío**, útil para depurar dependencias ocultas de variables. |

> **Nota:** El entorno de un proceso en ejecución puede consultarse desde fuera leyendo `/proc/PID/environ`. Como los valores van separados por bytes nulos, se suele filtrar con `tr`: `tr '\0' '\n' < /proc/$$/environ`.

---

## 2. Listado de variables de entorno interesantes

| Variable | Descripción |
|---|---|
| `SHELL` | Ruta del intérprete de comandos asignado al usuario en `/etc/passwd`. No indica necesariamente la shell que se está ejecutando en este momento. |
| `HOME` | Ruta absoluta del directorio personal del usuario. Es el valor al que recurre `cd` cuando se invoca sin argumentos. |
| `USER` / `LOGNAME` | Nombre de la cuenta con la que se inició la sesión. |
| `UID` / `EUID` | Identificador numérico del usuario real y del efectivo. Son variables internas de Bash, no de entorno. |
| `PATH` | Lista de directorios separados por dos puntos (`:`) que se recorren **en orden** al teclear el nombre de un ejecutable sin ruta. |
| `PWD` / `OLDPWD` | Directorio de trabajo actual y directorio anterior. `cd -` regresa al que guarda `OLDPWD`. |
| `LANG` / `LC_*` | Definen idioma, codificación y criterios de ordenación. `LC_ALL` tiene prioridad sobre todas las demás. |
| `TERM` | Tipo de terminal (`xterm-256color`, `linux`...). De él dependen los colores y el comportamiento de programas como `vim`, `less` o `top`. |
| `PS1` | Cadena que define el aspecto del *prompt* interactivo. `PS2` es el prompt de continuación. |
| `EDITOR` / `VISUAL` | Editor que invocan por defecto herramientas como `visudo`, `crontab -e` o `git`. |
| `HOSTNAME` | Nombre de la máquina. |
| `HISTSIZE` / `HISTFILE` | Número de comandos que se conservan en memoria y fichero donde se vuelcan al cerrar la sesión. |
| `SHLVL` | Nivel de anidamiento de shells. Aumenta en uno cada vez que se abre una shell dentro de otra. |
| `$$` | PID de la shell actual. |
| `?` | Código de salida del último comando ejecutado: `0` si tuvo éxito, distinto de `0` si falló. |
| `_` | Referencia al último argumento del comando anterior, o a la ruta del ejecutable en curso. |

> **Advertencia:** Nunca debe incluirse el directorio actual (`.`) ni una ruta vacía en la variable `PATH`, y menos aún al principio. Si lo hacemos, bastaría con que alguien dejara un ejecutable llamado `ls` o `sudo` en un directorio compartido como `/tmp` para que lo ejecutáramos sin darnos cuenta al entrar en él.

Un uso muy habitual consiste en añadir un directorio propio a la variable `PATH`. Obsérvese que se reutiliza el valor anterior para no destruirlo:

```bash
usuario@debian:~$ echo $PATH
/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
usuario@debian:~$ export PATH="$HOME/bin:$PATH"
usuario@debian:~$ echo $PATH
/home/usuario/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
```

> **Recuerda:** Este cambio solo dura lo que dure la sesión actual. Para que sea permanente hay que escribir la línea `export` en uno de los ficheros de configuración que se describen en el siguiente apartado, habitualmente `~/.profile` o `~/.bashrc`.

---

## 3. Configuración de archivos de entorno en Linux

Para comprender correctamente cómo y cuándo se aplican las configuraciones en Linux, es fundamental entender la diferencia entre los tipos de sesión en la consola:
- **Shell con login (de sesión):** Ocurre cuando el usuario se autentica ingresando sus credenciales (por ejemplo, mediante una conexión `ssh`, al entrar en un TTY desde modo texto o al acceder al entorno gráfico inicial).
- **Shell sin login (sin sesión):** Ocurre cuando ya estamos autenticados y simplemente abrimos una nueva ventana/pestaña del emulador de terminal gráfico, o cuando se ejecuta un script de forma no interactiva.

### 3.1 Ficheros con aplicación a todo el sistema (todos los usuarios del sistema)

- `/etc/environment`: Fichero específico a nivel de sistema operativo para la definición de variables de entorno de forma estática (sintaxis `VARIABLE="valor"`). **No puede contener scripts ni lógica de programación**. Lo procesa el módulo PAM `pam_env` en el momento de **iniciar sesión**, antes incluso de que arranque la shell, por lo que sus variables alcanzan también a las sesiones gráficas. Al no ser un script, no admite `export`, ni sustitución de variables como `$HOME`, ni comentarios con lógica condicional.
- `/etc/profile`: Permite definir variables de entorno, funciones y llamadas a scripts de forma global. Aunque su uso está permitido, no es apropiado modificar este fichero directamente para configuraciones propias (en su lugar, debe crearse un nuevo fichero en el subdirectorio `/etc/profile.d/`). Se ejecuta únicamente en **shells con login**.
- `/etc/profile.d/`: Un directorio de tipo *drop-in* que contiene scripts individuales (usualmente `.sh`) que el sistema lee y ejecuta automáticamente durante la inicialización de **shells con login**. Facilita la administración modular de configuraciones de terceros.
- `/etc/bash.bashrc`: Permite definir variables de entorno, alias y funciones que estarán disponibles de forma global para programas y terminales iniciados desde la shell `bash`. Las variables que se definan en este fichero **no** van a estar disponibles para programas iniciados gráficamente desde los menús de escritorio. Se ejecuta generalmente en **shells sin login**.

> **Importante:** La mejor práctica como administrador de sistemas al querer inyectar configuraciones para todos los usuarios es crear scripts `.sh` separados dentro de `/etc/profile.d/`. De esta forma tus modificaciones personalizadas no serán sobrescritas por actualizaciones de paquetes del sistema operativo que actualicen el archivo `/etc/profile`.

### 3.2 Ficheros con aplicación a un usuario específico

- `~/.profile`: Permite al usuario definir sus variables de entorno, agregar directorios a su variable `$PATH` o ejecutar scripts propios al inicio. Se ejecuta al iniciar la sesión de escritorio o al entrar en una **shell con login**. Estas variables se heredan y afectan a todos los programas ejecutados desde el escritorio gráfico o desde cualquier terminal interactiva.
- `~/.bash_profile`, `~/.bash_login`: Ficheros para configurar el entorno exclusivo de `bash`. Permiten definir variables de entorno y scripts. Se ejecutan cuando se inicia una **shell con login**. Las variables definidas solo afectarán a los programas ejecutados a partir de esta instancia de `bash`.
- `~/.bashrc`: Permite definir alias, funciones, variables locales y scripts personales. Se ejecuta cuando el usuario abre un terminal interactivo en una **shell sin login**. Es el archivo de configuración personal que se procesa más frecuentemente.
- `~/.bash_logout`: Se ejecuta automáticamente cuando el usuario cierra sesión o finaliza una **shell con login**. Se utiliza para limpiar cachés, borrar temporales o matar procesos residuales.
- `~/.bash_history`: Un archivo oculto que almacena en texto plano el historial de comandos ejecutados previamente por el usuario, permitiendo volver atrás o buscar con atajos como `Ctrl+R`.

> **Nota:** En función de la shell predeterminada trabajaremos con ficheros distintos. Igual que en Bash personalizamos a través de `~/.bashrc`, en Zsh lo haremos sobre `~/.zshrc` y en Ksh sobre `~/.kshrc`, teniendo cada intérprete sus propias reglas y particularidades de sintaxis. El detalle exacto del orden de carga de Bash está documentado en `man bash`, sección *INVOCATION*.

---

## 4. Archivos de configuración de Bash y su orden de ejecución

Bash dispone de una serie de archivos de configuración y dotfiles que se leen en cadena antes y después de que lo haga el intérprete de comandos principal. Estos archivos son scripts de bash convencionales, pero la lógica de carga es condicional, ya que algunos se ejecutan solo si estamos en una shell de sesión (login), otros solo si es interactiva, y algunos únicamente actúan a nivel usuario o sistema.

1. **Ficheros que se ejecutan en una shell sin sesión (non-login shell):**

   - `/etc/bashrc` (o `/etc/bash.bashrc` en sistemas Debian/Ubuntu): Archivo común global, administrado por el usuario `root`.
   - `~/.bashrc`: Archivo específico y privado de cada usuario, gestionado por él mismo.

2. **Ficheros que se ejecutan en una shell de sesión (login shell):**

   - `/etc/profile`: Archivo común global, modificable únicamente por `root` y que se carga el primero.
   - Archivos de inicio específicos del usuario. Bash los procesará de forma excluyente siguiendo este estricto orden (solo leerá el **primero** que encuentre, ignorando el resto):
     1. Busca `~/.bash_profile`. Si existe, lo ejecuta.
     2. Si no existe el anterior, busca `~/.bash_login`.
     3. Si ninguno de los dos anteriores existe, como método de compatibilidad heredada, busca y ejecuta `~/.profile`.

3. **Fichero que se ejecuta al salir de una shell de sesión:**

   - `~/.bash_logout`: Se lee y ejecuta justo antes de que finalice la sesión y el usuario salga por completo de la consola.

> **Importante:** Estas dos listas parecen excluyentes, pero en la práctica no lo son. En Debian, el `~/.profile` que se crea por defecto termina invocando a `~/.bashrc` si la shell es Bash:
>
> ```bash
> if [ -n "$BASH_VERSION" ]; then
>     if [ -f "$HOME/.bashrc" ]; then
>         . "$HOME/.bashrc"
>     fi
> fi
> ```
>
> Gracias a este puente, los alias y funciones definidos en `~/.bashrc` también están disponibles en una shell con login. Si creas un `~/.bash_profile` propio y olvidas incluir esa llamada, `~/.profile` dejará de leerse y tus alias desaparecerán al conectarte por SSH. Es una de las causas más frecuentes de "mi configuración funciona en el terminal gráfico pero no por SSH".

Se puede comprobar de forma empírica qué tipo de shell tenemos delante. Si el primer carácter de `$0` es un guion, se trata de una shell con login:

```bash
usuario@debian:~$ echo $0
bash
usuario@debian:~$ ssh usuario@localhost
usuario@debian:~$ echo $0
-bash
```

También sirve `shopt`, que informa directamente del estado de la opción `login_shell`:

```bash
usuario@debian:~$ shopt login_shell
login_shell     off
```

---

## 5. ¿Por qué tantos archivos?

La razón de separar esta jerarquía es mantener retrocompatibilidad de sistema. Los archivos que contienen la palabra "bash" en su nombre (como `~/.bashrc` o `~/.bash_profile`) albergan configuraciones exclusivas y extendidas que solo serán ejecutables por el intérprete `bash` de GNU. 

En cambio, ficheros históricos como `/etc/profile` y `~/.profile` son heredados y comunes a todos los intérpretes de comandos clásicos compatibles con POSIX basados en `sh`, como `ksh` o `dash`, los cuales podrían no entender la sintaxis extendida de Bash. Por esta razón, no deberíamos introducir directivas de configuración exclusivas o funciones avanzadas de `bash` dentro de estos archivos genéricos o compartidos.
