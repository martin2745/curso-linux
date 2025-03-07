# set, unset y env

El comando `set` en Linux, sin opciones, muestra los nombres y valores de cada variable de la shell en un formato que puede ser reutilizado como entrada. `set` como comando permite ver las variables de entorno, variables locales y globales. Con la opción "-o" o "+o", permite establecer o quitar respectivamente atributos de la shell.

```bash
$ set -o # Muestra todas las opciones activadas (on) y desactivadas (off) en la shell
$ set +o # Muestra todas las opciones activadas (-o) y desactivadas (+o) en la shell, con el formato de las órdenes utilizadas para lograr ese resultado
$ set -o noclobber # Con esta opción, la shell bash no puede sobrescribir un archivo existente con los operadores de redirección (>, >&, <>). Añade la opción noclobber a la variable SHELLOPTS, siendo esta variable una lista de elementos separados por dos puntos, de opciones activas de la shell.
$ set +o noclobber # Desactiva el comando anterior, es decir, se activa la posibilidad de sobrescribir archivos con los operadores de redirección
$ set -C # Equivale a set -o noclobber
$ set +C # Equivale a set +o noclobber
```

`unset` elimina variables de la shell. No puede eliminar variables de solo lectura (definidas con "readonly" o "declare -r").

```bash
si@si-VirtualBox:~$ declare papelera='AAA'
si@si-VirtualBox:~$ echo $papelera
AAA
si@si-VirtualBox:~$ unset papelera
si@si-VirtualBox:~$ echo $papelera
```

El comando `env` ejecuta un programa con un entorno modificado según los parámetros con los que se ejecute. Esto significa que ejecuta un programa definiendo qué variables de entorno reconoce. Sin opciones o nombre de programa, el comando muestra el entorno resultante (las variables globales del entorno), similar al comando `printenv`.

- `env bash`: Este comando ejecuta el shell de bash con el entorno actual, es decir, utiliza las variables de entorno existentes tal como están en ese momento.

- `env variable=JEJEJE bash`: Aquí se ejecuta el shell de bash con una variable de entorno llamada `variable` establecida en el valor "JEJEJE". Esto significa que al abrir el shell, la variable `variable` tendrá el valor "JEJEJE".

- `env -i bash`: Este comando ejecuta el shell de bash con un entorno vacío. La opción `-i` indica "ignorar el entorno existente", por lo que no se pasan variables de entorno al nuevo shell bash, dejándolo con un entorno limpio.

A modo de resumen podemos decir:

- set -> todas las variables

- env -> variables de un entorno

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
