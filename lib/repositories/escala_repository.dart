import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nursia_app/data/local/daos/escala_dao.dart';
import 'package:nursia_app/models/escala_metadata.dart';
import 'package:nursia_app/models/ver_mas_screen.dart';

/// Repositorio = lógica de negocio.
///
/// Las pantallas (screens) hablan SOLO con esta clase.
/// Nunca deben importar sqflite ni el Dao directamente.
/// Aquí vive la regla "si la tabla está vacía, cargar el JSON semilla".
class EscalaRepository {
  final EscalaDao _dao;

  EscalaRepository(this._dao);

  /// Se llama una vez al iniciar la app (ver main.dart).
  Future<void> cargarSemillaSiHaceFalta() async {
    final cuenta = await _dao.contar();
    if (cuenta > 0) {
      debugPrint('Escalas: ya hay $cuenta registros, no se recarga.');
      return;
    }

    try {
      final jsonLista = await rootBundle.loadString(
        'assets/data/escalas_lista.json',
      );
      final dataLista = json.decode(jsonLista) as Map<String, dynamic>;
      final escalasLista = dataLista['escalas'] as List<dynamic>;

      final jsonData = await rootBundle.loadString(
        'assets/data/scales_data.json',
      );
      final dataClinica = json.decode(jsonData) as Map<String, dynamic>;

      var insertadas = 0;
      for (final item in escalasLista) {
        final id = item['id'] as String;
        final detalles = dataClinica[id];
        if (detalles == null) continue;

        await _dao.insertar({
          'id': id,
          'nombre': item['nombre'],
          'categoria': item['categoria'],
          'ruta': item['ruta'],
          'description': detalles['description'],
          'when_to_use': jsonEncode(detalles['when_to_use']),
          'components': jsonEncode(detalles['components']),
          'interpretation': jsonEncode(detalles['interpretation']),
          'limitations': jsonEncode(detalles['limitations']),
          'clinical_notes': jsonEncode(detalles['clinical_notes']),
          'references_data': jsonEncode(detalles['references']),
        });
        insertadas++;
      }
      debugPrint('Escalas: semilla cargada ($insertadas registros).');
    } catch (e) {
      debugPrint('Error cargando semilla de escalas: $e');
    }
  }

  Future<List<EscalaMetadata>> obtenerTodos() => _dao.obtenerTodos();

  Future<VerMasScreen?> obtenerPorId(String id) => _dao.obtenerPorId(id);
}
