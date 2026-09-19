# Comandos command y builtin

## Índice

1. [El orden de precedencia de ejecución](#1-el-orden-de-precedencia-de-ejecución)
   1. [La tabla hash de Bash](#11-la-tabla-hash-de-bash)
2. [Uso del comando command](#2-uso-del-comando-command)
3. [Uso del comando builtin](#3-uso-del-comando-builtin)

---

## 1. El orden de precedencia de ejecución

El orden en el que Bash busca un comando para su ejecución es el siguiente:

1. **`alias`**:
   - Localización típica: `~/.bashrc`, `/etc/bashrc` o configurados en la sesión actual.
   - Descripción: Un alias personalizado que sustituye al comando.

2. **`keywords` (palabras clave)**:
   - Palabras reservadas del lenguaje de scripting de Bash (ej. `function`, `if`, `for`).

3. **`functions` (funciones)**:
   - Formato: `nombre_funcion() { ... }`
   - Descripción: Funciones personalizadas definidas en el entorno o scripts de Bash.

4. **`builtin` (comandos internos)**:
   - Descripción: Comandos internos de Bash que siempre están cargados en memoria y no requieren crear un proceso hijo (ej. `cd`, `echo`, `type`).

5. **`file` (archivos ejecutables/binarios)**:
   - Descripción: Scripts y programas ejecutables físicos buscados en los directorios listados en la variable de entorno `$PATH` (ej. `/bin/ls`, `/usr/bin/cat`).

> **Recuerda:** Una forma sencilla de memorizar el orden es la regla mnemotécnica **A-K-F-B-F**: Alias, Keyword, Function, Builtin, File. El comando `type` lo revela para cualquier nombre, y `type -a` muestra **todas** las resoluciones posibles en ese mismo orden.

### 1.1 La tabla hash de Bash

Entre el paso 4 y el paso 5 falta un detalle que explica un comportamiento desconcertante. Recorrer todos los directorios del `$PATH` cada vez que se teclea un comando sería lento, de modo que Bash **memoriza** la ruta completa de cada ejecutable la primera vez que lo encuentra y la guarda en una tabla interna llamada *hash*. En las siguientes invocaciones va directamente a esa ruta sin volver a buscar.

```bash
usuario@debian:~$ hash
hits    command
   2    /usr/bin/ls
   1    /usr/bin/grep
```

> **Advertencia:** Esta caché provoca el clásico "he movido el programa y la shell sigue usando el antiguo". Si se instala una versión nueva de un comando en una ruta distinta, o se borra el binario que Bash tenía memorizado, la shell seguirá intentando la ruta guardada y puede responder con un desconcertante `No such file or directory` sobre un comando que existe perfectamente.
>
> ```bash
> usuario@debian:~$ hash -d ls      # olvida la ruta memorizada de 'ls'
> usuario@debian:~$ hash -r         # vacia la tabla entera
> ```
>
> Es la primera comprobación que conviene hacer cuando un comando se comporta de forma inexplicable tras una actualización o un cambio en el `$PATH`.

---

## 2. Uso del comando command

El comando `command` fuerza a Bash a **ignorar las funciones** que pudiesen existir con ese nombre, y buscar directamente entre los comandos internos (`builtin`) o en el sistema de archivos (`file`/`$PATH`).

> **Nota:** En cuanto a los alias, el efecto es el mismo pero el mecanismo es distinto, y conviene entenderlo. `command` no "desactiva" ningún alias: lo que ocurre es que Bash solo expande alias en la **primera palabra** de una orden. Al escribir `command ls`, la primera palabra pasa a ser `command`, de modo que `ls` queda en segunda posición y su alias no llega a expandirse nunca.

| Herramienta | Salta el alias | Salta la función | Salta el builtin |
|---|---|---|---|
| `\ls` | Sí | No | No |
| `command ls` | Sí | Sí | No |
| `builtin cd` | Sí | Sí | — (obliga a usarlo) |
| `enable -n cd` | — | — | Sí (lo desactiva) |
| `/usr/bin/ls` | Sí | Sí | Sí |

> **Nota:** Esto es extremadamente útil dentro de scripts de automatización para evitar conflictos si un usuario tiene un alias extraño asignado a un comando estándar (por ejemplo, si tiene `alias ls='ls -la'`).

```bash
usuario@debian:~$ type -a ls
ls es un alias de `ls --color=auto'
ls es /usr/bin/ls
ls es /bin/ls
```

Al utilizar `command ls`, evitamos la ejecución del alias:

```bash
usuario@debian:~$ command ls
d1         Documentos   fichero.txt   Música     Público
Descargas  Escritorio   Imágenes      Plantillas Vídeos
```

---

## 3. Uso del comando builtin

El comando `builtin` es aún más restrictivo que `command`: obliga al shell a ejecutar **exclusivamente un comando interno** de Bash, ignorando por completo funciones, alias y también cualquier archivo binario con el mismo nombre en el `$PATH`.

```bash
usuario@debian:~$ type -a cd
cd es una orden interna del shell
```

Podemos ejecutar `cd` explícitamente como comando interno:

```bash
usuario@debian:~$ builtin cd /tmp
usuario@debian:/tmp$
```

> **Advertencia:** `cd` **tiene** que ser un comando interno y no puede existir como programa externo. Un programa se ejecuta siempre en un proceso hijo, y el directorio de trabajo es una propiedad de cada proceso: si `cd` fuese un binario, cambiaría el directorio de su propio proceso y ese proceso moriría inmediatamente después, dejando la shell donde estaba. Lo mismo ocurre con `export`, `source`, `alias`, `ulimit` o `umask`: todos ellos modifican el estado de la propia shell y por eso son necesariamente internos.

> **Nota:** El comando `enable` permite desactivar temporalmente un comando interno para que se resuelva el externo equivalente, y volver a activarlo después:
>
> ```bash
> usuario@debian:~$ type echo
> echo es una orden interna del shell
> usuario@debian:~$ enable -n echo
> usuario@debian:~$ type echo
> echo es /usr/bin/echo
> usuario@debian:~$ enable echo
> ```
>
> Resulta útil para comprobar diferencias de comportamiento, ya que el `echo` interno de Bash y el `/usr/bin/echo` de coreutils no admiten exactamente las mismas opciones.

> **Recuerda:** El documento 07 trata `command -v`, que es la variante de `command` empleada para averiguar si una herramienta está disponible antes de usarla dentro de un script.

> **Recuerda:** Si existe un programa binario en tu sistema llamado `/usr/bin/cd` (poco probable) o `/bin/echo` (común) y tienes una función llamada `echo`, `builtin echo` garantizará la ejecución de la orden rápida cargada en memoria, sin levantar un nuevo proceso en el sistema operativo.
