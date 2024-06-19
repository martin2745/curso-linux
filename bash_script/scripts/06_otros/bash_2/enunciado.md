### **Enunciado del Script de Bash para Creación de Usuarios**

```csv
#nome;contrasinal;grupo;habilitado
user01;abc123.;group01;N
user02;abc123.;group01;s
user03;abc123.;group01;n
user04;abc123.;group02;s
user05;abc123.;group02;S
```

Este script de Bash, diseñado para sistemas Linux, automatiza la creación de usuarios basada en la información proporcionada en un archivo CSV. Se espera que el usuario proporcione un parámetro al ejecutar el script, que debe ser el nombre del archivo CSV que contiene los detalles de los usuarios a crear. Si no se proporciona este parámetro, el script mostrará un mensaje de error y proporcionará un ejemplo de cómo ejecutar correctamente el script.

El archivo CSV debe tener el siguiente formato:
- Cada línea del archivo debe contener información separada por punto y coma (`;`), en el orden siguiente: nombre de usuario, contraseña, nombre de grupo y estado de activación (`s` o `n`).
- El script verificará la existencia de cada grupo especificado en el archivo CSV y lo creará si no existe.
- Para cada usuario en el archivo CSV, el script creará un nuevo usuario en el sistema, asignando el directorio `/home/usuario` y generando una contraseña segura encriptada con SHA-512.
- Si el usuario ya existe en el sistema, se registrará un mensaje en el archivo de registro especificado (`/var/log/usuarios.log`).

El script también registra la actividad en el archivo de registro, indicando la fecha y hora de ejecución. Después de procesar todos los usuarios en el archivo CSV, elimina el archivo temporal utilizado para almacenar los datos.

Para ejecutar este script correctamente, use el siguiente formato:
```
bash script.sh create-users.csv
```
Donde `script.sh` es el nombre del script y `create-users.csv` es el archivo CSV que contiene la información para crear los usuarios.

Este script es útil en entornos donde es necesario gestionar la creación masiva de usuarios de manera automatizada y asegurada, asegurando que cada usuario tenga configuraciones coherentes y seguras en el sistema.
