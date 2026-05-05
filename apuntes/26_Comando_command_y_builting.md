# Comandos command y builtin

## Índice

1. [El orden de precedencia de ejecución](#1-el-orden-de-precedencia-de-ejecución)
2. [Uso del comando command](#2-uso-del-comando-command)
3. [Uso del comando builtin](#3-uso-del-comando-builtin)

---

En Linux y más concretamente en intérpretes como Bash, cuando escribimos una instrucción, el shell debe decidir cómo resolverla. Para esto, existe un orden estricto de precedencia. Además, contamos con los comandos `command` y `builtin` para saltarnos temporalmente ese orden de ejecución.

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

---

## 2. Uso del comando command

El comando `command` fuerza a Bash a **ignorar las funciones y los alias** que pudiesen existir con el mismo nombre, y en su lugar buscar directamente en los comandos internos (`builtin`) o en el sistema de archivos (`file`/`$PATH`).

> **Nota:** Esto es extremadamente útil dentro de scripts de automatización para evitar conflictos si un usuario tiene un alias extraño asignado a un comando estándar (por ejemplo, si tiene `alias ls='ls -la'`).

```bash
usuario@debian:~$ type -a ls
ls es un alias de `ls --color=auto'
ls is /usr/bin/ls
ls is /bin/ls
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
usuario@debian:~$ command cd
usuario@debian:~$ builtin cd
```

> **Recuerda:** Si existe un programa binario en tu sistema llamado `/usr/bin/cd` (poco probable) o `/bin/echo` (común) y tienes una función llamada `echo`, `builtin echo` garantizará la ejecución de la orden rápida cargada en memoria, sin levantar un nuevo proceso en el sistema operativo.
