
### declare, typeset y readonly

`declare e typeset` son sinónimos por lo que todos los siguientes ejemplos funcionan del mismo modo con los dos comandos. Permiten declarar variables.

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

- `declare -r` no permite volver a redeclarar una variable. En este caso tanto `declare -r` como `readonly` para declarar variables de solo lectura funcionan del mismo modo.

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

- `declare -p` permite ver todas las variables del sistema junto con las nuevas vaiables creadas en la shell.
