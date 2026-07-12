import 'package:sqflite/sqflite.dart';
import 'package:nursia_app/models/norma.dart';

/// DAO = Data Access Object.
///
/// Esta clase SOLO sabe hablar SQL. No sabe nada de JSON semilla,
/// no sabe nada de reglas de negocio, no sabe nada de la UI.
/// Si mañana cambias de SQLite a otra base de datos, esta es la
/// ÚNICA clase que tendrías que reescribir para "normas".
class NormaDao {
  final Database db;

  NormaDao(this.db);

  Future<void> insertar(Norma norma) async {
    await db.insert(
      'normas',
      norma.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> contar() async {
    final resultado = await db.rawQuery('SELECT COUNT(*) FROM normas');
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  Future<List<Norma>> obtenerTodos() async {
    final mapas = await db.query('normas');
    return mapas.map(Norma.fromMap).toList();
  }
}
