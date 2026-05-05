# Comandos de localización e intérprete: which y type

## Índice

1. [Introducción](#introducción)
2. [Comando which](#comando-which)
3. [Comando type](#comando-type)

---

## Introducción

Ambos comandos, `which` y `type`, son herramientas esenciales de diagnóstico en la línea de comandos. Son muy útiles para identificar la ubicación física de un comando específico, verificar si tenemos algo instalado, y para determinar con exactitud cómo se interpretará una instrucción concreta en nuestro entorno.

---

## Comando which

El comando `which` se utiliza para encontrar la ubicación física de un comando ejecutable en el sistema de archivos del usuario. 

Su funcionamiento es sencillo: escanea secuencialmente de izquierda a derecha todos los directorios que estén registrados actualmente en tu variable de entorno `$PATH`. Devuelve la ruta completa del primer archivo ejecutable válido que coincida con el nombre buscado.

```bash
usuario@debian:~$ which ls
/usr/bin/ls
```

**Explicación:** En este caso, el sistema nos indica que cuando invocamos el comando `ls`, el archivo binario real que se va a ejecutar reside en la ruta `/usr/bin/ls`. 

> **Nota:** `which` es muy literal. Solo encuentra archivos ejecutables en el `$PATH`. Es completamente ciego a funciones personalizadas del usuario, alias de Bash o comandos internos integrados en el propio *shell*.

---

## Comando type

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
ls is /usr/bin/ls
ls is /bin/ls
```

**Explicación:** Con `type -a ls`, el intérprete nos cuenta la historia completa: primero intentará ejecutar el alias de los colores, pero si este no existiera, recurriría al archivo binario de `/usr/bin/ls` y, como último recurso de herencia en el `$PATH`, buscaría en `/bin/ls`.
