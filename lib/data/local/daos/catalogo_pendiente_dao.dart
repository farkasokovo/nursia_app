import 'package:sqflite/sqflite.dart';
import 'package:nursia_app/turno_activo/models/pendiente_turno.dart';

/// DAO = Data Access Object.
///
/// Esta clase SOLO sabe hablar SQL. No sabe nada de JSON semilla,
/// no sabe nada de reglas de negocio, no sabe nada de la UI.
/// Cubre la tabla "catalogo_pendientes" (catálogo de sugerencias
/// para el buscador del turno activo).
class CatalogoPendienteDao {
  final Database db;

  CatalogoPendienteDao(this.db);

  Future<void> insertar(PendienteInfo pendiente) async {
    await db.insert(
      'catalogo_pendientes',
      {'nombre': pendiente.nombre, 'icono': pendiente.icono},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> contar() async {
    final resultado = await db.rawQuery(
      'SELECT COUNT(*) FROM catalogo_pendientes',
    );
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  Future<List<PendienteInfo>> obtenerTodos() async {
    final mapas = await db.query('catalogo_pendientes');
    return mapas.map(PendienteInfo.fromMap).toList();
  }
}
