
# Entorno y variables de Entorno en Linux

Listado de variables de entorno interesantes:

- **SHELL**: El nombre de la shell por defecto del usuario.

- **HOME**: El nombre de la ruta de tu directorio personal.

- **LANG / LANGUAGE**: Define el conjunto de caracteres y el orden de cotejo de su idioma.

- **PATH**: Una lista separada por dos puntos de los directorios que se buscan cuando introducimos el nombre de un programa ejecutable.

- **PWD**: El directorio de trabajo actual.

- **\_**: Una referencia al programa /usr/bin/printenv (prueba a ejecutar el comando `$_`).

- **USER**: Tu nombre de usuario.

#### Configuración de Archivos de Entorno en Linux

##### Ficheros con aplicación a todo el sistema (todos los usuarios del sistema)

- **/etc/enviroment**: Fichero específico para la definición de variables de entorno. No puede contener scripts. Se ejecuta al iniciar el sistema.

- **/etc/profile**: Permite definir variables de entorno y scripts, aunque no es apropiado modificar este fichero directamente (debe crearse un nuevo fichero en /etc/profile.d). Se ejecuta en shells con login.

- **/etc/profile.d**: Contiene scripts que se ejecutan en shells con login.

- **/etc/bash.bashrc**: Permite definir variables de entorno y scripts que estarán disponibles para programas iniciados desde la shell bash. Las variables que se definan en este fichero no van a estar disponibles para programas iniciados desde la interfaz gráfica. No se ejecuta en shells con login.

##### Ficheros con aplicación a un usuario específico

- **~/.profile**: Permite definir variables de entorno y scripts. Se ejecutan al iniciar la sesión de Escritorio o en una shell con login. Las variables afectan a todos los programas ejecutados desde el escritorio gráfico o desde la shell.

- **~/.bash_profile**, **~/.bash_login**: Permiten definir variables de entorno y scripts. Se ejecutan cuando se utiliza una shell con login. Las variables definidas solo afectaran a los programas ejecutados desde bash.

- **~/.bashrc**: Permite definir variables de entorno y scripts. Se ejecuta cuando se abre la shell sin necesidad de hacer login. Las variables definidas solo afectaran a los programas ejecutados desde bash.

_*Nota*_: En función de nuestra shell podemos trabajar con [.bashrc](https://www.compuhoy.com/que-es-bashrc-en-linux/) o [.zshrc](https://respontodo.com/que-es-zsh-y-por-que-deberia-usarlo-en-lugar-de-bash/) teniendo cada una sus propias particularidades.