import 'package:sqflite/sqflite.dart';
import 'package:nursia_app/models/termino_glosario.dart';

/// DAO = Data Access Object.
///
/// Esta clase SOLO sabe hablar SQL. No sabe nada de JSON semilla,
/// no sabe nada de reglas de negocio, no sabe nada de la UI.
/// Si mañana cambias de SQLite a otra base de datos, esta es la
/// ÚNICA clase que tendrías que reescribir para "glosario".
class GlosarioDao {
  final Database db;

  GlosarioDao(this.db);

  Future<void> insertar(TerminoGlosario termino) async {
    await db.insert(
      'glosario',
      termino.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> contar() async {
    final resultado = await db.rawQuery('SELECT COUNT(*) FROM glosario');
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  /// Ordenado alfabéticamente por término. El orden en que se PINTAN los
  /// términos de una ficha no sale de aquí sino del arreglo "terminos" del
  /// bloque, que es el que decide quien escribe la ficha.
  Future<List<TerminoGlosario>> obtenerTodos() async {
    final mapas = await db.query('glosario', orderBy: 'termino ASC');
    return mapas.map(TerminoGlosario.fromMap).toList();
  }
}
