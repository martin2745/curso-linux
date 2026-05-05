# Entorno y variables de entorno en Linux

## Índice

1. [Listado de variables de entorno interesantes](#listado-de-variables-de-entorno-interesantes)
2. [Configuración de Archivos de Entorno en Linux](#configuración-de-archivos-de-entorno-en-linux)
   - [Ficheros con aplicación a todo el sistema](#ficheros-con-aplicación-a-todo-el-sistema-todos-los-usuarios-del-sistema)
   - [Ficheros con aplicación a un usuario específico](#ficheros-con-aplicación-a-un-usuario-específico)
3. [Archivos de Configuración de Bash y su Orden de Ejecución](#archivos-de-configuración-de-bash-y-su-orden-de-ejecución)
   - [¿Por qué tantos archivos?](#por-qué-tantos-archivos)

---

## Listado de variables de entorno interesantes

- **`SHELL`**: El nombre de la shell (o intérprete de comandos) por defecto asignada al usuario.
- **`HOME`**: El nombre de la ruta completa de tu directorio personal o carpeta de inicio.
- **`LANG` / `LANGUAGE`**: Define el conjunto de caracteres, la codificación y el orden de cotejo de su idioma local.
- **`PATH`**: Una lista separada por dos puntos (`:`) de los directorios absolutos que se buscan de forma secuencial cuando introducimos el nombre de un programa ejecutable sin especificar su ruta completa.
- **`PWD`**: El directorio de trabajo actual (*Print Working Directory*).
- **`_`**: Una referencia al último argumento del comando anterior o a la ruta del ejecutable actual (prueba a ejecutar el comando `$_` o `/usr/bin/printenv` para observar su comportamiento).
- **`USER`**: Tu nombre de usuario en la sesión actual.

> **Recuerda:** Para ver todas las variables de entorno activas en tu sesión actual, puedes utilizar comandos como `env` o `printenv`. Para ver tanto variables de entorno como variables locales, usa el comando `set`.

---

## Configuración de Archivos de Entorno en Linux

Para comprender correctamente cómo y cuándo se aplican las configuraciones en Linux, es fundamental entender la diferencia entre los tipos de sesión en la consola:
- **Shell con login (de sesión):** Ocurre cuando el usuario se autentica ingresando sus credenciales (por ejemplo, mediante una conexión `ssh`, al entrar en un TTY desde modo texto o al acceder al entorno gráfico inicial).
- **Shell sin login (sin sesión):** Ocurre cuando ya estamos autenticados y simplemente abrimos una nueva ventana/pestaña del emulador de terminal gráfico, o cuando se ejecuta un script de forma no interactiva.

### Ficheros con aplicación a todo el sistema (todos los usuarios del sistema)

- `/etc/environment`: Fichero específico a nivel de sistema operativo para la definición de variables de entorno de forma estática (sintaxis `VARIABLE="valor"`). **No puede contener scripts ni lógica de programación**. Se procesa e inicializa de manera muy temprana al arrancar el sistema por módulos PAM (`pam_env`).
- `/etc/profile`: Permite definir variables de entorno, funciones y llamadas a scripts de forma global. Aunque su uso está permitido, no es apropiado modificar este fichero directamente para configuraciones propias (en su lugar, debe crearse un nuevo fichero en el subdirectorio `/etc/profile.d/`). Se ejecuta únicamente en **shells con login**.
- `/etc/profile.d/`: Un directorio de tipo *drop-in* que contiene scripts individuales (usualmente `.sh`) que el sistema lee y ejecuta automáticamente durante la inicialización de **shells con login**. Facilita la administración modular de configuraciones de terceros.
- `/etc/bash.bashrc`: Permite definir variables de entorno, alias y funciones que estarán disponibles de forma global para programas y terminales iniciados desde la shell `bash`. Las variables que se definan en este fichero **no** van a estar disponibles para programas iniciados gráficamente desde los menús de escritorio. Se ejecuta generalmente en **shells sin login**.

> **Importante:** La mejor práctica como administrador de sistemas al querer inyectar configuraciones para todos los usuarios es crear scripts `.sh` separados dentro de `/etc/profile.d/`. De esta forma tus modificaciones personalizadas no serán sobrescritas por actualizaciones de paquetes del sistema operativo que actualicen el archivo `/etc/profile`.

### Ficheros con aplicación a un usuario específico

- `~/.profile`: Permite al usuario definir sus variables de entorno, agregar directorios a su variable `$PATH` o ejecutar scripts propios al inicio. Se ejecuta al iniciar la sesión de escritorio o al entrar en una **shell con login**. Estas variables se heredan y afectan a todos los programas ejecutados desde el escritorio gráfico o desde cualquier terminal interactiva.
- `~/.bash_profile`, `~/.bash_login`: Ficheros para configurar el entorno exclusivo de `bash`. Permiten definir variables de entorno y scripts. Se ejecutan cuando se inicia una **shell con login**. Las variables definidas solo afectarán a los programas ejecutados a partir de esta instancia de `bash`.
- `~/.bashrc`: Permite definir alias, funciones, variables locales y scripts personales. Se ejecuta cuando el usuario abre un terminal interactivo en una **shell sin login**. Es el archivo de configuración personal que se procesa más frecuentemente.
- `~/.bash_logout`: Se ejecuta automáticamente cuando el usuario cierra sesión o finaliza una **shell con login**. Se utiliza para limpiar cachés, borrar temporales o matar procesos residuales.
- `~/.bash_history`: Un archivo oculto que almacena en texto plano el historial de comandos ejecutados previamente por el usuario, permitiendo volver atrás o buscar con atajos como `Ctrl+R`.

> **Nota:** En función de nuestra shell predeterminada en Linux, trabajaremos con diferentes ficheros. Así como en Bash personalizamos a través del fichero [`~/.bashrc`](https://www.compuhoy.com/que-es-bashrc-en-linux/), en Zsh lo haremos sobre [`~/.zshrc`](https://respontodo.com/que-es-zsh-y-por-que-deberia-usarlo-en-lugar-de-bash/), teniendo cada intérprete sus propias reglas y particularidades de sintaxis.

---

## Archivos de Configuración de Bash y su Orden de Ejecución

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

### ¿Por qué tantos archivos?

La razón de separar esta jerarquía es mantener retrocompatibilidad de sistema. Los archivos que contienen la palabra "bash" en su nombre (como `~/.bashrc` o `~/.bash_profile`) albergan configuraciones exclusivas y extendidas que solo serán ejecutables por el intérprete `bash` de GNU. 

En cambio, ficheros históricos como `/etc/profile` y `~/.profile` son heredados y comunes a todos los intérpretes de comandos clásicos compatibles con POSIX basados en `sh`, como `ksh` o `dash`, los cuales podrían no entender la sintaxis extendida de Bash. Por esta razón, no deberíamos introducir directivas de configuración exclusivas o funciones avanzadas de `bash` dentro de estos archivos genéricos o compartidos.
