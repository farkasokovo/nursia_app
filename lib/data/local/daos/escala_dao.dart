import 'package:sqflite/sqflite.dart';
import 'package:nursia_app/models/escala_metadata.dart';
import 'package:nursia_app/models/ver_mas_screen.dart';

/// DAO = Data Access Object.
///
/// Esta clase SOLO sabe hablar SQL. No sabe nada de JSON semilla,
/// no sabe nada de reglas de negocio, no sabe nada de la UI.
/// Si mañana cambias de SQLite a otra base de datos, esta es la
/// ÚNICA clase que tendrías que reescribir para "escalas".
class EscalaDao {
  final Database db;

  EscalaDao(this.db);

  Future<void> insertar(Map<String, dynamic> row) async {
    await db.insert(
      'escalas',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> contar() async {
    final resultado = await db.rawQuery('SELECT COUNT(*) FROM escalas');
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  Future<List<EscalaMetadata>> obtenerTodos() async {
    final mapas = await db.query(
      'escalas',
      columns: ['id', 'nombre', 'categoria', 'ruta'],
    );
    return mapas.map(EscalaMetadata.fromMap).toList();
  }

  Future<VerMasScreen?> obtenerPorId(String id) async {
    final mapas = await db.query('escalas', where: 'id = ?', whereArgs: [id]);
    if (mapas.isEmpty) return null;
    return VerMasScreen.fromMap(mapas.first);
  }
}
