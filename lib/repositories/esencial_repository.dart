import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nursia_app/data/local/daos/esencial_dao.dart';
import 'package:nursia_app/models/ficha_esencial.dart';

/// Repositorio = lógica de negocio.
///
/// Las pantallas (screens) hablan SOLO con esta clase.
/// Nunca deben importar sqflite ni el Dao directamente.
/// Aquí vive la regla "si la tabla está vacía, cargar el JSON semilla".
class EsencialRepository {
  final EsencialDao _dao;

  EsencialRepository(this._dao);

  /// Se llama una vez al iniciar la app (ver main.dart).
  Future<void> cargarSemillaSiHaceFalta() async {
    final cuenta = await _dao.contar();
    if (cuenta > 0) {
      debugPrint('Esenciales: ya hay $cuenta registros, no se recarga.');
      return;
    }

    try {
      final respuesta = await rootBundle.loadString(
        'assets/data/esenciales_data.json',
      );
      final data = json.decode(respuesta) as List<dynamic>;
      for (final item in data) {
        await _dao.insertar(FichaEsencial.fromJson(item));
      }
      debugPrint('Esenciales: semilla cargada (${data.length} registros).');
    } catch (e) {
      debugPrint('Error cargando semilla de esenciales: $e');
    }
  }

  Future<List<FichaEsencial>> obtenerTodos() => _dao.obtenerTodos();
}
