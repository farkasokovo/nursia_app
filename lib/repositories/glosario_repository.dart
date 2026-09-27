import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nursia_app/data/local/daos/glosario_dao.dart';
import 'package:nursia_app/models/termino_glosario.dart';

/// Repositorio = lógica de negocio.
///
/// Las pantallas (screens) hablan SOLO con esta clase.
/// Nunca deben importar sqflite ni el Dao directamente.
/// Aquí vive la regla "si la tabla está vacía, cargar el JSON semilla".
///
/// Convención de los ids del glosario, que se respeta al escribir
/// `assets/data/glosario_data.json` y al citarlos desde un bloque
/// "glosario" de una ficha: minúsculas, palabras separadas por guion, sin
/// acentos ni espacios. Ejemplos: `peep`, `volumen-tidal`, `bias-flow`,
/// `fio2`. El id lo escribe el autor del contenido, no lo genera la base, y
/// una prueba en `test/glosario_test.dart` verifica que se cumpla y que todo
/// id citado por una ficha exista aquí.
class GlosarioRepository {
  final GlosarioDao _dao;

  GlosarioRepository(this._dao);

  /// Se llama una vez al iniciar la app (ver main.dart).
  Future<void> cargarSemillaSiHaceFalta() async {
    final cuenta = await _dao.contar();
    if (cuenta > 0) {
      debugPrint('Glosario: ya hay $cuenta registros, no se recarga.');
      return;
    }

    try {
      final respuesta = await rootBundle.loadString(
        'assets/data/glosario_data.json',
      );
      final data = json.decode(respuesta) as List<dynamic>;
      for (final item in data) {
        await _dao.insertar(TerminoGlosario.fromJson(item));
      }
      debugPrint('Glosario: semilla cargada (${data.length} registros).');
    } catch (e) {
      debugPrint('Error cargando semilla del glosario: $e');
    }
  }

  /// Los términos indexados por su id.
  ///
  /// Es lo que necesita la pantalla de ficha para resolver los ids que cita
  /// un bloque "glosario": se pide el mapa una vez al abrir la ficha y cada
  /// id se busca en memoria, en vez de hacer una consulta por término.
  Future<Map<String, TerminoGlosario>> obtenerPorId() async {
    final terminos = await _dao.obtenerTodos();
    return {for (final termino in terminos) termino.id: termino};
  }
}
