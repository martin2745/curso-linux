# Boletín 2

### Ejercicio 1

Escribir un comando que muestre por pantalla cuántos archivos y subdirectorios del directorio actual contienen en su nombre la letra "b".

### Ejercicio 2

Realizar un script que reciba un directorio como parámetro y muestre de sus archivos el nombre y sus permisos.

### Ejercicio 3

Realizar un script al que le daremos desde la línea de comandos tres parámetros y nos mostrará el nombre del comando, así como los argumentos que le pasamos:

- El comando es: `./xxxx`
- Los argumentos son: `arg1 arg2 arg3`

### Ejercicio 4

Realizar un script que debe mostrar el siguiente menú:

```
1. Listar el contenido del directorio actual
2. Listar el contenido del directorio actual en formato largo
3. Salir
```

- Si se introduce un valor diferente, el script mostrará el mensaje **“error en la selección”**.
- El menú se repetirá hasta que el usuario introduzca la opción **3 (Salir)**.

### Ejercicio 5

Realizar un script que por 10 veces guarde cada 2 minutos los usuarios conectados en el sistema en el archivo `usuarios.log`.

### Ejercicio 6

Crear un script que otorgue todos los permisos de lectura y escritura a los archivos del directorio que se pasa como parámetro, y solo permisos de lectura y ejecución a los subdirectorios.

### Ejercicio 7

Realizar un script que acepte como argumentos los nombres de los archivos y muestre el contenido de cada uno de ellos, precediendo a cada uno de una línea:

```
Contenido del archivo x
```

### Ejercicio 8

Añadir una línea en el archivo `.bashrc` del usuario para que el prompt que le aparezca sea:

```
Buenos días, loginUsuario >
```

### Ejercicio 9

Realizar un script que dado un nombre de archivo, si este existe, es un archivo normal y se puede escribir, muestre el siguiente mensaje:

```
El archivo f existe, es un archivo normal y se puede escribir.
```

- Si no se puede escribir:

```
El archivo f existe, es un archivo normal pero no se puede escribir.
```

- Si no existe o es un directorio, aparecerán los siguientes mensajes:

```
El archivo f no existe.
```

```
El archivo f es un directorio.
```
