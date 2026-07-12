import 'package:sqflite/sqflite.dart';
import 'package:nursia_app/models/calculadora_info.dart';

/// DAO = Data Access Object.
///
/// Esta clase SOLO sabe hablar SQL. No sabe nada de JSON semilla,
/// no sabe nada de reglas de negocio, no sabe nada de la UI.
/// Si mañana cambias de SQLite a otra base de datos, esta es la
/// ÚNICA clase que tendrías que reescribir para "calculadoras".
class CalculadoraDao {
  final Database db;

  CalculadoraDao(this.db);

  Future<void> insertar(CalculadoraInfo calculadora) async {
    await db.insert(
      'calculadoras',
      calculadora.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> contar() async {
    final resultado = await db.rawQuery('SELECT COUNT(*) FROM calculadoras');
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  Future<List<CalculadoraInfo>> obtenerTodos() async {
    final mapas = await db.query('calculadoras');
    return mapas.map(CalculadoraInfo.fromMap).toList();
  }

  Future<CalculadoraInfo?> obtenerPorId(String id) async {
    final mapas = await db.query(
      'calculadoras',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (mapas.isEmpty) return null;
    return CalculadoraInfo.fromMap(mapas.first);
  }
}
