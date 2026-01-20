# arrays en bash

## Teoría de arrays

### declarar arrays

Para declarar un array podemos hacerlo de varias maneras.

- `declare -a`: Utilizado para declarar una variable como un array en Bash. Esto significa que la variable podrá contener múltiples valores, accesibles a través de índices numéricos. Esta opción es útil para asegurar que una variable se comporte como un array, incluso si no contiene valores al principio.

```bash
usuario@debian:~$ vectorUno[0]=nuevo

usuario@debian:~$ declare -p | tail -3
declare -- snap_bin_path="/snap/bin"
declare -- snap_xdg_path="/var/lib/snapd/desktop"
declare -a vectorUno=([0]="nuevo")

usuario@debian:~$ vectorUno[1]=nuevo2
usuario@debian:~$ vectorUno[3]=3

usuario@debian:~$ declare -p | tail -3
declare -- snap_bin_path="/snap/bin"
declare -- snap_xdg_path="/var/lib/snapd/desktop"
declare -a vectorUno=([0]="nuevo" [1]="nuevo2" [3]="3")
```

```bash
usuario@debian:~$ vectorDos=(uno dos tres)
usuario@debian:~$ declare -p vectorDos
declare -a vectorDos=([0]="uno" [1]="dos" [2]="tres")
```

```bash
usuario@debian:~$ vectorTres=([0]=Uno [1]=Dos [4]=Cuatro)
usuario@debian:~$ declare -p vectorTres
declare -a vectorTres=([0]="Uno" [1]="Dos" [4]="Cuatro")
```

```bash
usuario@debian:~$ declare -a vectorCuatro[0]=Hola
usuario@debian:~$ echo ${vectorCuatro[0]}
Hola
```

- `declare -p`: Esta opción muestra información sobre una o más variables, incluyendo su tipo y valor. Es útil para depurar y entender el estado de las variables en un script de Bash.

```bash
usuario@debian:~$ declare -p vectorUno
declare -a vectorUno=([0]="nuevo" [1]="nuevo2" [3]="nuevo3")
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

### Referenciar Arrays

- `${nombre[índice]}` donde nombre es el nombre del array e índice es la posición entera que contiene su valor correspondiente.
- `${nombre}` equivale a `${nombre[0]}`
- `${nombre[@]}` donde nombre es el nombre del array y el índice @ representa todos los elementos del vector. Devuelve una cadena con los elementos separados por espacio.
- `${nombre[*]}` donde nombre es el nombre del array y el índice \* representa todos los elementos del vector. Devuelve una cadena con los elementos separados por espacio.
- `"${nombre[@]}"` donde nombre es el nombre del array y el índice @ representa todos los elementos del vector. Devuelve una cadena con los elementos separados por espacio.
- `"${nombre[*]}"` donde nombre es el nombre del array y el índice \* representa todos los elementos del vector. Devuelve una cadena con los elementos separados por el primer caracter de la variable separador de campos IFS.

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

### Eliminar arrays

- `unset nombre`: Elimina el array declarado como `nombre` siempre que no esté declarado en modo lectura.
- `unset nombre[índice]`: Elimina el índice del array `nombre` en la posición [índice] siempre que no esté declarado en modo lectura.

### Recorrer arrays

- Recorre los índices del array declarado como `nombre` y muestra cada valor en pantalla. Siempre utiliza comillas dobles para evitar errores de separadores como espacios que puedan existir en los valores de los índices.

```bash
for i in "${nombre[*]}"
do
echo $i
done
```

- Recorre los índices del array declarado como `nombre` y muestra cada valor en pantalla. Siempre utiliza comillas dobles para evitar errores de separadores como espacios que puedan existir en los valores de los índices. Si empleamos el "${nombre[@]}", con independencia del IFS siempre tendremos los elementos separados por espacio por lo que es preferible esta opción.

```bash
for i in "${nombre[@]}"
do
echo $i
done
```

### Longitud de los arrays e índices

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
usuario@debian:~$ vector3=(uno dos tres)   # Se define el array con 3 elementos.
usuario@debian:~$ echo ${vector3[*]}
uno dos tres                               # Muestra todos los elementos del array.
usuario@debian:~$ echo ${vector3[@]}
uno dos tres                               # Muestra todos los elementos (funciona igual que * aquí).
usuario@debian:~$ echo ${vector3[0]}
uno                                        # Muestra el contenido del índice 0 (el primero).
usuario@debian:~$ echo ${vector3}
uno                                        # Sin indicar índice, por defecto muestra el índice 0.
usuario@debian:~$ echo ${vector3[1]}
dos                                        # Muestra el contenido del índice 1 (el segundo).
usuario@debian:~$ echo ${vector3[2]}
tres                                       # Muestra el contenido del índice 2 (el tercero).
usuario@debian:~$ echo ${vector3[3]}
                                           # Sale vacío porque el índice 3 no existe.
usuario@debian:~$ echo ${#vector3[@]}
3                                          # La almohadilla (#) al inicio cuenta el TOTAL de elementos del array.
usuario@debian:~$ echo ${!vector3[@]}
0 1 2                                      # El signo (!) lista los ÍNDICES que existen, no los valores.
usuario@debian:~$ echo ${#vector3[0]}
3                                          # Cuenta los CARACTERES de la palabra "uno" (u-n-o).
usuario@debian:~$ echo ${#vector3[1]}
3                                          # Cuenta los CARACTERES de la palabra "dos" (d-o-s).
usuario@debian:~$ echo ${#vector3[2]}
4                                          # Cuenta los CARACTERES de la palabra "tres" (t-r-e-s).
```

### Arrays como parámetros de funciones

En la llamada a la función utilizamos como parámetro la notación "nombre[@]", y dentro del cuerpo de la función utilizamos la referencia indirecta ${!número}, donde número es el número del parámetro en la llamada a la función: 1, 2, 3...

```bash
f_nombre() { # Definición de la función llamada f_nombre
    parametros=("${!1}") # Referencia indirecta del parámetro $1 dentro de la definición del array parametros
    echo "${parametros[@]}" # Muestra todos los valores contenidos en los índices del array llamado parametros
} # Fin del cuerpo de la función f_nombre

nombres=(Anxo Brais) # Se declara la variable array nombres con los valores Anxo y Brais en los índices 0 y 1 respectivamente.
f_nombre "nombres[@]" # Llamada a la ejecución de la función llamada f_nombre donde el primer parámetro $1 toma el valor "nombres[@]", lo cual es equivalente a los valores de todos los índices del array llamado nombres
```

## Prácticas sobre arrays

### Declarar y eliminar arrays

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

1. ### Pedir datos para un array

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

2. ### Pedir datos para una posición del array

Recoge por teclado el valor del índice 1 del array llamado "curso5".

```bash
read -p 'Escriba valor para el índice 1: ' curso5[1]
```

Asigna el valor '4 5 6' al índice 1, ya que en la asignación al índice no se tiene en cuenta la variable IFS.

```bash
4 5 6
```
