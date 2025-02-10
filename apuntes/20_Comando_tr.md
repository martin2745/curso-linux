# Comando tr

El comando `tr` en Linux es una utilidad de línea de comandos utilizada para traducir, eliminar o comprimir caracteres de la entrada estándar y escribir el resultado en la salida estándar. Su nombre proviene de "translate" (traducir).

## Particularidades del comando `tr`

1. **Traducción de caracteres**: `tr` puede traducir un conjunto de caracteres a otro. Por ejemplo, puede convertir letras minúsculas en mayúsculas o viceversa.

```bash
si@si-VirtualBox:/tmp/prueba$ echo "Vamos a cambiar las a minusculas por mayusculas" | tr 'a' 'A'
VAmos A cAmbiAr lAs A minusculAs por mAyusculAs
```

2. **Eliminación de caracteres**: Usando la opción `-d`, `tr` puede eliminar caracteres específicos de la entrada.

```bash
si@si-VirtualBox:/tmp/prueba$ echo "Vamos a eliminar las letras a" | tr -d 'a'
Vmos  eliminr ls letrs
```

3. **Compresión de caracteres repetidos**: Con la opción `-s`, `tr` puede comprimir secuencias repetidas de caracteres en uno solo.

```bash
si@si-VirtualBox:/tmp/prueba$ echo "A     A   A   B" | tr -s ' '
A A A B
```

4. **Uso de clases de caracteres**: `tr` permite el uso de clases de caracteres predefinidas como `[:upper:]` para letras mayúsculas, `[:lower:]` para letras minúsculas, `[:digit:]` para dígitos, etc.

```bash
si@si-VirtualBox:/tmp/prueba$ echo "Vamos a cambiar a mayusculas" | tr '[[:lower:]]' '[[:upper:]]'
VAMOS A CAMBIAR A MAYUSCULAS
```

### Ejemplos de interes

#### Ejemplo 1

```bash
echo 'AA:BB:CC:DD:EE:FF' | tr '[[:upper:]]' '[[:lower:]]'
```

En este ejemplo:

- `echo 'AA:BB:CC:DD:EE:FF'` produce la cadena `'AA:BB:CC:DD:EE:FF'`.
- La tubería (`|`) pasa esta cadena como entrada a `tr`.
- `tr '[[:upper:]]' '[[:lower:]]'` traduce todas las letras mayúsculas (`[[:upper:]]`) a minúsculas (`[[:lower:]]`).

El resultado será:

```bash
aa:bb:cc:dd:ee:ff
```

#### Ejemplo 2

```bash
linea='"user1","p1","/bin/bash","/tmp"'
user=$(echo ${linea} | tr -d '"' | cut -d',' -f1)
```

En este ejemplo:

1. `echo ${linea}` imprime el valor de la variable `linea`.
2. `tr -d '"'` elimina todos los caracteres de comillas dobles (`"`) de la salida del `echo`.
3. `cut -d',' -f1` corta la cadena resultante en campos separados por comas (`,`) y selecciona el primer campo.

Por ejemplo, si `linea` contiene la cadena `'"user1,info,something"'`, el flujo sería:

- `echo ${linea}` produce la cadena `'"user1,info,something"'`.
- `tr -d '"'` elimina las comillas dobles, produciendo `user1,info,something`.
- `cut -d',' -f1` selecciona el primer campo, que es `user1`.

Finalmente, el valor `user1` se asigna a la variable `user`.
