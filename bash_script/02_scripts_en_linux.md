# Scripts en linux

Un script en Linux es un archivo de texto plano que contiene una secuencia de comandos o instrucciones escritas para ser ejecutadas por un intérprete de comandos, como Bash, en sistemas Unix o Linux. Estos archivos permiten automatizar tareas, gestionar procesos complejos y ejecutar múltiples comandos de manera secuencial sin intervención manual.

## Ejecución de un script

Los scripts tienen una primera linea, el _shebang_, también conocido como hashbang o sha-bang, es una convención en sistemas operativos tipo Unix que se utiliza en scripts para indicar qué intérprete de comandos debe ser utilizado para ejecutar el script. El shebang consiste en los caracteres "#!" seguidos de la ruta al intérprete. Por ejemplo:

- En scripts bash:

```bash
#!/bin/bash
```

- En scripts python:

```bash
#!/usr/bin/env python3
#!/usr/bin/env python
```

- **chmod -x env.sh && bash env.sh**: Si ejecutamos bash env.sh, no es necesario tener permisos de ejecución en el script y estamos **ejecutando el script en una subshell**, por lo que al finalizar el script se elimina la subshell.

- **chmod +x env.sh && ./env.sh**: Si el shebang es #!/bin/bash y lo ejecutamos mediante ./env.sh, siempre y cuando el script tenga permisos de ejecución, estamos **ejecutando el script en una subshell**, por lo que al finalizar el script se elimina la subshell. Es análogo a la ejecución mediante el comando bash.

- **chmod -x env.sh && . ./env.sh**: Si ejecutamos mediante . ./env.sh o source ./env.sh, no es necesario tener permisos de ejecución y estamos **ejecutando el script en la shell actual**.

Es fundamental comprender de que forma se ejecutan nuestros scripts para poder comprender si van a modificar aspectos de nuestro entorno o no. En el siguiente ejemplo podemos apreciar como el nivel de shell que es diferente en función de como lanzamos nuestro script.

Script **env-ejemplo1.sh**

```bash
#!/bin/bash
env | sort | grep -v '^_' | tee env1.txt
```

Si ejecutamos con las opciones 1 o 2, es decir, con `bash` o con `./` se ejecutará el script en una subshell por lo que no afectará a mi entorno.

Podemos ver que al lanzarlo con `bash` (o con `./`) estamos en el nivel de shell 1.

```bash
usuario@debian:~$ bash env-ejemplo1.sh
COLORTERM=truecolor
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
DESKTOP_SESSION=ubuntu
DISPLAY=:0
GDMSESSION=ubuntu
...

usuario@debian:~$ cat env1.txt | grep SHLVL
SHLVL=1
```

En este caso, ejecutamos directamente el comando y podemos ver que estamos en el nivel de shell 0, es decir, el mismo nivel de shell donde lanzamos comandos. Esto quiere decir que las modificaciones de este comando si podrían afectar a mi entorno a diferencia del caso anterior.

```bash
usuario@debian:~$ env | sort | grep -v '^_' | tee env2.txt
COLORTERM=truecolor
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
DESKTOP_SESSION=ubuntu
DISPLAY=:0
GDMSESSION=ubuntu
...

usuario@debian:~$ cat env2.txt | grep SHLVL
SHLVL=0
```

```bash
usuario@debian:~$ source env-ejemplo1.sh
COLORTERM=truecolor
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
DESKTOP_SESSION=ubuntu
DISPLAY=:0
GDMSESSION=ubuntu
...

usuario@debian:~$ cat env1.txt | grep SHLVL
SHLVL=0
```

Este es el motivo por el cual cuando queremos modificar nuestro entorno se hace uso de ficheros como **.bashrc** y este se lanza con **source**. El objetivo es hacer una modificación de nuestro entorno.

Cargamos .bashrc con **.** por lo tanto al ser lo mismo que **source** se convierten en variables de entorno las variables locales definidas dentro a las que se le aplica un **export**.

```bash
usuario@debian:~$ cat .profile | grep ".bashrc"
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
```

## Variables locales y globales en un script

Todas las variables en los scripts bash, a menos que se definan de otra manera, son globales, es decir, una vez definidas pueden ser utilizadas en cualquier parte del script. Para que una variable sea local, es decir, tenga sentido solamente dentro de una sección del script, como en una función, y no en todo el script, debe ser precedida por la sentencia: **local**.

1. **caso A**: Sin sentencia **local** para la variable `NOMBRE`.

```bash
usuario@debian:~$ cat script.sh
    #!/bin/bash

    function dentro_variable_local() {
            NOMBRE="DENTRO"
            echo ${NOMBRE}
    }

    NOMBRE="FUERA"
    echo ${NOMBRE}

    dentro_variable_local
    echo ${NOMBRE}

usuario@debian:~$ ./script.sh
FUERA
DENTRO
DENTRO
```

2. **caso B**: Con sentencia **local** para la variable `NOMBRE`.

```bash
usuario@debian:~$ cat script.sh
    #!/bin/bash

    function dentro_variable_local() {
            local NOMBRE="DENTRO"
            echo ${NOMBRE}
    }

    NOMBRE="FUERA"
    echo ${NOMBRE}

    dentro_variable_local
    echo ${NOMBRE}

usuario@debian:~$ ./script.sh
FUERA
DENTRO
FUERA
```

En un script de shell en Linux, puedes definir variables locales y globales dentro de una función de la siguiente manera:

### Sin especificar nada (implícitamente global):

```bash
mi_funcion() {
    variable_global="Hola"
}
```

- **Descripción:** La variable **variable_global** será global y accesible desde cualquier parte del script después de llamar a **mi_funcion()**.

### Con `local`:

```bash
mi_funcion() {
    local variable_local="Mundo"
}
```

- **Descripción:** **variable_local** será local a la función **mi_funcion()** y no estará disponible fuera de ella.

### Con `declare`:

```bash
mi_funcion() {
    declare variable_local="Linux"
}
```

- **Descripción:** Similar a **local**, **variable_local** será local a la función **mi_funcion()** y no estará disponible fuera de ella. El uso de **declare** implica una forma más explícita de declarar variables en Bash.

### Con `declare -g`:

```bash
mi_funcion() {
    declare -g variable_global="Adiós"
}
```

- **Descripción:** **variable_global** será global, incluso si se define dentro de una función, y será accesible desde cualquier parte del script después de llamar a **mi_funcion()**.

#### Resumen:

- **Global (implícito):** Sin ninguna palabra clave, la variable es global.
- **Local:** Se define usando **local** o **declare** dentro de la función.
- **Global explícito:** Se usa **declare -g** para declarar una variable global dentro de una función.

## Diferencia entre el uso del operador [ y [[

Preferiblemente hacer uso de **[[]]** en lugar de **[] o test** ya que a diferencia de los **[]** los **[[]]**:

1. No tienen en cuenta el separador de campos IFS.

```bash
usuario@debian:~$ set | grep IFS | head -1
IFS=$' \t\n'
```

2. No tiene en cuenta el globbing o explansión de caracteres.
3. Permite el operador `=~` para comparar expresiones regulares.
4. El operador `-o` y `-a` empleados en `[] y test` no funcionan y se hace uso del `||` o `&&`.

En conclusión, usa `[[` siempre que sea posible, ya que es más seguro y potente. Sin embargo, si escribes scripts que deben ejecutarse en shells POSIX antiguos, entonces usa `[` para compatibilidad.

### Comando test o []

El comando `test` en Unix/Linux se utiliza para evaluar expresiones condicionales, normalmente dentro de scripts de shell. Permite verificar condiciones como la existencia de archivos, comparaciones de cadenas y valores numéricos, entre otras.

- **Sintaxis básica**:

```bash
test EXPRESION
```

- **Sintaxis alternativa (preferida en scripts)**:

```bash
[ EXPRESION ]
```

#### Opciones `-n` y `-z`

Estas opciones se utilizan para evaluar el estado de las cadenas de texto.

- **-n STRING**: Evalúa si la longitud de **STRING** es mayor que cero (es decir, si la cadena no está vacía).
- **-z STRING**: Evalúa si la longitud de **STRING** es igual a cero (es decir, si la cadena está vacía).

#### Ejemplos

1. **Usando `-n` para verificar si una cadena no está vacía**:

   ```bash
   cadena="Hola"
   if [ -n "$cadena" ]; then
     echo "La cadena no está vacía"
   else
     echo "La cadena está vacía"
   fi
   ```

   - **Resultado**: `La cadena no está vacía` (porque `cadena` contiene "Hola").

2. **Usando `-z` para verificar si una cadena está vacía**:

   ```bash
   cadena=""
   if [ -z "$cadena" ]; then
     echo "La cadena está vacía"
   else
     echo "La cadena no está vacía"
   fi
   ```

   - **Resultado**: `La cadena está vacía` (porque `cadena` no contiene ningún valor).

#### Ejemplos más completos

3. **Comparación de cadenas**:

   ```bash
   cadena1="Hola"
   cadena2=""

   if [ -n "$cadena1" ]; then
     echo "cadena1 no está vacía"
   else
     echo "cadena1 está vacía"
   fi

   if [ -z "$cadena2" ]; then
     echo "cadena2 está vacía"
   else
     echo "cadena2 no está vacía"
   fi
   ```

   - **Resultado**:
     ```
     cadena1 no está vacía
     cadena2 está vacía
     ```

4. **Combinar condiciones**:

   ```bash
   cadena1="Hola"
   cadena2="Mundo"

   if [ -n "$cadena1" ] && [ -n "$cadena2" ]; then
     echo "Ambas cadenas no están vacías"
   else
     echo "Una de las cadenas está vacía"
   fi
   ```

   - **Resultado**: `Ambas cadenas no están vacías` (porque ambas cadenas contienen texto).

Como resumen podemos decir que:

- `test -n STRING` o `[ -n STRING ]` verifica si `STRING` no está vacía.
- `test -z STRING` o `[ -z STRING ]` verifica si `STRING` está vacía.

Estos comandos son útiles en scripts de shell para tomar decisiones basadas en el contenido de las cadenas.

Existen otras opciones del comando `test` muy comunes, a continuación se muestran varios ejemplo:

| **Opción** | **Descripción**                                                | **Ejemplo**                                                                 |
| ---------- | -------------------------------------------------------------- | --------------------------------------------------------------------------- |
| `-n`       | Evalúa si la longitud de una cadena es mayor que cero.         | `[ -n "$cadena" ]` (verdadero si `cadena` no está vacía)                    |
| `-z`       | Evalúa si la longitud de una cadena es igual a cero.           | `[ -z "$cadena" ]` (verdadero si `cadena` está vacía)                       |
| `-r`       | Evalúa si un archivo existe y tiene permiso de lectura.        | `[ -r "$archivo" ]` (verdadero si `archivo` es legible)                     |
| `-w`       | Evalúa si un archivo existe y tiene permiso de escritura.      | `[ -w "$archivo" ]` (verdadero si `archivo` es escribible)                  |
| `-x`       | Evalúa si un archivo existe y tiene permiso de ejecución.      | `[ -x "$archivo" ]` (verdadero si `archivo` es ejecutable)                  |
| `-f`       | Evalúa si un archivo existe y es un archivo regular.           | `[ -f "$archivo" ]` (verdadero si `archivo` es un archivo regular)          |
| `-d`       | Evalúa si un archivo existe y es un directorio.                | `[ -d "$directorio" ]` (verdadero si `directorio` es un directorio)         |
| `-e`       | Evalúa si un archivo existe.                                   | `[ -e "$archivo" ]` (verdadero si `archivo` existe)                         |
| `-s`       | Evalúa si un archivo existe y no está vacío.                   | `[ -s "$archivo" ]` (verdadero si `archivo` tiene tamaño mayor que cero)    |
| `-eq`      | Compara dos números si son iguales.                            | `[ "$a" -eq "$b" ]` (verdadero si `a` es igual a `b`)                       |
| `-ne`      | Compara dos números si son diferentes.                         | `[ "$a" -ne "$b" ]` (verdadero si `a` no es igual a `b`)                    |
| `-lt`      | Compara dos números si el primero es menor que el segundo.     | `[ "$a" -lt "$b" ]` (verdadero si `a` es menor que `b`)                     |
| `-le`      | Compara dos números si el primero es menor o igual al segundo. | `[ "$a" -le "$b" ]` (verdadero si `a` es menor o igual a `b`)               |
| `-gt`      | Compara dos números si el primero es mayor que el segundo.     | `[ "$a" -gt "$b" ]` (verdadero si `a` es mayor que `b`)                     |
| `-ge`      | Compara dos números si el primero es mayor o igual al segundo. | `[ "$a" -ge "$b" ]` (verdadero si `a` es mayor o igual a `b`)               |
| `=`        | Compara si dos cadenas son iguales.                            | `[ "$cadena1" = "$cadena2" ]` (verdadero si las cadenas son iguales)        |
| `!=`       | Compara si dos cadenas son diferentes.                         | `[ "$cadena1" != "$cadena2" ]` (verdadero si las cadenas son diferentes)    |
| `-o`       | Operador lógico OR (usado dentro de corchetes `[ ... ]`).      | `[ -f "$archivo" -o -d "$directorio" ]` (verdadero si cualquiera es cierto) |
| `-a`       | Operador lógico AND (usado dentro de corchetes `[ ... ]`).     | `[ -f "$archivo" -a -d "$directorio" ]` (verdadero si ambos son ciertos)    |
| `!`        | Negación, evalúa si la condición no es verdadera.              | `[ ! -f "$archivo" ]` (verdadero si `archivo` no existe)                    |

En el caso de hacer uso del `[[]]` la tabla resultante sería la siguiente:

| Opción | Descripción                                                    | Ejemplo                          |
| :----- | :------------------------------------------------------------- | :------------------------------- |
| `-n`   | Evalúa si la longitud de una cadena es mayor que cero.         | `[[ -n "$cadena" ]]`             |
| `-z`   | Evalúa si la longitud de una cadena es igual a cero.           | `[[ -z "$cadena" ]]`             |
| `-r`   | Evalúa si un archivo existe y tiene permiso de lectura.        | `[[ -r "$archivo" ]]`            |
| `-w`   | Evalúa si un archivo existe y tiene permiso de escritura.      | `[[ -w "$archivo" ]]`            |
| `-x`   | Evalúa si un archivo existe y tiene permiso de ejecución.      | `[[ -x "$archivo" ]]`            |
| `-f`   | Evalúa si un archivo existe y es un archivo regular.           | `[[ -f "$archivo" ]]`            |
| `-d`   | Evalúa si un archivo existe y es un directorio.                | `[[ -d "$directorio" ]]`         |
| `-e`   | Evalúa si un archivo existe.                                   | `[[ -e "$archivo" ]]`            |
| `-s`   | Evalúa si un archivo existe y no está vacío.                   | `[[ -s "$archivo" ]]`            |
| `-eq`  | Compara dos números si son iguales.                            | `[[ "$a" -eq "$b" ]]`            |
| `-ne`  | Compara dos números si son diferentes.                         | `[[ "$a" -ne "$b" ]]`            |
| `-lt`  | Compara dos números si el primero es menor que el segundo.     | `[[ "$a" -lt "$b" ]]`            |
| `-le`  | Compara dos números si el primero es menor o igual al segundo. | `[[ "$a" -le "$b" ]]`            |
| `-gt`  | Compara dos números si el primero es mayor que el segundo.     | `[[ "$a" -gt "$b" ]]`            |
| `-ge`  | Compara dos números si el primero es mayor o igual al segundo. | `[[ "$a" -ge "$b" ]]`            |
| `=`    | Compara si dos cadenas son iguales.                            | `[[ "$cadena1" = "$cadena2" ]]`  |
| `!=`   | Compara si dos cadenas son diferentes.                         | `[[ "$cadena1" != "$cadena2" ]]` |
| `-o`   | Operador lógico OR.                                            | `[[ cond1 \|\| cond2 ]]`         |
| `-a`   | Operador lógico AND.                                           | `[[ cond1 && cond2 ]]`           |
| `!`    | Negación, evalúa si la condición no es verdadera.              | `[[ ! -f "$archivo" ]]`          |

#### Ejemplos de uso

1. **Verificar si una cadena no está vacía**:

   ```bash
   cadena="Hola"
   if [ -n "$cadena" ]; then
     echo "La cadena no está vacía"
   fi
   ```

2. **Verificar si una cadena está vacía**:

   ```bash
   cadena=""
   if [ -z "$cadena" ]; then
     echo "La cadena está vacía"
   fi
   ```

3. **Verificar si un archivo es legible**:

   ```bash
   archivo="/path/to/file"
   if [ -r "$archivo" ]; then
     echo "El archivo es legible"
   fi
   ```

4. **Verificar si un archivo es escribible**:

   ```bash
   archivo="/path/to/file"
   if [ -w "$archivo" ]; then
     echo "El archivo es escribible"
   fi
   ```

5. **Verificar si un archivo es ejecutable**:

   ```bash
   archivo="/path/to/file"
   if [ -x "$archivo" ]; then
     echo "El archivo es ejecutable"
   fi
   ```

6. **Verificar si un archivo es un archivo regular**:

   ```bash
   archivo="/path/to/file"
   if [ -f "$archivo" ]; then
     echo "El archivo es un archivo regular"
   fi
   ```

7. **Verificar si un archivo es un directorio**:

   ```bash
   directorio="/path/to/directory"
   if [ -d "$directorio" ]; then
     echo "El directorio existe"
   fi
   ```

8. **Verificar si un archivo existe**:

   ```bash
   archivo="/path/to/file"
   if [ -e "$archivo" ]; then
     echo "El archivo existe"
   fi
   ```

9. **Verificar si un archivo no está vacío**:
   ```bash
   archivo="/path/to/file"
   if [ -s "$archivo" ]; then
     echo "El archivo no está vacío"
   fi
   ```

Estas opciones son muy útiles para escribir scripts de shell que necesiten realizar comprobaciones de condiciones antes de ejecutar ciertas operaciones.

## Variables especiales en un script

A continuación se muestra una breve descripción de cada una de estas variables especiales dentro de un script de shell, presentadas en forma de tabla:

| **Variable**  | **Descripción**                                                                                                                    | **Ejemplo**          |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------- | -------------------- |
| `$0`          | Nombre del script (o programa) ejecutado.                                                                                          | `echo $0`            |
| `$1, $2, ...` | Parámetros posicionales. `$1` es el primer parámetro, `$2` el segundo, y así sucesivamente.                                        | `echo $1`, `echo $2` |
| `$#`          | Número de argumentos pasados al script.                                                                                            | `echo $#`            |
| `$?`          | Código de salida del último comando ejecutado. 0 indica éxito, otros valores indican error.                                        | `echo $?`            |
| `$$`          | PID (Identificador de Proceso) del script en ejecución.                                                                            | `echo $$`            |
| `$*`          | Todos los argumentos pasados al script como una sola cadena, separados por el primer caracter de `IFS` (Internal Field Separator). | `echo "$*"`          |
| `$@`          | Todos los argumentos pasados al script como una lista de palabras separadas por un espacio.                                        | `echo "$@"`          |
| `${@:4}`      | Expansión que devuelve los argumentos desde el cuarto en adelante como una única cadena.                                           | `echo "${@:4}"`      |
| `${@:4:2}`    | Expansión que devuelve dos argumentos empezando desde el cuarto (el cuarto y el quinto argumento).                                 | `echo "${@:4:2}"`    |

Estas variables son fundamentales para manipular la entrada, salida y estado de un script de shell en ejecución.

Un ejemplo de uso de varias de las anteriores variables especiales sería el siguiente script.

```bash
#!/bin/bash
echo "El nombre del script es $0 y el ID del proceso es $$"
echo "El número de parámetros es $#"
echo "El primer parámetro es $1"
echo "El segundo parámetro es $2"
echo "El tercer parámetro es $3"
echo "Una forma de ver todos los parámetros es $*"
echo "Otra forma de ver todos los parámetros es $@"
```

```bash
usuario@debian:~$ ./script.sh Martín Gil Blanco
El nombre del script es ./script.sh y el ID del proceso es 4095
El número de parámetros es 3
El primer parámetro es Martín
El segundo parámetro es Gil
El tercer parámetro es Blanco
Una forma de ver todos los parámetros es Martín:Gil:Blanco
Otra forma de ver todos los parámetros es Martín Gil Blanco
```

## Variables PS

Las variables PS (que significan Prompt String) son variables de entorno en Linux (específicamente en la shell Bash) que controlan la apariencia y el comportamiento del "prompt" o línea de comandos. Básicamente, definen qué símbolos o textos ves cuando la terminal te está pidiendo que introduzcas información.

Existen 4 variables principales: PS1, PS2, PS3 y PS4. Aquí te explico cada una con ejemplos claros:

| Variable | Uso                                                | Símbolo Típico |
| :------- | :------------------------------------------------- | :------------- |
| **PS1**  | **Principal**: Esperando comandos normales.        | `$` o `#`      |
| **PS2**  | **Continuación**: Comando incompleto (multilínea). | `>`            |
| **PS3**  | **Selección**: Usado en menús `select` de scripts. | `#?`           |
| **PS4**  | **Debug**: Traza de ejecución (modo `set -x`).     | `+`            |

### Ejemplos de edición y personalización

A continuación vamos a editar las variables PS de nuestro terminal.

#### 1. Editar PS1 (Tu prompt principal)

Cambiaremos el prompt clásico para que muestre la hora y tenga una flecha personalizada.

```bash
# \t = hora actual
# \u = nombre de usuario
# \w = directorio actual
export PS1="[\t] \u en \w -> "

```

_Resultado:_

```bash
usuario@debian:~$ export PS1="[\t] \u en \w -> "
[15:49:50] usuario en ~ -> whoami
usuario
```

#### 2. Editar PS2 (El prompt de continuación)

Cambiaremos el símbolo `>` por algo más visible para cuando escribas comandos largos que ocupan varias líneas.

```bash
export PS2="...continuando... "

# Pruébalo escribiendo: echo "hola (y pulsa Enter sin cerrar la comilla)

```

_Resultado:_

```bash
usuario@debian:~$ echo "Hola
...continuando... adios"
Hola
adios
```

#### 3. Editar PS3 (El prompt de menús)

Este es útil dentro de scripts. Vamos a crear un pequeño "one-liner" para probarlo en la terminal:

```bash
# Definimos el prompt de pregunta
export PS3="¿Cuál es tu color favorito? (Elige número): "

# Creamos un menú rápido
select color in Rojo Verde Azul; do echo "Elegiste $color"; break; done

```

_Resultado:_

```bash
1) Rojo
2) Verde
3) Azul
¿Cuál es tu color favorito? (Elige número):

```

#### 4. Editar PS4 (El prompt de depuración)

Este es el más útil para programadores. Por defecto es solo un `+`, pero podemos configurarlo para que nos diga **el archivo y la línea exacta** donde se ejecuta el comando.

_Nota: Es importante usar comillas simples `' '` para que `$LINENO` se evalúe al ejecutarse, no al definirse._

```bash
# Configuramos para ver: [nombre_script][numero_linea]
export PS4='[$0:$LINENO] + '

# Activamos el modo debug para probarlo
set -x
ls -l /tmp
set +x # Desactivamos debug

```

_Resultado:_

```bash
[bash:42] + ls -l /tmp
```
