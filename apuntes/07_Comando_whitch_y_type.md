# Comandos de localización e intérprete: which y type

## Índice

1. [Introducción](#1-introducción)
2. [Comando which](#2-comando-which)
3. [Comando type](#3-comando-type)
4. [Comando command -v y la portabilidad en scripts](#4-comando-command--v-y-la-portabilidad-en-scripts)
   1. [Cuándo usar cada uno](#41-cuándo-usar-cada-uno)

---

## 1. Introducción

Ambos comandos, `which` y `type`, son herramientas esenciales de diagnóstico en la línea de comandos. Son muy útiles para identificar la ubicación física de un comando específico, verificar si tenemos algo instalado, y para determinar con exactitud cómo se interpretará una instrucción concreta en nuestro entorno.

---

## 2. Comando which

El comando `which` se utiliza para encontrar la ubicación física de un comando ejecutable en el sistema de archivos del usuario. 

Su funcionamiento es sencillo: escanea secuencialmente de izquierda a derecha todos los directorios que estén registrados actualmente en tu variable de entorno `$PATH`. Devuelve la ruta completa del primer archivo ejecutable válido que coincida con el nombre buscado.

```bash
usuario@debian:~$ which ls
/usr/bin/ls
```

**Explicación:** En este caso, el sistema nos indica que cuando invocamos el comando `ls`, el archivo binario real que se va a ejecutar reside en la ruta `/usr/bin/ls`. 

> **Nota:** `which` es muy literal. Solo encuentra archivos ejecutables en el `$PATH`. Es completamente ciego a funciones personalizadas del usuario, alias de Bash o comandos internos integrados en el propio *shell*.

---

## 3. Comando type

El comando `type` es mucho más exhaustivo que `which`. No solo muestra la ubicación de un comando ejecutable, sino que también desvela **cómo será interpretado por el propio shell** (*Bash*).

Dependiendo del comando consultado, `type` te advertirá si se trata de:
- Un comando **interno** del shell (*built-in*), como `cd` o `echo`, que no tienen por qué ser archivos en el disco duro.
- Un comando **externo** (informando de la ubicación del archivo ejecutable, igual que `which`).
- Un **alias** configurado por el usuario (un atajo que redirige a otro comando).
- Una **función** de shell definida.

```bash
usuario@debian:~$ type ls
ls es un alias de `ls --color=auto`
```

**Explicación:** La salida de `type ls` nos revela un comportamiento oculto: en nuestra terminal, el comando `ls` está en realidad interceptado por un alias que le añade color automáticamente (`--color=auto`). Esto explica por qué `ls` imprime en colores, a pesar de que el archivo binario base original no lo hace por defecto.

Para profundizar aún más, el comando `type` admite el parámetro `-a` (*all*), el cual nos obliga a buscar e imprimir **todas** las posibles coincidencias e interpretaciones para el comando en el sistema, no solo la primera.

```bash
usuario@debian:~$ type -a ls
ls es un alias de `ls --color=auto'
ls es /usr/bin/ls
ls es /bin/ls
```

**Explicación:** Con `type -a ls`, el intérprete nos cuenta la historia completa: primero ejecutará el alias de los colores; si este no existiera, recurriría al binario `/usr/bin/ls`, y en último lugar al que encontrase en `/bin/ls`.

> **Recuerda:** Las dos últimas rutas apuntan en realidad **al mismo fichero**. Desde el *UsrMerge* descrito en el documento 01, `/bin` es un enlace simbólico a `/usr/bin`, pero ambos directorios siguen figurando por separado en la variable `$PATH`, de modo que `type -a` los muestra como dos coincidencias distintas. Se puede confirmar comparando sus inodos con `ls -li /usr/bin/ls /bin/ls`.

---

## 4. Comando command -v y la portabilidad en scripts

Dentro de un script conviene evitar `which`. No es un comando interno del shell sino un programa externo, su comportamiento varía entre distribuciones y su código de salida no es fiable en todas ellas. El sustituto recomendado es `command -v`, que forma parte del estándar POSIX y va integrado en el propio intérprete:

```bash
usuario@debian:~$ command -v ls
alias ls='ls --color=auto'
usuario@debian:~$ command -v gzip
/usr/bin/gzip
usuario@debian:~$ command -v comando_inexistente
usuario@debian:~$ echo $?
1
```

La comprobación habitual de si una herramienta está disponible antes de usarla queda así:

```bash
if ! command -v git > /dev/null 2>&1; then
    echo "Este script necesita git instalado." >&2
    exit 1
fi
```

> **Nota:** Existe además `whereis`, que no busca en el `$PATH` sino en una lista fija de directorios estándar, y que devuelve de una sola vez el binario, el código fuente y la página de manual asociada al comando.
>
> ```bash
> usuario@debian:~$ whereis ls
> ls: /usr/bin/ls /usr/share/man/man1/ls.1.gz
> ```

### 4.1 Cuándo usar cada uno

| Herramienta | Tipo | Ve alias y funciones | Uso recomendado |
|---|---|---|---|
| `which` | Programa externo | No | Consulta rápida e interactiva de dónde está un binario. |
| `type` | Interno del shell | Sí | Diagnosticar por qué un comando se comporta de forma inesperada. |
| `command -v` | Interno del shell | Sí | Comprobaciones dentro de scripts, por portabilidad. |
| `whereis` | Programa externo | No | Localizar también el manual y las fuentes del comando. |
