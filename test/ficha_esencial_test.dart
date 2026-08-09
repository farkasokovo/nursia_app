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

    test('cubre las 4 categorías y los 5 tipos de bloque', () {
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
      expect(tipos, {'texto', 'nota', 'lista', 'tabla', 'colores'});
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

    test('un contenido que no es lista deja la ficha vacía, no crashea', () {
      final ficha = FichaEsencial.fromJson({
        'titulo': 'Rota',
        'contenido': 'esto debería ser un arreglo',
      });
      expect(ficha.contenido, isEmpty);
    });
  });
}
