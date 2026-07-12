import 'package:sqflite/sqflite.dart';
import 'package:nursia_app/models/medicamento.dart';

/// DAO = Data Access Object.
///
/// Esta clase SOLO sabe hablar SQL. No sabe nada de JSON semilla,
/// no sabe nada de reglas de negocio, no sabe nada de la UI.
/// Si mañana cambias de SQLite a otra base de datos, esta es la
/// ÚNICA clase que tendrías que reescribir para "medicamentos".
class MedicamentoDao {
  final Database db;

  MedicamentoDao(this.db);

  Future<void> insertar(Medicamento medicamento) async {
    await db.insert(
      'medicamentos',
      medicamento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> contar() async {
    final resultado = await db.rawQuery('SELECT COUNT(*) FROM medicamentos');
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  Future<List<Medicamento>> obtenerTodos() async {
    final mapas = await db.query('medicamentos');
    return mapas.map(Medicamento.fromMap).toList();
  }

  Future<Medicamento?> obtenerPorNombre(String nombre) async {
    final mapas = await db.query(
      'medicamentos',
      where: 'nombre = ?',
      whereArgs: [nombre],
    );
    if (mapas.isEmpty) return null;
    return Medicamento.fromMap(mapas.first);
  }
}
