# Herramienta tmux

## Índice

1. [Instalación de tmux](#1-instalación-de-tmux)
2. [Principales comandos de tmux](#2-principales-comandos-de-tmux)
   1. [Gestión de sesiones](#21-gestión-de-sesiones)
   2. [Gestión de ventanas](#22-gestión-de-ventanas)
   3. [Gestión de paneles (Splits)](#23-gestión-de-paneles-splits)
   4. [Modo comando y modo copia](#24-modo-comando-y-modo-copia)

---

## 1. Instalación de tmux

Si `tmux` no está instalado en tu sistema, puedes instalarlo con los siguientes comandos según tu sistema operativo:

```bash
sudo apt update && sudo apt install tmux -y
```

---

## 2. Principales comandos de tmux

### 2.1 Gestión de sesiones

| Comando / Atajo | Descripción |
|-----------------|-------------|
| `tmux` | Crea una nueva sesión sin nombre. |
| `tmux new -s mi_sesion` | Crea una nueva sesión con nombre. |
| `tmux ls` | Lista todas las sesiones activas. |
| `tmux attach -t mi_sesion` | Se conecta (attach) a una sesión existente. |
| `Ctrl+b, d` | Desconecta (detach) de la sesión actual sin terminarla. |
| `Ctrl+b, $` | Renombra la sesión actual. |

### 2.2 Gestión de ventanas

| Atajo | Descripción |
|-------|-------------|
| `Ctrl+b, c` | Crea una nueva ventana. |
| `Ctrl+b, n` | Va a la siguiente ventana. |
| `Ctrl+b, p` | Va a la ventana anterior. |
| `Ctrl+b, 0-9` | Va a la ventana con ese número. |
| `Ctrl+b, ,` | Renombra la ventana actual. |
| `Ctrl+b, &` | Cierra la ventana actual (pide confirmación). |

### 2.3 Gestión de paneles (Splits)

| Atajo | Descripción |
|-------|-------------|
| `Ctrl+b, %` | Divide el panel en dos, uno a la **izquierda** y otro a la **derecha** (separados por una línea vertical). |
| `Ctrl+b, "` | Divide el panel en dos, uno **arriba** y otro **abajo** (separados por una línea horizontal). |
| `Ctrl+b, ←/→/↑/↓` | Mueve el foco entre paneles. |
| `Ctrl+b, x` | Cierra el panel actual (pide confirmación). |
| `Ctrl+b, z` | Maximiza/restaura el panel actual (zoom). |
| `Ctrl+b, q` | Muestra brevemente los números de los paneles. |
| `Ctrl+b, {` / `Ctrl+b, }` | Intercambia la posición del panel con el anterior o el siguiente. |
| `Ctrl+b, espacio` | Rota entre las distintas distribuciones de paneles predefinidas. |

> **Nota:** Los nombres "vertical" y "horizontal" son una fuente inagotable de confusión en `tmux`, porque pueden referirse a la orientación de la línea divisoria o a la disposición de los paneles. Para evitar dudas, basta recordar el símbolo: la tecla `%` recuerda a una barra inclinada que separa izquierda y derecha, y la comilla `"` cae desde arriba. Internamente, `%` ejecuta `split-window -h` y `"` ejecuta `split-window -v`.

### 2.4 Modo comando y modo copia

Además de los atajos, `tmux` dispone de una línea de órdenes propia que se abre con `Ctrl+b, :`. Desde ahí se ejecutan comandos completos, como `rename-window registros` o `kill-session -t antigua`.

El **modo copia**, que se activa con `Ctrl+b, [`, permite desplazarse hacia atrás por el historial de salida de un panel con las flechas y `RePag`/`AvPag`, buscar texto y copiarlo. Se sale con `q`.

| Atajo | Descripción |
|---|---|
| `Ctrl+b, [` | Entra en modo copia para desplazarse por el historial. |
| `Ctrl+b, ]` | Pega lo último copiado. |
| `Ctrl+b, ?` | Muestra la lista completa de atajos activos. |
| `Ctrl+b, t` | Muestra un reloj en el panel. |

> **Recuerda:** El verdadero valor de `tmux` en administración de sistemas es la **persistencia de sesiones remotas**. Al conectarse por SSH a un servidor y trabajar dentro de una sesión de `tmux`, se puede cerrar la conexión (o perderla por un corte de red) con `Ctrl+b, d`, y al volver a entrar recuperar exactamente el estado con `tmux attach`. Los procesos que se estuvieran ejecutando dentro no se interrumpen. Es la solución natural al problema de `SIGHUP` descrito en el documento 22, y evita tener que recurrir a `nohup` para tareas largas.

---

![tmux](../imagenes/recursos/tmux/0.png)
