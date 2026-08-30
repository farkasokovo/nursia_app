// test/opcion_selector_test.dart
//
// OpcionSelector lo comparten el selector de mcg/mg/g de la calculadora de
// dosis, el de horas/minutos del goteo IV y el de tipo de equipo. Estas pruebas
// cuidan lo que no se puede ver sin dispositivo: que el texto de la opción
// elegida crezca, que crezca de forma animada, y sobre todo que ese crecimiento
// no mueva el layout.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursia_app/theme/app_theme.dart';
import 'package:nursia_app/widgets/opcion_selector.dart';

// Enum público a propósito: lo usan las funciones auxiliares de este archivo.
enum OpcionPrueba { uno, dos, tres }

/// Tamaño de letra con el que se está pintando una etiqueta.
double tamanoDe(WidgetTester tester, String etiqueta) {
  final estilo = DefaultTextStyle.of(tester.element(find.text(etiqueta))).style;
  return estilo.fontSize!;
}

Future<void> montarSelector(
  WidgetTester tester, {
  required OpcionPrueba seleccionada,
  required void Function(OpcionPrueba) onChanged,
  double anchoPantalla = 360,
}) async {
  tester.view.physicalSize = Size(anchoPantalla * 3, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme(),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: OpcionSelector<OpcionPrueba>(
            opciones: OpcionPrueba.values,
            seleccionada: seleccionada,
            etiqueta: (opcion) => opcion.name,
            onChanged: onChanged,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('pinta un botón por opción, con su etiqueta', (tester) async {
    await montarSelector(
      tester,
      seleccionada: OpcionPrueba.uno,
      onChanged: (_) {},
    );

    expect(find.byType(OutlinedButton), findsNWidgets(3));
    for (final opcion in OpcionPrueba.values) {
      expect(find.text(opcion.name), findsOneWidget);
    }
  });

  testWidgets('tocar una opción avisa cuál fue', (tester) async {
    final tocadas = <OpcionPrueba>[];
    await montarSelector(
      tester,
      seleccionada: OpcionPrueba.uno,
      onChanged: tocadas.add,
    );

    await tester.tap(find.text('dos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('tres'));
    await tester.pumpAndSettle();

    expect(tocadas, [OpcionPrueba.dos, OpcionPrueba.tres]);
  });

  testWidgets('el texto de la opción elegida es más grande', (tester) async {
    await montarSelector(
      tester,
      seleccionada: OpcionPrueba.dos,
      onChanged: (_) {},
    );

    final elegida = tamanoDe(tester, 'dos');
    final otra = tamanoDe(tester, 'uno');

    expect(elegida, greaterThan(otra));
    // Sutil: un par de puntos, no el doble.
    expect(elegida - otra, lessThanOrEqualTo(4));
    expect(elegida, lessThan(otra * 1.5));
  });

  testWidgets('el crecimiento es animado, no un salto', (tester) async {
    // Se monta con "uno" elegida y se vuelve a montar con "dos": el widget es
    // sin estado, así que el cambio de selección viene de afuera igual que en
    // las pantallas reales.
    await montarSelector(
      tester,
      seleccionada: OpcionPrueba.uno,
      onChanged: (_) {},
    );
    final tamanoBase = tamanoDe(tester, 'dos');
    final tamanoElegida = tamanoDe(tester, 'uno');

    await montarSelector(
      tester,
      seleccionada: OpcionPrueba.dos,
      onChanged: (_) {},
    );
    // pumpAndSettle ya dejó terminar la animación.
    expect(tamanoDe(tester, 'dos'), tamanoElegida);
    expect(tamanoDe(tester, 'uno'), tamanoBase);
  });

  testWidgets('a media animación el tamaño está entre los dos extremos', (
    tester,
  ) async {
    var seleccionada = OpcionPrueba.uno;
    late StateSetter cambiar;

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (context, setState) {
                cambiar = setState;
                return OpcionSelector<OpcionPrueba>(
                  opciones: OpcionPrueba.values,
                  seleccionada: seleccionada,
                  etiqueta: (opcion) => opcion.name,
                  onChanged: (opcion) => setState(() => seleccionada = opcion),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tamanoBase = tamanoDe(tester, 'dos');
    final tamanoElegida = tamanoDe(tester, 'uno');

    cambiar(() => seleccionada = OpcionPrueba.dos);
    await tester.pump();
    // A la mitad de la transición ninguno de los dos está en su extremo.
    await tester.pump(const Duration(milliseconds: 90));
    final enTransicion = tamanoDe(tester, 'dos');
    expect(enTransicion, greaterThan(tamanoBase));
    expect(enTransicion, lessThan(tamanoElegida));

    await tester.pumpAndSettle();
    expect(tamanoDe(tester, 'dos'), tamanoElegida);
  });

  testWidgets('el botón no cambia de tamaño al crecer el texto', (
    tester,
  ) async {
    await montarSelector(
      tester,
      seleccionada: OpcionPrueba.uno,
      onChanged: (_) {},
    );

    final rects = [
      for (final opcion in OpcionPrueba.values)
        tester.getRect(find.widgetWithText(OutlinedButton, opcion.name)),
    ];
    // Mismo alto en todos, elegido o no (44 de minimumSize, que Material sube
    // a 48 por el área mínima de toque).
    for (final rect in rects) {
      expect(rect.height, rects.first.height);
      expect(rect.height, greaterThanOrEqualTo(44));
    }

    await montarSelector(
      tester,
      seleccionada: OpcionPrueba.tres,
      onChanged: (_) {},
    );

    // Con otra opción elegida, los botones ocupan exactamente el mismo lugar.
    for (final (i, opcion) in OpcionPrueba.values.indexed) {
      expect(
        tester.getRect(find.widgetWithText(OutlinedButton, opcion.name)),
        rects[i],
        reason: 'El botón "${opcion.name}" se movió al cambiar la selección',
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('no desborda en pantalla angosta con etiquetas largas', (
    tester,
  ) async {
    // Las etiquetas reales más largas son "minutos" y "Micro"/"Normo"/"Macro".
    tester.view.physicalSize = const Size(960, 2400); // 320 px lógicos
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                OpcionSelector<String>(
                  opciones: const ['horas', 'minutos'],
                  seleccionada: 'minutos',
                  etiqueta: (opcion) => opcion,
                  onChanged: (_) {},
                ),
                OpcionSelector<String>(
                  opciones: const ['Micro', 'Normo', 'Macro'],
                  seleccionada: 'Micro',
                  etiqueta: (opcion) => opcion,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('minutos'), findsOneWidget);
    expect(find.text('Macro'), findsOneWidget);
  });
}
