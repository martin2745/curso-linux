# Comando history

## Índice

1. [Uso básico e invocación](#1-uso-básico-e-invocación)
2. [Gestión y persistencia del historial](#2-gestión-y-persistencia-del-historial)
3. [Variables del sistema](#3-variables-del-sistema)
4. [Control del historial (HISTCONTROL)](#4-control-del-historial-histcontrol)
5. [Formato de tiempo (HISTTIMEFORMAT)](#5-formato-de-tiempo-histtimeformat)
6. [Carga de configuraciones desde archivos (source)](#6-carga-de-configuraciones-desde-archivos-source)

---

El comando `history` en Linux muestra el historial de comandos ejecutados en la sesión del shell. Es útil para revisar comandos anteriores, reutilizarlos y gestionar el historial.

---

## 1. Uso básico e invocación

Ejemplos de invocación con el comando `history`:

```bash
history       # muestra todo el historial de la sesión actual y del archivo ~/.bash_history
history 10    # muestra solo los últimos 10 comandos
history -c    # limpia el historial de la sesión actual en memoria
```

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

Desactivar el historial permanentemente para la sesión actual:

```bash
export HISTFILESIZE=0
```

---

## 3. Variables del sistema

Variables del sistema involucradas con la gestión del historial de la terminal:

| Variable | Descripción |
|----------|-------------|
| `$HISTFILE` | Contiene la ruta del archivo donde se guarda. Normalmente es: `~/.bash_history`. |
| `$HISTFILESIZE` | Contiene el número máximo de líneas/comandos que se guardarán en el archivo físico. |
| `$HISTSIZE` | Contiene el número máximo de comandos mantenidos en memoria durante la sesión. |
| `$HISTIGNORE` | Define patrones de comandos a ignorar (ej: `ls*:cd*:history*:exit:passwd*`). |

---

## 4. Control del historial (HISTCONTROL)

La variable `HISTCONTROL` permite decidir si ciertos comandos se guardan o no. Por ejemplo, los comandos que comiencen con un espacio en blanco no se guardarán en el historial si lo configuramos así:

```bash
export HISTCONTROL=ignorespace
```

> **Nota:** ¿Por qué usarlo? Para evitar que comandos sensibles o privados queden registrados (por ejemplo, contraseñas en plano, tokens o configuraciones) y para ejecutar comandos temporales sin llenar el historial innecesariamente.

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

## 6. Carga de configuraciones desde archivos (source)

El símbolo `~` en Linux y otros sistemas tipo Unix es un atajo para el directorio de inicio (`$HOME`) del usuario actual. Este símbolo simplifica la navegación hacia el directorio principal del usuario sin tener que escribir la ruta completa.

Ejemplo revisando el archivo de perfil:

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

> **Importante:** El comando `source` en Bash (y otros shells similares, a veces alias de `.`) se utiliza para ejecutar comandos desde un archivo **en el contexto del shell actual**. Esto significa que las variables de entorno, funciones y configuraciones definidas en el archivo se aplican directamente a la sesión activa en lugar de ejecutarse en un subproceso hijo que moriría instantáneamente.
