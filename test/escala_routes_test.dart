// test/escala_routes_test.dart
//
// Cada entrada de escalas_lista.json abre su pantalla por el nombre de ruta
// que trae en "ruta". Si esa ruta no está registrada en escala_routes.dart,
// el buscador lleva a ninguna parte y solo se nota en el dispositivo.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nursia_app/utils/escala_routes.dart';

void main() {
  test('toda ruta de escalas_lista.json está registrada', () {
    final json =
        jsonDecode(File('assets/data/escalas_lista.json').readAsStringSync())
            as Map<String, dynamic>;
    final rutas = [
      for (final e in json.values.whereType<List>().expand((l) => l))
        (e as Map<String, dynamic>)['ruta'] as String,
    ];
    expect(rutas, isNotEmpty);
    for (final ruta in rutas) {
      expect(escalaRoutes.containsKey(ruta), isTrue, reason: ruta);
    }
  });
}
