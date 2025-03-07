### arrays en bash

#### declarar arrays

Para declarar un array podemos hacerlo de varias maneras.

- `declare -a`: Utilizado para declarar una variable como un array en Bash. Esto significa que la variable podrá contener múltiples valores, accesibles a través de índices numéricos. Esta opción es útil para asegurar que una variable se comporte como un array, incluso si no contiene valores al principio.

```bash
si@si-VirtualBox:~$ vectorUno[0]=nuevo

si@si-VirtualBox:~$ declare -p | tail -3
declare -- snap_bin_path="/snap/bin"
declare -- snap_xdg_path="/var/lib/snapd/desktop"
declare -a vectorUno=([0]="nuevo")

si@si-VirtualBox:~$ vectorUno[1]=nuevo2
si@si-VirtualBox:~$ vectorUno[3]=3

si@si-VirtualBox:~$ declare -p | tail -3
declare -- snap_bin_path="/snap/bin"
declare -- snap_xdg_path="/var/lib/snapd/desktop"
declare -a vectorUno=([0]="nuevo" [1]="nuevo2" [3]="3")
```

```bash
si@si-VirtualBox:~$ vectorDos=(uno dos tres)
si@si-VirtualBox:~$ declare -p vectorDos
declare -a vectorDos=([0]="uno" [1]="dos" [2]="tres")
```

```bash
si@si-VirtualBox:~$ vectorTres=([0]=Uno [1]=Dos [4]=Cuatro)
si@si-VirtualBox:~$ declare -p vectorTres
declare -a vectorTres=([0]="Uno" [1]="Dos" [4]="Cuatro")
```

```bash
si@si-VirtualBox:~$ declare -a vectorCuatro[0]=Hola
si@si-VirtualBox:~$ echo ${vectorCuatro[0]}
Hola
```

- `declare -p`: Esta opción muestra información sobre una o más variables, incluyendo su tipo y valor. Es útil para depurar y entender el estado de las variables en un script de Bash.

```bash
si@si-VirtualBox:~$ declare -p vectorUno
declare -a vectorUno=([0]="nuevo" [1]="nuevo2" [3]="3")
```

- `local` es una palabra clave que se utiliza dentro de funciones para declarar variables locales. Esto significa que las variables definidas como locales solo son visibles y accesibles dentro de la función donde se declaran, y no afectan a variables con el mismo nombre fuera de la función. Por ejemplo:

```bash
mi_funcion() {
    local variable_local="Este es un valor local"
    echo "Dentro de la función: $variable_local"
}

mi_funcion
echo "Fuera de la función: $variable_local"  # Esto mostrará un valor vacío o error, ya que $variable_local no está definido fuera de la función
```

- `local -a` es una variante de `local` que se utiliza para declarar variables locales como arrays. Esto asegura que la variable declarada sea tratada como un array dentro de la función. Por ejemplo:

```bash
mi_funcion() {
    local -a array_local
    array_local=("elemento1" "elemento2" "elemento3")
    echo "Dentro de la función: ${array_local[@]}"
}

mi_funcion
echo "Fuera de la función: ${array_local[@]}"  # Esto mostrará un valor vacío o error, ya que $array_local no está definido fuera de la función
```

#### Referenciar Arrays

- `${nombre[índice]}` donde nombre es el nombre del array e índice es la posición entera que contiene su valor correspondiente.
- `${nombre[@]}` donde nombre es el nombre del array y el índice @ representa todos los elementos del vector. Devuelve una cadena con los elementos separados por espacio.
- `${nombre[*]}` donde nombre es el nombre del array y el índice \* representa todos los elementos del vector. Devuelve una cadena con los elementos separados por espacio.
- `"${nombre[@]}"` donde nombre es el nombre del array y el índice @ representa todos los elementos del vector. Devuelve una cadena con los elementos separados por espacio.
- `"${nombre[*]}"` donde nombre es el nombre del array y el índice \* representa todos los elementos del vector. Devuelve una cadena con los elementos separados por el primer caracter de la variable separador de campos IFS.
- `${nombre}` equivale a `${nombre[0]}`

```bash
$ nombre=(primero segundo tercero)
$ declare -p nombre
declare -a nombre=([0]="primero" [1]="segundo" [2]="tercero")

$ echo ${nombre[*]}
primero segundo tercero
$ echo "${nombre[*]}"
primero segundo tercero

$ set | grep ^IFS
IFS=$' \t\n'
$ IFS=$'Z\t\n'
$ set | grep IFS
IFS=$'Z\t\n'

$ echo ${nombre[*]}
primero segundo tercero
$ echo "${nombre[*]}"
primeroZsegundoZtercero

Es decir, a "${nombre[*]}" Le afecta el primer caracter de la variable separador de campos IFS.
```

#### Eliminar arrays

- `unset nombre`: Elimina el array declarado como `nombre` siempre que no esté declarado en modo lectura.
- `unset nombre[índice]`: Elimina el índice del array `nombre` en la posición [índice] siempre que no esté declarado en modo lectura.

#### Recorrer arrays

- Recorre los índices del array declarado como `nombre` y muestra cada valor en pantalla. Siempre utiliza comillas dobles para evitar errores de separadores como espacios que puedan existir en los valores de los índices.

```bash
for i in "${nombre[*]}"
do
echo $i
done
```

- Recorre los índices del array declarado como `nombre` y muestra cada valor en pantalla. Siempre utiliza comillas dobles para evitar errores de separadores como espacios que puedan existir en los valores de los índices.

```bash
for i in "${nombre[@]}"
do
echo $i
done
```

#### Longitud de los arrays e índices

```bash
echo ${#nombre[@]}
```

- Muestra el número de elementos existentes en el array declarado como `nombre`, es decir, proporciona el número de posiciones ocupadas en el array.

```bash
echo ${!nombre[@]}
```

- Muestra los índices de los elementos que no son NULOS en el array declarado como `nombre`.

```bash
echo ${#nombre[índice]}
```

- Muestra el número de caracteres de longitud del índice `índice` para el array declarado como `nombre`.

```bash
si@si-VirtualBox:~$ vector3=(uno dos tres)
si@si-VirtualBox:~$ echo ${vector3[*]}
uno dos tres
si@si-VirtualBox:~$ echo ${vector3[@]}
uno dos tres
si@si-VirtualBox:~$ echo ${vector3[0]}
uno
si@si-VirtualBox:~$ echo ${vector3}
uno
si@si-VirtualBox:~$ echo ${vector3[1]}
dos
si@si-VirtualBox:~$ echo ${vector3[2]}
tres
si@si-VirtualBox:~$ echo ${vector3[3]}

si@si-VirtualBox:~$ echo ${#vector3[@]}
3
si@si-VirtualBox:~$ echo ${!vector3[@]}
0 1 2
si@si-VirtualBox:~$ echo ${#vector3[0]}
3
si@si-VirtualBox:~$ echo ${#vector3[1]}
3
si@si-VirtualBox:~$ echo ${#vector3[2]}
4
```

#### Arrays como parámetros de funciones

En la llamada a la función utilizamos como parámetro la notación "nombre[@]", y dentro del cuerpo de la función utilizamos la referencia indirecta ${!número}, donde número es el número del parámetro en la llamada a la función: 1, 2, 3...

```bash
f_nombre() { # Definición de la función llamada f_nombre
    parametros=("${!1}") # Referencia indirecta del parámetro $1 dentro de la definición del array parametros
    echo "${parametros[@]}" # Muestra todos los valores contenidos en los índices del array llamado parametros
} # Fin del cuerpo de la función f_nombre

nombres=(Anxo Brais) # Se declara la variable array nombres con los valores Anxo y Brais en los índices 0 y 1 respectivamente.
f_nombre "nombres[@]" # Llamada a la ejecución de la función llamada f_nombre donde el primer parámetro $1 toma el valor "nombres[@]", lo cual es equivalente a los valores de todos los índices del array llamado nombres
```

---

### Prácticas sobre arrays

#### Declarar y eliminar arrays

Muestra el valor de la variable llamada "curso" y cómo está declarada en caso de existir.

```bash
declare -p curso
```

Crea automáticamente el array llamado "curso" donde en el índice 0 toma el valor '2015-2016'.

```bash
curso[0]='2015-2016'
```

Genera un nuevo array llamado "curso" donde los índices 0 y 1 toman los valores '2017-2018' y '2018-2019' respectivamente.

```bash
curso=('2017-2018' '2018-2019')
```

Aunque no existe el índice 2 en el array llamado "curso", la sintaxis del comando genera un nuevo array con solo un índice: el índice 2 que toma el valor '2019-2020'.

```bash
curso=([2]='2019-2020')
```

Genera un nuevo array llamado "curso" donde solo se hacen referencia en la declaración a los índices 0 y 5, por lo que el resto de los elementos del array irán guardando sus valores a partir del índice 5. Así, los índices 0, 5, 6 y 7 toman los valores '1111-1112', '1112-1113', '1113-1114' y '1114-1115' respectivamente.

```bash
curso=([0]='1111-1112' [5]='1112-1113' '1113-1114' '1114-1115')
```

Muestra el valor de la variable array llamada "curso" y cómo está declarada.

```bash
declare -p curso
```

Declara la variable array llamada "curso" en modo solo lectura.

```bash
declare -r curso
```

No puede eliminar la variable "curso" ya que está declarada en modo solo lectura.

```bash
unset curso
unset curso[@]
unset curso[*]
```

No puede eliminar el elemento de la posición 1 de la variable "curso" ya que está declarada en modo solo lectura.

```bash
unset curso[1]
```

_*Nota: No es lo mismo pedir por teclado unos datos para el array que pedir los datos para un índice concreto del array.*_

1. #### Pedir datos para un array

Lee desde la entrada estándar (teclado) una lista de palabras como índices en un array llamado "curso5", comenzando desde 0.

Los campos separadores de palabras, que serán recogidos en los índices del array, están determinados por el valor de la variable separador de campos $IFS.

```bash
read -p 'Escriba valores del array en una lista: ' -a curso5
```

Muestra el mensaje 'Escriba valores del array en una lista: ' y recoge desde la entrada estándar (teclado) la lista de palabras como índices en un array llamado curso5, empezando por 0. Los campos separadores de palabras, que serán recogidos en los índices del array, están determinados por el valor de la variable separador de campos $IFS.

```bash
1 2 3
```

Como el valor de IFS=$' \r\n' y el número de palabras de la lista insertada es 3, se sustituyen los valores de los índices 0, 1 y 2 por estos nuevos: 1, 2 y 3 respectivamente.

2. #### Pedir datos para una posición del array

Recoge por teclado el valor del índice 1 del array llamado "curso5".

```bash
read -p 'Escriba valor para el índice 1: ' curso5[1]
```

Asigna el valor '4 5 6' al índice 1, ya que en la asignación al índice no se tiene en cuenta la variable IFS.

```bash
4 5 6
```

---

### Comando test

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

---

### Variables locales y globales en un script

En un script de shell en Linux, puedes definir variables locales y globales dentro de una función de la siguiente manera:

#### Sin especificar nada (implícitamente global):

```bash
mi_funcion() {
    variable_global="Hola"
}
```

- **Descripción:** La variable `variable_global` será global y accesible desde cualquier parte del script después de llamar a `mi_funcion()`.

#### Con `local`:

```bash
mi_funcion() {
    local variable_local="Mundo"
}
```

- **Descripción:** `variable_local` será local a la función `mi_funcion()` y no estará disponible fuera de ella.

#### Con `declare`:

```bash
mi_funcion() {
    declare variable_local="Linux"
}
```

- **Descripción:** Similar a `local`, `variable_local` será local a la función `mi_funcion()` y no estará disponible fuera de ella. `declare` es una forma más explícita de declarar variables en Bash.

#### Con `declare -g`:

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

---

### Variables especiales en un script

A continuación se muestra una breve descripción de cada una de estas variables especiales dentro de un script de shell, presentadas en forma de tabla:

| **Variable**  | **Descripción**                                                                                                                         | **Ejemplo**          |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------- | -------------------- |
| `$0`          | Nombre del script (o programa) ejecutado.                                                                                               | `echo $0`            |
| `$1, $2, ...` | Parámetros posicionales. `$1` es el primer parámetro, `$2` el segundo, y así sucesivamente.                                             | `echo $1`, `echo $2` |
| `$#`          | Número de argumentos pasados al script.                                                                                                 | `echo $#`            |
| `$?`          | Código de salida del último comando ejecutado. 0 indica éxito, otros valores indican error.                                             | `echo $?`            |
| `$$`          | PID (Identificador de Proceso) del script en ejecución.                                                                                 | `echo $$`            |
| `$*`          | Todos los argumentos pasados al script como una sola cadena, separados por el primer caracter de `IFS` (Internal Field Separator).      | `echo "$*"`          |
| `$@`          | Todos los argumentos pasados al script como una lista de palabras separadas por el primer caracter de `IFS` (Internal Field Separator). | `echo "$@"`          |
| `${@:4}`      | Expansión que devuelve los argumentos desde el cuarto en adelante como una única cadena.                                                | `echo "${@:4}"`      |
| `${@:4:2}`    | Expansión que devuelve dos argumentos empezando desde el cuarto (el cuarto y el quinto argumento).                                      | `echo "${@:4:2}"`    |

Estas variables son fundamentales para manipular la entrada, salida y estado de un script de shell en ejecución.

---

#### En la siguiente ruta podrá encontrar explicaciones relacionadas con scripting en bash

[Apuntes de Linux y bash](../libros%20de%20linux/APUNTES_LINUX.md)
