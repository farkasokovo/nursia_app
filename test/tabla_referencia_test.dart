// test/tabla_referencia_test.dart
//
// La tabla de signos vitales pediátricos tiene 6 columnas, scroll horizontal
// y encabezados teñidos que se estiran al alto del renglón. Esa combinación
// solo falla al pintar, así que se monta en un ancho de celular y en los dos
// temas para que un error de layout salga aquí y no en el dispositivo.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursia_app/theme/app_theme.dart';
import 'package:nursia_app/utils/signos_vitales_pediatricos.dart';
import 'package:nursia_app/widgets/tabla_referencia.dart';

void main() {
  for (final tema in {
    'claro': AppTheme.lightTheme(),
    'oscuro': AppTheme.darkTheme(),
  }.entries) {
    testWidgets('6 columnas con scroll y encabezado teñido (${tema.key})', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360 * 3, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: tema.value,
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: TablaReferencia(
                ajustarAlAncho: false,
                encabezados: const ['Edad', 'B', 'Normal', 'L', 'M', 'G'],
                coloresEncabezado: const [
                  null,
                  Colors.grey,
                  Colors.green,
                  Colors.red,
                  Colors.red,
                  Colors.red,
                ],
                filas: [
                  for (final r in tablaFrecuenciaCardiaca)
                    [
                      etiquetaEdad(r.mesesMin, r.mesesMax),
                      '${r.bajoMax}',
                      '${r.bajoMax + 1} a ${r.normalMax}',
                      '${r.normalMax + 1} a ${r.leveMax}',
                      '${r.leveMax + 1} a ${r.moderadaMax}',
                      '${r.moderadaMax + 1}',
                    ],
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Menor de 1 mes'), findsNothing);
      expect(find.text('15 - 18 años'), findsOneWidget);
      // El encabezado teñido no queda aplastado a alto cero.
      expect(tester.getSize(find.text('Normal')).height, greaterThan(0));
    });
  }
}
