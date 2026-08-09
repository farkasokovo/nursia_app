import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('nursia.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 18, // Aumentamos la versión a 18
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS normas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              codigo TEXT,
              titulo TEXT,
              titulo_corto TEXT,
              area_salud TEXT,
              resumen TEXT,
              palabras_clave TEXT,
              puntos_clave TEXT,
              dof_referencia TEXT
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS pacientes_turno (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              orden INTEGER NOT NULL DEFAULT 0
            )
          ''');
        }
        // Migración para las nuevas tablas de pendientes
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS catalogo_pendientes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              icono TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS pendientes_turno (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              icono TEXT NOT NULL,
              orden INTEGER NOT NULL DEFAULT 0
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS medicamentos_turno (
              id     INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT    NOT NULL,
              icono  TEXT    NOT NULL DEFAULT 'pill',
              orden  INTEGER NOT NULL DEFAULT 0
            )
          ''');
        }
        // Catálogo de pendientes ampliado: se vacía para que
        // cargarSemillaSiHaceFalta() lo vuelva a sembrar con el JSON nuevo.
        if (oldVersion < 6) {
          await db.delete('catalogo_pendientes');
        }
        // Contenido de escalas actualizado (corrección de Braden, limpieza de
        // puntuación y convención de saltos de línea). Se vacía la tabla para
        // que cargarSemillaSiHaceFalta() la vuelva a sembrar desde el JSON en
        // el próximo arranque. NO afecta datos del usuario (turno activo).
        if (oldVersion < 7) {
          await db.delete('escalas');
        }
        // Contenido de normas actualizado: "puntos_clave" pasó de un String
        // con saltos de línea a una lista de objetos {icono, texto} (cada
        // punto con su propio ícono). Se vacía la tabla para que
        // cargarSemillaSiHaceFalta() la vuelva a sembrar desde el JSON nuevo
        // en el próximo arranque. NO afecta datos del usuario (turno activo).
        if (oldVersion < 8) {
          await db.delete('normas');
        }
        // Se agregaron dos calculadoras nuevas (PAM y goteo) al JSON. Se vacía
        // la tabla para que cargarSemillaSiHaceFalta() la vuelva a sembrar con
        // el contenido actualizado en el próximo arranque. NO afecta datos del
        // usuario (turno activo).
        if (oldVersion < 9) {
          await db.delete('calculadoras');
        }
        // Contenido de la calculadora de PAM actualizado (se retiró la
        // interpretación pediátrica y su nota). Se vacía la tabla para que
        // cargarSemillaSiHaceFalta() la vuelva a sembrar con el JSON nuevo en
        // el próximo arranque. NO afecta datos del usuario (turno activo).
        if (oldVersion < 10) {
          await db.delete('calculadoras');
        }
        // Se agregaron dos normas nuevas (NOM-022 terapia de infusión y NOM-087
        // RPBI) al JSON. Se vacía la tabla para que cargarSemillaSiHaceFalta()
        // la vuelva a sembrar con el contenido actualizado en el próximo
        // arranque. NO afecta datos del usuario (turno activo).
        if (oldVersion < 11) {
          await db.delete('normas');
        }
        // Se agregó el campo "altoRiesgo" a medicamentos (electrolitos
        // concentrados, insulinas, anticoagulantes, citotóxicos). Se agrega
        // la columna a la tabla existente y se vacía para que
        // cargarSemillaSiHaceFalta() la vuelva a sembrar con el JSON
        // actualizado en el próximo arranque. NO afecta datos del usuario
        // (turno activo).
        if (oldVersion < 12) {
          await db.execute(
            'ALTER TABLE medicamentos ADD COLUMN altoRiesgo INTEGER NOT NULL DEFAULT 0',
          );
          await db.delete('medicamentos');
        }
        // Se agregó el campo "dilucion" a medicamentos (objeto JSON con
        // reconstitución, diluyente y tiempos de perfusión). Se agrega la
        // columna a la tabla existente y se vacía para que
        // cargarSemillaSiHaceFalta() la vuelva a sembrar con el JSON
        // actualizado en el próximo arranque. NO afecta datos del usuario
        // (turno activo).
        if (oldVersion < 13) {
          await db.execute('ALTER TABLE medicamentos ADD COLUMN dilucion TEXT');
          await db.delete('medicamentos');
        }
        // Se agregó contenido de dilución al JSON de medicamentos (9 fármacos
        // con reconstitución, diluyente y tiempos de perfusión con fuente
        // citada). Se vacía la tabla para que cargarSemillaSiHaceFalta() la
        // vuelva a sembrar con el JSON actualizado en el próximo arranque. NO
        // afecta datos del usuario (turno activo).
        if (oldVersion < 14) {
          await db.delete('medicamentos');
        }
        // El campo "requiereDilucion" dentro de "dilucion" cambió de booleano
        // a cadena, con cuatro estados clínicos ("no_requiere", "no_diluir",
        // "opcional", "requiere"). Se vacía la tabla para que
        // cargarSemillaSiHaceFalta() la vuelva a sembrar con el JSON en el
        // formato nuevo en el próximo arranque. NO afecta datos del usuario
        // (turno activo).
        if (oldVersion < 15) {
          await db.delete('medicamentos');
        }
        // Se corrigió el umbral de pH en las observaciones de furosemida: la
        // solución no tiene capacidad tamponante, su pH es 9 y el principio
        // activo precipita por debajo de pH 7 (antes decía pH 5.5). Se vacía
        // la tabla para que cargarSemillaSiHaceFalta() la vuelva a sembrar con
        // el JSON corregido en el próximo arranque. NO afecta datos del
        // usuario (turno activo).
        if (oldVersion < 16) {
          await db.delete('medicamentos');
        }
        // El objeto "dilucion" se reestructuró: se retiraron "ivDirecta" y
        // "perfusionIntermitente", y en su lugar entraron "volumen",
        // "tiempoInfusion" y "bolo". El diluyente ahora aclara si requiere
        // dilución o ya viene aforado. Se vacía la tabla para que
        // cargarSemillaSiHaceFalta() la vuelva a sembrar con el JSON en el
        // formato nuevo en el próximo arranque. NO afecta datos del usuario
        // (turno activo).
        if (oldVersion < 17) {
          await db.delete('medicamentos');
        }
        // Se restauró "perfusionIntermitente" dentro de "dilucion", que se
        // había retirado en la v17. Convive con "volumen" y "tiempoInfusion".
        // Se vacía la tabla para que cargarSemillaSiHaceFalta() la vuelva a
        // sembrar con el JSON actualizado en el próximo arranque. NO afecta
        // datos del usuario (turno activo).
        if (oldVersion < 18) {
          await db.delete('medicamentos');
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. Tabla de Medicamentos
    await db.execute('''
      CREATE TABLE medicamentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        icono TEXT,
        categoria TEXT,
        farmacodinamia TEXT,
        farmacocinetica TEXT,
        indicaciones TEXT,
        viaAdministracion TEXT,
        contraindicaciones TEXT,
        efectosSecundarios TEXT,
        efectosAdversos TEXT,
        interacciones TEXT,
        observaciones TEXT,
        dilucion TEXT,
        referencias TEXT,
        altoRiesgo INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 2. Tabla de Escalas
    await db.execute('''
      CREATE TABLE escalas (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        categoria TEXT,
        ruta TEXT,
        description TEXT,
        when_to_use TEXT,
        components TEXT,
        interpretation TEXT,
        limitations TEXT,
        clinical_notes TEXT,
        references_data TEXT
      )
    ''');

    // 3. Tabla de Calculadoras
    await db.execute('''
      CREATE TABLE calculadoras (
        id TEXT PRIMARY KEY,
        titulo TEXT NOT NULL,
        descripcion TEXT,
        formula TEXT,
        notas TEXT,
        referencias TEXT
      )
    ''');

    // 4. Tabla de Normas (NOMs)
    await db.execute('''
      CREATE TABLE normas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo TEXT,
        titulo TEXT,
        titulo_corto TEXT,
        area_salud TEXT,
        resumen TEXT,
        palabras_clave TEXT,
        puntos_clave TEXT,
        dof_referencia TEXT
      )
    ''');

    // 5. Tabla de Pacientes del Turno Activo
    await db.execute('''
      CREATE TABLE pacientes_turno (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        orden INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 6. Tabla de Catálogo de Pendientes (JSON)
    await db.execute('''
      CREATE TABLE catalogo_pendientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        icono TEXT NOT NULL
      )
    ''');

    // 7. Tabla de Pendientes del Turno Activo
    await db.execute('''
      CREATE TABLE pendientes_turno (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        icono TEXT NOT NULL,
        orden INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE medicamentos_turno (
        id     INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT    NOT NULL,
        icono  TEXT    NOT NULL DEFAULT 'pill',
        orden  INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
