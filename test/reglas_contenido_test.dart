import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Guarda las reglas permanentes de contenido: potasemia (no kalemia) y
// solo nombres genéricos de medicamentos. Si falla, el JSON está mal.
void main() {
  final archivos = Directory(
    'assets/data',
  ).listSync().whereType<File>().where((f) => f.path.endsWith('.json'));

  final prohibidos = <String, RegExp>{
    'kalemia': RegExp('kalemia', caseSensitive: false),
    'calemia (no calcemia)': RegExp('(?<!c)calemia', caseSensitive: false),
    'nombre comercial': RegExp(
      r'Pisaca[ií]na|Buvaca[ií]na|Indufol|Angiopohl|Isorbid|Proartcar|Solinitrina'
      r'|Amcef|Lopresor|Aldactone|Inhepar|Supacid|Antivon|Lamobrigan|Solidtrax'
      r'|Amchafibrin|Konakion|Combivent|Lipoven|Xylocaina|Lasix|Buscapina'
      r'|Diprivan|Marca[ií]na|Lantus|Clexane',
      caseSensitive: false,
    ),
  };

  test('los JSON de assets/data no contienen términos prohibidos', () {
    expect(archivos, isNotEmpty);
    final hallazgos = <String>[];
    for (final archivo in archivos) {
      // Las ligas pueden llevar la marca en su ruta; no se muestran al usuario.
      final texto = archivo.readAsStringSync().replaceAll(
        RegExp(r'"url":\s*"[^"]*"'),
        '',
      );
      prohibidos.forEach((regla, regex) {
        for (final m in regex.allMatches(texto)) {
          hallazgos.add('${archivo.path}: ${m.group(0)} ($regla)');
        }
      });
    }
    expect(hallazgos, isEmpty);
  });
}
