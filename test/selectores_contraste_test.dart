// test/selectores_contraste_test.dart
//
// Los dos widgets de selección propios (el de las escalas y el de las
// calculadoras) invierten el color del control contra el de su contenido.
// En modo claro esa inversión salía sola porque primaryContainer y
// onPrimaryContainer son un par oscuro/claro real; en oscuro no, y el par
// colapsaba dejando las dos mitades claras.
//
// Estas pruebas fijan los pares resueltos, no los widgets: si alguien mueve
// un valor de la paleta o cambia una ranura, el número cae aquí antes de
// llegar al celular.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursia_app/theme/app_theme.dart';
import 'package:nursia_app/theme/theme_colors.dart';

double contraste(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

Future<BuildContext> contextoConTema(
  WidgetTester tester,
  ThemeData tema,
) async {
  late BuildContext capturado;
  await tester.pumpWidget(
    MaterialApp(
      theme: tema,
      home: Builder(
        builder: (context) {
          capturado = context;
          return const SizedBox();
        },
      ),
    ),
  );
  return capturado;
}

/// Los 4 pares fondo/texto de `ScaleParameterSelector`, resueltos igual que
/// en el widget. Se reconstruyen aquí a propósito: si el widget cambia una
/// ranura sin cambiar esto, los dos dejan de coincidir y la revisión lo nota.
({Color fondo, Color texto}) chip(BuildContext context, bool seleccionado) {
  final esquema = Theme.of(context).colorScheme;
  return seleccionado
      ? (
          fondo: ThemeColors.segunTema(
            context,
            claro: esquema.primaryContainer,
            oscuro: AppColorsDark.ink2,
          ),
          texto: ThemeColors.segunTema(
            context,
            claro: esquema.onPrimaryContainer,
            oscuro: AppColorsDark.accentOn,
          ),
        )
      : (
          fondo: ThemeColors.segunTema(
            context,
            claro: esquema.onPrimaryContainer,
            oscuro: AppColorsDark.ruleSoft,
          ),
          texto: esquema.onSecondaryContainer,
        );
}

({Color fondo, Color texto}) insignia(BuildContext context, bool seleccionado) {
  final esquema = Theme.of(context).colorScheme;
  return seleccionado
      ? (
          fondo: ThemeColors.segunTema(
            context,
            claro: esquema.onPrimaryContainer,
            oscuro: AppColorsDark.accentOn,
          ),
          texto: ThemeColors.segunTema(
            context,
            claro: esquema.onSurface,
            oscuro: AppColorsDark.ink2,
          ),
        )
      : (
          fondo: ThemeColors.segunTema(
            context,
            claro: esquema.primaryContainer,
            oscuro: AppColorsDark.ink2,
          ),
          texto: ThemeColors.segunTema(
            context,
            claro: esquema.onPrimaryContainer,
            oscuro: AppColorsDark.accentOn,
          ),
        );
}

void main() {
  group('ScaleParameterSelector: los 4 pares se leen', () {
    for (final (nombreTema, tema) in [
      ('claro', AppTheme.lightTheme()),
      ('oscuro', AppTheme.darkTheme()),
    ]) {
      testWidgets('en $nombreTema ningún par baja de 4.5:1', (tester) async {
        final context = await contextoConTema(tester, tema);

        for (final seleccionado in [true, false]) {
          final c = chip(context, seleccionado);
          expect(
            contraste(c.texto, c.fondo),
            greaterThanOrEqualTo(4.5),
            reason: 'El texto del chip (seleccionado: $seleccionado) no se lee',
          );

          final i = insignia(context, seleccionado);
          expect(
            contraste(i.texto, i.fondo),
            greaterThanOrEqualTo(4.5),
            reason: 'La insignia (seleccionada: $seleccionado) no se lee',
          );
        }
      });

      testWidgets('en $nombreTema la insignia invierte contra su chip', (
        tester,
      ) async {
        final context = await contextoConTema(tester, tema);

        // Es la intención del diseño: el número resalta porque su recuadro
        // va al revés que el chip, para no confundirse con los números que
        // pueda traer la etiqueta (rangos de MEWS, por ejemplo).
        for (final seleccionado in [true, false]) {
          expect(
            contraste(
              insignia(context, seleccionado).fondo,
              chip(context, seleccionado).fondo,
            ),
            greaterThanOrEqualTo(4.5),
            reason: 'La insignia se funde con el chip ($seleccionado)',
          );
        }
      });

      testWidgets('en $nombreTema se distingue lo seleccionado', (
        tester,
      ) async {
        final context = await contextoConTema(tester, tema);

        // La razón de que en oscuro el chip seleccionado sea el CLARO: los
        // dos fondos tienen que separarse solos, sin depender del borde.
        expect(
          contraste(chip(context, true).fondo, chip(context, false).fondo),
          greaterThanOrEqualTo(4.5),
          reason: 'Seleccionado y sin seleccionar se ven casi igual',
        );
      });
    }
  });

  group('OpcionSelector: el texto se lee sobre su botón', () {
    // El botón SIN seleccionar va sobre `colorScheme.primary`. En claro eso
    // da 3.73:1 y así ha estado siempre: no se toca, porque el criterio de
    // aceptación es que el modo claro no cambie. Lo que sí se exige es que
    // el oscuro no herede el problema, que es donde estaba el bug (1.85:1).
    testWidgets('en claro conserva exactamente el valor de hoy', (
      tester,
    ) async {
      final context = await contextoConTema(tester, AppTheme.lightTheme());
      final esquema = Theme.of(context).colorScheme;

      expect(
        ThemeColors.tituloSobrePrimary(context),
        esquema.onPrimaryContainer,
        reason: 'El texto sin seleccionar se movió en modo claro',
      );
    });

    testWidgets('en oscuro ambos estados pasan 4.5:1', (tester) async {
      final context = await contextoConTema(tester, AppTheme.darkTheme());
      final esquema = Theme.of(context).colorScheme;

      // Sin seleccionar: fondo `primary`, que en oscuro es el acento CLARO.
      expect(
        contraste(ThemeColors.tituloSobrePrimary(context), esquema.primary),
        greaterThanOrEqualTo(4.5),
        reason: 'La opción sin seleccionar no se lee',
      );
      // Seleccionado: fondo `primaryContainer`.
      expect(
        contraste(esquema.onPrimaryContainer, esquema.primaryContainer),
        greaterThanOrEqualTo(4.5),
        reason: 'La opción seleccionada no se lee',
      );
    });

    testWidgets('el oscuro no queda peor que el claro', (tester) async {
      final claro = await contextoConTema(tester, AppTheme.lightTheme());
      final enClaro = contraste(
        ThemeColors.tituloSobrePrimary(claro),
        Theme.of(claro).colorScheme.primary,
      );
      final oscuro = await contextoConTema(tester, AppTheme.darkTheme());
      final enOscuro = contraste(
        ThemeColors.tituloSobrePrimary(oscuro),
        Theme.of(oscuro).colorScheme.primary,
      );

      expect(enOscuro, greaterThanOrEqualTo(enClaro));
    });
  });
}
