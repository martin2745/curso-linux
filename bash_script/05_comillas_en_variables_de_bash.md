# Comillas en variables de bash

Lo que estás viendo es un ejemplo de cómo se comportan las variables en bash (o cualquier shell de Unix) con diferentes tipos de comillas y la expansión de comandos.

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