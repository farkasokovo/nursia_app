# Nurska

App móvil Flutter/Dart, offline-first, de referencia clínica para personal de enfermería (México). Sin backend, sin internet — todo vive en SQLite local del dispositivo.

## Quién soy y cómo prefiero trabajar
Soy DIEGO estudiante de enfermería (casi egresado), no soy programador profesional. Tengo conocimientos básicos de programación pero estoy aprendiendo arquitectura de software sobre la marcha. Por favor:
- Explica brevemente el *por qué* de un cambio, no solo el *qué*, cuando sea una decisión de arquitectura.
- Prefiero cambios módulo por módulo, no refactors masivos de un jalón. Si una tarea toca muchos archivos, dime el plan antes de ejecutarlo.
- Si algo no compila o hay ambigüedad, pregunta antes de asumir.

## Stack
- Flutter/Dart (SDK ^3.11.1)
- `sqflite` para SQLite local, con migraciones manuales versionadas (`onUpgrade`)
- `provider` para inyección de dependencias y estado (agregado recientemente)
- `phosphor_flutter`, `url_launcher`, `shared_preferences`
- Datos de referencia (medicamentos, escalas, calculadoras, normas) se siembran desde JSON en `assets/data/*.json` hacia SQLite la primera vez que la app corre.

## Arquitectura
Migramos de un `DatabaseHelper` monolítico (SQL + lógica de negocio + logging mezclados) hacia capas separadas:

```
lib/
  models/                    Modelos de datos (fromMap/toMap/fromJson). Sin lógica de negocio.
  data/local/daos/           DAOs: SOLO SQL crudo. Reciben un Database ya abierto. Nunca lógica de negocio.
  repositories/              Lógica de negocio (ej. "si la tabla está vacía, cargar semilla JSON").
                             Las pantallas SOLO hablan con repositories, nunca con DAOs ni con DatabaseHelper directo.
  database/database_helper.dart   Legacy: hoy mezcla conexión+migraciones+lógica vieja de módulos
                                   aún no migrados. Se está adelgazando poco a poco — NO agregar
                                   lógica nueva aquí, solo conexión y migraciones de schema.
  screens/                   UI. Obtienen su repository vía Provider (`context.read<XRepository>()`),
                             normalmente en initState.
```

**Estado actual de la migración (julio 2026): ✅ COMPLETA.**
Los 7 módulos ya están migrados al patrón Dao + Repository + Provider: `medicamentos`, `escalas`, `calculadoras`, `normas`, y los tres de `turno_activo` (`pacientes_turno`, `pendientes_turno`, `medicamentos_turno`). Todos conectados vía `MultiProvider` en `main.dart`.

`database_helper.dart` quedó adelgazado a ~187 líneas: SOLO conexión (`database` getter, `_initDB`), migraciones de schema (`_createDB`, `onUpgrade`) y `close()`. Ninguna lógica de negocio ni carga de JSON debe volver a vivir ahí.

Si en el futuro se agrega un módulo nuevo (tabla nueva), usa `medicamento_dao.dart` y `medicamento_repository.dart` como plantilla exacta del patrón (mismos nombres de método: `insertar`, `contar`, `obtenerTodos`, `obtenerPorNombre`/`obtenerPorId`, `cargarSemillaSiHaceFalta`). Para tablas sin semilla JSON (datos generados por el usuario, como los de `turno_activo`), usa `paciente_turno_dao.dart` / `paciente_turno_repository.dart` como plantilla — mismo patrón pero sin `cargarSemillaSiHaceFalta`.

## Convenciones
- Nombres de clases, métodos y variables de dominio en **español**, consistente con el resto del código (`obtenerTodos`, `Medicamento`, `PacienteTurno`, etc.).
- Nunca uses `print()` para logging — usa `debugPrint()`.
- Providers se registran en `main.dart` con `Provider<XRepository>.value(value: ..., child: ...)`.
- Después de cualquier cambio, verifica con `flutter analyze` antes de dar por hecho que algo compila.

## Cómo agregar medicamentos nuevos a Farmacología

DIEGO provee la info clínica de cada fármaco en texto (farmacodinamia, farmacocinética, indicaciones, contraindicaciones, efectos, interacciones, referencias). Este es el flujo paso a paso para convertir eso en algo funcional en la app.

### Paso 0 — Regla de oro: el seed solo carga una vez
`MedicamentoRepository.cargarSemillaSiHaceFalta()` (llamado desde `main.dart`) solo lee `assets/data/medicamentos.json` si la tabla `medicamentos` está vacía. Si el emulador/celular de pruebas ya corrió la app antes, **los medicamentos nuevos no van a aparecer hasta borrar los datos de la app o desinstalar/reinstalar**. Avisar esto siempre al terminar.

### Paso 1 — Agregar los fármacos a `assets/data/medicamentos.json`
Es una lista plana de objetos. Cada uno debe tener EXACTAMENTE estos campos (los lee `Medicamento.fromJson` en `lib/models/medicamento.dart`):

```json
{
  "nombre": "string — debe ser único, se usa como clave de búsqueda",
  "icono": "string — ver Paso 2",
  "categoria": "string — snake/lowercase, ej. 'anticoagulante'",
  "farmacodinamia": "string — párrafos separados con \\n si son varios puntos",
  "farmacocinetica": "string — convención: 'Absorción: ...\\nDistribución: ...\\nMetabolismo: ...\\nEliminación: ...'",
  "indicaciones": "string — puntos separados con \\n, cada uno terminado en punto",
  "viaAdministracion": "string corto, ej. 'IV, SC'",
  "contraindicaciones": { "absolutas": ["..."], "relativas": ["..."] },
  "efectosSecundarios": ["..."],
  "efectosAdversos": ["..."],
  "interacciones": [
    { "medicamento": "...", "efecto": "...", "severidad": "alta" | "media" | "baja" }
  ],
  "observaciones": { "preparacion": "...", "administracion": "...", "precauciones": "..." },
  "referencias": [{ "text": "cita APA sin el link", "url": "..." }]
}
```

Notas:
- `farmacodinamia`, `farmacocinetica`, `indicaciones`, `viaAdministracion` son **strings**, no arrays — si el usuario da una lista con viñetas, se unen con `\n` dentro del mismo string (así ya lo hace todo el archivo).
- `observaciones` es opcional y sus 3 campos también lo son individualmente — solo incluir los que el usuario haya dado info que aplique (ej. notas de seguridad, tiempos de acción, cosas que no encajan bien en otro campo).
- `severidad` en interacciones: asignar con criterio clínico según lo que describa el efecto (hemorragias graves/riesgo de trombosis → `alta`; manejable con monitoreo → `media`/`baja`).
- Puedo editar el JSON directo con un script Python corto (leer, `.append()`, volver a escribir con `indent=2, ensure_ascii=False`) para no arriesgar errores de sintaxis a mano en archivos largos — así lo hice la primera vez.

### Paso 2 — Ícono de la categoría
Revisar `lib/utils/icon_mapper.dart`: si la categoría nueva encaja con un ícono ya mapeado (ej. `drop` para algo relacionado a sangre/fluidos, `heartbeat` para cardiovascular), reusarlo — evita tocar un archivo `.dart` y mantiene el cambio 100% en datos. Si de verdad no hay ninguno que encaje, ahí sí hay que agregar un `case` nuevo en el `switch` de `IconMapper.fromString`, con un ícono de Phosphor apropiado.

### Paso 3 — ¿Categoría nueva o fármaco de una categoría existente?

**Si es un fármaco más de una categoría que YA tiene pantalla** (ej. otro antibiótico): solo agregar un `FarmaButton` más dentro de esa pantalla existente en `lib/screens/farmacologia/<categoria>_screen.dart`, apuntando a `FichaMedicamento(nombreMedicamento: "Nombre Exacto")`. No se toca nada más.

**Si es una categoría/grupo nuevo** : crear una pantalla nueva en `lib/screens/farmacologia/<categoria>_screen.dart`, copiando la estructura de `diureticos_screen.dart` como plantilla exacta:
- Un widget StatelessWidget que envuelve todo en `ExpandableCategoryScreen` (con `heroTag`, `title`, `icon`).
- Un `_XLayout` interno con un `Column` de `FarmaButton`, uno por cada fármaco de esa categoría, cada uno navegando con `Navigator.push` a `FichaMedicamento(nombreMedicamento: "...")`.

⚠️ **`nombreMedicamento` debe coincidir EXACTO (mismos acentos, mismas mayúsculas) con el campo `"nombre"` del JSON** — `FichaMedicamento` busca con `MedicamentoRepository.obtenerPorNombre()`, que es un match exacto por SQL `WHERE nombre = ?`, no aproximado.

Luego, registrar la categoría nueva en `lib/screens/farmacologia_screen.dart`:
1. Import del archivo nuevo.
2. Un `_buildButton("Título", icono, "heroTag", const XScreen())` más dentro de la lista `todasLasCategorias`.

### Paso 4 — Verificar
- `flutter analyze` — debe dar 0 issues.
- Recordar a DIEGO el Paso 0 (borrar datos de la app / reinstalar) para ver los fármacos nuevos reflejados.

### Si DIEGO pide un campo que el modelo NO tiene hoy
(ej. "dosis pediátrica" como columna nueva, no solo texto dentro de un campo existente) — eso NO es este flujo. Requiere: agregar el campo a `Medicamento` (`fromJson`/`fromMap`/`toMap`), una migración de schema en `database_helper.dart` (`onUpgrade`, bump de `version`), y ajustar `MedicamentoDao`. Avisar al usuario que es un cambio de arquitectura más grande antes de tocarlo.

## Qué NO hacer
- No modifiques módulos que no se te pidió tocar.
- No agregues dependencias nuevas sin decir cuáles y por qué.
- No renombres archivos/carpetas existentes sin confirmarlo antes.