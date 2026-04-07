import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:nursia_app/models/escala_metadata.dart';
import 'package:nursia_app/models/medicamento.dart';
import 'package:nursia_app/models/ver_mas_screen.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // El "Getter" para obtener la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('nursia.db');
    return _database!;
  }

  // Inicializa la base de datos en el almacenamiento del celular
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1, // Si luego cambias la estructura, subes este número
      onCreate: _createDB,
    );
  }

  // Aquí definimos el "molde" (la tabla) de tus medicamentos
  // Aquí definimos el "molde" (las tablas) de Nursia
  Future _createDB(Database db, int version) async {
    // 1. Tabla de Medicamentos (Esta ya la tienes, la dejamos intacta)
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
        referencias TEXT
      )
    ''');

    // 2. NUEVA: Tabla de Escalas (Fusionada)
    await db.execute('''
      CREATE TABLE escalas (
        id TEXT PRIMARY KEY, -- Usaremos 'glasgow', 'ramsay' como identificador único
        nombre TEXT NOT NULL,
        categoria TEXT,
        ruta TEXT,
        description TEXT,
        when_to_use TEXT,    -- Lista convertida a texto con jsonEncode
        components TEXT,     -- Lista convertida a texto
        interpretation TEXT, -- Lista convertida a texto
        limitations TEXT,    -- Lista convertida a texto
        clinical_notes TEXT, -- Lista convertida a texto
        references_data TEXT -- Lista de mapas convertida a texto
      )
    ''');
  }

  // Función para cerrar la base de datos cuando no se use
  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // --- FUNCIÓN PARA INSERTAR UN MEDICAMENTO ---
  Future<void> insertarMedicamento(Medicamento medicamento) async {
    final db = await instance.database;

    // Aquí usamos el toMap() que creamos en el paso anterior.
    // conflictAlgorithm asegura que si un medicamento ya existe, lo reemplace y no marque error.
    await db.insert(
      'medicamentos',
      medicamento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- LA FUNCIÓN "PUENTE" (MIGRACIÓN) ---
  Future<void> cargarSemillaDesdeJSON() async {
    final db = await instance.database;

    // 1. Verificamos si ya hay datos para no duplicar cada vez que abras la app
    final resultado = await db.rawQuery('SELECT COUNT(*) FROM medicamentos');
    int? cuenta = Sqflite.firstIntValue(resultado);

    if (cuenta == 0) {
      // print("Base de datos vacía. Iniciando migración desde JSON...");

      try {
        // 2. Leemos el archivo JSON original (el que ya tienes en assets)
        final String respuesta = await rootBundle.loadString(
          'assets/data/medicamentos.json',
        );
        final List<dynamic> data = json.decode(respuesta);

        // 3. Recorremos la lista del JSON
        for (var item in data) {
          // Convertimos el mapa del JSON a un objeto Medicamento
          final medicamento = Medicamento.fromJson(item);

          // Lo guardamos en SQLite usando nuestra nueva función
          await insertarMedicamento(medicamento);
        }
        // print("¡Migración completada con éxito!");
      } catch (e) {
        print("Error en la migración: $e");
      }
    } else {
      print(
        "La base de datos ya tiene $cuenta medicamentos. Saltando migración.",
      );
    }
  }

  // --- FUNCIÓN PARA OBTENER TODOS (Para tu lista de farmacología) ---
  Future<List<Medicamento>> obtenerTodosLosMedicamentos() async {
    final db = await instance.database;

    // Le pedimos a la base de datos todos los registros de la tabla
    final List<Map<String, dynamic>> mapas = await db.query('medicamentos');

    // Convertimos cada fila de la tabla de vuelta a un objeto Medicamento de Dart
    return List.generate(mapas.length, (i) {
      return Medicamento.fromMap(mapas[i]);
    });
  }

  // --- 1. INSERTAR UNA ESCALA ---
  Future<void> insertarEscala(Map<String, dynamic> row) async {
    final db = await instance.database;
    await db.insert(
      'escalas',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- 2. EL PUENTE DE MIGRACIÓN PARA ESCALAS ---
  Future<void> cargarEscalasDesdeJSON() async {
    final db = await instance.database;

    // Verificamos si la tabla de escalas ya tiene datos
    final resultado = await db.rawQuery('SELECT COUNT(*) FROM escalas');
    int? cuenta = Sqflite.firstIntValue(resultado);

    if (cuenta == 0) {
      //print("Iniciando migración de Escalas...");
      try {
        // A. Cargamos el archivo de la LISTA (Metadata)
        final String jsonLista = await rootBundle.loadString(
          'assets/data/escalas_lista.json',
        );
        final Map<String, dynamic> dataLista = json.decode(jsonLista);
        final List<dynamic> escalasLista = dataLista['escalas'];

        // B. Cargamos el archivo de los DATOS CLÍNICOS (Diccionario)
        final String jsonData = await rootBundle.loadString(
          'assets/data/scales_data.json',
        );
        final Map<String, dynamic> dataClinica = json.decode(jsonData);

        // C. Fusionamos ambos mundos
        for (var item in escalasLista) {
          String id = item['id'];

          // Buscamos los detalles en el segundo JSON usando el ID
          final detalles = dataClinica[id];

          if (detalles != null) {
            // Creamos el mapa final para la base de datos
            final Map<String, dynamic> row = {
              'id': id,
              'nombre': item['nombre'],
              'categoria': item['categoria'],
              'ruta': item['ruta'],
              'description': detalles['description'],
              // Convertimos las listas a texto plano para SQLite
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

  // --- 3. OBTENER LISTA PARA EL BUSCADOR ---
  Future<List<EscalaMetadata>> obtenerEscalasMetadata() async {
    final db = await instance.database;
    // Solo pedimos las columnas necesarias para que sea ultra rápido
    final List<Map<String, dynamic>> mapas = await db.query(
      'escalas',
      columns: ['id', 'nombre', 'categoria', 'ruta'],
    );

    return mapas.map((m) => EscalaMetadata.fromMap(m)).toList();
  }

  // --- 4. OBTENER DETALLE CLÍNICO (Para el "Ver Más") ---
  Future<VerMasScreen?> obtenerDetalleEscala(String id) async {
    final db = await instance.database;
    final mapas = await db.query('escalas', where: 'id = ?', whereArgs: [id]);

    if (mapas.isNotEmpty) {
      return VerMasScreen.fromMap(mapas.first);
    }
    return null;
  }
}
