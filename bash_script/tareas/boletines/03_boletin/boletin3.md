# Boletín 3

### Ejercicio 1

Crea un script llamado `script1.sh` que sea capaz de recoger en 3 columnas, separadas por `' --- '` (espacio, 3 guiones, espacio), los campos usuario, directorio de entrada al sistema y la shell del archivo `/etc/passwd`. En caso de que la shell sea `/bin/false`, esta debería sustituirse por el siguiente texto: `/bin/false, shell que no permite acceso al sistema`. La salida debe guardarse en un fichero llamado `columnas`.

#### Notas:

1. Añadir comentarios que expliquen qué hace el código empleado.
2. Debes ofrecer **4 soluciones** a este ejercicio, donde:
   - **Solución 1**: Usa los comandos `sed` y `awk` (sin la opción `-F`).
   - **Solución 2**: Usa los comandos `sed` y `awk` (con la opción `-F`).
   - **Solución 3**: Usa los comandos `cut` y `sed`.
   - **Solución 4**: Usa el comando `tee` para la creación del fichero `columnas`.
3. La ejecución del programa se hará con: `bash script1.sh`, por lo que **no es necesario dar permisos de ejecución** al archivo `script1.sh`.

### Ejercicio 2

El archivo _*users.csv*_ tiene el siguiente contenido:

```bash
"Usuario","Password","Shell","Directorio de entrada al sistema"
"user1","p1","/bin/bash","/tmp"
"user2","p2","/bin/false","/home/user2"
"user3","p3","/bin/bash","/home/user3"
"user4","p4","/bin/bash","/tmp"
"user5","p5","/bin/bash","/tmp"
"user6","p6","/bin/false","/home/user6"
"user7","p7","/bin/bash","/tmp"
"user8","p8","/bin/bash","/home/user8"
"user9","p9","/bin/false","/tmp"
"user10","p10","/bin/bash","/tmp"
```

#### Donde:

- **Usuario** representa el nombre del usuario.
- **Password** representa la contraseña del usuario.
- **Shell** representa la shell del usuario.
- **Directorio de entrada al sistema** representa el (`$HOME`).

Crea un script llamado `script2.sh` que sea capaz de **crear todos los usuarios** con las características correspondientes que aparecen en el archivo `users.csv`.

#### Notas:

1. Explicar el código empleado.
2. Es **obligatorio** usar el comando `tr` para la sustitución de caracteres.
3. Es **opcional** usar el comando `sed` para la sustitución de caracteres.
4. Debes ofrecer **4 soluciones** a este ejercicio:
   - **Solución 1**: Usa el bucle `while`.
   - **Solución 2**: Usa `cat` y el bucle `while`.
   - **Solución 3**: Usa `$IFS`, el bucle `for` y `cat`.
   - **Solución 4**: Usa `cat`, `wc` y `seq`.
5. La ejecución del programa se hará con `./script2.sh`, por lo que **es necesario dar permisos de ejecución** al archivo `script2.sh` con: `chmod +x script2.sh` o `chmod 755 script2.sh`.

### Ejercicio 3

El archivo _*users.csv*_ tiene el siguiente contenido:

```bash
"Usuario","Password","Shell","Directorio","Enable"
"user1","p1","/bin/bash","/tmp","off"
"user2","p2","/bin/false","/home/user2","off"
"user3","p3","/bin/bash","/home/user3","on"
"user4","p4","/bin/bash","/tmp","off"
"user5","p5","/bin/bash","/tmp","on"
"user6","p6","/bin/false","/home/user6","on"
"user7","p7","/bin/bash","/tmp","on"
"user8","p8","/bin/bash","/home/user8","off"
"user9","p9","/bin/false","/tmp","on"
"user10","p10","/bin/bash","/tmp","off"
"user11","p11","/bin/bash","/tmp","off"
"user12","p12","/bin/false","/tmp","off"
"user13","p13","/bin/bash","/home/user13","off"
"user14","p14","/bin/bash","/home/user14","on"
```

#### Donde:

- **Usuario** representa el nombre del usuario.
- **Password** representa la contraseña del usuario.
- **Shell** representa la shell del usuario.
- **Directorio** representa el directorio de entrada al sistema (`$HOME`).
- **Enable** indica si el usuario está activo (`on`) o no (`off`).

Crea un script llamado **`script3.sh`** que sea capaz de **crear todos los usuarios activos**, con las características correspondientes que aparecen en el archivo `users.csv`.

#### Notas:

1. Explicar el código empleado.
2. Debes ofrecer **dos soluciones** a este ejercicio, donde se usen los comandos `tr` y `while`, además:
   - **Solución 1**: **No debe usarse** la variable `$?`.
   - **Solución 2**: **Debe usarse** la variable `$?`.
3. La ejecución del programa será con:
   ```bash
   bash script3.sh
   ```
   por lo que **no es necesario dar permisos de ejecución** al archivo `script3.sh`.
