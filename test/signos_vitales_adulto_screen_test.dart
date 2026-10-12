// test/signos_vitales_adulto_screen_test.dart
//
// Lo que no se ve sin dispositivo en la pantalla del adulto: que el selector
// de oxígeno solo aparezca con EPOC, que "Limpiar" apague los dos, que la
// saturación se interprete con la escala elegida y que las fichitas de
// laboratorio se desplieguen. Se monta en ancho de celular y en los dos temas
// para atrapar desbordes.
//
// El ancho es 412 y no 360: la fuente de pruebas pinta cada letra como un
// cuadro de 1em, y con ella el título de dos renglones de
// ExpandableCategoryScreen se desborda 14 px en 360, igual en la pantalla
// pediátrica. En el dispositivo, con la fuente real, cabe.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursia_app/models/ver_mas_screen.dart';
import 'package:nursia_app/repositories/escala_repository.dart';
import 'package:provider/provider.dart';
import 'package:nursia_app/screens/escalas/signos_vitales/adulto_screen.dart';
import 'package:nursia_app/theme/app_theme.dart';

/// La pestaña Información pide su texto al repositorio. Aquí no hay base de
/// datos: el falso responde que no hay entrada.
class _EscalaRepositoryFalso implements EscalaRepository {
  @override
  Future<VerMasScreen?> obtenerPorId(String id) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final tema in {
    'claro': AppTheme.lightTheme(),
    'oscuro': AppTheme.darkTheme(),
  }.entries) {
    testWidgets('EPOC, oxígeno, limpiar y fichitas (${tema.key})', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(412 * 3, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: tema.value,
          home: Provider<EscalaRepository>.value(
            value: _EscalaRepositoryFalso(),
            child: const SignosVitalesAdultoScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      const oxigeno = 'Recibe oxígeno suplementario';
      expect(find.text(oxigeno), findsNothing);

      // EPOC en Sí muestra el selector de oxígeno.
      await tester.ensureVisible(find.text('Sí').first);
      await tester.tap(find.text('Sí').first);
      await tester.pumpAndSettle();
      expect(find.text(oxigeno), findsOneWidget);

      // Con EPOC y oxígeno, 95% está por arriba de la meta.
      await tester.ensureVisible(find.text('Sí').last);
      await tester.tap(find.text('Sí').last);
      await tester.enterText(find.byType(TextField).at(5), '95');
      await tester.ensureVisible(find.text('Interpretar'));
      await tester.tap(find.text('Interpretar'));
      await tester.pumpAndSettle();
      expect(find.text('Por arriba de la meta'), findsOneWidget);

      // Limpiar apaga EPOC, y con él el selector de oxígeno.
      await tester.ensureVisible(find.text('Limpiar'));
      await tester.tap(find.text('Limpiar'));
      await tester.pumpAndSettle();
      expect(find.text(oxigeno), findsNothing);
      expect(find.text('Por arriba de la meta'), findsNothing);

      // Las fichitas muestran los valores cerradas y el detalle al tocarlas.
      final glucosa = find.text('Glucosa en ayuno');
      await tester.ensureVisible(glucosa);
      expect(find.text('70 - 99 mg/dL'), findsOneWidget);
      expect(find.textContaining('hipoglucemia clínicamente'), findsNothing);
      await tester.tap(glucosa);
      await tester.pumpAndSettle();
      expect(find.textContaining('hipoglucemia clínicamente'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  }
}
