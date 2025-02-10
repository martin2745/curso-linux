# Comando history

El comando history en Linux muestra el historial de comandos ejecutados en la sesión actual del shell.

- La opción -c limpia el historial de comandos, borrando todos los comandos almacenados.
- La opción -a guarda los comandos introducidos desde el último borrado en el archivo de historial, usualmente ~/.bash_history.
- HISTFILE: Especifica la ubicación del archivo donde se guarda el historial de comandos.
- HISTSIZE: Determina el número máximo de comandos almacenados en el historial.
- !!: Atajo para repetir el último comando ejecutado.
- !15: Ejecuta el comando número 15 del historial.
- !ls: Ejecuta el último comando que comienza con "ls" en el historial.