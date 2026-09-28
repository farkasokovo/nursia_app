// test/alert_colors_test.dart
//
// El criterio de aceptación del modo oscuro es que el modo CLARO no cambie
// ni un color. AlertColors metió una indirección entre las escalas y la
// paleta, así que esa promesa deja de ser evidente al leer el código: aquí
// queda fijada.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursia_app/theme/alert_colors.dart';
import 'package:nursia_app/theme/app_theme.dart';

/// El color que cada nivel tenía CLAVADO en las escalas antes de AlertColors.
/// Se escriben aquí a mano, sin leerlos de AlertColors, para que la prueba
/// falle si alguien cambia el mapeo.
const Map<NivelAlerta, Color> coloresClarosDeSiempre = {
  NivelAlerta.sinAlerta: AppColors.withoutAlert,
  NivelAlerta.verde: AppColors.greenAlert,
  NivelAlerta.rojo1: AppColors.redAlertv1,
  NivelAlerta.rojo2: AppColors.redAlertv2,
  NivelAlerta.rojo3: AppColors.redAlertv3,
  NivelAlerta.rojo4: AppColors.redAlertv4,
};

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
    testWidgets('onSurface y fill devuelven el color de siempre', (
      tester,
    ) async {
      final context = await contextoConTema(tester, AppTheme.lightTheme());

      for (final entrada in coloresClarosDeSiempre.entries) {
        expect(
          AlertColors.onSurface(context, entrada.key),
          entrada.value,
          reason: 'onSurface cambió el claro de ${entrada.key}',
        );
        expect(
          AlertColors.fill(context, entrada.key),
          entrada.value,
          reason: 'fill cambió el claro de ${entrada.key}',
        );
      }
    });
  });

  group('en modo oscuro las dos variantes se separan', () {
    testWidgets('onSurface es más claro que fill en todos los niveles', (
      tester,
    ) async {
      final context = await contextoConTema(tester, AppTheme.darkTheme());

      for (final nivel in NivelAlerta.values) {
        final texto = AlertColors.onSurface(context, nivel);
        final relleno = AlertColors.fill(context, nivel);

        // Si los dos coincidieran, uno de los dos usos quedaría ilegible:
        // ese es justo el problema que AlertColors existe para evitar.
        expect(
          texto,
          isNot(relleno),
          reason: '$nivel usa el mismo color para texto y para relleno',
        );
        expect(
          texto.computeLuminance(),
          greaterThan(relleno.computeLuminance()),
          reason:
              'En $nivel el color de texto no es más claro que el de relleno',
        );
      }
    });

    testWidgets('el texto contrasta contra el fondo de la app', (tester) async {
      final context = await contextoConTema(tester, AppTheme.darkTheme());
      final fondo = AppColorsDark.ground.computeLuminance();

      for (final nivel in NivelAlerta.values) {
        final texto = AlertColors.onSurface(context, nivel).computeLuminance();
        final contraste = (texto + 0.05) / (fondo + 0.05);
        // 3:1 es el mínimo de WCAG para texto grande y en negritas, que es
        // como se usan estos colores (resultados y etiquetas de escala).
        expect(
          contraste,
          greaterThanOrEqualTo(3.0),
          reason: '$nivel no se lee sobre el fondo oscuro ($contraste:1)',
        );
      }
    });
  });
}
