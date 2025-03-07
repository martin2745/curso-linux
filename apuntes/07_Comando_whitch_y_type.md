# Comando which y type

Ambos comandos, `which` y `type`, son útiles para identificar la ubicación de un comando específico y para determinar cómo se interpretará un comando en particular.

1. **`which`**:

   - `which` es un comando que se utiliza para encontrar la ubicación de un comando ejecutable en el sistema de archivos del usuario. Devuelve la ruta completa del ejecutable de ese comando si está presente en alguna de las rutas de búsqueda del sistema.

   Por ejemplo:

   ```bash
   si@si-VirtualBox:/tmp$ which ls
   /usr/bin/ls
   ```

2. **`type`**:

   - `type` es un comando que no solo muestra la ubicación de un comando ejecutable, sino también cómo será interpretado por el shell. Puede ser un comando interno del shell, un comando externo (ubicación del archivo ejecutable) o una función shell definida por el usuario.

   Por ejemplo:

   ```bash
   si@si-VirtualBox:/tmp$ type ls
   ls is aliased to `ls --color=auto'
   si@si-VirtualBox:/tmp$ type -a ls
   ls is aliased to `ls --color=auto'
   ls is /usr/bin/ls
   ls is /bin/ls
   ```
