# Nurska

App móvil Flutter/Dart, offline-first, de referencia clínica para personal de enfermería (México). Sin backend, sin internet — todo vive en SQLite local del dispositivo.

## Quién soy y cómo prefiero trabajar
Soy estudiante de enfermería (casi egresado), no soy programador profesional. Tengo conocimientos básicos de programación pero estoy aprendiendo arquitectura de software sobre la marcha. Por favor:
- Explica brevemente el *por qué* de un cambio, no solo el *qué*, cuando sea una decisión de arquitectura.
- Prefiero cambios módulo por módulo, no refactors masivos de un jalón. Si una tarea toca muchos archivos, dime el plan antes de ejecutarlo.
- Si algo no compila o hay ambigüedad, pregunta antes de asumir.

## Stack
- Flutter/Dart (SDK ^3.11.1)
- `sqflite` para SQLite local, con migraciones manuales versionadas (`onUpgrade`)
- `provider` para inyección de dependencias y estado (agregado recientemente)
- `phosphor_flutter`, `url_launcher`, `shared_preferences`
- Datos de referencia (medicamentos, escalas, calculadoras, normas) se siembran desde JSON en `assets/data/*.json` hacia SQLite la primera vez que la app corre.

## Arquitectura (en migración activa — lee esto con cuidado)
Estamos migrando de un `DatabaseHelper` monolítico (SQL + lógica de negocio + logging mezclados) hacia capas separadas:

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

**Estado actual de la migración (julio 2026):**
- ✅ `medicamentos` — YA migrado: `MedicamentoDao` + `MedicamentoRepository`, conectado vía Provider en `main.dart`, y `farmacologia_screen.dart` / `ficha_medicamento.dart` ya usan el repository.
- ⏳ `escalas`, `calculadoras`, `normas` — pendientes, siguen usando `DatabaseHelper` directo.
- ⏳ `turno_activo` (pacientes_turno, pendientes_turno, medicamentos_turno) — pendiente, sigue usando `DatabaseHelper` directo.

Cuando migres un módulo nuevo, usa `medicamento_dao.dart` y `medicamento_repository.dart` como plantilla exacta del patrón (mismos nombres de método: `insertar`, `contar`, `obtenerTodos`, `obtenerPorNombre`, `cargarSemillaSiHaceFalta`).

## Convenciones
- Nombres de clases, métodos y variables de dominio en **español**, consistente con el resto del código (`obtenerTodos`, `Medicamento`, `PacienteTurno`, etc.).
- Nunca uses `print()` para logging — usa `debugPrint()`.
- Providers se registran en `main.dart` con `Provider<XRepository>.value(value: ..., child: ...)`.
- Después de cualquier cambio, verifica con `flutter analyze` antes de dar por hecho que algo compila.

## Qué NO hacer
- No modifiques módulos que no se te pidió tocar.
- No agregues dependencias nuevas sin decir cuáles y por qué.
- No renombres archivos/carpetas existentes sin confirmarlo antes.