import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nursia_app/data/local/daos/norma_dao.dart';
import 'package:nursia_app/models/norma.dart';

/// Repositorio = lógica de negocio.
///
/// Las pantallas (screens) hablan SOLO con esta clase.
/// Nunca deben importar sqflite ni el Dao directamente.
/// Aquí vive la regla "si la tabla está vacía, cargar el JSON semilla".
class NormaRepository {
  final NormaDao _dao;

  NormaRepository(this._dao);

  /// Se llama una vez al iniciar la app (ver main.dart).
  Future<void> cargarSemillaSiHaceFalta() async {
    final cuenta = await _dao.contar();
    if (cuenta > 0) {
      debugPrint('Normas: ya hay $cuenta registros, no se recarga.');
      return;
    }

    try {
      final respuesta = await rootBundle.loadString(
        'assets/data/normas_data.json',
      );
      final data = json.decode(respuesta) as List<dynamic>;
      for (final item in data) {
        await _dao.insertar(Norma.fromJson(item));
      }
      debugPrint('Normas: semilla cargada (${data.length} registros).');
    } catch (e) {
      debugPrint('Error cargando semilla de normas: $e');
    }
  }

  Future<List<Norma>> obtenerTodos() => _dao.obtenerTodos();
}
