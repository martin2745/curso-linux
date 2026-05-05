# Comando tr

## Índice

1. [Particularidades del comando tr](#1-particularidades-del-comando-tr)
2. [Ejemplos de interés](#2-ejemplos-de-interés)

---

El comando `tr` en Linux es una utilidad de línea de comandos utilizada para traducir, eliminar o comprimir caracteres de la entrada estándar y escribir el resultado en la salida estándar. Su nombre proviene de "translate" (traducir).

---

## 1. Particularidades del comando tr

A diferencia de otros comandos, `tr` no acepta un nombre de archivo como argumento; solo lee desde la entrada estándar, por lo que casi siempre se usa junto con tuberías (`|`).

1. **Traducción de caracteres**: `tr` puede traducir un conjunto de caracteres a otro. Por ejemplo, puede convertir letras minúsculas en mayúsculas o viceversa.

```bash
usuario@debian:/tmp/prueba$  echo "Vamos a cambiar las a minusculas por mayusculas" | tr 'a' 'A'
VAmos A cAmbiAr lAs A minusculAs por mAyusculAs
```

2. **Eliminación de caracteres (`-d`)**: Usando la opción `-d`, `tr` puede eliminar caracteres específicos de la entrada.

```bash
usuario@debian:/tmp/prueba$  echo "Vamos a eliminar las letras a" | tr -d 'a'
Vmos  eliminr ls letrs
```

3. **Compresión de caracteres repetidos (`-s`)**: Con la opción `-s` (_squeeze_), `tr` puede comprimir secuencias repetidas de caracteres en uno solo.

```bash
usuario@debian:/tmp/prueba$  echo "A     A   A   B" | tr -s ' '
A A A B
```

4. **Uso de clases de caracteres**: `tr` permite el uso de clases de caracteres predefinidas POSIX como `[:upper:]` para letras mayúsculas, `[:lower:]` para letras minúsculas, `[:digit:]` para dígitos, etc.

```bash
usuario@debian:/tmp/prueba$  echo "Vamos a cambiar a mayusculas" | tr '[[:lower:]]' '[[:upper:]]'
VAMOS A CAMBIAR A MAYUSCULAS
```

---

## 2. Ejemplos de interés

### Ejemplo 1: Conversión de formatos MAC

```bash
echo 'AA:BB:CC:DD:EE:FF' | tr '[[:upper:]]' '[[:lower:]]'
```

En este ejemplo:
- `echo 'AA:BB:CC:DD:EE:FF'` produce la cadena `'AA:BB:CC:DD:EE:FF'`.
- La tubería (`|`) pasa esta cadena como entrada a `tr`.
- `tr '[[:upper:]]' '[[:lower:]]'` traduce todas las letras mayúsculas a minúsculas usando clases POSIX.

El resultado será:

```bash
aa:bb:cc:dd:ee:ff
```

### Ejemplo 2: Limpieza de variables para scripts

```bash
linea='"user1","p1","/bin/bash","/tmp"'
user=$(echo ${linea} | tr -d '"' | cut -d',' -f1)
```

En este ejemplo de Bash:
1. `echo ${linea}` imprime el valor de la variable `linea`.
2. `tr -d '"'` elimina todos los caracteres de comillas dobles (`"`) del flujo.
3. `cut -d',' -f1` corta la cadena resultante en campos separados por comas (`,`) y selecciona el primer campo.

Por ejemplo, el flujo funciona así:
- `echo ${linea}` produce la cadena `'"user1","p1",...'`.
- `tr -d '"'` elimina las comillas dobles, produciendo `user1,p1,...`.
- `cut -d',' -f1` selecciona el primer campo, que es `user1`.

> **Nota:** Finalmente, el valor limpio `user1` se asigna a la variable `$user`, un patrón muy útil al parsear archivos CSV rudimentarios en scripts de automatización.
