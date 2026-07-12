import 'package:nursia_app/data/local/daos/medicamento_turno_dao.dart';
import 'package:nursia_app/turno_activo/models/medicamento_turno.dart';

/// Repositorio = lógica de negocio.
///
/// Las pantallas (screens) hablan SOLO con esta clase.
/// Nunca deben importar sqflite ni el Dao directamente.
///
/// Igual que pacientes_turno, aquí no hay semilla JSON que cargar: los
/// medicamentos del turno los da de alta la propia usuaria durante su
/// turno, así que este repositorio solo delega al Dao.
class MedicamentoTurnoRepository {
  final MedicamentoTurnoDao _dao;

  MedicamentoTurnoRepository(this._dao);

  Future<MedicamentoTurno> insertar(MedicamentoTurno medicamento) =>
      _dao.insertar(medicamento);

  Future<List<MedicamentoTurno>> obtenerTodos() => _dao.obtenerTodos();

  Future<void> eliminar(int id) => _dao.eliminar(id);

  Future<void> actualizarOrden(List<MedicamentoTurno> medicamentos) =>
      _dao.actualizarOrden(medicamentos);
}
