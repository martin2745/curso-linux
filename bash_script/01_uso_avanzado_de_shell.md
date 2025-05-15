# Uso avanzado de shell

El shell, como intérprete de comandos, actúa como intermediario entre el usuario y el núcleo del sistema, interpretando instrucciones, gestionando procesos, permitiendo la manipulación eficiente de archivos y facilitando la creación de scripts que automatizan tareas repetitivas o complejas. En Linux, cuando ejecutas un comando en la terminal, el sistema sigue un **orden de preferencia** para determinar qué ejecutar. El orden es el siguiente:

```bash
alias > keyword > function > builtin > file
```

Indica cómo el shell (como `bash` o `zsh`) prioriza las distintas formas en que un comando puede estar definido. Vamos a explicarlo con detalle:

## 1. **Alias**  
- Son atajos que el usuario define para simplificar comandos más largos.  
- Se crean con `alias nombre='comando'`.  
- Se revisan con `alias` o `type nombre`.  
- **Ejemplo:**  
```bash
┌──(kali㉿kali)-[~]
└─$ type -a ls
ls is an alias for ls --color=auto
ls is /usr/bin/ls
ls is /bin/ls
```
Si escribimos `ls`, el shell usará el alias definido en el `.bashrc` antes de cualquier otro tipo de comando.

## 2. **Keyword (Palabra clave de shell)**  
- Son palabras reservadas del shell con significado especial, como `if`, `for`, `while`, `case`, etc.  
- **Ejemplo:**  
```bash
┌──(kali㉿kali)-[~]
└─$ if [ 5 -eq 5 ]; then; echo "5 es igual a 5"; fi
5 es igual a 5
```
- Aquí, `if` es una **keyword**, no un comando ejecutable.

## 3. **Function (Función de shell)**  
- Definidas dentro del shell, permiten agrupar comandos en una estructura reutilizable.  
- Se crean con la sintaxis:  
```bash
function nombre {
comandos
}
```
- Se revisan con `declare -f nombre` o `type nombre`.  
- **Ejemplo:**  
```bash
┌──(kali㉿kali)-[~]
└─$ function nombre {
echo "Me llamo Martín :)"
function> }

┌──(kali㉿kali)-[~]
└─$ nombre
Me llamo Martín :)

┌──(kali㉿kali)-[~]
└─$ declare -f nombre
nombre () {
        echo "Me llamo Martín :)"
}
```
- Si ejecutas `nombre`, se usará esta función antes que un comando del sistema si existiera.

## 4. **Builtin (Comando interno del shell)**  
- Son comandos incorporados dentro del shell, ejecutados sin llamar a un programa externo.  
- Algunos ejemplos: `cd`, `echo`, `exit`, `read`, `set`.  
- Se revisan con `help comando` o `type comando`.  
- **Ejemplo:**  
```bash
echo "Me llamo Martín :)"
```
- Aquí, `echo` es un **shell builtin**, pero si existe un alias `alias echo='echo -e'`, el alias tendrá prioridad.

## 5. **File (Ejecutable en el sistema)**  
- Si no se encuentra en las opciones anteriores, el shell busca en los directorios de `$PATH`.  
- Usa `which comando` o `type comando` para verificar.  
- **Ejemplo:**  
```bash
┌──(kali㉿kali)-[~]
└─$ type ls
ls is an alias for ls --color=auto

┌──(kali㉿kali)-[~]
└─$ type -a ls
ls is an alias for ls --color=auto
ls is /usr/bin/ls
ls is /bin/ls

┌──(kali㉿kali)-[~]
└─$ which ls
ls: aliased to ls --color=auto
```
- Aquí, el shell ejecuta el alias de `ls` creado en el `.bashrc` pero si no existiera, ejecutaría el archivo `ls` ubicado en `/usr/bin/ls`.

## **Ejemplo de Prioridad en Acción**

Todo lo anterior se puede ver reflejado a continuación.

```bash
┌──(kali㉿kali)-[~]
└─$ type -a ls
ls is an alias for ls --color=auto
ls is /usr/bin/ls
ls is /bin/ls

┌──(kali㉿kali)-[~]
└─$ function ls {
function> echo "Soy la función ls"
function> }

┌──(kali㉿kali)-[~]
└─$ type -a ls
ls is an alias for ls --color=auto
ls is a shell function
ls is /usr/bin/ls
ls is /bin/ls

┌──(kali㉿kali)-[~]
└─$ ls
Desktop  Documents  Downloads  Music  Pictures  Public  Templates  Videos  copias # Se muestra con colores

┌──(kali㉿kali)-[~]
└─$ unalias ls

┌──(kali㉿kali)-[~]
└─$ type -a ls
ls is a shell function
ls is /usr/bin/ls
ls is /bin/ls

┌──(kali㉿kali)-[~]
└─$ ls
Soy la función ls

┌──(kali㉿kali)-[~]
└─$ unset -f ls

┌──(kali㉿kali)-[~]
└─$ type -a ls
ls is /usr/bin/ls
ls is /bin/ls

┌──(kali㉿kali)-[~]
└─$ ls
Desktop  Documents  Downloads  Music  Pictures  Public  Templates  Videos  copias # Se muestra sin colores
```

## Orden de ejecución
Cuando ejecutas un comando en Linux, el shell sigue este orden:  
1. **Alias** → Si existe, lo usa primero.  
2. **Keyword** → Si el comando es una palabra clave reservada, la ejecuta.  
3. **Function** → Si hay una función con ese nombre, la ejecuta.  
4. **Builtin** → Si es un comando interno del shell, lo usa.  
5. **File** → Finalmente, busca un ejecutable en `$PATH`.  

Esto nos permite personalizar y modificar el comportamiento de los comandos según tus necesidades.

Los comandos internos en Linux son aquellos que están integrados en el shell (como Bash) y no requieren un programa o archivo externo para ejecutarse. Estos comandos se ejecutan directamente en el proceso del shell, lo que los hace más rápidos y útiles para tareas básicas de administración y control del entorno de la sesión.

*Gestión de directorios*
- cd: Cambia el directorio actual.
- pwd: Muestra el directorio de trabajo actual.
- pushd y popd: Administran la pila de directorios para navegar fácilmente entre ellos.

*Gestión de variables*
- export: Define o hace disponibles variables de entorno para los procesos hijos.
- unset: Elimina una variable de entorno o de shell.
- set: Configura o muestra opciones y variables del shell.

*Comandos de control de flujo*
- if, then, else, fi: Condiciones de control de flujo en scripts.
- for, while, until: Estructuras de bucle para iteración en scripts.
- case: Estructura de control para comparar patrones en scripts.

*Gestión de procesos*
- jobs: Muestra trabajos en segundo plano en la sesión actual.
- bg: Envía un proceso al segundo plano.
- fg: Trae un proceso en segundo plano al primer plano.
- kill: Envia una señal para finalizar un proceso (usualmente con un PID).

*Redirección y control de salida*
- echo: Imprime texto o variables en la pantalla.
- read: Lee la entrada del usuario y la asigna a una variable.
- wait: Espera a que uno o varios procesos finalicen.
- exec: Reemplaza el shell actual con un comando o programa especificado, sin crear un nuevo proceso.

*Comandos de información y ayuda*
- help: Muestra ayuda para comandos internos del shell.
- type: Indica si un comando es interno, externo, o un alias.
- alias y unalias: Crea o elimina alias para comandos.

*Control de sesión*
- exit: Finaliza la sesión del shell.
- logout: Cierra la sesión en sistemas multiusuario.
- history: Muestra el historial de comandos usados en la sesión.


## Variables en shell

Una variable es un identificador al que se le asigna un valor, que puede ser leído por el shell y otros comandos, alterando su comportamiento según el contenido de la variable. Los valores pueden ser únicos o múltiples, separados por espacios u otros caracteres. Para asignar un valor, se escribe el nombre de la variable seguido de un signo igual (=) y el valor. Los nombres deben iniciar con una letra o subrayado, y solo pueden contener letras, números y subrayado. Son sensibles a mayúsculas y minúsculas, y es recomendable usar comillas al asignar valores con caracteres especiales.

En Bash, las variables se usan para configurar preferencias y modificar el comportamiento del shell y los comandos. 
- Variables locales: disponibles en el shell donde se crean.
- Variables de entorno: disponibles para el shell y los procesos que inicia. 

_*Nota*_: Por convención, los nombres en minúsculas se usan para variables locales y en mayúsculas para variables de entorno, aunque no es una regla obligatoria. 

Las variables se pueden declarar y mostrar de diferentes maneras. A continuación se muestran diferentes ejemplos:

1. Aquí estás asignando el valor "ls" a la variable "a".

```bash
si@si-VirtualBox:~$ a=ls
```

2. Al imprimir el valor de la variable "a" con `$a`, bash expande la variable y ejecuta el comando "ls", mostrando el contenido del directorio actual.

```bash
si@si-VirtualBox:~$ echo $a
ls
```

3. Al imprimir '$a' entre comillas simples, bash toma el texto literalmente y no expande la variable "a", por lo que muestra "$a".

```bash
si@si-VirtualBox:~$ echo '$a'
$a
```

4. Al imprimir "$a" entre comillas dobles, bash expande la variable "a" y ejecuta el comando "ls", mostrando el contenido del directorio actual.

```bash
si@si-VirtualBox:~$ echo "$a"
ls
```

5. Aquí estás intentando ejecutar el comando "ls" usando la expansión de comandos, pero la forma en que está escrito no es correcta. Esto ejecuta el resultado de "ls" como un comando independiente, lo que significa que si hay archivos o directorios en el directorio actual, intentará ejecutarlos como comandos y puede generar errores si no son ejecutables.

```bash
si@si-VirtualBox:~$ echo `$a`
Desktop Documents Downloads env-exemplo1.sh Music Pictures Public script.sh snap Templates Videos
```


Ahora bien, hay que tener en cuenta que las variables se pueden mostrar haciendo uso del `{}` o sin ellas. A continuación, se muestra la diferencia.

```bash
si@si-VirtualBox:~$ a=1
si@si-VirtualBox:~$ b=2
si@si-VirtualBox:~$ c=3
```

1. `echo $a-$b-$c`: Aquí, bash expande las variables y las une con el guión (-) como se indica en la cadena de formato. El resultado es "1-2-3".

```bash
si@si-VirtualBox:~$ echo $a-$b-$c
1-2-3
```

2. `echo ${a}_${b}_${c}`: Al utilizar las llaves `{}` para delimitar las variables, bash entiende claramente que la variable es "a", "b" y "c", mientras que el guión bajo (\_) se utiliza como un literal y se concatena entre ellas. El resultado es "1_2_3".

```bash
si@si-VirtualBox:~$ echo ${a}_${b}_${c}
1_2_3
```

3. `echo $a_$b_$c`: En este caso, bash interpreta la expresión `$a_` como una variable llamada "a*" y expande su valor, que es "3" según lo definido anteriormente, y las demás variables y guiones bajos son ignorados. Entonces, solo imprime el valor de "a*" que es "3". Es importante destacar que el guión bajo no se considera un separador de nombres de variables en bash, por lo que "a\_" se interpreta como una variable diferente a "a".

```bash
si@si-VirtualBox:~$ echo $a_$b_$c
3
```

_*Nota: Siempre es preferible hacer uso de `{}` para invocar a variables.*_

## Formas de declarar, ver y exportar variables

Para mostrar y declarar variables, hay varios comandos que proporcionan diferentes resultados:

- El comando *env* se utiliza para mostrar todas las variables de entorno y sus valores en la sesión actual. También puede utilizarse para ejecutar comandos con un entorno modificado.
- El comando *set* muestra todas las variables y funciones del shell locales y de entorno, mientras que comandos como *env*, *export -p*, *declare -x* y *typeset -x* solo muestran o gestionan variables de entorno.
- El comando *source* y el carácter punto `.` son sinónimos. Leen y ejecutan los comandos existentes en un archivo dado en el entorno actual de la shell. El archivo no necesita ser ejecutable y se busca primero en las rutas del PATH y luego en la ruta actual (pwd) de ejecución del comando.
- El comando *export* se utiliza para declarar variables de entorno dentro de un script o sesión de Bash. Además, *export -p* muestra una lista de todas las variables de entorno exportadas. Es útil para ver qué variables se han marcado para ser exportadas a procesos hijos.
- El comando *declare -x*, al igual que *export* se utiliza para declarar variables de entorno dentro de un script o sesión de Bash.
- El comando *typeset -x* es similar a declare -x, pero se utiliza principalmente en versiones más antiguas de Bash o en otros shells como ksh (KornShell). En Bash moderno, declare -x y typeset -x son funcionalmente equivalentes.

### Ejemplos de uso y declaración de variables

1. `declare e typeset` son sinónimos por lo que todos los siguientes ejemplos funcionan del mismo modo con los dos comandos. Permiten declarar variables.

```bash
si@si-VirtualBox:~$ declare var1='AAA'
si@si-VirtualBox:~$ var2='BBB'
si@si-VirtualBox:~$ declare | grep var[12]
var1=AAA
var2=BBB

si@si-VirtualBox:~$ var1='CCC'
si@si-VirtualBox:~$ declare -p | grep var[12]
declare -- var1="CCC"
declare -- var2="BBB"
```

2. `declare -r` no permite volver a redeclarar una variable. En este caso tanto `declare -r` como `readonly` para declarar variables de solo lectura funcionan del mismo modo.

```bash
si@si-VirtualBox:~$ declare -r var3='CCC'
si@si-VirtualBox:~$ declare -p | grep var3
declare -- _="var3=CCC"
declare -r var3="CCC"
si@si-VirtualBox:~$ var3='NO PUEDO DECLARAR'
bash: var3: readonly variable
```

```bash
si@si-VirtualBox:~$ readonly var3='No puedo declarar de nuevo'
bash: var3: readonly variable
si@si-VirtualBox:~$ readonly var4='No puedo declarar de nuevo'
si@si-VirtualBox:~$ declare -p | grep var4
declare -- _="var4=No puedo declarar de nuevo"
declare -r var4="No puedo declarar de nuevo"
```

3. `declare -p` permite ver todas las variables del sistema junto con las nuevas vaiables creadas en la shell.

4. `set` en Linux, sin opciones, muestra los nombres y valores de cada variable de la shell en un formato que puede ser reutilizado como entrada. El comando `set` como comando permite ver las variables de entorno, variables locales y globales. Con la opción "-o" o "+o", permite establecer o quitar respectivamente atributos de la shell.

```bash
$ set -o # Muestra todas las opciones activadas (on) y desactivadas (off) en la shell
$ set +o # Muestra todas las opciones activadas (-o) y desactivadas (+o) en la shell, con el formato de las órdenes utilizadas para lograr ese resultado
$ set -o noclobber # Con esta opción, la shell bash no puede sobrescribir un archivo existente con los operadores de redirección (>, >&, <>). Añade la opción noclobber a la variable SHELLOPTS, siendo esta variable una lista de elementos separados por dos puntos, de opciones activas de la shell.
$ set +o noclobber # Desactiva el comando anterior, es decir, se activa la posibilidad de sobrescribir archivos con los operadores de redirección
$ set -C # Equivale a set -o noclobber
$ set +C # Equivale a set +o noclobber
```

5. `unset` elimina variables de la shell. No puede eliminar variables de solo lectura (definidas con "readonly" o "declare -r").

```bash
si@si-VirtualBox:~$ declare papelera='AAA'
si@si-VirtualBox:~$ echo $papelera
AAA
si@si-VirtualBox:~$ unset papelera
si@si-VirtualBox:~$ echo $papelera
```

6. El comando `env` ejecuta un programa con un entorno modificado según los parámetros con los que se ejecute. Esto significa que ejecuta un programa definiendo qué variables de entorno reconoce. Sin opciones o nombre de programa, el comando muestra el entorno resultante (las variables globales del entorno), similar al comando `printenv`.

- `env bash`: Este comando ejecuta el shell de bash con el entorno actual, es decir, utiliza las variables de entorno existentes tal como están en ese momento.

- `env variable=JEJEJE bash`: Aquí se ejecuta el shell de bash con una variable de entorno llamada `variable` establecida en el valor "JEJEJE". Esto significa que al abrir el shell, la variable `variable` tendrá el valor "JEJEJE".

- `env -i bash`: Este comando ejecuta el shell de bash con un entorno vacío. La opción `-i` indica "ignorar el entorno existente", por lo que no se pasan variables de entorno al nuevo shell bash, dejándolo con un entorno limpio.

A modo de resumen podemos decir:
- env -> variables de un entorno.
- set -> todas las variables.

```bash
nuevo@si-VirtualBox:~$ env | wc -l
32

nuevo@si-VirtualBox:~$ set | wc -l
2136
```

```bash
si@si-VirtualBox:~$ env | wc -l
54

si@si-VirtualBox:~$ set | wc -l
2161
```

7. `source` y el carácter punto `.` son sinónimos. Leen y ejecutan los comandos existentes en un archivo dado en el entorno actual de la shell. El archivo no necesita ser ejecutable y se busca primero en las rutas del PATH y luego en la ruta actual (pwd) de ejecución del comando.

```bash
source $HOME/.bashrc # Recarga el archivo $HOME/.bashrc en la shell actual
```

8. El comando `export` permite exportar variables al entorno actual del shell, de manera que una vez exportadas, son válidas tanto en el entorno actual del shell como en cualquier subshell.

```bash
si@si-VirtualBox:~$ export HHH='hes' # Declara una variable llamada HHH con el valor 'hes' y además exporta la variable para que pueda ser reconocida en el entorno actual de la shell.
si@si-VirtualBox:~$ env | grep HHH
HHH=hes
si@si-VirtualBox:~$ echo $SHLVL
1

si@si-VirtualBox:~$ bash
si@si-VirtualBox:~$ echo $SHLVL
2
si@si-VirtualBox:~$ env | grep HHH
HHH=hes
si@si-VirtualBox:~$
```

Es importante destacar que esto no se puede realizar a la inversa, es decir, las variables exportadas en una subshell no van a afectar a la shell padre.

```bash
si@si-VirtualBox:~$ echo $SHLVL
2
si@si-VirtualBox:~$ export noAfecta="Variable de subshell"
si@si-VirtualBox:~$ env | grep noAfecta
noAfecta=Variable de subshell
si@si-VirtualBox:~$ exit
exit

si@si-VirtualBox:~$ echo $SHLVL
1
si@si-VirtualBox:~$ env | grep noAfecta
si@si-VirtualBox:~$
```

Como se puede ver podemos crear tambien variables que no se puedan borrar ni editar y luego exportarlas.

```bash
si@si-VirtualBox:~$ declare -r noBorrar="No me puedes borrar JAJA"
si@si-VirtualBox:~$ echo $noBorrar
No me puedes borrar JAJA

si@si-VirtualBox:~$ declare -p | grep noBorrar
declare -r noBorrar="No me puedes borrar JAJA"

si@si-VirtualBox:~$ noBorrar2="Vamos a editar la variable"
-bash: noBorrar2: readonly variable

si@si-VirtualBox:~$ export noBorrar
si@si-VirtualBox:~$ declare -p | grep noBorrar
declare -rx noBorrar="No me puedes borrar JAJA"
```

## SubShell

En Bash, una **subshell** es una instancia secundaria del shell que se crea para ejecutar comandos de manera aislada del shell principal. Las variables y configuraciones dentro de una subshell no afectan al entorno del shell principal pero las variables de la shell padre son heredadas por las nuevas instancias de shell hijas. A continuación, se muestra cómo identificar el nivel de shell usando la variable especial `$SHLVL`:

```bash
usuario@usuario:~$ echo $SHLVL
1
usuario@usuario:~$ bash
usuario@usuario:~$ echo $SHLVL
2
```

Si colocamos una secuencia de órdenes entre paréntesis, forzamos a que estos comandos se ejecuten en una subshell.

```bash
$ (readonly AAA='aes'; echo $AAA; unset AAA; echo $AAA); AAA='bes'; echo $AAA; unset AAA;
echo $AAA # En la subshell definida con paréntesis y en la shell, las variables AAA son variables distintas.
```