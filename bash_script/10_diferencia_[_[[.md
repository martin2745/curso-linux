# Diferencia entre [ y [[

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

## Comando test o []

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
