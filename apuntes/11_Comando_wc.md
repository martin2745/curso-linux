# Comando wc

## Índice

1. [Opciones comunes](#1-opciones-comunes)
2. [Ejemplo de uso](#2-ejemplo-de-uso)
3. [Uso con tuberías y en scripts](#3-uso-con-tuberías-y-en-scripts)

---

## 1. Opciones comunes

| Parámetro | Descripción |
|-----------|-------------|
| `-l` | Muestra solo el recuento de líneas. |
| `-w` | Muestra solo el recuento de palabras. |
| `-c` | Muestra solo el recuento de **bytes** (*chars* en la nomenclatura histórica). |
| `-m` | Muestra solo el recuento de **caracteres**, interpretando la codificación del *locale* activo. |
| `-L` | Muestra la longitud, en caracteres, de la línea más larga del fichero. |
| `--files0-from=F` | Lee del fichero `F` la lista de rutas a procesar, separadas por el byte nulo. Se combina con `find -print0` para trabajar con nombres que contengan espacios. |

> **Nota:** Por defecto, si se ejecuta `wc` sin opciones, mostrará el número de líneas, palabras y bytes, en ese orden. El orden de las columnas es siempre ese, con independencia del orden en que se escriban las opciones.

> **Advertencia:** `-c` y `-m` no son sinónimos, aunque a menudo devuelvan el mismo número. `-c` cuenta **bytes** y `-m` cuenta **caracteres**. Coinciden mientras el texto sea ASCII puro, porque ahí cada carácter ocupa un byte, pero difieren en cuanto aparece una tilde, una `ñ` o un símbolo como `€`, que en UTF-8 ocupan dos o tres bytes cada uno.

> **Importante:** `-l` no cuenta líneas: cuenta **saltos de línea**. La diferencia aflora cuando un fichero no termina en salto de línea, algo frecuente en ficheros generados por programas o editados en Windows.
>
> ```bash
> usuario@debian:~$ printf 'uno\ndos\ntres\n' > con.txt
> usuario@debian:~$ printf 'uno\ndos\ntres'   > sin.txt
> usuario@debian:~$ wc -l con.txt sin.txt
>  3 con.txt
>  2 sin.txt
>  5 total
> ```
>
> Los dos ficheros contienen tres líneas de texto, pero `sin.txt` declara dos porque le falta el último salto. Al procesar varios ficheros a la vez, `wc` añade además una fila `total` con la suma.

---

## 2. Ejemplo de uso

El siguiente ejemplo muestra la creación de un archivo de texto con un contenido específico y la posterior ejecución del comando `wc` combinando múltiples opciones (`-l`, `-w`, `-c`) simultáneamente.

```bash
usuario@debian:~$ echo "VirtualBox es un software de virtualización de código abierto gratuito que permite crear y gestionar máquinas virtuales para ejecutar múltiples sistemas operativos (como Windows, Linux o macOS) simultáneamente en un solo dispositivo físico." > /tmp/texto.txt
usuario@debian:~$ wc -lwc /tmp/texto.txt
  1  33 247 /tmp/texto.txt
```

> **Explicación del output:** La salida `1 33 247 /tmp/texto.txt` significa que el archivo contiene 1 línea, 33 palabras y 247 **bytes**, seguido del nombre del archivo analizado.

Este ejemplo sirve precisamente para comprobar que bytes y caracteres no son lo mismo. El texto contiene seis vocales acentuadas (*virtualización*, *código*, *máquinas*, *múltiples*, *simultáneamente* y *físico*), y cada una ocupa dos bytes en UTF-8:

```bash
usuario@debian:~$ wc -c /tmp/texto.txt
247 /tmp/texto.txt
usuario@debian:~$ wc -m /tmp/texto.txt
241 /tmp/texto.txt
```

Los 6 bytes de diferencia son exactamente el segundo byte de cada vocal acentuada.

> **Advertencia:** El recuento de `-m` depende del *locale*. Si la sesión trabaja bajo el *locale* `C` o `POSIX`, el sistema no reconoce la codificación multibyte y `-m` devuelve el mismo valor que `-c`:
>
> ```bash
> usuario@debian:~$ LC_ALL=C wc -m /tmp/texto.txt
> 247 /tmp/texto.txt
> ```

---

## 3. Uso con tuberías y en scripts

El empleo más frecuente de `wc` no es sobre ficheros, sino al final de una tubería, para contar cuántos resultados ha devuelto otro comando:

```bash
usuario@debian:~$ ls /etc | wc -l
122
usuario@debian:~$ ps aux | grep -c sshd
2
usuario@debian:~$ grep -c "" /etc/passwd
25
```

> **Nota:** Cuando lo único que se necesita es contar líneas coincidentes, `grep -c patron fichero` resuelve en un solo proceso lo que `grep patron fichero | wc -l` hace en dos. El resultado es el mismo y la orden es más corta.

Hay una diferencia entre pasar el fichero como argumento y pasarlo por la entrada estándar que conviene tener presente al escribir scripts:

```bash
usuario@debian:~$ wc -l /etc/passwd
25 /etc/passwd
usuario@debian:~$ wc -l < /etc/passwd
25
```

En el primer caso `wc` conoce el nombre del fichero y lo imprime junto al número; en el segundo recibe el contenido por `stdin` y no tiene nombre que mostrar. Por eso, para guardar el recuento en una variable se usa siempre la segunda forma, que devuelve el número limpio:

```bash
usuario@debian:~$ lineas=$(wc -l < /etc/passwd)
usuario@debian:~$ echo "El fichero tiene $lineas líneas."
El fichero tiene 25 líneas.
```

> **Advertencia:** Contar ficheros con `ls | wc -l` falla si algún nombre contiene un salto de línea, porque `wc` contará ese nombre como dos entradas. Para un recuento fiable conviene recurrir a `find . -maxdepth 1 -type f -printf '.' | wc -c`, o directamente a `find . -maxdepth 1 -type f | wc -l` asumiendo nombres normales.
