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
      version: 6, // Aumentamos la versión a 6
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
        referencias TEXT
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
