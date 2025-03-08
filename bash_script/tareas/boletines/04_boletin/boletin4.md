# Boletín 4

### Ejercicio 1

Ejecutar:

```bash
$ rm -rf /tmp/renombrar
$ mkdir /tmp/renombrar
$ for i in $(seq 1 10); do touch "/tmp/renombrar/antes de entregar _volA_$i.txt" ;done
$ for i in $(seq 1 10); do touch "/tmp/renombrar/antes de entregar _volB_$i.txt" ;done
```

Los comandos anteriores crean archivos vacíos que contienen espacios en el nombre del archivo. Crea un script llamado **`renombrar.sh`** que permita renombrar esos archivos para que **no contengan espacios** en su nombre. Además, en caso de que los archivos contengan el **patrón "volB"** en su nombre, dicho patrón debe ser modificado por **"entregado"**. Así, los archivos:

```bash
/tmp/renombrar/antes de entregar _volA_1.txt
/tmp/renombrar/antes de entregar _volB_1.txt
```

Pasarán a llamarse:

```bash
/tmp/renombrar/antesdeentregar_volA_1.txt
/tmp/renombrar/entregado_volB_1.txt
```

#### Notas:

1. Añadir comentarios que expliquen el código.
2. Debes ofrecer **3 soluciones** a este ejercicio, donde:
   - **Solución 1**: Usa `$IFS`, `for`, `ls`.
   - **Solución 2**: Usa `find` y `xargs`.
   - **Solución 3**: Usa `rename`.
3. La ejecución del programa será con: `bash B2_script1.sh` por lo que **no es necesario dar permisos de ejecución** al archivo `B2_script1.sh`.

### Ejercicio 2

Existe un módulo **PENDIENTES** en el cual hay alumnos matriculados. Todos los matriculados tienen una cuenta en la máquina, aunque algunos **no tienen la shell activa**, por lo que su shell es `/bin/false`. A estos los llamaremos **usuarios inactivos**.

Crea un script llamado **`B2_script2.sh`** que realice las siguientes acciones:

- Haga una **copia comprimida** del **home** (`$HOME`) de todos los **usuarios activos**.
- Elimine la cuenta de los **usuarios inactivos**.
- Muestre un **pequeño informe** con las acciones que está realizando.

#### Notas:

1. Añadir comentarios que expliquen el código.
2. La ejecución del programa será con: `bash B2_script2.sh`.
3. **Solo los usuarios matriculados** pueden ser usuarios activos.
4. **Solo los usuarios matriculados** tienen su **home** en el directorio `alumno-15-16`.
5. El archivo `/etc/passwd` a utilizar es el siguiente:

```bash
jperez:x:10912:1009:Juan Perez,,,:/home/alumno-15-16/jperez:/bin/bash
mfernan:x:10913:1009:Manuel Fernandez,,,:/home/alumno-14-15/mfernan:/bin/bash
mgarcia:x:10914:1009:Maria Garcia ,,,:/home/alumno-15-16/mgarcia:/bin/bash
alruiz:x:10915:1009:Alberto Ruiz ,,,:/home/alumno-15-16/alruiz:/bin/false
japerez:x:10916:1009:Javier Perez,,,:/home/alumno-15-16/japerez:/bin/bash
mafernan:x:10917:1009:Marcos Fernandez,,,:/home/alumno-14-15/mafernan:/bin/bash
magarcia:x:10918:1009:Manel Garcia ,,,:/home/alumno-05-06/magarcia:/bin/bash
luisruiz:x:10919:1009:Luis Ruiz ,,,:/home/alumno-15-16/luisruiz:/bin/false
```

6. Si el usuario es **inactivo**, tendrá la shell `/bin/false`.
7. Las **copias de seguridad** de los **home** serán guardadas en `/var/tmp/Nome_Usuario`. Estos directorios no existen previamente, siendo **Nome_Usuario** los nombres de los usuarios activos, por ejemplo: `jperez`.
8. Para hacer una **copia de seguridad**, se debe utilizar el comando `tar`.
9. El **informe** que muestre el programa debe ser parecido a este:  
   (Aquí usualmente se incluiría un ejemplo de informe, pero no está especificado. Si necesitas un formato concreto, dime y lo puedo añadir).

```bash
jperez. Usuario activo, copiando su /home en /var/tmp/jperez
mfernan. Usuario no matriculado.
mgarcia. Usuario activo, copiando su /home en /var/tmp/mgarcia
alruiz. Usuario inactivo, se borra su cuenta
```

### Ejercicio 3

Tenemos un aula (**aula2**) con **30 PCs**, donde cada PC tiene un archivo **`/etc/hosts`** que indica los nombres y direcciones IP de algunas máquinas. Para cada PC del aula, el archivo **`/etc/hosts`** puede tener información distinta, es decir, puede tener diferentes líneas y en distinto orden. En el archivo **`/etc/hosts`** existen **15 máquinas alfa** y **15 máquinas beta**. Un extracto del archivo es similar al siguiente:

```bash
192.168.4.1 aula2alfa1.insti.es a2eq1
192.168.4.3 aula2alfa3.insti.es a2eq3
192.168.4.7 aula2alfa7.insti.es a2eq7
...
192.168.4.11 aula2alfa11.insti.es a2eq11
192.168.4.13 aula2alfa13.insti.es a2eq13
...
192.168.4.16 aula2beta16.insti.es beta16
192.168.4.14 aula2alfa14.insti.es a2eq14
192.168.4.20 aula2beta20.insti.es beta20
...
192.168.4.25 aula2beta25.insti.es beta25
192.168.4.32 aula2beta32.insti.es beta32
192.168.4.23 aula2beta23.insti.es beta23
```

Crea un script llamado **`B2_script3.sh`**, que será ejecutado en cada máquina, y que sea capaz de cambiar:

- Las direcciones IP y los nombres de las máquinas **betaNN** (donde **NN** es el número del ordenador) por **a2eqNN**.
- La nueva dirección de cada máquina será: `10.0.133.YY aula2alfaNN.insti.es a2eqNN`, donde **YY = NN + 40**.

**Ejemplo**:  
Si el archivo contiene:

```
192.168.4.23 aula2beta23.insti.es beta23
```

Debe convertirse en:

```
10.0.133.63 aula2alfa63.insti.es a2eq63
```

### Enunciado en castellano:

El script debe mostrar por la salida estándar (consola) las líneas que se van a modificar y las líneas modificadas en el archivo **`/etc/hosts`**. Por ejemplo:

```bash
192.168.4.16 aula2beta16.insti.es beta16
10.0.133.56 aula2alfa56.insti.es a2eq56
192.168.4.20 aula2beta20.insti.es beta20
10.0.133.60 aula2alfa60.insti.es a2eq60
```

El script debe **sustituir solo las líneas modificadas** en el archivo **`/etc/hosts`**, dejando las no modificadas. Por ejemplo:

```bash
192.168.4.1 aula2alfa1.insti.es a2eq1
192.168.4.3 aula2alfa3.insti.es a2eq3
192.168.4.7 aula2alfa7.insti.es a2eq7
...
192.168.4.11 aula2alfa11.insti.es a2eq11
192.168.4.13 aula2alfa13.insti.es a2eq13
...
192.168.4.56 aula2alfa56.insti.es a2eq56
192.168.4.14 aula2alfa14.insti.es a2eq14
192.168.4.60 aula2alfa60.insti.es a2eq60
...
192.168.4.65 aula2alfa65.insti.es a2eq65
192.168.4.72 aula2alfa72.insti.es a2eq72
192.168.4.63 aula2alfa63.insti.es a2eq63
```

#### Notas:

1. **Añadir comentarios que expliquen el código**.
2. Para realizar este script, utiliza el comando **`cut`**.
3. La ejecución del programa será con: `bash B2_script3.sh` por lo que **no es necesario dar permisos de ejecución** al archivo **`B2_script3.sh`**.
4. **No sabemos cuántas líneas** a modificar existen, ya que el archivo **`/etc/hosts`** mostrado no está completo. **No podemos suponer** que el archivo esté ordenado. Pueden existir **huecos en la numeración**. Por ejemplo, puede que existan **beta16** y **beta20**, pero falte **beta29**.
