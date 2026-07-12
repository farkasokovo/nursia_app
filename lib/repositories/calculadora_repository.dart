import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nursia_app/data/local/daos/calculadora_dao.dart';
import 'package:nursia_app/models/calculadora_info.dart';

/// Repositorio = lógica de negocio.
///
/// Las pantallas (screens) hablan SOLO con esta clase.
/// Nunca deben importar sqflite ni el Dao directamente.
/// Aquí vive la regla "si la tabla está vacía, cargar el JSON semilla".
class CalculadoraRepository {
  final CalculadoraDao _dao;

  CalculadoraRepository(this._dao);

  /// Se llama una vez al iniciar la app (ver main.dart).
  Future<void> cargarSemillaSiHaceFalta() async {
    final cuenta = await _dao.contar();
    if (cuenta > 0) {
      debugPrint('Calculadoras: ya hay $cuenta registros, no se recarga.');
      return;
    }

    try {
      final respuesta = await rootBundle.loadString(
        'assets/data/calculadoras_info.json',
      );
      final data = json.decode(respuesta) as Map<String, dynamic>;
      final calculadoras = data['calculadoras'] as List<dynamic>;
      for (final item in calculadoras) {
        await _dao.insertar(CalculadoraInfo.fromJson(item));
      }
      debugPrint('Calculadoras: semilla cargada (${calculadoras.length} registros).');
    } catch (e) {
      debugPrint('Error cargando semilla de calculadoras: $e');
    }
  }

  Future<List<CalculadoraInfo>> obtenerTodos() => _dao.obtenerTodos();

  Future<CalculadoraInfo> obtenerPorId(String id) async {
    final info = await _dao.obtenerPorId(id);
    if (info == null) {
      throw Exception('No se encontró la calculadora con id: $id');
    }
    return info;
  }
}
