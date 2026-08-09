// Valida la semilla de Esenciales ANTES de compilar un APK.
//
// El parseo de bloques es tolerante a propósito: un bloque con un error de
// dedo se descarta con debugPrint() y la app sigue viva. Eso está bien en el
// celular, pero significa que en un build de release un bloque mal escrito
// desaparece SIN QUE SE NOTE. Esta prueba es la red que atrapa eso: exige que
// TODOS los bloques del JSON sobrevivan al parseo.
//
// Correr con:  flutter test test/ficha_esencial_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nursia_app/models/ficha_esencial.dart';

const _rutaSemilla = 'assets/data/esenciales_data.json';

void main() {
  late List<dynamic> crudo;
  late List<FichaEsencial> fichas;

  setUp(() {
    crudo = json.decode(File(_rutaSemilla).readAsStringSync()) as List<dynamic>;
    fichas = crudo.map((e) => FichaEsencial.fromJson(e)).toList();
  });

  group('semilla real ($_rutaSemilla)', () {
    test('ningún bloque se pierde en silencio al parsear', () {
      for (var i = 0; i < crudo.length; i++) {
        final bloquesEnJson = (crudo[i]['contenido'] as List).length;
        expect(
          fichas[i].contenido.length,
          bloquesEnJson,
          reason:
              'La ficha "${fichas[i].titulo}" tiene $bloquesEnJson bloques en '
              'el JSON pero solo ${fichas[i].contenido.length} sobrevivieron. '
              'Revisa la consola: el parseo dice cuál se descartó y por qué.',
        );
      }
    });

    test('toda ficha trae sus campos obligatorios', () {
      const categoriasValidas = {'insumos', 'paciente', 'equipo', 'codigos'};
      for (final f in fichas) {
        expect(f.titulo, isNotEmpty, reason: 'Hay una ficha sin título.');
        expect(f.icono, isNotEmpty, reason: '"${f.titulo}" no tiene ícono.');
        expect(f.fuente, isNotEmpty, reason: '"${f.titulo}" no tiene fuente.');
        expect(
          f.contenido,
          isNotEmpty,
          reason: '"${f.titulo}" se quedó sin bloques de contenido.',
        );
        expect(
          categoriasValidas,
          contains(f.categoria),
          reason:
              '"${f.titulo}" tiene la categoría "${f.categoria}", que no '
              'existe. Válidas: $categoriasValidas',
        );
      }
    });

    test('las tablas no pasan de 3 columnas (ancho de pantalla móvil)', () {
      for (final f in fichas) {
        for (final b in f.contenido.whereType<BloqueTabla>()) {
          expect(
            b.encabezados.length,
            lessThanOrEqualTo(3),
            reason:
                'La tabla "${b.titulo ?? f.titulo}" tiene '
                '${b.encabezados.length} columnas y no va a caber.',
          );
        }
      }
    });

    test('ninguna tabla se queda sin filas', () {
      // Una fila con distinto número de celdas que encabezados se descarta en
      // silencio al parsear. Con fichas que mezclan tablas de 2 y de 3
      // columnas, ese error de dedo es fácil: esto lo atrapa.
      for (final f in fichas) {
        for (final b in f.contenido.whereType<BloqueTabla>()) {
          expect(
            b.filas,
            isNotEmpty,
            reason:
                'La tabla "${b.titulo ?? f.titulo}" se quedó sin filas. '
                'Revisa que cada fila tenga ${b.encabezados.length} celdas.',
          );
        }
      }
    });

    test('toda fila de tabla cuadra con sus encabezados', () {
      // Se valida sobre el JSON CRUDO: el parseo tira la fila que no cuadra,
      // así que revisarla ya parseada nunca detectaría la que falta.
      for (final ficha in crudo) {
        for (final bloque in (ficha['contenido'] as List)) {
          if (bloque['tipo'] != 'tabla') continue;
          final columnas = (bloque['encabezados'] as List).length;
          for (final fila in (bloque['filas'] as List)) {
            expect(
              (fila as List).length,
              columnas,
              reason:
                  'En "${ficha['titulo']}", la tabla "${bloque['titulo']}" '
                  'tiene una fila con ${fila.length} celdas y $columnas '
                  'encabezados: $fila',
            );
          }
        }
      }
    });

    test('cubre las 4 categorías y los 6 tipos de bloque', () {
      expect(fichas.map((f) => f.categoria).toSet(), {
        'insumos',
        'paciente',
        'equipo',
        'codigos',
      });

      final tipos = <String>{};
      for (final f in fichas) {
        for (final b in f.contenido) {
          tipos.add(b.toJson()['tipo'] as String);
        }
      }
      expect(tipos, {
        'texto',
        'nota',
        'lista',
        'tabla',
        'colores',
        'referencias',
      });
    });

    test('toda ficha cierra con referencias utilizables', () {
      for (final f in fichas) {
        final referencias = f.contenido.whereType<BloqueReferencias>().toList();
        expect(
          referencias,
          isNotEmpty,
          reason: '"${f.titulo}" no trae bloque de referencias.',
        );
        expect(
          f.contenido.last,
          isA<BloqueReferencias>(),
          reason: 'Las referencias de "${f.titulo}" deben ir al final.',
        );

        for (final item in [for (final b in referencias) ...b.items]) {
          expect(item.texto, isNotEmpty);
          // url es opcional (un libro impreso no tiene liga), pero si viene
          // tiene que ser una liga real: la UI la abre en el navegador.
          if (item.url != null) {
            expect(
              item.url,
              startsWith('http'),
              reason:
                  'La referencia "${item.texto}" tiene una url que no parece '
                  'una liga: ${item.url}',
            );
          }
        }
      }
    });

    test('todo color del JSON viene en formato #RRGGBB', () {
      // Se valida sobre el JSON CRUDO a propósito: el parseo descarta en
      // silencio un color mal escrito, así que revisarlo ya parseado no
      // atraparía el error de dedo.
      final hex = RegExp(r'^#[0-9a-fA-F]{6}$');
      for (final ficha in crudo) {
        for (final bloque in (ficha['contenido'] as List)) {
          if (bloque['tipo'] != 'colores') continue;
          for (final item in (bloque['items'] as List)) {
            expect(
              hex.hasMatch(item['color'] as String),
              isTrue,
              reason:
                  'En "${ficha['titulo']}" el color "${item['color']}" de '
                  '"${item['etiqueta']}" no tiene formato #RRGGBB.',
            );
          }
        }
      }
    });

    test('round-trip toMap -> fromMap conserva el contenido', () {
      // toMap serializa los bloques a JSON dentro de una columna TEXT; fromMap
      // los vuelve a leer. Si algo se pierde ahí, la ficha se ve bien en la
      // primera corrida (viene del JSON) y rota en la segunda (viene de SQLite).
      for (final f in fichas) {
        final recuperada = FichaEsencial.fromMap(f.toMap());

        expect(recuperada.titulo, f.titulo);
        expect(recuperada.tituloCorto, f.tituloCorto);
        expect(recuperada.categoria, f.categoria);
        expect(recuperada.icono, f.icono);
        expect(recuperada.resumen, f.resumen);
        expect(recuperada.palabrasClave, f.palabrasClave);
        expect(recuperada.fuente, f.fuente);
        expect(recuperada.orden, f.orden);
        expect(
          jsonEncode(recuperada.contenido.map((b) => b.toJson()).toList()),
          jsonEncode(f.contenido.map((b) => b.toJson()).toList()),
          reason: 'El contenido de "${f.titulo}" cambió al pasar por SQLite.',
        );
      }
    });

    test('el switch exhaustivo de la sealed class compila', () {
      // Si algún día se agrega un sexto tipo de bloque, este switch deja de
      // compilar y avisa que la UI también tiene que manejarlo.
      for (final f in fichas) {
        for (final b in f.contenido) {
          final etiqueta = switch (b) {
            BloqueTexto() => 'texto',
            BloqueNota() => 'nota',
            BloqueLista() => 'lista',
            BloqueTabla() => 'tabla',
            BloqueColores() => 'colores',
            BloqueReferencias() => 'referencias',
          };
          expect(etiqueta, isNotEmpty);
        }
      }
    });
  });

  group('tolerancia a errores de dedo', () {
    test('los bloques malos se descartan y los buenos sobreviven', () {
      final ficha = FichaEsencial.fromJson({
        'titulo': 'Rota',
        'contenido': [
          // 1. tipo que no existe
          {'tipo': 'inventado', 'valor': 'x'},
          // 2. texto sin "valor"
          {'tipo': 'texto'},
          // 3. lista sin items
          {'tipo': 'lista', 'items': []},
          // 4. estilo desconocido: cae a viñetas, el bloque se conserva
          {
            'tipo': 'lista',
            'estilo': 'romanos',
            'items': ['a'],
          },
          // 5. fila con menos celdas que encabezados: se va la fila, no la tabla
          {
            'tipo': 'tabla',
            'encabezados': ['A', 'B'],
            'filas': [
              ['1', '2'],
              ['solo una celda'],
            ],
          },
          // 6. color con hex inválido: se va ese ítem, no el bloque
          {
            'tipo': 'colores',
            'items': [
              {'color': 'rojo', 'etiqueta': 'hex inválido'},
              {'color': '#112233', 'etiqueta': 'ok'},
            ],
          },
          {'tipo': 'texto', 'valor': 'este sí sobrevive'},
        ],
      });

      expect(ficha.contenido.length, 4);
      expect((ficha.contenido[0] as BloqueLista).estilo, EstiloLista.vinetas);
      expect((ficha.contenido[1] as BloqueTabla).filas.length, 1);
      expect((ficha.contenido[2] as BloqueColores).items.length, 1);
      expect((ficha.contenido[3] as BloqueTexto).valor, 'este sí sobrevive');
    });

    test('en referencias se descarta el item malo, no la lista', () {
      final ficha = FichaEsencial.fromJson({
        'titulo': 'Rota',
        'contenido': [
          {
            'tipo': 'referencias',
            'items': [
              {'url': 'https://example.com'}, // sin "texto": se va el item
              {'texto': 'Con liga', 'url': 'https://example.com'},
              {'texto': 'Sin liga'}, // url es opcional
            ],
          },
          // Bloque de referencias donde NINGÚN item sirve: se va completo.
          {
            'tipo': 'referencias',
            'items': [
              {'url': 'https://example.com'},
            ],
          },
        ],
      });

      expect(ficha.contenido.length, 1);
      final bloque = ficha.contenido.first as BloqueReferencias;
      expect(bloque.items.length, 2);
      expect(bloque.items[0].url, 'https://example.com');
      expect(bloque.items[1].url, isNull);
    });

    test('un contenido que no es lista deja la ficha vacía, no crashea', () {
      final ficha = FichaEsencial.fromJson({
        'titulo': 'Rota',
        'contenido': 'esto debería ser un arreglo',
      });
      expect(ficha.contenido, isEmpty);
    });
  });
}
