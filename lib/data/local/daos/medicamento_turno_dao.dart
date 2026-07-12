import 'package:sqflite/sqflite.dart';
import 'package:nursia_app/turno_activo/models/medicamento_turno.dart';

/// DAO = Data Access Object.
///
/// Esta clase SOLO sabe hablar SQL. No sabe nada de reglas de negocio,
/// no sabe nada de la UI. Si mañana cambias de SQLite a otra base de
/// datos, esta es la ÚNICA clase que tendrías que reescribir para
/// "medicamentos_turno".
class MedicamentoTurnoDao {
  final Database db;

  MedicamentoTurnoDao(this.db);

  Future<MedicamentoTurno> insertar(MedicamentoTurno medicamento) async {
    final id = await db.insert('medicamentos_turno', medicamento.toMap());
    return medicamento.copyWith(id: id);
  }

  Future<List<MedicamentoTurno>> obtenerTodos() async {
    final mapas = await db.query('medicamentos_turno', orderBy: 'orden ASC');
    return mapas.map(MedicamentoTurno.fromMap).toList();
  }

  Future<void> eliminar(int id) async {
    await db.delete('medicamentos_turno', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> actualizarOrden(List<MedicamentoTurno> medicamentos) async {
    final batch = db.batch();
    for (int i = 0; i < medicamentos.length; i++) {
      final m = medicamentos[i];
      if (m.id != null) {
        batch.update(
          'medicamentos_turno',
          {'orden': i},
          where: 'id = ?',
          whereArgs: [m.id],
        );
      }
    }
    await batch.commit(noResult: true);
  }
}
