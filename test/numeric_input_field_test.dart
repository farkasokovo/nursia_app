// test/numeric_input_field_test.dart
//
// NumericInputField lo comparten las 5 calculadoras y la escala de índice de
// choque. Estas pruebas cuidan el layout del campo (que el label flotante no
// recorte el texto de entrada) sin necesidad de un dispositivo físico.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursia_app/theme/app_theme.dart';
import 'package:nursia_app/widgets/numeric_input_field.dart';

/// Monta un campo aislado, con el ancho de pantalla que se le indique.
Future<void> montarCampo(
  WidgetTester tester, {
  required String label,
  String? textoAyuda,
  int maxLength = 4,
  bool allowDecimal = true,
  required TextEditingController controller,
  required FocusNode focusNode,
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
          // Mismo padding que usan las pantallas de calculadora.
          padding: const EdgeInsets.all(20),
          child: NumericInputField(
            label: label,
            textoAyuda: textoAyuda,
            controller: controller,
            focusNode: focusNode,
            maxLength: maxLength,
            allowDecimal: allowDecimal,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('el label de ayuda sigue visible mientras se escribe', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await montarCampo(
      tester,
      label: 'Dosis indicada (mg)',
      textoAyuda: 'Cantidad prescrita',
      controller: controller,
      focusNode: focusNode,
    );

    // En reposo el label ocupa el lugar del antiguo hint.
    expect(find.text('Cantidad prescrita'), findsOneWidget);
    expect(find.text('Dosis indicada (mg)'), findsOneWidget);

    final campo = find.byType(TextField);
    final rectCampoVacio = tester.getRect(campo);

    await tester.enterText(campo, '1234');
    await tester.pumpAndSettle();

    // Esta es la diferencia contra el hint: con texto adentro, el label sigue ahí.
    expect(find.text('Cantidad prescrita'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Y flota: queda por encima del texto de entrada.
    final rectLabel = tester.getRect(find.text('Cantidad prescrita'));
    final rectTexto = tester.getRect(find.text('1234'));
    expect(rectLabel.top, lessThan(rectTexto.top));

    // El campo no cambia de tamaño al escribir (nada salta en pantalla).
    expect(tester.getRect(campo).size, rectCampoVacio.size);
  });

  testWidgets('el texto de entrada no se recorta dentro del campo', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await montarCampo(
      tester,
      label: 'Presentación del fármaco (mg)',
      textoAyuda: 'Contenido de la ampolleta',
      controller: controller,
      focusNode: focusNode,
    );

    final campo = find.byType(TextField);
    await tester.enterText(campo, '9999');
    await tester.pumpAndSettle();

    final rectCampo = tester.getRect(campo);
    final rectTexto = tester.getRect(find.text('9999'));

    // El texto cabe completo entre los bordes del campo, sin recortes.
    expect(rectTexto.top, greaterThanOrEqualTo(rectCampo.top));
    expect(rectTexto.bottom, lessThanOrEqualTo(rectCampo.bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('sin textoAyuda mantiene un label por defecto', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await montarCampo(
      tester,
      label: 'Frecuencia cardíaca (lpm)',
      controller: controller,
      focusNode: focusNode,
      allowDecimal: false,
      maxLength: 3,
    );

    expect(find.text('Ingresa un valor'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no desborda en pantalla angosta con los usos reales', (
    tester,
  ) async {
    // Combinaciones que existen hoy en las 5 calculadoras: maxLength de 2 a 7,
    // con y sin decimales, y los textos de ayuda más largos.
    final usos = <(String, String, int, bool)>[
      ('Peso del paciente (kg)', 'Peso registrado', 3, true),
      ('Presentación del fármaco (mg)', 'Contenido de la ampolleta', 4, true),
      ('Frecuencia respiratoria (rpm)', 'Respiraciones por minuto', 2, false),
      (
        'Segunda concentración disponible (%)',
        'Porcentaje del 2° frasco',
        2,
        false,
      ),
      ('Cantidad', 'Valor a convertir', 7, true),
    ];

    for (final (label, ayuda, maxLength, decimal) in usos) {
      final controller = TextEditingController();
      final focusNode = FocusNode();

      await montarCampo(
        tester,
        label: label,
        textoAyuda: ayuda,
        controller: controller,
        focusNode: focusNode,
        maxLength: maxLength,
        allowDecimal: decimal,
        // Pantalla angosta: 320 px lógicos es el ancho de los celulares chicos.
        anchoPantalla: 320,
      );

      await tester.enterText(find.byType(TextField), '9' * maxLength);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: 'Desborda con "$label"');
      expect(find.text(ayuda), findsOneWidget, reason: 'Sin label en "$label"');

      controller.dispose();
      focusNode.dispose();
    }
  });
}
