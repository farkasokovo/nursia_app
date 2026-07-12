import 'package:nursia_app/data/local/daos/paciente_turno_dao.dart';
import 'package:nursia_app/turno_activo/models/paciente_turno.dart';

/// Repositorio = lógica de negocio.
///
/// Las pantallas (screens) hablan SOLO con esta clase.
/// Nunca deben importar sqflite ni el Dao directamente.
///
/// A diferencia de medicamentos/escalas/calculadoras/normas, aquí no hay
/// semilla JSON que cargar: los pacientes del turno los da de alta la
/// propia usuaria durante su turno, así que este repositorio solo delega
/// al Dao.
class PacienteTurnoRepository {
  final PacienteTurnoDao _dao;

  PacienteTurnoRepository(this._dao);

  Future<Paciente> insertar(Paciente paciente) => _dao.insertar(paciente);

  Future<List<Paciente>> obtenerTodos() => _dao.obtenerTodos();

  Future<void> eliminar(int id) => _dao.eliminar(id);

  Future<void> actualizarOrden(List<Paciente> pacientes) =>
      _dao.actualizarOrden(pacientes);
}
