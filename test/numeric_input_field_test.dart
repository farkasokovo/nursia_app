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

  testWidgets('el campo es compacto sin dejar de ser cómodo de tocar', (
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

    final campo = find.byType(TextField);
    final alto = tester.getSize(campo).height;

    // Antes medía 66 px. Ahora 50: notablemente más compacto, pero por encima
    // del mínimo cómodo para el pulgar (48 px).
    expect(alto, greaterThanOrEqualTo(48));
    expect(alto, lessThanOrEqualTo(52));

    // El alto no cambia al escribir: nada salta en pantalla.
    await tester.enterText(campo, '1234');
    await tester.pumpAndSettle();
    expect(tester.getSize(campo).height, alto);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el label flotante queda sobre el borde, no sobre el número', (
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
    final rectLabel = tester.getRect(find.text('Contenido de la ampolleta'));
    final rectTexto = tester.getRect(find.text('9999'));

    // El label flota montado en el borde superior: arranca por encima del
    // campo. Si el recorte de altura lo hubiera empujado hacia adentro, esto
    // fallaría.
    expect(rectLabel.top, lessThan(rectCampo.top));
    // Y el número sigue completo dentro del campo.
    expect(rectTexto.top, greaterThanOrEqualTo(rectCampo.top));
    expect(rectTexto.bottom, lessThanOrEqualTo(rectCampo.bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('el campo del conversor acepta 7 dígitos más el punto', (
    tester,
  ) async {
    // El límite del campo cuenta caracteres, y el punto ocupa uno: por eso el
    // conversor usa maxLength 8 y no 7.
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await montarCampo(
      tester,
      label: 'Unidad a convertir (mg)',
      textoAyuda: 'Ingresa un valor',
      controller: controller,
      focusNode: focusNode,
      maxLength: 8,
    );

    final campo = find.byType(TextField);

    await tester.enterText(campo, '1234567.8');
    await tester.pumpAndSettle();
    expect(controller.text, '1234567.');

    await tester.enterText(campo, '0.000001');
    await tester.pumpAndSettle();
    expect(controller.text, '0.000001');

    expect(tester.takeException(), isNull);
  });

  testWidgets('con decimales solo se acepta un punto', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await montarCampo(
      tester,
      label: 'Unidad a convertir (mg)',
      textoAyuda: 'Ingresa un valor',
      controller: controller,
      focusNode: focusNode,
      maxLength: 8,
    );

    final campo = find.byType(TextField);

    // Un segundo punto se descarta junto con lo que venga después.
    await tester.enterText(campo, '1.2.3');
    await tester.pumpAndSettle();
    expect(controller.text, '1.2');

    // El punto suelto sí se puede escribir (el conversor lo trata como
    // "todavía no hay número").
    await tester.enterText(campo, '.');
    await tester.pumpAndSettle();
    expect(controller.text, '.');

    // Y el punto al inicio se conserva tal cual.
    await tester.enterText(campo, '.5');
    await tester.pumpAndSettle();
    expect(controller.text, '.5');

    expect(tester.takeException(), isNull);
  });

  testWidgets('sin decimales el punto no entra (campo de tiempo del goteo)', (
    tester,
  ) async {
    // El campo de tiempo del goteo IV no acepta decimales a propósito: los
    // tiempos cortos se capturan cambiando la unidad a minutos.
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await montarCampo(
      tester,
      label: 'Tiempo (horas)',
      textoAyuda: 'Horas de infusión',
      controller: controller,
      focusNode: focusNode,
      maxLength: 3,
      allowDecimal: false,
    );

    await tester.enterText(find.byType(TextField), '0.5');
    await tester.pumpAndSettle();
    expect(controller.text, '05');
    expect(tester.takeException(), isNull);
  });
}
