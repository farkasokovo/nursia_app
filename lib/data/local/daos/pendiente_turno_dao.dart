import 'package:sqflite/sqflite.dart';
import 'package:nursia_app/turno_activo/models/pendiente_turno.dart';

/// DAO = Data Access Object.
///
/// Esta clase SOLO sabe hablar SQL. No sabe nada de reglas de negocio,
/// no sabe nada de la UI. Cubre la tabla "pendientes_turno" (lista
/// activa de pendientes del turno, sin semilla — la genera la usuaria).
class PendienteTurnoDao {
  final Database db;

  PendienteTurnoDao(this.db);

  Future<PendienteInfo> insertar(PendienteInfo pendiente) async {
    final id = await db.insert('pendientes_turno', {
      'nombre': pendiente.nombre,
      'icono': pendiente.icono,
      'orden': pendiente.orden,
    });
    return pendiente.copyWith(id: id);
  }

  Future<List<PendienteInfo>> obtenerTodos() async {
    final mapas = await db.query('pendientes_turno', orderBy: 'orden ASC');
    return mapas.map(PendienteInfo.fromMap).toList();
  }

  Future<void> eliminar(int id) async {
    await db.delete('pendientes_turno', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> actualizarOrden(List<PendienteInfo> pendientes) async {
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
