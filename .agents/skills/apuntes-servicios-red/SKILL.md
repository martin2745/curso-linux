---
name: apuntes-servicios-red
description: Formatea, corrige y amplía apuntes técnicos sobre servicios en red en Linux (Apache, Nginx, SSH, FTP, DNS, DHCP, Samba, NFS, etc.) en documentos Markdown profesionales y homogéneos. Úsalo cuando el usuario adjunte o proporcione un archivo .md con apuntes sobre configuración de servicios en red en Linux y pida darle formato, corregir errores, ampliar explicaciones o generar un índice. También debe activarse cuando el usuario mencione: 'formatear apuntes', 'mejorar documento de servicio', 'añadir índice', 'corregir apuntes de red', 'ampliar explicaciones técnicas', 'estandarizar manual de servicio Linux', o cuando adjunte un .md con bloques de código de comandos de administración de sistemas (systemctl, apt, ss, netstat, nano, cat, etc.) y pida aplicar mejoras. Este skill es especialmente útil cuando el usuario tiene múltiples documentos de apuntes que quiere unificar bajo un formato común.
---

# Apuntes Servicios en Red — Linux

Skill para transformar apuntes técnicos en bruto sobre servicios en red en Linux en documentos Markdown profesionales, homogéneos y pedagógicamente enriquecidos, sin eliminar ni reducir el contenido original.

---

## Flujo de trabajo

### 1. Lectura y análisis previo

Antes de aplicar ningún cambio, leer el documento completo e identificar:

- Secciones presentes y su estructura jerárquica (`#`, `##`, `###`, etc.)
- Bloques de código existentes — se respetarán íntegramente
- Errores ortográficos, de acentuación o de expresión evidentes
- Explicaciones teóricas que puedan ampliarse con información relevante
- Comandos clave que merezcan una tabla de parámetros
- Notas o advertencias que deberían destacarse visualmente
- Servicio o servicios tratados en el documento (Apache, SSH, DNS, etc.)

**Antes de aplicar cambios, exponer al usuario el plan de modificaciones.** Esperar confirmación antes de proceder.

---

### 2. Cambios a aplicar (en orden)

Consultar `references/criterios-ampliacion.md` para guías de ampliación específicas por servicio.

#### 2.1 Índice numerado con anclas

Generar un índice con enlaces internos Markdown a todas las secciones y subsecciones relevantes, insertado justo después del título principal (`# ...`) y antes del primer `---`.

Formato:

```markdown
## Índice

1. [Introducción](#introducción)
2. [Configuración básica](#configuración-básica)
   - 2.1 [Puerto de escucha y direccionamiento](#puerto-de-escucha-y-direccionamiento)
   - 2.2 [Virtual Hosts](#virtual-hosts)
3. [Directivas](#directivas)
...
```

#### 2.2 Separadores horizontales (`---`)

Colocar un `---` tras el índice y entre cada sección principal (`## ...`) para mejorar la lectura.

#### 2.3 Corrección ortográfica y de expresión

Corregir únicamente:
- Errores de acentuación (ej: `deberiamos` → `deberíamos`, `imágen` → `imagen`)
- Errores ortográficos evidentes en texto narrativo
- Errores tipográficos en nombres de comandos, rutas o URLs cuando sean inequívocos

**NUNCA modificar el contenido de bloques de código.**

#### 2.4 Ampliación de explicaciones teóricas

Ampliar las explicaciones teóricas existentes con información adicional relevante. **Nunca reducir ni eliminar el contenido original.**

Criterios para ampliar:
- Si una explicación describe un concepto sin mencionar su propósito práctico → añadir contexto de uso
- Si se menciona un módulo, protocolo o directiva sin detallar su funcionamiento → ampliar brevemente
- Si hay una comparativa implícita (ej: HTTP vs HTTPS, Basic vs Digest) → hacerla explícita
- Si falta contexto de seguridad relevante → añadirlo

Ver `references/criterios-ampliacion.md` para ejemplos concretos por tipo de sección.

#### 2.5 Tablas de parámetros para comandos clave

Para comandos con múltiples flags o parámetros importantes, añadir una tabla inmediatamente **después** del bloque de código:

| Parámetro | Descripción |
|-----------|-------------|
| `-X`      | Explicación breve |

Comandos que siempre merecen tabla: `apt`, `systemctl`, `ss`, `netstat`, `ps`, `openssl`, `htpasswd`, `a2enmod`, `a2ensite`, y equivalentes de otros servicios.

#### 2.6 Callouts con `>`

Añadir blockquotes (`>`) para destacar información crítica tras bloques de código o explicaciones:

```markdown
> **Nota:** El archivo ports.conf solo define los puertos de escucha. La configuración de los VirtualHosts debe hacerse en sites-available.

> **Advertencia:** La autenticación HTTP Basic transmite las credenciales codificadas en Base64, que puede revertirse fácilmente. Usar siempre junto con HTTPS.

> **Importante:** Reiniciar el servicio tras cualquier cambio en la configuración.
```

Tipos de callout a usar:
- `> **Nota:**` — información complementaria útil
- `> **Advertencia:**` — riesgos de seguridad o configuraciones peligrosas
- `> **Importante:**` — pasos obligatorios o consecuencias de omisión
- `> **Recuerda:**` — conceptos previos necesarios para entender el punto actual

#### 2.7 Texto de transición entre bloques de código consecutivos

Si hay dos o más bloques de código seguidos sin explicación entre ellos, añadir una frase de transición que explique qué hace el siguiente bloque y por qué.

#### 2.8 Formateo de comandos inline

Los comandos, rutas, directivas y nombres de archivo que aparezcan en el texto narrativo deben ir siempre formateados como código inline con backticks:

- ✅ `systemctl restart apache2`
- ✅ `/etc/apache2/ports.conf`
- ✅ directiva `Listen`
- ❌ systemctl restart apache2 (sin backticks)

#### 2.9 Estandarización de notas

Las notas existentes en el documento (con formatos variados como `_*Nota*_:`, `**Nota:**`, etc.) deben estandarizarse al formato callout `>`:

```markdown
> **Nota:** Contenido de la nota.
```

---

### 3. Reglas de oro — NUNCA hacer esto

- **NUNCA modificar el contenido de un bloque de código.** Los comandos, outputs y configuraciones son sagrados.
- **NUNCA eliminar** información técnica o explicaciones del documento original.
- **NUNCA reducir** el contenido de una explicación para "simplificarla".
- **NUNCA cambiar** el orden lógico ni la estructura de secciones originales.
- **NUNCA inventar** rutas, comandos, directivas, parámetros o comportamientos que no estén documentados o sean incorrectos.
- No añadir secciones vacías si no hay datos suficientes para rellenarlas.
- No aplicar formato de lista donde el original usa prosa continua (y viceversa), salvo que mejore claramente la legibilidad.

### 4. Confirmación final

Tras generar el documento, informar al usuario de:
- Número de correcciones ortográficas aplicadas
- Secciones donde se amplió contenido (y qué se añadió)
- Tablas de parámetros añadidas
- Callouts insertados

---

## Referencia rápida

Consultar `references/criterios-ampliacion.md` para:
- Guías de ampliación específicas por tipo de sección (introducción, instalación, configuración, seguridad, logs)
- Ejemplos de callouts por contexto
- Lista de directivas y módulos comunes por servicio que merecen explicación adicional
