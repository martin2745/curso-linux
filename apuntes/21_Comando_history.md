# Comando history

El comando history en Linux muestra el historial de comandos ejecutados en la sesión del shell. Es útil para revisar comandos anteriores, reutilizarlos y gestionar el historial.

1. Ejemplos con el comando history:

```bash
history #muestra todo el historial
history 10 #muestra las últimas 10
history –c #limpia el historial
```

2. Repetir un comando del historial

```bash
!775
```

3. Apagar o prender el historial

```bash
set +o history #Apaga el historial
set -o history #Prende el historial
```

4. Desactivar el Historial Permanente

```bash
export HISTFILESIZE=0
```

5. Variables del sistema involucradas con el historial

- $HISTFILE Contiene el nombre del archivo. Normalmente es: ~/.bash_history
- $HISTFILESIZE Esta variable contiene el tamaño máximo del archivo
- $HISTSIZE Esta variable contiene el tamaño máximo de comandos
- $HISTIGNORE=ls*:cd*:history*:exit:passwd*:

6. HISTCONTROL: Los comandos que comiencen con un espacio en blanco no se guardarán en el historial.

```bash
export HISTCONTROL=ignorespace
```

¿Por qué usarlo?

- Para evitar que comandos sensibles o privados queden registrados (por ejemplo, contraseñas o configuraciones).
- Para ejecutar comandos temporales sin llenar el historial innecesariamente.

Otras opciones de HISTCONTROL:

| Valor       | Descripción                                                                                |
| ----------- | ------------------------------------------------------------------------------------------ |
| ignorespace | No guarda comandos que comiencen con un espacio en el historial.                           |
| ignoredups  | No guarda comandos duplicados consecutivos en el historial.                                |
| ignoreboth  | Combina ignorespace e ignoredups, evitando comandos con espacio y duplicados consecutivos. |
| erasedups   | Elimina todas las entradas duplicadas anteriores, manteniendo solo la última ocurrencia.   |
| none        | No ignora ningún comando.                                                                  |

7. HISTTIMEFORMAT: Permite mostrar la fecha y hora de cada comando en el historial.
   Para habilitar el registro de la hora en el historial, puedes configurar HISTTIMEFORMAT de la siguiente manera:

```bash
export HISTTIMEFORMAT="%F %T "
```

Explicación:

- %F - Muestra la fecha en formato YYYY-MM-DD.
- %T - Muestra la hora en formato HH:MM:SS.
- El espacio al final mejora la legibilidad.

Salida:

```bash
1 2025-03-27 14:23:45 ls
2 2025-03-27 14:23:46 pwd
3 2025-03-27 14:23:47 echo "Hola"
```

Hacerlo Permanente

```bash
echo 'export HISTTIMEFORMAT="%F %T "' >> ~/.bashrc
source ~/.bashrc
```

Formatos comunes para HISTTIMEFORMAT:

| Formato        | Descripción                                  | Ejemplo de Salida        |
| -------------- | -------------------------------------------- | ------------------------ |
| %F %T          | Fecha completa y hora                        | 2025-03-27 14:23:45      |
| %d-%m-%Y %T    | Día-Mes-Año y Hora                           | 27-03-2025 14:23:45      |
| %Y/%m/%d %H:%M | Año/Mes/Día y Hora:Minuto                    | 2025/03/27 14:23         |
| %c             | Fecha y hora local en formato completo       | Thu Mar 27 14:23:45 2025 |
| %x %X          | Fecha y hora según la configuración regional | 03/27/2025 14:23:45      |

8. El símbolo ~ en Linux y otros sistemas tipo Unix es un atajo para el directorio de inicio del usuario actual. Este símbolo simplifica la navegación hacia el directorio principal del usuario sin tener que escribir la ruta completa.

cat /~/.bash_profile

```bash
PATH=$PATH:$HOME/bin:/lpic1
PS1='\[\e[1;32m\][\u@\h \W]\$\[\e[0m\]'
HISTIGNORE='ls*:cd*:history*:exit'
EDITOR=/usr/bin/vi
HISTFILE=/root/.historial
export PATH PS1 HISTIGNORE EDITOR HISTFILE
```

Ejecutamos el comando source para aplicar los cambios de nuestro .bash_profile

```bash
source /root/.bash_profile
```

El comando source en Bash (y otros shells similares) se utiliza para ejecutar comandos desde un archivo en el contexto del shell actual. Esto significa que las variables de entorno, funciones y configuraciones definidas en el archivo permanecen accesibles después de su ejecución.
