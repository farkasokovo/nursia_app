// test/tabs_calculadora_dosis_test.dart
//
// Las pestañas de la calculadora de dosis son el caso apretado del módulo: son
// tres, "Conversor" es la etiqueta más larga, y el texto de la pestaña activa
// se pinta a 20 px contra 15 de las inactivas. Antes ese texto no cabía y se
// cortaba.
//
// Estas pruebas montan TabbedContent con la MISMA configuración que usa
// lib/screens/calculadoras/calculadora_dosis.dart (mismas etiquetas, mismo
// labelPadding, mismo FittedBox) y cargan la fuente Poppins real, porque con la
// fuente de prueba por defecto los anchos no son los del celular.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursia_app/theme/app_theme.dart';
import 'package:nursia_app/widgets/tabbed_content.dart';

/// Copia de `_pestana` de la calculadora de dosis.
Tab pestana(String texto) => Tab(
  child: FittedBox(fit: BoxFit.scaleDown, child: Text(texto)),
);

const etiquetas = ['Cálculo', 'Conversor', 'Ver más'];

Future<void> montarPestanas(
  WidgetTester tester, {
  double anchoPantalla = 360,
  EdgeInsetsGeometry labelPadding = const EdgeInsets.symmetric(horizontal: 8),
}) async {
  tester.view.physicalSize = Size(anchoPantalla * 3, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme(),
      home: Scaffold(
        body: TabbedContent(
          labelPadding: labelPadding,
          tabs: [for (final e in etiquetas) pestana(e)],
          tabViews: const [SizedBox(), SizedBox(), SizedBox()],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Alto real con el que se está pintando una etiqueta, ya con la escala que le
/// haya aplicado el FittedBox.
double altoPintado(WidgetTester tester, String etiqueta) =>
    tester.getRect(find.text(etiqueta)).height;

/// Deja activa una pestaña distinta a [etiqueta] y devuelve el alto de
/// [etiqueta] en reposo. Hace falta porque al montar ya hay una activa
/// (la primera), y medirla ahí daría su tamaño grande, no el de reposo.
Future<double> altoEnReposo(WidgetTester tester, String etiqueta) async {
  final otra = etiquetas.firstWhere((e) => e != etiqueta);
  await tester.tap(find.text(otra));
  await tester.pumpAndSettle();
  return altoPintado(tester, etiqueta);
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final loader = FontLoader('Poppins');
    for (final archivo in ['Poppins-SemiBold.ttf', 'Poppins-Regular.ttf']) {
      loader.addFont(
        File(
          'assets/fonts/$archivo',
        ).readAsBytes().then((bytes) => ByteData.view(bytes.buffer)),
      );
    }
    await loader.load();
  });

  testWidgets('las tres etiquetas se pintan', (tester) async {
    await montarPestanas(tester);
    for (final etiqueta in etiquetas) {
      expect(find.text(etiqueta), findsOneWidget);
    }
    // "Información" quedó atrás: es más largo y las escalas ya decían "Ver más".
    expect(find.text('Información'), findsNothing);
  });

  testWidgets('ninguna etiqueta se sale de su pestaña', (tester) async {
    // El corte que reportaron las usuarias: el texto más ancho que su hueco.
    for (final ancho in [320.0, 360.0, 412.0]) {
      await montarPestanas(tester, anchoPantalla: ancho);

      for (var i = 0; i < etiquetas.length; i++) {
        await tester.tap(find.text(etiquetas[i]));
        await tester.pumpAndSettle();

        for (final etiqueta in etiquetas) {
          final texto = tester.getRect(find.text(etiqueta));
          final hueco = tester.getRect(
            find.ancestor(of: find.text(etiqueta), matching: find.byType(Tab)),
          );
          expect(
            texto.width,
            lessThanOrEqualTo(hueco.width + 0.5),
            reason:
                '"$etiqueta" se sale de su pestaña con "${etiquetas[i]}" '
                'activa, en pantalla de $ancho px',
          );
        }
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('la pestaña activa se ve más grande, en las tres', (
    tester,
  ) async {
    // El FittedBox no debe anular el efecto: si encogiera justo lo que el
    // TabBar agranda, la pestaña activa se vería igual que las demás.
    for (final ancho in [320.0, 360.0, 412.0]) {
      await montarPestanas(tester, anchoPantalla: ancho);

      for (final etiqueta in etiquetas) {
        final enReposo = await altoEnReposo(tester, etiqueta);

        await tester.tap(find.text(etiqueta));
        await tester.pumpAndSettle();
        final activa = altoPintado(tester, etiqueta);

        // El texto inactivo va a 15 y el activo a 20: el crecimiento visible
        // tiene que ser de al menos un 15 %, aun después del FittedBox.
        expect(
          activa,
          greaterThan(enReposo * 1.15),
          reason:
              '"$etiqueta" activa se pinta a $activa y en reposo a $enReposo, '
              'en pantalla de $ancho px',
        );
      }
    }
  });

  testWidgets('en un celular normal el crecimiento es el completo', (
    tester,
  ) async {
    // A 360 px o más, el texto cabe entero y el FittedBox no interviene: la
    // pestaña activa llega a los 20 px de la hoja de estilo, no a menos.
    for (final ancho in [360.0, 412.0]) {
      await montarPestanas(tester, anchoPantalla: ancho);

      for (final etiqueta in etiquetas) {
        final enReposo = await altoEnReposo(tester, etiqueta);
        await tester.tap(find.text(etiqueta));
        await tester.pumpAndSettle();
        final activa = altoPintado(tester, etiqueta);

        // 20 / 15 = 1.333. Se deja holgura por el redondeo de las métricas.
        expect(
          activa / enReposo,
          greaterThan(1.30),
          reason:
              '"$etiqueta" solo creció ${(activa / enReposo).toStringAsFixed(2)} '
              'veces en pantalla de $ancho px',
        );
      }
    }
  });

  testWidgets('con el aire original el texto sí se cortaba', (tester) async {
    // Prueba de que el labelPadding es lo que resolvió el corte, y no un
    // detalle accesorio: con el valor de antes, "Conversor" activa no cabe.
    await montarPestanas(
      tester,
      labelPadding: const EdgeInsets.symmetric(horizontal: 20),
    );

    await tester.tap(find.text('Conversor'));
    await tester.pumpAndSettle();

    final hueco = tester.getRect(
      find.ancestor(of: find.text('Conversor'), matching: find.byType(Tab)),
    );
    final natural = TextPainter(
      textDirection: TextDirection.ltr,
      text: const TextSpan(
        text: 'Conversor',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
    )..layout();

    expect(natural.width, greaterThan(hueco.width));
  });
}
