// Valida el glosario central de Esenciales ANTES de compilar un APK.
//
// La pantalla resuelve cada id contra el glosario y, si no lo encuentra, se
// salta ese término con un debugPrint. Eso está bien en el celular, pero
// significa que un id mal escrito desaparece SIN QUE SE NOTE en un build de
// release. La primera prueba de este archivo es la red que atrapa eso.
//
// Correr con:  flutter test test/glosario_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:nursia_app/models/ficha_esencial.dart';
import 'package:nursia_app/models/termino_glosario.dart';

const _rutaGlosario = 'assets/data/glosario_data.json';
const _rutaFichas = 'assets/data/esenciales_data.json';

void main() {
  late List<TerminoGlosario> terminos;
  late List<dynamic> fichasCrudas;

  setUp(() {
    final crudo =
        json.decode(File(_rutaGlosario).readAsStringSync()) as List<dynamic>;
    terminos = crudo.map((e) => TerminoGlosario.fromJson(e)).toList();
    fichasCrudas =
        json.decode(File(_rutaFichas).readAsStringSync()) as List<dynamic>;
  });

  group('glosario central ($_rutaGlosario)', () {
    test('todo id citado por una ficha existe en el glosario', () {
      final existentes = terminos.map((t) => t.id).toSet();

      for (final ficha in fichasCrudas) {
        for (final bloque in (ficha['contenido'] as List)) {
          if (bloque['tipo'] != 'glosario') continue;
          for (final id in (bloque['terminos'] as List)) {
            expect(
              existentes,
              contains(id),
              reason:
                  'La ficha "${ficha['titulo']}" cita el término "$id", que '
                  'no existe en $_rutaGlosario. En el celular ese término '
                  'desaparecería de la sección sin aviso.',
            );
          }
        }
      }
    });

    test('los ids no se repiten', () {
      final vistos = <String>{};
      for (final t in terminos) {
        expect(
          vistos.add(t.id),
          isTrue,
          reason:
              'El id "${t.id}" está dos veces. Al sembrar, el segundo pisa al '
              'primero, porque id es la clave primaria de la tabla.',
        );
      }
    });

    test('los ids cumplen la convención', () {
      // Minúsculas, palabras separadas por guion, sin acentos ni espacios.
      final convencion = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');
      for (final t in terminos) {
        expect(
          convencion.hasMatch(t.id),
          isTrue,
          reason:
              'El id "${t.id}" no cumple la convención: minúsculas, palabras '
              'separadas por guion, sin acentos ni espacios.',
        );
        expect(t.termino, isNotEmpty, reason: '"${t.id}" no tiene término.');
        expect(
          t.definicion,
          isNotEmpty,
          reason: '"${t.id}" no tiene definición.',
        );
      }
    });

    test('el término y el bloque sobreviven el viaje por toJson', () {
      // toMap serializa las referencias a JSON dentro de una columna TEXT y
      // fromMap las vuelve a leer. Si algo se pierde ahí, el término se ve
      // bien en la primera corrida (viene del JSON) y rota en la segunda
      // (viene de SQLite).
      for (final t in terminos) {
        final recuperado = TerminoGlosario.fromMap(t.toMap());
        expect(recuperado.id, t.id);
        expect(recuperado.termino, t.termino);
        expect(recuperado.desglose, t.desglose);
        expect(recuperado.definicion, t.definicion);
        expect(
          jsonEncode(recuperado.toJson()),
          jsonEncode(t.toJson()),
          reason: 'El término "${t.id}" cambió al pasar por SQLite.',
        );
      }

      final bloque = BloqueGlosario(
        titulo: 'Glosario',
        terminos: const ['peep', 'trigger'],
      );
      final recuperado = FichaEsencial.fromJson({
        'titulo': 'Con glosario',
        'contenido': [bloque.toJson()],
      }).contenido.single;

      expect(recuperado, isA<BloqueGlosario>());
      expect((recuperado as BloqueGlosario).terminos, bloque.terminos);
      expect(recuperado.titulo, 'Glosario');
      expect(jsonEncode(recuperado.toJson()), jsonEncode(bloque.toJson()));
    });
  });
}
