# Comando history

## Índice

1. [Uso básico e invocación](#1-uso-básico-e-invocación)
   1. [Expansión del historial](#11-expansión-del-historial)
   2. [Búsqueda interactiva con Ctrl+R](#12-búsqueda-interactiva-con-ctrlr)
2. [Gestión y persistencia del historial](#2-gestión-y-persistencia-del-historial)
3. [Variables del sistema](#3-variables-del-sistema)
4. [Control del historial (HISTCONTROL)](#4-control-del-historial-histcontrol)
5. [Formato de tiempo (HISTTIMEFORMAT)](#5-formato-de-tiempo-histtimeformat)
6. [Configuración permanente del historial](#6-configuración-permanente-del-historial)

---

## 1. Uso básico e invocación

Ejemplos de invocación con el comando `history`:

```bash
history       # muestra la lista de comandos que el shell mantiene en memoria
history 10    # muestra solo los últimos 10 comandos
history -c    # limpia el historial de la sesión actual en memoria
```

> **Importante:** Conviene distinguir los dos lugares donde vive el historial, porque casi todas las confusiones nacen de mezclarlos:
>
> - **La lista en memoria**, que es la que muestra `history` y la que se recorre con las flechas. Al abrir el terminal se carga desde el fichero, y durante la sesión solo existe en RAM.
> - **El fichero `~/.bash_history`**, que se actualiza normalmente **al cerrar la sesión**, no en cada comando.
>
> De ahí que un comando ejecutado en una terminal no aparezca en el `history` de otra abierta al mismo tiempo, y que `history -c` a secas no vacíe el fichero: solo borra la copia en memoria, y al salir el fichero puede volver a escribirse.

| Parámetro | Descripción |
|---|---|
| `-c` | Vacía la lista en memoria. |
| `-d N` | Elimina únicamente la entrada número `N`. Es lo que se usa para borrar un comando concreto que no debería haberse escrito. |
| `-w` | (*Write*) Vuelca la lista en memoria al fichero, sobrescribiéndolo. |
| `-a` | (*Append*) Añade al fichero solo las líneas nuevas de esta sesión. |
| `-r` | (*Read*) Carga el contenido del fichero y lo añade a la lista en memoria. |
| `-n` | Lee del fichero únicamente las líneas que aún no estaban en memoria. |

Para borrar de verdad el historial, hay que limpiar ambos sitios:

```bash
usuario@debian:~$ history -c && history -w
```

### 1.1 Expansión del historial

El signo de admiración permite reutilizar comandos y argumentos anteriores sin volver a teclearlos:

| Expresión | Significado |
|---|---|
| `!!` | El comando anterior completo. |
| `!775` | El comando número 775 del historial. |
| `!-2` | El penúltimo comando. |
| `!apt` | El último comando que empezaba por `apt`. |
| `!?error?` | El último comando que **contenía** la cadena `error` en cualquier posición. |
| `!$` | El último argumento del comando anterior. |
| `!*` | Todos los argumentos del comando anterior. |
| `^viejo^nuevo` | Repite el comando anterior sustituyendo la primera aparición de `viejo` por `nuevo`. |

Las dos que más tiempo ahorran en la práctica son `sudo !!`, cuando se olvida el `sudo`, y `!$`, para reutilizar la ruta que se acaba de escribir:

```bash
usuario@debian:~$ apt install nginx
E: Could not open lock file /var/lib/dpkg/lock-frontend - open (13: Permiso denegado)
usuario@debian:~$ sudo !!
sudo apt install nginx

usuario@debian:~$ mkdir -p /tmp/proyecto/documentos
usuario@debian:~$ cd !$
cd /tmp/proyecto/documentos
usuario@debian:/tmp/proyecto/documentos$
```

> **Advertencia:** La expansión se produce **antes** de ejecutar nada, y Bash muestra en pantalla el comando resultante antes de lanzarlo. Aun así, `sudo !!` sobre un historial que no se recuerda con exactitud puede ejecutar con privilegios algo muy distinto de lo que se pretendía. Para revisarlo antes, existe la opción `shopt -s histverify`, que deja el comando expandido escrito en el prompt a la espera de que se pulse Intro.

### 1.2 Búsqueda interactiva con Ctrl+R

En el uso diario, la forma más rápida de recuperar un comando no es `history` sino la búsqueda incremental hacia atrás. Pulsando `Ctrl + R` el prompt cambia a `(reverse-i-search)` y basta con escribir cualquier fragmento del comando buscado:

```bash
(reverse-i-search)`ssh': ssh usuario@192.168.1.50 -p 2222
```

| Tecla | Acción |
|---|---|
| `Ctrl + R` | Inicia la búsqueda, o salta a la coincidencia anterior. |
| `Ctrl + S` | Avanza a la coincidencia siguiente. |
| `Intro` | Ejecuta el comando encontrado. |
| `Flecha derecha` o `Esc` | Lo deja escrito en el prompt para poder editarlo antes de ejecutarlo. |
| `Ctrl + G` | Cancela la búsqueda y deja el prompt vacío. |

> **Nota:** `Ctrl + S` puede no responder, porque en muchos terminales esa combinación está reservada para detener el flujo de salida (*XOFF*). Si la terminal parece congelarse tras pulsarla, se reanuda con `Ctrl + Q`. Para liberar la combinación basta con ejecutar `stty -ixon`.

Para repetir un comando específico usando su identificador numérico en el historial:

```bash
!775
```

> **Recuerda:** También puedes repetir el comando más reciente ejecutando simplemente `!!`, o el último que empezaba por ciertas letras con `!letra`.

---

## 2. Gestión y persistencia del historial

Apagar o prender el guardado de historial en la sesión activa:

```bash
set +o history # Apaga la grabación en el historial
set -o history # Prende la grabación en el historial
```

Impedir que el historial de esta sesión llegue a guardarse en disco:

```bash
export HISTFILESIZE=0
```

> **Advertencia:** `HISTFILESIZE=0` **no desactiva el historial**. Los comandos se siguen registrando con normalidad en memoria y `history` los muestra durante toda la sesión; lo único que hace es truncar el fichero a cero líneas al cerrar. Para que no se registre nada en absoluto hay que actuar sobre la lista en memoria o desligarla del fichero:
>
> | Orden | Efecto |
> |---|---|
> | `unset HISTFILE` | El historial funciona en memoria pero al salir no se vuelca a ningún sitio. Es la forma más habitual. |
> | `export HISTSIZE=0` | No se guarda nada ni siquiera en memoria: `history` aparece vacío y las flechas no recuperan nada. |
> | `set +o history` | Detiene la grabación a partir de ese punto, conservando lo anterior. |

> **Nota:** Ninguna de estas medidas oculta nada a un administrador. Los comandos ejecutados con `sudo` quedan registrados en `/var/log/auth.log` con independencia de la configuración del historial del usuario, y el sistema de auditoría `auditd`, si está activo, registra las llamadas de ejecución directamente en el núcleo.

---

## 3. Variables del sistema

Variables del sistema involucradas con la gestión del historial de la terminal:

| Variable | Descripción |
|----------|-------------|
| `$HISTFILE` | Contiene la ruta del archivo donde se guarda. Normalmente es: `~/.bash_history`. |
| `$HISTFILESIZE` | Contiene el número máximo de líneas/comandos que se guardarán en el archivo físico. |
| `$HISTSIZE` | Contiene el número máximo de comandos mantenidos en memoria durante la sesión. |
| `$HISTIGNORE` | Define patrones de comandos a ignorar (ej: `ls*:cd*:history*:exit:passwd*`). |
| `$HISTCONTROL` | Controla qué comandos se descartan por su forma, no por su contenido. Se detalla en el apartado siguiente. |
| `$HISTTIMEFORMAT` | Formato de fecha y hora con el que se muestra cada entrada. Se detalla más adelante. |

> **Nota:** Tanto `HISTSIZE` como `HISTFILESIZE` admiten el valor `-1` para no imponer límite alguno. Es una configuración frecuente entre administradores, que prefieren conservar el historial completo como registro de lo que se ha hecho en cada máquina.

> **Advertencia:** Por defecto, al cerrar una sesión Bash **sobrescribe** `~/.bash_history` con su copia en memoria. Si se trabaja con varias terminales abiertas a la vez, la última en cerrarse machaca lo que hubieran guardado las demás, y buena parte del historial se pierde sin aviso. La solución es activar el modo de añadido:
>
> ```bash
> shopt -s histappend
> ```
>
> En Debian esta opción ya viene activada en el `~/.bashrc` por defecto. Para ir un paso más allá y que cada comando se escriba en el fichero en el momento de ejecutarse, de modo que quede disponible al instante para las demás terminales, se emplea:
>
> ```bash
> export PROMPT_COMMAND='history -a; history -n'
> ```

---

## 4. Control del historial (HISTCONTROL)

La variable `HISTCONTROL` permite decidir si ciertos comandos se guardan o no. Por ejemplo, los comandos que comiencen con un espacio en blanco no se guardarán en el historial si lo configuramos así:

```bash
export HISTCONTROL=ignorespace
```

> **Nota:** ¿Por qué usarlo? Para evitar que comandos sensibles o privados queden registrados (por ejemplo, contraseñas en plano, tokens o configuraciones) y para ejecutar comandos temporales sin llenar el historial innecesariamente.

> **Advertencia:** El truco del espacio inicial solo funciona si `HISTCONTROL` **ya contenía** `ignorespace` o `ignoreboth` **antes** de escribir el comando. Configurarlo después no borra lo ya registrado. Y aunque el comando no llegue al historial, una contraseña escrita en la línea de órdenes sigue siendo visible durante su ejecución para cualquier usuario del sistema a través de `ps aux` o de `/proc`. La forma correcta de introducir una contraseña es dejar que el programa la pida de forma interactiva, o leerla de un fichero con permisos restringidos.

Otras opciones de `HISTCONTROL`:

| Valor | Descripción |
|-------|-------------|
| `ignorespace` | No guarda comandos que comiencen con un espacio en el historial. |
| `ignoredups` | No guarda comandos duplicados consecutivos en el historial. |
| `ignoreboth` | Combina `ignorespace` e `ignoredups`, evitando comandos con espacio y duplicados. |
| `erasedups` | Elimina todas las entradas duplicadas anteriores, manteniendo solo la última ocurrencia. |
| `none` | No ignora ningún comando (comportamiento por defecto en algunos sistemas). |

---

## 5. Formato de tiempo (HISTTIMEFORMAT)

`HISTTIMEFORMAT` permite registrar y mostrar la fecha y hora en que se ejecutó cada comando en el historial.

Para habilitar el registro temporal en la sesión actual:

```bash
export HISTTIMEFORMAT="%F %T "
```

Explicación:
- `%F` - Muestra la fecha en formato YYYY-MM-DD.
- `%T` - Muestra la hora en formato HH:MM:SS.
- El espacio al final mejora la legibilidad separando la fecha del comando.

Salida de ejemplo:
```bash
    1 2025-03-27 14:23:45 ls
    2 2025-03-27 14:23:46 pwd
    3 2025-03-27 14:23:47 echo "Hola"
```

Para hacerlo permanente en tu entorno de usuario, añádelo a tu archivo de configuración:

```bash
echo 'export HISTTIMEFORMAT="%F %T "' >> ~/.bashrc
source ~/.bashrc
```

Formatos comunes para `HISTTIMEFORMAT`:

| Formato        | Descripción                                  | Ejemplo de Salida        |
| -------------- | -------------------------------------------- | ------------------------ |
| `%F %T `       | Fecha completa y hora                        | 2025-03-27 14:23:45      |
| `%d-%m-%Y %T ` | Día-Mes-Año y Hora                           | 27-03-2025 14:23:45      |
| `%Y/%m/%d %H:%M `| Año/Mes/Día y Hora:Minuto                  | 2025/03/27 14:23         |
| `%c `          | Fecha y hora local en formato completo       | Thu Mar 27 14:23:45 2025 |
| `%x %X `       | Fecha y hora según la configuración regional | 03/27/2025 14:23:45      |

---

## 6. Configuración permanente del historial

Todas las variables vistas hasta aquí se han fijado con `export` sobre la sesión en curso, de modo que se pierden al cerrar la terminal. Para conservarlas hay que escribirlas en uno de los ficheros de configuración del intérprete descritos en el documento 02.

> **Recuerda:** El símbolo `~` es un atajo para el directorio personal del usuario (`$HOME`), de manera que `~/.bash_profile` equivale a `/home/usuario/.bash_profile`.

Ejemplo de un perfil que concentra toda la configuración del historial:

```bash
cat ~/.bash_profile
```

```bash
PATH=$PATH:$HOME/bin:/lpic1
PS1='\[\e[1;32m\][\u@\h \W]\$\[\e[0m\]'
HISTIGNORE='ls*:cd*:history*:exit'
EDITOR=/usr/bin/vi
HISTFILE=/root/.historial
export PATH PS1 HISTIGNORE EDITOR HISTFILE
```

Para aplicar los cambios sin cerrar sesión, ejecutamos el comando `source`:

```bash
source ~/.bash_profile
```

> **Importante:** El comando `source` en Bash (y su sinónimo `.`) ejecuta las órdenes de un fichero **en el contexto del shell actual**. Esto significa que las variables de entorno, funciones y configuraciones definidas en el archivo se aplican directamente a la sesión activa, en lugar de ejecutarse en un subproceso hijo que moriría instantáneamente llevándose consigo los cambios.

> **Advertencia:** El fichero del ejemplo es un `~/.bash_profile`, que Bash lee únicamente en las **shells con login**. Si la configuración debe aplicarse también al abrir una ventana nueva del terminal gráfico, el sitio adecuado es `~/.bashrc`. La distinción entre ambos ficheros se explica en el documento 02.
