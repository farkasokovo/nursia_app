import 'package:sqflite/sqflite.dart';
import 'package:nursia_app/models/ficha_esencial.dart';

/// DAO = Data Access Object.
///
/// Esta clase SOLO sabe hablar SQL. No sabe nada de JSON semilla,
/// no sabe nada de reglas de negocio, no sabe nada de la UI.
/// Si mañana cambias de SQLite a otra base de datos, esta es la
/// ÚNICA clase que tendrías que reescribir para "esenciales".
class EsencialDao {
  final Database db;

  EsencialDao(this.db);

  Future<void> insertar(FichaEsencial ficha) async {
    await db.insert(
      'esenciales',
      ficha.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> contar() async {
    final resultado = await db.rawQuery('SELECT COUNT(*) FROM esenciales');
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  /// Ordenado por "orden" y, a igual orden, alfabéticamente. El campo "orden"
  /// permite decidir a mano qué ficha va primero dentro de su categoría, en
  /// vez de depender del alfabeto.
  Future<List<FichaEsencial>> obtenerTodos() async {
    final mapas = await db.query(
      'esenciales',
      orderBy: 'orden ASC, titulo ASC',
    );
    return mapas.map(FichaEsencial.fromMap).toList();
  }
}
