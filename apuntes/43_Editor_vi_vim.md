# El editor vi y vim

## Índice

1. [La idea clave: un editor modal](#1-la-idea-clave-un-editor-modal)
2. [Abrir, guardar y salir](#2-abrir-guardar-y-salir)
3. [Entrar en el modo inserción](#3-entrar-en-el-modo-inserción)
4. [Moverse por el texto (modo normal)](#4-moverse-por-el-texto-modo-normal)
5. [Editar: borrar, copiar y pegar](#5-editar-borrar-copiar-y-pegar)
6. [Buscar y reemplazar](#6-buscar-y-reemplazar)
   1. [Búsqueda](#61-búsqueda)
   2. [Reemplazo](#62-reemplazo)
7. [La gramática de vi: operador + movimiento](#7-la-gramática-de-vi-operador--movimiento)
8. [Modo visual (solo vim)](#8-modo-visual-solo-vim)
9. [Configuración básica: el fichero ~/.vimrc](#9-configuración-básica-el-fichero-vimrc)
10. [Referencia rápida](#10-referencia-rápida)

---

## 1. La idea clave: un editor modal

La primera vez que se abre `vi`, casi todo el mundo se queda atascado: escribe texto y no aparece, o aparecen cosas raras, y no consigue salir. La causa es que `vi` funciona de una forma radicalmente distinta a un editor normal como el Bloc de notas o `nano`: es un editor **modal**. Las teclas no siempre escriben; según el modo en que se esté, la misma tecla hace cosas diferentes.

Hay tres modos, y entender cómo se pasa de uno a otro resuelve el 90 % de la confusión inicial:

| Modo | Para qué sirve | Cómo se entra |
|---|---|---|
| **Normal** (o de comandos) | Moverse por el texto y ejecutar órdenes de edición (borrar, copiar, pegar). Es el modo en el que se arranca. | Se vuelve a él pulsando **`Esc`** desde cualquier otro modo. |
| **Inserción** | Escribir texto, como en cualquier editor. | Pulsando `i`, `a`, `o` (entre otras) desde el modo normal. |
| **Última línea** (o de comando `ex`) | Guardar, salir, buscar y reemplazar, y otras órdenes que se escriben abajo. | Pulsando **`:`** desde el modo normal. |

> **Importante:** La tecla más importante de `vi` es **`Esc`**. Ante la duda, o si algo no responde como se espera, se pulsa `Esc` para volver al modo normal, que es el punto de partida seguro desde el que se puede hacer cualquier otra cosa. El flujo mental es siempre el mismo: desde normal se entra a insertar para escribir, y con `Esc` se vuelve a normal para dar órdenes.

---

## 2. Abrir, guardar y salir

Se abre un fichero pasándolo como argumento. Si no existe, se creará al guardar:

```bash
usuario@debian:~$ vim /etc/hosts
```

Las órdenes de guardar y salir se dan desde el **modo última línea**, es decir, pulsando primero `Esc` (por si acaso) y después `:`. Estas son las imprescindibles:

| Orden | Efecto |
|---|---|
| `:w` | Guarda (*write*) los cambios sin salir. |
| `:q` | Sale (*quit*). Se niega si hay cambios sin guardar. |
| `:wq` | Guarda y sale. Es la combinación más usada. |
| `:x` | Igual que `:wq`, pero solo escribe si ha habido cambios. |
| `:q!` | Sale **descartando** los cambios. La exclamación fuerza la acción. |
| `:w archivo` | Guarda con otro nombre (*guardar como*). |

> **Recuerda:** El bloqueo clásico de los principiantes es no poder salir. La causa casi siempre es haber modificado el fichero sin querer: `:q` se niega a salir para no perder cambios, y muestra el aviso `E37: No write since last change`. La solución es `:q!` para salir descartando, o `:wq` para salir guardando. Y si aparecen letras raras al teclear, es que se está en modo inserción sin saberlo: se pulsa `Esc` primero.

> **Nota:** El editor `vim` incluye un tutorial interactivo excelente para practicar, que se abre con el comando `vimtutor` desde la terminal. Media hora con él vale más que leer cualquier chuleta.

---

## 3. Entrar en el modo inserción

Desde el modo normal hay varias teclas para empezar a escribir, y la diferencia entre ellas es **dónde** se coloca el cursor. Elegir la adecuada ahorra mucho movimiento:

| Tecla | Empieza a escribir... |
|---|---|
| `i` | *antes* del cursor (*insert*). |
| `a` | *después* del cursor (*append*). |
| `I` | al *principio* de la línea (primer carácter no en blanco). |
| `A` | al *final* de la línea. |
| `o` | en una *línea nueva* creada debajo de la actual. |
| `O` | en una *línea nueva* creada encima de la actual. |

Una vez dentro del modo inserción se escribe con normalidad, y al terminar se pulsa **`Esc`** para volver al modo normal.

---

## 4. Moverse por el texto (modo normal)

En modo normal, las teclas mueven el cursor. Aunque las flechas funcionan en `vim`, conviene acostumbrarse a las teclas originales `h`, `j`, `k`, `l`, porque están en la fila de reposo de las manos y funcionan en cualquier `vi`, incluso en sistemas donde las flechas dan problemas.

| Tecla | Movimiento |
|---|---|
| `h` `j` `k` `l` | Izquierda, abajo, arriba, derecha. |
| `w` / `b` | Palabra siguiente / anterior. |
| `0` / `$` | Principio / final de la línea. |
| `gg` / `G` | Principio / final del documento. |
| `:N` | Salta a la línea número `N` (por ejemplo `:42`). |
| `Ctrl-f` / `Ctrl-b` | Avanza / retrocede una pantalla completa. |

> **Nota:** Casi todos los movimientos admiten un número delante que los multiplica. `5j` baja cinco líneas, `3w` avanza tres palabras y `10G` salta a la línea 10. Esta idea de "número + orden" es la base de la potencia de `vi` y reaparece en el apartado 7.

---

## 5. Editar: borrar, copiar y pegar

Estas órdenes se dan en modo normal, sin necesidad de entrar a insertar. Son las que dan a `vi` su fama de rápido una vez se dominan:

| Orden | Efecto |
|---|---|
| `x` | Borra el carácter bajo el cursor. |
| `dd` | Borra (*delete*) la línea entera. |
| `dw` | Borra desde el cursor hasta el final de la palabra. |
| `yy` | Copia (*yank*) la línea entera. |
| `p` / `P` | Pega (*paste*) lo último borrado o copiado, debajo / encima. |
| `u` | Deshace (*undo*) el último cambio. |
| `Ctrl-r` | Rehace lo deshecho (*redo*). |
| `.` | Repite la última orden de edición. |
| `r` | Reemplaza el carácter bajo el cursor por el siguiente que se pulse. |
| `cw` | Cambia la palabra: la borra y entra en modo inserción. |

> **Importante:** En `vi`, borrar y copiar dejan el contenido en un portapapeles interno, de modo que `dd` seguido de `p` en otro sitio **mueve** una línea, y `yy` seguido de `p` la **duplica**. No existen los atajos `Ctrl-C` / `Ctrl-V` habituales: el mecanismo es `y` para copiar, `d` para cortar y `p` para pegar.

> **Recuerda:** La tecla `.` (punto) repite la última edición y es una de las que más tiempo ahorran. Si se acaba de borrar una línea con `dd`, pulsar `.` borra otra; si se reemplazó una palabra con `cw`, `.` repite el cambio en la siguiente. Combinada con los movimientos, permite hacer ediciones repetitivas a gran velocidad.

---

## 6. Buscar y reemplazar

### 6.1 Búsqueda

Desde el modo normal, `/` inicia una búsqueda hacia adelante y `?` hacia atrás. Se escribe el texto (o una expresión regular, como las del documento 09) y se pulsa Intro:

```text
/PermitRootLogin
```

Una vez hecha la búsqueda, `n` salta a la siguiente coincidencia y `N` a la anterior.

| Tecla | Efecto |
|---|---|
| `/texto` | Busca `texto` hacia adelante. |
| `?texto` | Busca `texto` hacia atrás. |
| `n` / `N` | Siguiente / anterior coincidencia. |

### 6.2 Reemplazo

La sustitución se hace desde el modo última línea con el comando `:s`, cuya sintaxis es idéntica a la del comando `sed` (documento 15), lo que no es casualidad: ambos heredan la misma tradición del editor `ex`.

| Orden | Efecto |
|---|---|
| `:s/viejo/nuevo/` | Reemplaza la **primera** aparición de `viejo` en la línea actual. |
| `:s/viejo/nuevo/g` | Reemplaza **todas** las apariciones de la línea actual (*global*). |
| `:%s/viejo/nuevo/g` | Reemplaza en **todo el documento** (`%` significa "todas las líneas"). |
| `:%s/viejo/nuevo/gc` | Igual, pero pide **confirmación** en cada una (`c` de *confirm*). |

```text
:%s/eth0/enp0s3/g
```

> **Nota:** El `%` del comando `:%s` es lo que extiende la sustitución a todo el fichero; sin él, `:s` solo actúa sobre la línea donde está el cursor. Y añadir la `c` final es una buena costumbre en ficheros importantes, porque permite revisar cada cambio antes de aplicarlo, respondiendo `y` (sí), `n` (no) o `a` (todos) a cada coincidencia.

---

## 7. La gramática de vi: operador + movimiento

Lo que distingue a `vi` de un editor corriente es que sus órdenes se **combinan** siguiendo una especie de gramática: un **operador** (qué hacer) se une a un **movimiento** (sobre qué), y opcionalmente a un **número** (cuántas veces). Entender esto convierte una lista de teclas sueltas en un sistema que se puede razonar.

Los operadores principales son `d` (borrar), `y` (copiar) y `c` (cambiar). Se combinan con cualquiera de los movimientos del apartado 4:

| Combinación | Se lee | Efecto |
|---|---|---|
| `dw` | *delete word* | Borra hasta el final de la palabra. |
| `d$` | *delete to end* | Borra hasta el final de la línea. |
| `d3w` | *delete 3 words* | Borra tres palabras. |
| `dG` | *delete to end of file* | Borra desde la línea actual hasta el final del documento. |
| `y2j` | *yank 2 down* | Copia la línea actual y las dos siguientes. |
| `c$` | *change to end* | Borra hasta el final de la línea y entra en modo inserción. |

> **Recuerda:** Una vez interiorizada esta lógica de "operador + movimiento + número", ya no hace falta memorizar cada combinación por separado: se construyen sobre la marcha. Es exactamente la misma idea del número que multiplica un movimiento (apartado 4), aplicada ahora también a las órdenes de edición. Ahí reside toda la eficiencia de `vi`.

---

## 8. Modo visual (solo vim)

`vim` añade un modo que `vi` original no tiene y que resulta muy intuitivo: el **modo visual**, que permite **seleccionar** texto resaltándolo antes de operar sobre él, de forma parecida a arrastrar con el ratón.

| Tecla | Selecciona |
|---|---|
| `v` | Carácter a carácter, moviéndose con las teclas de dirección. |
| `V` | Líneas completas. |
| `Ctrl-v` | Un bloque rectangular (por columnas). |

Con el texto seleccionado se aplica directamente un operador: `d` para borrarlo, `y` para copiarlo o `>` para indentarlo. Por ejemplo, para copiar cinco líneas: se coloca el cursor en la primera, se pulsa `V`, se baja cuatro líneas con `4j` y se pulsa `y`.

---

## 9. Configuración básica: el fichero ~/.vimrc

El comportamiento de `vim` se personaliza en el fichero `~/.vimrc`, que se lee cada vez que arranca. Las mismas órdenes se pueden probar sobre la marcha escribiéndolas en el modo última línea (por ejemplo `:set number`), pero en ese caso solo duran mientras el editor esté abierto.

Una configuración inicial razonable sería:

```bash
usuario@debian:~$ cat ~/.vimrc
syntax on            " coloreado de sintaxis
set number           " numero de linea en el margen
set expandtab        " la tecla Tab inserta espacios
set tabstop=4        " un tabulador equivale a 4 espacios
set hlsearch         " resalta todas las coincidencias de una busqueda
set ignorecase       " las busquedas no distinguen mayusculas
```

| Opción | Efecto |
|---|---|
| `syntax on` | Colorea la sintaxis según el tipo de fichero. |
| `set number` | Muestra el número de línea en el margen izquierdo. |
| `set hlsearch` | Resalta todas las coincidencias de la última búsqueda. |
| `set expandtab` | Convierte el tabulador en espacios, útil en ficheros de configuración sensibles a ello. |

> **Advertencia:** Algunos ficheros de configuración, como los de YAML o los `Makefile`, son sensibles a la diferencia entre tabuladores y espacios. Conviene tenerlo presente al ajustar `expandtab`, porque un cambio silencioso de tabuladores por espacios (o al revés) puede romper esos ficheros sin que el error sea evidente a simple vista.

---

## 10. Referencia rápida

| Quiero... | Pulso |
|---|---|
| Volver a un estado seguro | `Esc` |
| Escribir texto | `i` (o `a`, `o`) |
| Guardar y salir | `:wq` |
| Salir sin guardar | `:q!` |
| Borrar una línea | `dd` |
| Copiar / pegar una línea | `yy` / `p` |
| Deshacer / rehacer | `u` / `Ctrl-r` |
| Repetir la última edición | `.` |
| Ir a la línea N | `:N` |
| Buscar | `/texto` y luego `n` |
| Reemplazar en todo el fichero | `:%s/viejo/nuevo/g` |
