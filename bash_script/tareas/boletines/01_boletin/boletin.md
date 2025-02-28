# Boletín 1

**Ejercicio 1:**  
Escribe un script en Bash que reciba al menos 5 parámetros por línea de comandos. El script debe verificar que se han pasado al menos 5 valores, y en caso contrario, mostrar un mensaje de error y finalizar su ejecución. Si la cantidad de parámetros es suficiente, debe indicar cuántos datos se han introducido y mostrar los tres primeros.  

**Ejercicio 2:**  
Crea un script en Bash que utilice las variables del sistema para mostrar un mensaje indicando el usuario que ejecuta el script, el shell que está utilizando y el directorio en el que se encuentra. Por ejemplo:  
_"Eres root usando /bin/bash desde el directorio /root"_  

**Ejercicio 3:**  
Desarrolla un script en Bash que solicite al usuario la ruta de un directorio para realizar una copia de seguridad. Si el directorio existe, el script debe crear un archivo comprimido en formato `.tar.bz2` con el contenido del directorio. Si el directorio no existe, debe informar al usuario de la situación.  

**Ejercicio 4:**  
Crea un script en Bash que solicite un nombre de usuario y verifique si dicho usuario tiene un directorio personal en `/home`. Si el directorio existe, se debe generar una copia de seguridad en formato `.tar.gz`. En caso contrario, debe informar al usuario de que el directorio no existe y volver a solicitar un usuario válido.  