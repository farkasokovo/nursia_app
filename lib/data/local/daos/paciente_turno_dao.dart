import 'package:sqflite/sqflite.dart';
import 'package:nursia_app/turno_activo/models/paciente_turno.dart';

/// DAO = Data Access Object.
///
/// Esta clase SOLO sabe hablar SQL. No sabe nada de reglas de negocio,
/// no sabe nada de la UI. Si mañana cambias de SQLite a otra base de
/// datos, esta es la ÚNICA clase que tendrías que reescribir para
/// "pacientes_turno".
class PacienteTurnoDao {
  final Database db;

  PacienteTurnoDao(this.db);

  Future<Paciente> insertar(Paciente paciente) async {
    final id = await db.insert(
      'pacientes_turno',
      paciente.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return paciente.copyWith(id: id);
  }

  Future<List<Paciente>> obtenerTodos() async {
    final mapas = await db.query('pacientes_turno', orderBy: 'orden ASC');
    return mapas.map(Paciente.fromMap).toList();
  }

  Future<void> eliminar(int id) async {
    await db.delete('pacientes_turno', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> actualizarOrden(List<Paciente> pacientes) async {
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
}
