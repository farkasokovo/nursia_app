import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nursia_app/data/local/daos/catalogo_pendiente_dao.dart';
import 'package:nursia_app/data/local/daos/pendiente_turno_dao.dart';
import 'package:nursia_app/turno_activo/models/pendiente_turno.dart';

/// Repositorio = lógica de negocio.
///
/// Las pantallas (screens) hablan SOLO con esta clase.
/// Nunca deben importar sqflite ni los Daos directamente.
///
/// Cubre dos tablas relacionadas del mismo módulo "pendientes":
/// - catalogo_pendientes: catálogo de sugerencias con semilla JSON,
///   usado para el buscador (Autocomplete) al agregar un pendiente.
/// - pendientes_turno: la lista activa de pendientes del turno, sin
///   semilla — la genera la propia usuaria durante su turno.
///
/// Se exponen ambas desde un solo repositorio (en vez de dos) porque,
/// desde el punto de vista de las pantallas, "pendientes" es una sola
/// feature: no tiene sentido registrar dos providers para algo que la
/// UI siempre consume junto.
class PendienteTurnoRepository {
  final CatalogoPendienteDao _catalogoDao;
  final PendienteTurnoDao _activosDao;

  PendienteTurnoRepository(this._catalogoDao, this._activosDao);

  /// Se llama una vez al iniciar la app (ver main.dart).
  /// Solo aplica al catálogo de sugerencias, no a los pendientes activos.
  Future<void> cargarSemillaSiHaceFalta() async {
    final cuenta = await _catalogoDao.contar();
    if (cuenta > 0) {
      debugPrint(
        'Catálogo de pendientes: ya hay $cuenta registros, no se recarga.',
      );
      return;
    }

    try {
      final respuesta = await rootBundle.loadString(
        'assets/data/pendientes_data.json',
      );
      final data = json.decode(respuesta) as List<dynamic>;
      for (final item in data) {
        await _catalogoDao.insertar(PendienteInfo.fromMap(item));
      }
      debugPrint(
        'Catálogo de pendientes: semilla cargada (${data.length} registros).',
      );
    } catch (e) {
      debugPrint('Error cargando semilla del catálogo de pendientes: $e');
    }
  }

  Future<List<PendienteInfo>> obtenerCatalogo() => _catalogoDao.obtenerTodos();

  Future<PendienteInfo> insertarActivo(PendienteInfo pendiente) =>
      _activosDao.insertar(pendiente);

  Future<List<PendienteInfo>> obtenerActivos() => _activosDao.obtenerTodos();

  Future<void> eliminarActivo(int id) => _activosDao.eliminar(id);

  Future<void> actualizarOrdenActivos(List<PendienteInfo> pendientes) =>
      _activosDao.actualizarOrden(pendientes);
}
