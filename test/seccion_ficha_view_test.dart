// test/seccion_ficha_view_test.dart
//
// SeccionFichaView marca el peso clínico de una sección, y lo comparten la
// ficha de medicamento y la pestaña "Ver más" de las escalas. Antes ese peso lo
// cargaba un borde izquierdo de color; ahora lo cargan el tinte de fondo y el
// color del ícono.
//
// Estas pruebas cuidan justo eso: que al quitar el borde la señal no se haya
// perdido y que la gradación entre niveles siga existiendo.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursia_app/theme/app_theme.dart';
import 'package:nursia_app/utils/secciones_ficha.dart';
import 'package:nursia_app/widgets/seccion_ficha_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

SeccionFicha seccionDe(NivelSeguridad nivel) => SeccionFicha(
  clave: 'prueba',
  titulo: 'Sección de prueba',
  icono: PhosphorIconsFill.warning,
  nivel: nivel,
);

Future<void> montarSeccion(WidgetTester tester, NivelSeguridad nivel) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme(),
      home: Scaffold(
        body: SeccionFichaView(
          seccion: seccionDe(nivel),
          children: const [Text('contenido')],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Decoración de la caja de la sección. Null cuando no lleva caja.
BoxDecoration? decoracionDe(WidgetTester tester) {
  final contenedores = find.descendant(
    of: find.byType(SeccionFichaView),
    matching: find.byType(Container),
  );
  if (contenedores.evaluate().isEmpty) return null;
  return tester.widget<Container>(contenedores.first).decoration
      as BoxDecoration?;
}

Color colorDelIcono(WidgetTester tester) =>
    tester.widget<Icon>(find.byType(Icon)).color!;

void main() {
  group('el nivel se nota en la caja', () {
    testWidgets('una sección informativa no lleva caja ni ícono teñido', (
      tester,
    ) async {
      await montarSeccion(tester, NivelSeguridad.ninguno);

      expect(decoracionDe(tester), isNull);
      expect(
        colorDelIcono(tester),
        AppTheme.lightTheme().colorScheme.onSecondary,
      );
    });

    testWidgets('las secciones con peso clínico llevan fondo teñido', (
      tester,
    ) async {
      for (final nivel in [
        NivelSeguridad.leve,
        NivelSeguridad.medio,
        NivelSeguridad.alto,
      ]) {
        await montarSeccion(tester, nivel);
        final decoracion = decoracionDe(tester);

        expect(decoracion, isNotNull, reason: '$nivel sin caja');
        expect(
          decoracion!.color!.a,
          greaterThan(0),
          reason: '$nivel sin tinte de fondo',
        );
      }
    });

    testWidgets('ya no hay borde lateral de color', (tester) async {
      // El cambio de esta tarea: el borde se quitó y la caja se cierra pareja.
      for (final nivel in NivelSeguridad.values) {
        await montarSeccion(tester, nivel);
        final decoracion = decoracionDe(tester);
        if (decoracion == null) continue;

        expect(decoracion.border, isNull, reason: '$nivel todavía tiene borde');
        expect(
          decoracion.borderRadius,
          BorderRadius.circular(10),
          reason: '$nivel no tiene el radio parejo',
        );
      }
    });
  });

  group('la señal clínica se conserva', () {
    testWidgets('el ícono toma el color de alerta de su nivel', (tester) async {
      for (final nivel in [
        NivelSeguridad.leve,
        NivelSeguridad.medio,
        NivelSeguridad.alto,
      ]) {
        await montarSeccion(tester, nivel);
        expect(
          colorDelIcono(tester),
          nivel.colorAcento,
          reason: 'El ícono de $nivel no lleva su color de alerta',
        );
      }
    });

    test('el tinte sube con el nivel', () {
      // La gradación la cargaba el grosor del borde; ahora la carga el fondo,
      // así que los tres valores tienen que estar separados de verdad.
      expect(NivelSeguridad.ninguno.opacidadFondo, 0);
      expect(
        NivelSeguridad.leve.opacidadFondo,
        lessThan(NivelSeguridad.medio.opacidadFondo),
      );
      expect(
        NivelSeguridad.medio.opacidadFondo,
        lessThan(NivelSeguridad.alto.opacidadFondo),
      );
      // Cada escalón se tiene que poder ver: saltos de al menos 0.02.
      expect(
        NivelSeguridad.medio.opacidadFondo - NivelSeguridad.leve.opacidadFondo,
        greaterThanOrEqualTo(0.02),
      );
      expect(
        NivelSeguridad.alto.opacidadFondo - NivelSeguridad.medio.opacidadFondo,
        greaterThanOrEqualTo(0.02),
      );
    });

    testWidgets('una sección con peso clínico no se ve igual que una neutra', (
      tester,
    ) async {
      // Es el riesgo de quitar el borde: que "Efectos adversos" acabe viéndose
      // como "Farmacocinética".
      await montarSeccion(tester, NivelSeguridad.ninguno);
      final iconoNeutro = colorDelIcono(tester);

      await montarSeccion(tester, NivelSeguridad.alto);
      expect(decoracionDe(tester), isNotNull);
      expect(colorDelIcono(tester), isNot(iconoNeutro));
    });
  });

  group('las secciones reales conservan su nivel', () {
    test('la ficha de medicamento marca lo que hay que encontrar primero', () {
      NivelSeguridad nivelDe(String clave) =>
          seccionPorClave(seccionesFichaMedicamento, clave).nivel;

      expect(nivelDe('contraindicaciones'), NivelSeguridad.alto);
      expect(nivelDe('efectos_adversos'), NivelSeguridad.alto);
      expect(nivelDe('interacciones'), NivelSeguridad.medio);
      expect(nivelDe('efectos_secundarios'), NivelSeguridad.leve);
      expect(nivelDe('farmacocinetica'), NivelSeguridad.ninguno);
    });

    test('las escalas marcan sus limitaciones', () {
      expect(
        seccionPorClave(seccionesFichaEscala, 'limitaciones').nivel,
        NivelSeguridad.medio,
      );
    });

    test('las calculadoras no marcan nada', () {
      for (final seccion in seccionesFichaCalculadora) {
        expect(seccion.nivel, NivelSeguridad.ninguno, reason: seccion.clave);
      }
    });
  });
}
