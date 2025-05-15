# Scripts en linux

Un script en Linux es un archivo de texto plano que contiene una secuencia de comandos o instrucciones escritas para ser ejecutadas por un intérprete de comandos, como Bash, en sistemas Unix o Linux. Estos archivos permiten automatizar tareas, gestionar procesos complejos y ejecutar múltiples comandos de manera secuencial sin intervención manual.

## Ejecución de un script

Los scripts tienen una primera linea, el *shebang*, también conocido como hashbang o sha-bang, es una convención en sistemas operativos tipo Unix que se utiliza en scripts para indicar qué intérprete de comandos debe ser utilizado para ejecutar el script. El shebang consiste en los caracteres "#!" seguidos de la ruta al intérprete. Por ejemplo:

- En scripts bash:

```bash
#!/bin/bash
```

- En scripts python:

```bash
#!/usr/bin/env python3
#!/usr/bin/env python
```

- `chmod -x env.sh && bash env.sh`: Si ejecutamos bash env.sh, no es necesario tener permisos de ejecución en el script y estamos `ejecutando el script en una subshell`, por lo que al finalizar el script se elimina la subshell.

- `chmod +x env.sh && ./env.sh`: Si el shebang es #!/bin/bash y lo ejecutamos mediante ./env.sh, siempre y cuando el script tenga permisos de ejecución, estamos `ejecutando el script en una subshell`, por lo que al finalizar el script se elimina la subshell. Es análogo a la ejecución mediante el comando bash.

- `chmod -x env.sh && . ./env.sh`: Si ejecutamos mediante . ./env.sh o source ./env.sh, no es necesario tener permisos de ejecución y estamos `ejecutando el script en la shell actual`.

Es fundamental comprender de que forma se ejecutan nuestros scripts para poder comprender si van a modificar aspectos de nuestro entorno o no. En el siguiente ejemplo podemos apreciar como el nivel de shell que es diferente en función de como lanzamos nuestro script.

Script `env-ejemplo1.sh`

```bash
#!/bin/bash
env | sort | grep -v '^_' | tee env1.txt
```

Si ejecutamos con las opciones 1 o 2, es decir, con `bash` o con `./` se ejecutará el script en una subshell por lo que no afectará a mi entorno.

Podemos ver que al lanzarlo con `bash` (o con `./`) estamos en el nivel de shell 1.

```bash
si@si-VirtualBox:~$ bash env-ejemplo1.sh
COLORTERM=truecolor
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
DESKTOP_SESSION=ubuntu
DISPLAY=:0
GDMSESSION=ubuntu
...

si@si-VirtualBox:~$ cat env1.txt | grep SHLVL
SHLVL=1
```

En este caso, ejecutamos directamente el comando y podemos ver que estamos en el nivel de shell 0, es decir, el mismo nivel de shell donde lanzamos comandos. Esto quiere decir que las modificaciones de este comando si podrían afectar a mi entorno a diferencia del caso anterior.

```bash
si@si-VirtualBox:~$ env | sort | grep -v '^_' | tee env2.txt
COLORTERM=truecolor
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
DESKTOP_SESSION=ubuntu
DISPLAY=:0
GDMSESSION=ubuntu
...

si@si-VirtualBox:~$ cat env2.txt | grep SHLVL
SHLVL=0
```

```bash
si@si-VirtualBox:~$ source env-ejemplo1.sh
COLORTERM=truecolor
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
DESKTOP_SESSION=ubuntu
DISPLAY=:0
GDMSESSION=ubuntu
...

si@si-VirtualBox:~$ cat env1.txt | grep SHLVL
SHLVL=0
```

Este es el motivo por el cual cuando queremos modificar nuestro entorno se hace uso de ficheros como `.bashrc` y este se lanza con `source`. El objetivo es hacer una modificación de nuestro entorno.

Cargamos .bashrc con `.` por lo tanto al ser lo mismo que `source` se convierten en variables de entorno las variables definidas dentro a las que se le aplica un `export`.

```bash
si@si-VirtualBox:~$ cat .profile | grep ".bashrc"
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
```

## Variables locales y globales en un script

`global, local`

Todas las variables en los scripts bash, a menos que se definan de otra manera, son globales, es decir, una vez definidas pueden ser utilizadas en cualquier parte del script. Para que una variable sea local, es decir, tenga sentido solamente dentro de una sección del script, como en una función, y no en todo el script, debe ser precedida por la sentencia: local.

1. `caso A`: Sin sentencia local para la variable `NOMBRE`.

```bash
si@si-VirtualBox:~$ cat script.sh
    #!/bin/bash

    function dentro_variable_local() {
            NOMBRE="DENTRO"
            echo ${NOMBRE}
    }

    NOMBRE="FUERA"
    echo ${NOMBRE}

    dentro_variable_local
    echo ${NOMBRE}

si@si-VirtualBox:~$ ./script.sh
FUERA
DENTRO
DENTRO
```

2. `caso B`: Con sentencia local para la variable `NOMBRE`.

```bash
si@si-VirtualBox:~$ cat script.sh
    #!/bin/bash

    function dentro_variable_local() {
            local NOMBRE="DENTRO"
            echo ${NOMBRE}
    }

    NOMBRE="FUERA"
    echo ${NOMBRE}

    dentro_variable_local
    echo ${NOMBRE}

si@si-VirtualBox:~$ ./script.sh
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

- **Descripción:** La variable `variable_global` será global y accesible desde cualquier parte del script después de llamar a `mi_funcion()`.

### Con `local`:

```bash
mi_funcion() {
    local variable_local="Mundo"
}
```

- **Descripción:** `variable_local` será local a la función `mi_funcion()` y no estará disponible fuera de ella.

### Con `declare`:

```bash
mi_funcion() {
    declare variable_local="Linux"
}
```

- **Descripción:** Similar a `local`, `variable_local` será local a la función `mi_funcion()` y no estará disponible fuera de ella. `declare` es una forma más explícita de declarar variables en Bash.

### Con `declare -g`:

```bash
mi_funcion() {
    declare -g variable_global="Adiós"
}
```

- **Descripción:** `variable_global` será global, incluso si se define dentro de una función, y será accesible desde cualquier parte del script después de llamar a `mi_funcion()`.

#### Resumen:

- **Global (implícito):** Sin ninguna palabra clave, la variable es global.
- **Local:** Se define usando `local` o `declare` dentro de la función.
- **Global explícito:** Se usa `declare -g` para declarar una variable global dentro de una función.

## Diferencia entre el uso del operador [ y [[

Preferiblemente hacer uso de `[[]]` en lugar de `[] o test` ya que a diferencia de los `[]` los `[[]]`:
1. No tienen en cuenta el separador de campos IFS.
```bash
┌──(kali㉿kali)-[~]
└─$ declare | grep IFS
IFS=$' \t\n\C-@'
```
2. No tiene en cuenta el globbing o explansión de caracteres.
3. Permite el operador `=~` para comparar expresiones regulares.
4. El operador `-o` y `-a` empleados en `[] y test` no funcionan y se hace uso del `||` o `&&`.

En conclusión, usa `[[` siempre que sea posible, ya que es más seguro y potente. Sin embargo, si escribes scripts que deben ejecutarse en shells POSIX antiguos, entonces usa `[` para compatibilidad.

### Comando test o []

El comando `test` en Unix/Linux se utiliza para evaluar expresiones condicionales, normalmente dentro de scripts de shell. Permite verificar condiciones como la existencia de archivos, comparaciones de cadenas y valores numéricos, entre otras.

- **Sintaxis básica**:
  ```sh
  test EXPRESION
  ```
- **Sintaxis alternativa (preferida en scripts)**:
  ```sh
  [ EXPRESION ]
  ```

#### Opciones `-n` y `-z`

Estas opciones se utilizan para evaluar el estado de las cadenas de texto.

- **`-n STRING`**: Evalúa si la longitud de `STRING` es mayor que cero (es decir, si la cadena no está vacía).
- **`-z STRING`**: Evalúa si la longitud de `STRING` es igual a cero (es decir, si la cadena está vacía).

#### Ejemplos

1. **Usando `-n` para verificar si una cadena no está vacía**:

   ```sh
   cadena="Hola"
   if [ -n "$cadena" ]; then
     echo "La cadena no está vacía"
   else
     echo "La cadena está vacía"
   fi
   ```

   - **Resultado**: `La cadena no está vacía` (porque `cadena` contiene "Hola").

2. **Usando `-z` para verificar si una cadena está vacía**:
   ```sh
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

   ```sh
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

   ```sh
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

| **Opción** | **Descripción**                                           | **Ejemplo**                                                              |
| ---------- | --------------------------------------------------------- | ------------------------------------------------------------------------ |
| `-n`       | Evalúa si la longitud de una cadena es mayor que cero.    | `[ -n "$cadena" ]` (verdadero si `cadena` no está vacía)                 |
| `-z`       | Evalúa si la longitud de una cadena es igual a cero.      | `[ -z "$cadena" ]` (verdadero si `cadena` está vacía)                    |
| `-r`       | Evalúa si un archivo existe y tiene permiso de lectura.   | `[ -r "$archivo" ]` (verdadero si `archivo` es legible)                  |
| `-w`       | Evalúa si un archivo existe y tiene permiso de escritura. | `[ -w "$archivo" ]` (verdadero si `archivo` es escribible)               |
| `-x`       | Evalúa si un archivo existe y tiene permiso de ejecución. | `[ -x "$archivo" ]` (verdadero si `archivo` es ejecutable)               |
| `-f`       | Evalúa si un archivo existe y es un archivo regular.      | `[ -f "$archivo" ]` (verdadero si `archivo` es un archivo regular)       |
| `-d`       | Evalúa si un archivo existe y es un directorio.           | `[ -d "$directorio" ]` (verdadero si `directorio` es un directorio)      |
| `-e`       | Evalúa si un archivo existe.                              | `[ -e "$archivo" ]` (verdadero si `archivo` existe)                      |
| `-s`       | Evalúa si un archivo existe y no está vacío.              | `[ -s "$archivo" ]` (verdadero si `archivo` tiene tamaño mayor que cero) |
| `-eq`      | Compara dos números si son iguales.                       | `[ "$a" -eq "$b" ]` (verdadero si `a` es igual a `b`)                    |
| `-ne`      | Compara dos números si son diferentes.                    | `[ "$a" -ne "$b" ]` (verdadero si `a` no es igual a `b`)                 |
| `-lt`      | Compara dos números si el primero es menor que el segundo.| `[ "$a" -lt "$b" ]` (verdadero si `a` es menor que `b`)                  |
| `-le`      | Compara dos números si el primero es menor o igual al segundo.| `[ "$a" -le "$b" ]` (verdadero si `a` es menor o igual a `b`)            |
| `-gt`      | Compara dos números si el primero es mayor que el segundo.| `[ "$a" -gt "$b" ]` (verdadero si `a` es mayor que `b`)                  |
| `-ge`      | Compara dos números si el primero es mayor o igual al segundo.| `[ "$a" -ge "$b" ]` (verdadero si `a` es mayor o igual a `b`)            |
| `=`        | Compara si dos cadenas son iguales.                       | `[ "$cadena1" = "$cadena2" ]` (verdadero si las cadenas son iguales)     |
| `!=`       | Compara si dos cadenas son diferentes.                    | `[ "$cadena1" != "$cadena2" ]` (verdadero si las cadenas son diferentes) |
| `-o`       | Operador lógico OR (usado dentro de corchetes `[ ... ]`).  | `[ -f "$archivo" -o -d "$directorio" ]` (verdadero si cualquiera es cierto)|
| `-a`       | Operador lógico AND (usado dentro de corchetes `[ ... ]`). | `[ -f "$archivo" -a -d "$directorio" ]` (verdadero si ambos son ciertos) |
| `!`        | Negación, evalúa si la condición no es verdadera.         | `[ ! -f "$archivo" ]` (verdadero si `archivo` no existe)                |

En el caso de hacer uso del `[[]]` la tabla resultante sería la siguiente:

| **Opción** | **Descripción**                                           | **Ejemplo**                                                              |
| ---------- | --------------------------------------------------------- | ------------------------------------------------------------------------ |
| `-n`       | Evalúa si la longitud de una cadena es mayor que cero.    | `[[ -n "$cadena" ]]` (verdadero si `cadena` no está vacía)               |
| `-z`       | Evalúa si la longitud de una cadena es igual a cero.      | `[[ -z "$cadena" ]]` (verdadero si `cadena` está vacía)                  |
| `-r`       | Evalúa si un archivo existe y tiene permiso de lectura.   | `[[ -r "$archivo" ]]` (verdadero si `archivo` es legible)                |
| `-w`       | Evalúa si un archivo existe y tiene permiso de escritura. | `[[ -w "$archivo" ]]` (verdadero si `archivo` es escribible)             |
| `-x`       | Evalúa si un archivo existe y tiene permiso de ejecución. | `[[ -x "$archivo" ]]` (verdadero si `archivo` es ejecutable)             |
| `-f`       | Evalúa si un archivo existe y es un archivo regular.      | `[[ -f "$archivo" ]]` (verdadero si `archivo` es un archivo regular)     |
| `-d`       | Evalúa si un archivo existe y es un directorio.           | `[[ -d "$directorio" ]]` (verdadero si `directorio` es un directorio)    |
| `-e`       | Evalúa si un archivo existe.                              | `[[ -e "$archivo" ]]` (verdadero si `archivo` existe)                    |
| `-s`       | Evalúa si un archivo existe y no está vacío.              | `[[ -s "$archivo" ]]` (verdadero si `archivo` tiene tamaño mayor que cero)|
| `-eq`      | Compara dos números si son iguales.                       | `[[ "$a" -eq "$b" ]]` (verdadero si `a` es igual a `b`)                  |
| `-ne`      | Compara dos números si son diferentes.                    | `[[ "$a" -ne "$b" ]]` (verdadero si `a` no es igual a `b`)               |
| `-lt`      | Compara dos números si el primero es menor que el segundo.| `[[ "$a" -lt "$b" ]]` (verdadero si `a` es menor que `b`)                |
| `-le`      | Compara dos números si el primero es menor o igual al segundo.| `[[ "$a" -le "$b" ]]` (verdadero si `a` es menor o igual a `b`)          |
| `-gt`      | Compara dos números si el primero es mayor que el segundo.| `[[ "$a" -gt "$b" ]]` (verdadero si `a` es mayor que `b`)                |
| `-ge`      | Compara dos números si el primero es mayor o igual al segundo.| `[[ "$a" -ge "$b" ]]` (verdadero si `a` es mayor o igual a `b`)          |
| `=`        | Compara si dos cadenas son iguales.                       | `[[ "$cadena1" = "$cadena2" ]]` (verdadero si las cadenas son iguales)   |
| `!=`       | Compara si dos cadenas son diferentes.                    | `[[ "$cadena1" != "$cadena2" ]]` (verdadero si las cadenas son diferentes) |
| `-o`       | Operador lógico OR (usado dentro de corchetes `[[ ... ]]`).| `[[ -f "$archivo" || -d "$directorio" ]]` (verdadero si cualquiera es cierto)|
| `-a`       | Operador lógico AND (usado dentro de corchetes `[[ ... ]]`).| `[[ -f "$archivo" && -d "$directorio" ]]` (verdadero si ambos son ciertos) |
| `!`        | Negación, evalúa si la condición no es verdadera.         | `[[ ! -f "$archivo" ]]` (verdadero si `archivo` no existe)              |


#### Ejemplos de uso

1. **Verificar si una cadena no está vacía**:

   ```sh
   cadena="Hola"
   if [ -n "$cadena" ]; then
     echo "La cadena no está vacía"
   fi
   ```

2. **Verificar si una cadena está vacía**:

   ```sh
   cadena=""
   if [ -z "$cadena" ]; then
     echo "La cadena está vacía"
   fi
   ```

3. **Verificar si un archivo es legible**:

   ```sh
   archivo="/path/to/file"
   if [ -r "$archivo" ]; then
     echo "El archivo es legible"
   fi
   ```

4. **Verificar si un archivo es escribible**:

   ```sh
   archivo="/path/to/file"
   if [ -w "$archivo" ]; then
     echo "El archivo es escribible"
   fi
   ```

5. **Verificar si un archivo es ejecutable**:

   ```sh
   archivo="/path/to/file"
   if [ -x "$archivo" ]; then
     echo "El archivo es ejecutable"
   fi
   ```

6. **Verificar si un archivo es un archivo regular**:

   ```sh
   archivo="/path/to/file"
   if [ -f "$archivo" ]; then
     echo "El archivo es un archivo regular"
   fi
   ```

7. **Verificar si un archivo es un directorio**:

   ```sh
   directorio="/path/to/directory"
   if [ -d "$directorio" ]; then
     echo "El directorio existe"
   fi
   ```

8. **Verificar si un archivo existe**:

   ```sh
   archivo="/path/to/file"
   if [ -e "$archivo" ]; then
     echo "El archivo existe"
   fi
   ```

9. **Verificar si un archivo no está vacío**:
   ```sh
   archivo="/path/to/file"
   if [ -s "$archivo" ]; then
     echo "El archivo no está vacío"
   fi
   ```

Estas opciones son muy útiles para escribir scripts de shell que necesiten realizar comprobaciones de condiciones antes de ejecutar ciertas operaciones.