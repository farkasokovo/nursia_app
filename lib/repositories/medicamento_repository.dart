import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nursia_app/data/local/daos/medicamento_dao.dart';
import 'package:nursia_app/models/medicamento.dart';

/// Repositorio = lógica de negocio.
///
/// Las pantallas (screens) hablan SOLO con esta clase.
/// Nunca deben importar sqflite ni el Dao directamente.
/// Aquí vive la regla "si la tabla está vacía, cargar el JSON semilla".
class MedicamentoRepository {
  final MedicamentoDao _dao;

  MedicamentoRepository(this._dao);

  /// Se llama una vez al iniciar la app (ver main.dart).
  Future<void> cargarSemillaSiHaceFalta() async {
    final cuenta = await _dao.contar();
    if (cuenta > 0) {
      debugPrint('Medicamentos: ya hay $cuenta registros, no se recarga.');
      return;
    }

    try {
      final respuesta = await rootBundle.loadString(
        'assets/data/medicamentos.json',
      );
      final data = json.decode(respuesta) as List<dynamic>;
      for (final item in data) {
        await _dao.insertar(Medicamento.fromJson(item));
      }
      debugPrint('Medicamentos: semilla cargada (${data.length} registros).');
    } catch (e) {
      debugPrint('Error cargando semilla de medicamentos: $e');
    }
  }

  Future<List<Medicamento>> obtenerTodos() => _dao.obtenerTodos();

  Future<Medicamento?> obtenerPorNombre(String nombre) =>
      _dao.obtenerPorNombre(nombre);
}
