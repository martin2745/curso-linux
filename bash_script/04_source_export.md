# source y export

`source` y el carácter punto `.` son sinónimos. Leen y ejecutan los comandos existentes en un archivo dado en el entorno actual de la shell. El archivo no necesita ser ejecutable y se busca primero en las rutas del PATH y luego en la ruta actual (pwd) de ejecución del comando.

```bash
source $HOME/.bashrc # Recarga el archivo $HOME/.bashrc en la shell actual
```

El comando `export` permite exportar variables al entorno actual del shell, de manera que una vez exportadas, son válidas tanto en el entorno actual del shell como en cualquier subshell.

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