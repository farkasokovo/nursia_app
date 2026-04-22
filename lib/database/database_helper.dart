import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:nursia_app/models/calculadora_info.dart';
import 'package:nursia_app/models/escala_metadata.dart';
import 'package:nursia_app/models/medicamento.dart';
import 'package:nursia_app/models/ver_mas_screen.dart';
import 'package:nursia_app/models/norma.dart';
import 'package:nursia_app/turno_activo/models/paciente.dart';
import 'package:nursia_app/turno_activo/models/pendiente_info.dart'; // ¡NUEVO IMPORT!
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
      version: 5, // Aumentamos la versión a 5
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
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // =========================================================
  // SECCIÓN MEDICAMENTOS
  // =========================================================
  Future<void> insertarMedicamento(Medicamento medicamento) async {
    final db = await instance.database;
    await db.insert(
      'medicamentos',
      medicamento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> cargarSemillaDesdeJSON() async {
    final db = await instance.database;
    final resultado = await db.rawQuery('SELECT COUNT(*) FROM medicamentos');
    int? cuenta = Sqflite.firstIntValue(resultado);

    if (cuenta == 0) {
      try {
        final String respuesta = await rootBundle.loadString(
          'assets/data/medicamentos.json',
        );
        final List<dynamic> data = json.decode(respuesta);
        for (var item in data) {
          final medicamento = Medicamento.fromJson(item);
          await insertarMedicamento(medicamento);
        }
      } catch (e) {
        print("Error en la migración: $e");
      }
    } else {
      print(
        "La base de datos ya tiene $cuenta medicamentos. Saltando migración.",
      );
    }
  }

  Future<List<Medicamento>> obtenerTodosLosMedicamentos() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> mapas = await db.query('medicamentos');
    return List.generate(mapas.length, (i) {
      return Medicamento.fromMap(mapas[i]);
    });
  }

  Future<Medicamento?> obtenerMedicamentoPorNombre(String nombre) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> mapas = await db.query(
      'medicamentos',
      where: 'nombre = ?',
      whereArgs: [nombre],
    );
    if (mapas.isNotEmpty) {
      return Medicamento.fromMap(mapas.first);
    }
    return null;
  }

  // =========================================================
  // SECCIÓN ESCALAS
  // =========================================================
  Future<void> insertarEscala(Map<String, dynamic> row) async {
    final db = await instance.database;
    await db.insert(
      'escalas',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> cargarEscalasDesdeJSON() async {
    final db = await instance.database;
    final resultado = await db.rawQuery('SELECT COUNT(*) FROM escalas');
    int? cuenta = Sqflite.firstIntValue(resultado);

    if (cuenta == 0) {
      try {
        final String jsonLista = await rootBundle.loadString(
          'assets/data/escalas_lista.json',
        );
        final Map<String, dynamic> dataLista = json.decode(jsonLista);
        final List<dynamic> escalasLista = dataLista['escalas'];

        final String jsonData = await rootBundle.loadString(
          'assets/data/scales_data.json',
        );
        final Map<String, dynamic> dataClinica = json.decode(jsonData);

        for (var item in escalasLista) {
          String id = item['id'];
          final detalles = dataClinica[id];

          if (detalles != null) {
            final Map<String, dynamic> row = {
              'id': id,
              'nombre': item['nombre'],
              'categoria': item['categoria'],
              'ruta': item['ruta'],
              'description': detalles['description'],
              'when_to_use': jsonEncode(detalles['when_to_use']),
              'components': jsonEncode(detalles['components']),
              'interpretation': jsonEncode(detalles['interpretation']),
              'limitations': jsonEncode(detalles['limitations']),
              'clinical_notes': jsonEncode(detalles['clinical_notes']),
              'references_data': jsonEncode(detalles['references']),
            };
            await insertarEscala(row);
          }
        }
        print("¡Escalas migradas correctamente!");
      } catch (e) {
        print("Error migrando escalas: $e");
      }
    }
  }

  Future<List<EscalaMetadata>> obtenerEscalasMetadata() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> mapas = await db.query(
      'escalas',
      columns: ['id', 'nombre', 'categoria', 'ruta'],
    );
    return mapas.map((m) => EscalaMetadata.fromMap(m)).toList();
  }

  Future<VerMasScreen?> obtenerDetalleEscala(String id) async {
    final db = await instance.database;
    final mapas = await db.query('escalas', where: 'id = ?', whereArgs: [id]);
    if (mapas.isNotEmpty) {
      return VerMasScreen.fromMap(mapas.first);
    }
    return null;
  }

  // =========================================================
  // SECCIÓN CALCULADORAS
  // =========================================================
  Future<void> cargarCalculadorasDesdeJSON() async {
    final db = await instance.database;
    final resultado = await db.rawQuery('SELECT COUNT(*) FROM calculadoras');
    int? cuenta = Sqflite.firstIntValue(resultado);

    if (cuenta == 0) {
      try {
        final String respuesta = await rootBundle.loadString(
          'assets/data/calculadoras_info.json',
        );
        final Map<String, dynamic> data = json.decode(respuesta);
        final List<dynamic> calculadoras = data['calculadoras'];

        for (var item in calculadoras) {
          final calc = CalculadoraInfo.fromJson(item);
          await db.insert(
            'calculadoras',
            calc.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        print("¡Calculadoras migradas!");
      } catch (e) {
        print("Error migrando calculadoras: $e");
      }
    }
  }

  Future<CalculadoraInfo?> obtenerInfoCalculadora(String id) async {
    final db = await instance.database;
    final mapas = await db.query(
      'calculadoras',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (mapas.isNotEmpty) {
      return CalculadoraInfo.fromMap(mapas.first);
    }
    return null;
  }

  // =========================================================
  // SECCIÓN NORMAS (NOMs)
  // =========================================================
  Future<void> cargarNormasDesdeJSON() async {
    final db = await instance.database;
    final resultado = await db.rawQuery('SELECT COUNT(*) FROM normas');
    int? cuenta = Sqflite.firstIntValue(resultado);

    if (cuenta == 0) {
      try {
        final String respuesta = await rootBundle.loadString(
          'assets/data/normas_data.json',
        );
        final List<dynamic> data = json.decode(respuesta);

        for (var item in data) {
          await db.insert('normas', {
            'codigo': item['codigo'],
            'titulo': item['titulo'],
            'titulo_corto': item['titulo_corto'],
            'area_salud': item['area_salud'],
            'resumen': item['resumen'],
            'palabras_clave': item['palabras_clave'],
            'puntos_clave': item['puntos_clave'],
            'dof_referencia': item['dof_referencia'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        print("¡Normas migradas con éxito!");
      } catch (e) {
        print("Error migrando normas: $e");
      }
    }
  }

  Future<List<Norma>> obtenerTodasLasNormas() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> mapas = await db.query('normas');

    return List.generate(mapas.length, (i) {
      return Norma.fromMap(mapas[i]);
    });
  }

  // =========================================================
  // SECCIÓN PACIENTES DEL TURNO ACTIVO
  // =========================================================
  Future<Paciente> insertarPacienteTurno(Paciente paciente) async {
    final db = await instance.database;
    final id = await db.insert(
      'pacientes_turno',
      paciente.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return paciente.copyWith(id: id);
  }

  Future<List<Paciente>> obtenerPacientesTurno() async {
    final db = await instance.database;
    final mapas = await db.query('pacientes_turno', orderBy: 'orden ASC');
    return mapas.map((m) => Paciente.fromMap(m)).toList();
  }

  Future<void> eliminarPacienteTurno(int id) async {
    final db = await instance.database;
    await db.delete('pacientes_turno', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> actualizarOrdenPacientes(List<Paciente> pacientes) async {
    final db = await instance.database;
    final batch = db.batch();
    for (int i = 0; i < pacientes.length; i++) {
      final p = pacientes[i];
      if (p.id != null) {
        batch.update(
          'pacientes_turno',
          {'orden': i},
          where: 'id = ?',
          whereArgs: [p.id],
        );
      }
    }
    await batch.commit(noResult: true);
  }

  // =========================================================
  // SECCIÓN PENDIENTES (NUEVO)
  // =========================================================

  /// Carga la lista inicial del JSON al catálogo (para el buscador)
  Future<void> cargarCatalogoPendientesDesdeJSON() async {
    final db = await instance.database;
    final resultado = await db.rawQuery(
      'SELECT COUNT(*) FROM catalogo_pendientes',
    );
    int? cuenta = Sqflite.firstIntValue(resultado);

    if (cuenta == 0) {
      try {
        final String respuesta = await rootBundle.loadString(
          'assets/data/pendientes_data.json',
        );
        final List<dynamic> data = json.decode(respuesta);

        for (var item in data) {
          await db.insert('catalogo_pendientes', {
            'nombre': item['nombre'],
            'icono': item['icono'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        print("¡Catálogo de pendientes migrado con éxito!");
      } catch (e) {
        print("Error migrando catálogo de pendientes: $e");
      }
    }
  }

  /// Obtiene todo el catálogo de pendientes disponibles para sugerir
  Future<List<PendienteInfo>> obtenerCatalogoPendientes() async {
    final db = await instance.database;
    final mapas = await db.query('catalogo_pendientes');
    return mapas.map((m) => PendienteInfo.fromMap(m)).toList();
  }

  /// Inserta un pendiente en la lista activa del turno del usuario
  Future<PendienteInfo> insertarPendienteTurno(PendienteInfo pendiente) async {
    final db = await instance.database;
    final id = await db.insert('pendientes_turno', {
      'nombre': pendiente.nombre,
      'icono': pendiente.icono,
      'orden': pendiente.orden,
    });
    return pendiente.copyWith(id: id);
  }

  /// Carga los pendientes activos ordenados
  Future<List<PendienteInfo>> obtenerPendientesTurno() async {
    final db = await instance.database;
    final mapas = await db.query('pendientes_turno', orderBy: 'orden ASC');
    return mapas.map((m) => PendienteInfo.fromMap(m)).toList();
  }

  /// Elimina un pendiente de la lista del turno activo
  Future<void> eliminarPendienteTurno(int id) async {
    final db = await instance.database;
    await db.delete('pendientes_turno', where: 'id = ?', whereArgs: [id]);
  }

  /// Actualiza el orden cuando haces reorder (igual que en pacientes)
  Future<void> actualizarOrdenPendientes(List<PendienteInfo> pendientes) async {
    final db = await instance.database;
    final batch = db.batch();
    for (int i = 0; i < pendientes.length; i++) {
      final p = pendientes[i];
      if (p.id != null) {
        batch.update(
          'pendientes_turno',
          {'orden': i},
          where: 'id = ?',
          whereArgs: [p.id],
        );
      }
    }
    await batch.commit(noResult: true);
  }
}
