---
version: alpha
name: Nurska — Frame (video vertical)
description: >
  Sistema de diseño de video para Nurska, derivado 1:1 de lib/theme/ de la app Flutter.
  La unidad es el frame vertical 1080×1920 (Reels / TikTok / Shorts). Los átomos son los de la
  app y no se reinterpretan: cafés cálidos sobre crema (registro claro) o crema sobre café casi
  negro (registro oscuro), Poppins en tres pesos (400/600/700), esquinas redondeadas generosas
  y una rampa de alertas clínicas que sube de café neutro a rojo vino. Lo que cambia es la escala:
  pensada para verse en un celular, dentro de un feed, con el pulgar encima.
unit: el frame — 1080×1920 (9:16) primario
principle: los colores son los de la app · la escala es de video · un mensaje por frame

colors:
  # — registro CLARO (AppColors) —
  bg: "#EFE9E4"              # secondaryColor, scaffold del tema claro
  bg-soft: "#F6F3F0"         # lightSecondaryColor, texto sobre bandas café
  card: "#FFFFFF"            # cardTheme.color en claro
  surface-tint: "#DFD3C9"    # widgetLightBrown, secondaryContainer
  accent-light: "#D6C9BE"    # accentLightColor, tertiaryContainer
  accent: "#CBA786"          # accentDarkColor, el dorado tostado
  primary: "#96775B"         # primaryColor, botones
  ink-muted: "#7E6754"       # semiDarkPrimaryColor, cuerpo secundario
  ink: "#624933"             # darkPrimaryColor, títulos y AppBar (onSurface == primaryContainer)
  ink-deep: "#2F2318"        # darkestColor
  # — registro OSCURO (AppColorsDark) —
  dark-ground: "#14100B"     # lienzo, scaffold oscuro
  dark-paper: "#271F18"      # tarjetas
  dark-enfasis: "#51402F"    # AppBar / bandas de énfasis
  dark-chip: "#453A2F"       # botones de categoría
  dark-rule: "#3B2F25"
  dark-ink: "#EFE9E4"
  dark-ink-2: "#DFD3C9"
  dark-ink-3: "#B5A08B"      # texto atenuado
  dark-accent: "#CBA786"
  dark-accent-on: "#241B14"  # texto sobre dark-accent
  dark-ink-muted: "#9D826C"
  # — gravedad clínica, registro CLARO (un solo tono sirve de texto y de relleno) —
  alert-neutral: "#9C785C"   # sinAlerta
  alert-green: "#9C965C"
  alert-red-1: "#9C5C61"
  alert-red-2: "#8D5458"
  alert-red-3: "#7E4B4F"
  alert-red-4: "#6F4346"
  # — gravedad clínica, registro OSCURO: TEXTO sobre el lienzo —
  dark-alert-neutral-text: "#C59F81"
  dark-alert-green-text: "#BDB679"
  dark-alert-red-1-text: "#C58187"
  dark-alert-red-2-text: "#C9787E"
  dark-alert-red-3-text: "#CF6E75"
  dark-alert-red-4-text: "#D5626B"
  # — gravedad clínica, registro OSCURO: RELLENO con texto crema encima —
  dark-alert-neutral-fill: "#987152"
  dark-alert-green-fill: "#8A8551"
  dark-alert-red-1-fill: "#985258"
  dark-alert-red-2-fill: "#894349"
  dark-alert-red-3-fill: "#78363B"
  dark-alert-red-4-fill: "#66292D"

fonts:
  family: "Poppins"
  files:
    400: "assets/fonts/Poppins-Regular.ttf"
    600: "assets/fonts/Poppins-SemiBold.ttf"
    700: "assets/fonts/Poppins-Bold.ttf"
  note: "Solo existen estos tres pesos. Nada de 300, 500, 800 ni itálica: el render no los tiene y la app tampoco."

scale:
  dp-to-px: 2.6   # un teléfono de ~411dp de ancho ocupa 1080px: 1dp de la app ≈ 2.6px de video
  rule: "Toda medida de la app se multiplica por 2.6. Si el resultado cae bajo el piso de video, manda el piso."

typography:
  # Tamaños en px sobre el frame de 1080 de ancho. Entre paréntesis, el estilo de la app del que salen.
  display:   { fontFamily: "Poppins", px: 160, weight: 700, lineHeight: 1.0,  tracking: "-0.02em", color: "ink" }        # titleBrownTextv3 (60dp)
  h1:        { fontFamily: "Poppins", px: 112, weight: 700, lineHeight: 1.05, tracking: "-0.015em", color: "ink" }       # titleBrownTextv2 (30dp), subido a piso de feed
  h2:        { fontFamily: "Poppins", px: 80,  weight: 700, lineHeight: 1.1,  tracking: "-0.01em", color: "ink" }        # titleBrownText (25dp)
  h3:        { fontFamily: "Poppins", px: 60,  weight: 700, lineHeight: 1.15, color: "ink" }                             # appBarTitle (22dp)
  body-strong: { fontFamily: "Poppins", px: 46, weight: 600, lineHeight: 1.35, color: "ink-muted" }                     # bodyDarkBrownText (18dp)
  body:      { fontFamily: "Poppins", px: 42,  weight: 600, lineHeight: 1.4,  color: "alert-neutral" }                  # bodyBrownText (16dp)
  caption:   { fontFamily: "Poppins", px: 36,  weight: 400, lineHeight: 1.45, color: "ink-muted" }                      # verMasBodyText (15dp)
  eyebrow:   { fontFamily: "Poppins", px: 34,  weight: 600, tracking: "0.08em", upper: true, color: "primary" }
  stat:      { fontFamily: "Poppins", px: 220, weight: 700, lineHeight: 0.95, tracking: "-0.03em", color: "ink" }       # un número clínico como héroe del frame

radii:
  card: "78px"     # AppRadius.defaultRadius 30dp × 2.6
  button: "78px"
  pill: "999px"
  phone: "96px"    # marco del teléfono en mockups
  chip: "40px"

spacing:
  frame-w: "1080px"
  frame-h: "1920px"
  pad-x: "72px"
  safe-top: "240px"      # barra de usuario / título de la plataforma
  safe-bottom: "420px"   # descripción, caption del post, controles
  safe-right: "150px"    # columna de botones (like, comentar, compartir)
  gap-stack: "40px"
  card-pad: "56px"

shadows:
  card-light: "0 10px 28px rgba(47,35,24,0.18)"   # cardTheme elevation 4, tinte darkestColor
  card-dark: "none"                                # en oscuro la tarjeta se despega por color (paper sobre ground), no por sombra

components:
  app-bar-band:
    backgroundColor: "{colors.ink}"          # claro; en oscuro {colors.dark-enfasis}
    textColor: "{colors.bg-soft}"            # claro; en oscuro {colors.dark-ink}
    typography: "{typography.h3}"
    height: "180px"
    description: "La banda café de arriba que todo usuario de la app reconoce. Úsala como encabezado de frame o dentro del mockup."
  card:
    backgroundColor: "{colors.card}"         # claro; en oscuro {colors.dark-paper}
    rounded: "{radii.card}"
    padding: "{spacing.card-pad}"
    shadow: "{shadows.card-light}"
    description: "Contenedor universal de contenido. Una tarjeta por idea."
  button-primary:
    backgroundColor: "{colors.primary}"      # claro; en oscuro {colors.dark-accent}
    textColor: "{colors.bg}"                 # claro; en oscuro {colors.dark-accent-on}
    rounded: "{radii.button}"
    typography: "Poppins 600, 46px"
    padding: "36px 56px"
    description: "El botón principal va a la DERECHA cuando hay dos: [Limpiar] [Calcular]."
  button-outline:
    border: "5px solid {colors.primary}"     # 2dp × 2.6
    textColor: "{colors.primary}"
    rounded: "{radii.button}"
  severity-pill:
    backgroundColor: "{colors.alert-*}"      # claro; en oscuro {colors.dark-alert-*-fill}
    textColor: "{colors.bg-soft}"
    rounded: "{radii.pill}"
    typography: "Poppins 700, 44px"
    description: "Resultado de una escala (riesgo bajo / moderado / alto). En oscuro SIEMPRE la variante -fill, nunca la -text."
  severity-text:
    textColor: "{colors.alert-*}"            # claro; en oscuro {colors.dark-alert-*-text}
    description: "Puntaje o palabra de gravedad sobre el lienzo, sin relleno."
  phone-mockup:
    rounded: "{radii.phone}"
    width: "780px"
    border: "14px solid {colors.ink-deep}"
    description: "Captura real de la app dentro de un marco. Ancho máximo 780px para dejar aire y respetar safe-right."
  category-tile:
    backgroundColor: "{colors.surface-tint}" # claro; en oscuro {colors.dark-chip}
    textColor: "{colors.ink}"                # claro; en oscuro {colors.dark-ink}
    rounded: "{radii.card}"
    description: "Los 4 botones del menú principal (Farmacología, Escalas, Calculadoras, Esenciales)."
---

# Nurska — Frame (video vertical)

## Overview

Nurska en video es **una herramienta de turno, no un anuncio**. El registro es cálido y sobrio:
cafés tostados, crema, nada de azul hospital ni verde quirófano. La paleta viene de una sola
familia de cafés; el único color que "grita" es la rampa de alertas, que va de café neutro a rojo
vino y existe para comunicar gravedad clínica. Por eso en video el rojo se reserva para eso: un
riesgo, un puntaje alto, un error que se previene. Nunca como decoración.

**Rasgos a escala de frame:**

- **Dos registros, uno por video.** Claro (crema `#EFE9E4` + café `#624933`) u oscuro
  (`#14100B` + crema `#EFE9E4`). No se mezclan dentro del mismo video salvo en una transición que
  muestre el cambio de tema de la app.
- **Poppins 700** para todo lo que se lee de reojo; 600 para cuerpo; 400 solo para captions.
- **Esquinas redondeadas grandes** (78px) en tarjetas, botones y mockups. Nada cuadrado.
- **La banda café** (AppBar) es el elemento de marca más reconocible: úsala.

## The Frame

- **Formato:** 1080×1920, 9:16. Se mira en un celular, dentro de un feed, a medio brazo.
- **Zonas seguras:** contenido clave fuera de los 240px de arriba, los 420px de abajo y los 150px
  de la derecha. Esas franjas las tapan el nombre de la cuenta, el texto del post y los botones de
  la plataforma. Son valores de partida; se calibran contra una captura real de la plataforma.
- **Área útil:** ~858×1260px centrada. Ahí vive todo lo que el video necesita que se lea.
- **Un mensaje por frame.** Si un frame necesita dos ideas, son dos frames.

### Pruebas de ojo antes de cualquier revisión técnica

- **Entrecerrar:** un solo elemento domina (título `h1`/`display`, número `stat` o el mockup) y es
  3 a 6 veces más grande que lo que le sigue.
- **Pulgar:** tapa la franja inferior y la columna derecha con el dedo. Si se pierde algo, se movió mal.
- **Un segundo:** el texto del frame se entiende en un segundo de mirada. Si no, sobra texto.

## Colors

`{colors.bg}` es el lienzo del registro claro; `{colors.dark-ground}` el del oscuro. Los títulos
van en `{colors.ink}` (claro) o `{colors.dark-ink}` (oscuro). `{colors.accent}` (`#CBA786`) es el
dorado tostado: subrayados, un número destacado, el borde de una tarjeta activa. Solo uno por frame.

**Las tres reglas que vienen de la app y siguen valiendo aquí:**

1. En oscuro, la gravedad clínica tiene **dos colores por nivel**: `-text` para escribir sobre el
   lienzo, `-fill` para rellenar una pastilla con texto crema encima. Usar el `-text` como relleno
   deja el texto crema ilegible.
2. Un color de **superficie** nunca se usa como **tinta**, y viceversa. `{colors.surface-tint}`,
   `{colors.accent-light}` y `{colors.dark-enfasis}` son fondos, no texto.
3. Cuando un color marca **selección** (chip activo, opción elegida), en oscuro el seleccionado es
   el CLARO. Si en oscuro ambos quedan oscuros, está mal.

**Rampa de gravedad** (de menor a mayor): neutral → verde → rojo 1 → rojo 2 → rojo 3 → rojo 4.
En claro el rojo se oscurece al subir; en oscuro se satura. Nunca se inventa un nivel intermedio.

## Typography

**Poppins** en 400, 600 y 700, cargada desde los `.ttf` del repo con `@font-face`, no desde
Google Fonts, para que el render sea idéntico a la app. Poppins es una fuente muy común en video;
aquí va porque es la marca, no por elección estética, y no se sustituye.

**Escala:** cada tamaño de la app × 2.6 da su equivalente en el frame. La rampa de arriba ya está
convertida y subida al piso de video en feed:

| Uso | px | Peso |
|---|---|---|
| Número héroe (`stat`) | 220 | 700 |
| Display / portada | 160 | 700 |
| Título de frame (`h1`) | 112 | 700 |
| Subtítulo (`h2`) | 80 | 700 |
| Encabezado de tarjeta (`h3`) | 60 | 700 |
| Cuerpo fuerte | 46 | 600 |
| Cuerpo | 42 | 600 |
| Caption / fuente | 36 | 400 |

- **Piso absoluto: 34px.** Nada que deba leerse va más chico. Las referencias de fuente (NOM, GPC)
  van en `caption` y pueden tener un frame propio al cierre.
- **Ajuste a la medida:** 1 a 3 palabras → `display`; 4 a 7 → `h1`; 8 a 14 → `h2`. Más de 14
  palabras no es un título, es un párrafo y no va en un frame.
- **Ancho máximo de bloque:** 858px. Máximo 3 líneas por título, 5 por cuerpo.
- Títulos en sentence case, nunca todo en mayúsculas salvo `eyebrow`. Sin itálica.

## Depth & Surface

- **Claro:** la tarjeta blanca sobre crema se despega con `{shadows.card-light}`, una sombra corta
  y cálida (tinte `#2F2318`, no negro puro).
- **Oscuro:** sin sombra. La tarjeta (`#271F18`) se despega del lienzo (`#14100B`) por diferencia
  de color; una sombra sobre fondo casi negro no se ve y solo ensucia.
- Profundidad máxima: lienzo → tarjeta → pastilla. Tres capas, no más.

## Shapes

- **78px** — tarjetas, botones, tiles de categoría (el 30dp de la app).
- **999px** — pastillas de gravedad, chips.
- **96px** — marco del teléfono.
- **Nada cuadrado.** La app no tiene una sola esquina recta en contenido.

## Components

- **app-bar-band** — banda café con título crema. Encabezado natural de cualquier frame que
  presente una pantalla.
- **card** — una idea por tarjeta, padding 56px.
- **phone-mockup** — capturas reales de la app, nunca recreaciones. Máximo 780px de ancho.
- **severity-pill / severity-text** — el resultado de una escala. Es el único lugar donde aparece rojo.
- **button-primary / button-outline** — si se muestran dos, el principal va a la derecha.
- **category-tile** — los 4 módulos del menú principal; útiles para un frame de "qué trae la app".

## Do's and Don'ts

**Sí:**
- Capturas reales de la app dentro de `phone-mockup`.
- Un dato clínico concreto como héroe ("10 a 15 L/min", "Braden ≤ 12").
- Fuente del dato en `caption` (NOM, GPC) cuando el frame afirma algo clínico.

**No:**
- Azules, verdes o turquesas "de hospital". La marca es café.
- Rojo fuera de la rampa de gravedad o usado como acento decorativo.
- Raya larga (—) en cualquier texto en pantalla. Rangos con "a": "7 a 10 días".
- Texto en las zonas seguras de la plataforma.
- Pesos de Poppins que no existen en el repo (300, 500, 800).
- Mezclar registro claro y oscuro en el mismo video sin una razón narrativa.
