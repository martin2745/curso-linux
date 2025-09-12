# **Tarea 01: Servidor Web Apache**

### **Descripción de la tarea**

En esta tarea se realizará la configuración de un servidor web Apache con las siguientes características.

### **Pasos de la tarea**

Debes instalar y configurar Apache2 en un sistema Debian/Ubuntu de forma que puedas albergar varios sitios web independientes. En vuestro caso podéis hacerlo en una de las máquinas virtuales.

Deberás configurar un sitio virtual (virtual host) accesible por nombre con las siguientes características:

- Será accesible a través de los nombres **apache2practica.gal** y **www.apache2practica.gal**.
- Tendrá definidos logs de acceso y de errores específicos para el sitio, con la categorización **vhost_combined** para el de accesos.
- El archivo por defecto para este sitio será **index.php** e **index.html**. Se permitirá listar el directorio.
- Tendremos un directorio específico denominado **/privado** (accesible desde apache2practica.gal/privado) cuyo archivo por defecto será **indice.html** y no se permitirá listar la carpeta si no existe el archivo por defecto. Para acceder a **/privado** pedirá autenticación **Basic** con un usuario denominado **martin** y contraseña **abc123.**, y solo permitirá el acceso desde una IP determinada, por ejemplo **10.158.120.251**.
- El sitio virtual solo será accesible desde **localhost** o desde una red local determinada, por ejemplo **10.158.120.0/24**.
- Se definirá una página de error **404** en la que se indique “No existe el recurso”.
- Se definirá un mensaje de error **401** en el que se indique “No estás autorizado”.

Configura ahora otro sitio web que sea accesible desde el puerto **8080**. Puedes reutilizar toda la configuración anterior salvo la restricción por nombre de dominio.
