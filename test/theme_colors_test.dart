// test/theme_colors_test.dart
//
// ThemeColors metió una indirección entre las pantallas y los literales de
// color que usaban antes (Colors.black12, Colors.white70...). El criterio de
// aceptación del modo oscuro es que el CLARO no cambie, así que aquí queda
// fijado que en claro devuelve exactamente el literal de siempre.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursia_app/theme/app_theme.dart';
import 'package:nursia_app/theme/theme_colors.dart';

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

void main() {
  group('en modo claro nada cambió', () {
    testWidgets('sombra devuelve el literal que recibe', (tester) async {
      final context = await contextoConTema(tester, AppTheme.lightTheme());

      for (final literal in [
        Colors.black12,
        Colors.black26,
        Colors.black.withValues(alpha: 0.10),
      ]) {
        expect(
          ThemeColors.sombra(context, claro: literal, oscuro: 0.35),
          literal,
          reason: 'La sombra clara ya no es $literal',
        );
      }
    });

    testWidgets('sobrePrimary devuelve el blanco que recibe', (tester) async {
      final context = await contextoConTema(tester, AppTheme.lightTheme());

      for (final literal in [Colors.white70, Colors.white54]) {
        expect(
          ThemeColors.sobrePrimary(context, literal),
          literal,
          reason: 'El color claro sobre primary ya no es $literal',
        );
      }
    });

    testWidgets('acento sigue siendo accentDarkColor', (tester) async {
      final context = await contextoConTema(tester, AppTheme.lightTheme());
      expect(ThemeColors.acento(context), AppColors.accentDarkColor);
    });
  });

  group('la premisa del cambio a onSurface', () {
    // ~100 sitios usaban primaryContainer como TINTA y pasaron a onSurface.
    // Eso solo es invisible en claro si las dos ranuras valen lo mismo ahí.
    // Si alguien cambia una de las dos, esta prueba avisa antes de que el
    // modo claro se mueva en cien lugares a la vez.
    testWidgets('en claro, primaryContainer y onSurface son el mismo color', (
      tester,
    ) async {
      final context = await contextoConTema(tester, AppTheme.lightTheme());
      final esquema = Theme.of(context).colorScheme;
      expect(esquema.onSurface, esquema.primaryContainer);
    });

    testWidgets('en oscuro son opuestos: uno tinta, otro superficie', (
      tester,
    ) async {
      final context = await contextoConTema(tester, AppTheme.darkTheme());
      final esquema = Theme.of(context).colorScheme;
      expect(
        esquema.onSurface.computeLuminance(),
        greaterThan(esquema.primaryContainer.computeLuminance()),
        reason: 'onSurface tiene que ser la tinta clara sobre la superficie',
      );
    });
  });

  group('tokens de tabla y de título', () {
    testWidgets('en claro conservan el valor exacto de hoy', (tester) async {
      final context = await contextoConTema(tester, AppTheme.lightTheme());
      final esquema = Theme.of(context).colorScheme;

      // La fila de datos usaba onPrimaryContainer como fondo.
      expect(ThemeColors.filaTabla(context), esquema.onPrimaryContainer);
      // El texto de celda usaba el color propio de bodySmall.
      expect(
        ThemeColors.sobreFilaTabla(context),
        AppTextStyles.verMasBodyText.color,
      );
      // El título de botón usaba el color propio de titleSmall.
      expect(
        ThemeColors.tituloSobrePrimary(context),
        AppTextStyles.titleWhiteText.color,
      );
    });

    testWidgets('en oscuro contrastan contra su propio fondo', (tester) async {
      final context = await contextoConTema(tester, AppTheme.darkTheme());
      final esquema = Theme.of(context).colorScheme;

      double contraste(Color a, Color b) {
        final la = a.computeLuminance(), lb = b.computeLuminance();
        final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
        return (hi + 0.05) / (lo + 0.05);
      }

      expect(
        contraste(
          ThemeColors.sobreFilaTabla(context),
          ThemeColors.filaTabla(context),
        ),
        greaterThanOrEqualTo(4.5),
        reason: 'El texto de celda no se lee sobre la fila',
      );
      expect(
        contraste(ThemeColors.tituloSobrePrimary(context), esquema.primary),
        greaterThanOrEqualTo(4.5),
        reason: 'El título no se lee sobre colorScheme.primary',
      );
    });
  });

  group('en modo oscuro los valores se separan', () {
    testWidgets('la sombra se opaca', (tester) async {
      final context = await contextoConTema(tester, AppTheme.darkTheme());

      final sombra = ThemeColors.sombra(
        context,
        claro: Colors.black12,
        oscuro: 0.35,
      );
      // Sigue siendo negra: no se inventan sombras de color.
      expect(sombra.r, 0);
      expect(sombra.g, 0);
      expect(sombra.b, 0);
      expect(sombra.a, greaterThan(Colors.black12.a));
    });

    testWidgets('sobrePrimary se oscurece y conserva su transparencia', (
      tester,
    ) async {
      final context = await contextoConTema(tester, AppTheme.darkTheme());

      for (final literal in [Colors.white70, Colors.white54]) {
        final resuelto = ThemeColors.sobrePrimary(context, literal);
        // La transparencia es la misma; lo que cambia es el tono.
        expect(resuelto.a, closeTo(literal.a, 0.001));
        // Sobre el acento claro del tema oscuro, el contenido va oscuro.
        expect(
          resuelto.computeLuminance(),
          lessThan(AppColorsDark.accent.computeLuminance()),
          reason: '$literal no contrastaría sobre colorScheme.primary',
        );
      }
    });
  });
}
