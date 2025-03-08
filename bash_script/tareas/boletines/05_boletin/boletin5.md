# Boletín 5

### Ejercicio 1

Crea un script bash llamado **`menu1.sh`** que contenga un menú con las siguientes opciones:

Seleccione una opción sobre la interfaz de red **$1**:

1. Activar interfaz **$1**
2. Desactivar interfaz **$1**
3. Configurar alias **$1:web** con la máscara de subred por defecto
4. Ver configuración alias **$1:web**
5. Salir

#### Notas:

1. **Añadir comentarios que expliquen el código**.
2. Se debe introducir el **nombre de la interfaz** (como **eth0**, **eth1**, etc.) como parámetro `$1`, y en caso de no tener valor, debe finalizar la ejecución del script mostrando el siguiente mensaje de error: **"Ejecución errónea"**.
3. En la opción 3 se debe utilizar el comando **`read`**, para solicitar la IP a configurar.
4. Si no se introduce una opción válida, debe aparecer un mensaje **"Opción no válida"**, esperar un segundo, y volver a ejecutar el menú.
5. La **única forma de salir** de la ejecución del script es eligiendo la opción **5**.
6. Se debe **activar dentro del script** la opción **`-x`** de **`set`**.
7. Debes ofrecer **2 soluciones** a este ejercicio, donde:
   - **Solución 1**: Usa **`ifconfig`**.
   - **Solución 2**: Usa **`ip`**.
8. **Deshabilitar** **<Ctrl>+<c>** para impedir su funcionamiento durante la ejecución del script.
9. La ejecución del programa será con: `bash menu1.sh $1` por lo que **no es necesario dar permisos de ejecución** al archivo **`menu1.sh`**.

### Ejercicio 2

Crea un script bash llamado **`menu2.sh`** que contenga un menú con las siguientes opciones:

Seleccione una opción sobre la interfaz de red **eth0**:

1. Ver solo la IP
2. Ver solo la dirección MAC
3. Ver la tabla de enrutamiento
4. Ver la configuración DNS
5. Salir

#### Notas:

1. **Añadir comentarios que expliquen el código**.
2. Las 2 primeras opciones del menú deben resolverse utilizando **expresiones regulares** y proporcionando **2 soluciones**, donde:
   - **Solución 1**: Usa **`ifconfig`** y expresiones regulares.
   - **Solución 2**: Usa **`ip`** y expresiones regulares.
3. La ejecución del programa será con: `bash menu2.sh` por lo que **no es necesario dar permisos de ejecución** al archivo **`menu2.sh`**.
