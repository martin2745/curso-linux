# Ejecución de scripts

`Shebang`: También conocido como hashbang o sha-bang, es una convención en sistemas operativos tipo Unix que se utiliza en scripts para indicar qué intérprete de comandos debe ser utilizado para ejecutar el script. El shebang consiste en los caracteres "#!" seguidos de la ruta al intérprete. Por ejemplo:

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