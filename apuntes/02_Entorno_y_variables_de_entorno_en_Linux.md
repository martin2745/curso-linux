# Entorno y variables de Entorno en Linux

## Listado de variables de entorno interesantes:

- **SHELL**: El nombre de la shell por defecto del usuario, entendiendo shell como intérprete de comandos.
- **HOME**: El nombre de la ruta de tu directorio personal.
- **LANG / LANGUAGE**: Define el conjunto de caracteres y el orden de cotejo de su idioma.
- **PATH**: Una lista separada por dos puntos de los directorios que se buscan cuando introducimos el nombre de un programa ejecutable.
- **PWD**: El directorio de trabajo actual.
- **\_**: Una referencia al programa /usr/bin/printenv (prueba a ejecutar el comando `$_`).
- **USER**: Tu nombre de usuario.

## Configuración de Archivos de Entorno en Linux

### Ficheros con aplicación a todo el sistema (todos los usuarios del sistema)

- **/etc/environment**: Fichero específico para la definición de variables de entorno. No puede contener scripts. Se ejecuta al iniciar el sistema.
- **/etc/profile**: Permite definir variables de entorno y scripts, aunque no es apropiado modificar este fichero directamente (debe crearse un nuevo fichero en /etc/profile.d). Se ejecuta en shells con login.
- **/etc/profile.d**: Contiene scripts que se ejecutan en shells con login.
- **/etc/bash.bashrc**: Permite definir variables de entorno y scripts que estarán disponibles para programas iniciados desde la shell bash. Las variables que se definan en este fichero no van a estar disponibles para programas iniciados desde la interfaz gráfica. No se ejecuta en shells con login.

### Ficheros con aplicación a un usuario específico

- **~/.profile**: Permite definir variables de entorno y scripts. Se ejecutan al iniciar la sesión de Escritorio o en una shell con login. Las variables afectan a todos los programas ejecutados desde el escritorio gráfico o desde la shell.
- **~/.bash_profile**, **~/.bash_login**: Permiten definir variables de entorno y scripts. Se ejecutan cuando se utiliza una shell con login. Las variables definidas solo afectarán a los programas ejecutados desde bash.
- **~/.bashrc**: Permite definir variables de entorno y scripts. Se ejecuta cuando se abre la shell sin necesidad de hacer login. Las variables definidas solo afectarán a los programas ejecutados desde bash.
- **~/.bash_logout**: Se ejecuta al finalizar un shell de sesión.
- **~/.bash_history**: Almacena el historial de comandos ejecutados por el usuario.

_*Nota*_: En función de nuestra shell podemos trabajar con [.bashrc](https://www.compuhoy.com/que-es-bashrc-en-linux/) o [.zshrc](https://respontodo.com/que-es-zsh-y-por-que-deberia-usarlo-en-lugar-de-bash/) teniendo cada una sus propias particularidades.

---

## Archivos de Configuración de Bash y su Orden de Ejecución

Bash dispone de una serie de archivos de configuración que se ejecutan antes y después de que lo haga el intérprete de comandos. Estos archivos son scripts de bash normales, pero el sistema de ejecución es un tanto complejo, ya que algunos se ejecutan solo si estamos en una shell de sesión, mientras que otros se ejecutan en shells que no son de sesión, y algunos únicamente para ciertos usuarios.

1. **Ficheros que se ejecutan en una shell sin sesión**:
   - **/etc/bashrc**: Archivo común a todos los usuarios, administrado por el usuario root.
   - **~/.bashrc**: Archivo específico de cada usuario, gestionado por él mismo.

2. **Ficheros que se ejecutan en una shell de sesión**:
   - **/etc/profile**: Archivo común a todos los usuarios, solo modificable por root.
   - **~/.bash_profile**, **~/.bash_login**, **~/.profile**: Archivos específicos de cada usuario. Se ejecutan en un orden particular:
     - Primero se busca **~/.bash_profile**.
     - Si no existe, se ejecuta **~/.bash_login**.
     - Si ninguno de los dos anteriores existe, se ejecuta **~/.profile**.
     - Solo se ejecutará el primero de estos tres archivos que se encuentre presente.

3. **Fichero que se ejecuta al salir de una shell de sesión**:
   - **~/.bash_logout**: Se ejecuta cuando finaliza la sesión en la shell.

### ¿Por qué tantos archivos?

La razón de esta estructura es que los archivos que contienen "bash" en su nombre son específicos de este intérprete de comandos, por lo que solo serán ejecutados por bash. En cambio, **/etc/profile** y **~/.profile** son comunes a todos los intérpretes de comandos basados en **sh**, como **ksh**, por lo que podrían ser ejecutados por otros intérpretes disponibles en el sistema. Por esta razón, no deberíamos introducir configuraciones específicas de bash en estos archivos comunes.

