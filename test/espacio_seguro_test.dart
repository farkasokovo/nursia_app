// test/espacio_seguro_test.dart
//
// Pruebas del espacio seguro inferior (la barra de navegación del sistema) en
// las pantallas que NO pasan por category_grid.dart, y del hueco que el molde
// de las escalas abría entre el título y las pestañas.
//
// Todas simulan las dos barras de Android: 48 px con navegación por botones
// (el caso que reportó la usuaria) y 24 con navegación por gestos.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursia_app/screens/home_dashboard.dart';
import 'package:nursia_app/theme/app_theme.dart';
import 'package:nursia_app/widgets/grid_botones_dashboard.dart';
import 'package:nursia_app/widgets/home_nav_button.dart';
import 'package:nursia_app/widgets/molde_escalas_screen.dart';
import 'package:nursia_app/widgets/scale_result_footer.dart';
import 'package:nursia_app/widgets/tarjeta_desplegable.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Alto de la barra de 3 botones de Android.
const double insetBotones = 48;

/// Alto de la barra de gestos.
const double insetGestos = 24;

/// Margen mínimo que las pantallas dejan encima de la barra del sistema.
const double margenMinimo = 12;

/// Pantalla de prueba. Es un poco más alta que un celular de 800 px a
/// propósito: la fuente de las pruebas es bastante más ancha que Poppins y
/// parte títulos como "Calculadoras" en dos renglones, así que los botones
/// necesitan más alto aquí que en el dispositivo real. Lo que se mide (que
/// nada invada la barra del sistema y que los huecos sean iguales) no depende
/// del alto de la pantalla.
const Size pantalla = Size(360, 900);

Future<void> montar(
  WidgetTester tester,
  Widget pantallaAProbar, {
  required double inset,
}) async {
  tester.view.physicalSize = Size(pantalla.width * 3, pantalla.height * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme(),
      home: MediaQuery(
        data: MediaQueryData(
          size: pantalla,
          padding: EdgeInsets.only(top: 24, bottom: inset),
          viewPadding: EdgeInsets.only(top: 24, bottom: inset),
        ),
        child: pantallaAProbar,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// El dashboard vive dentro del TabBarView de HomeScreen: un Scaffold con
/// AppBar y sin bottomNavigationBar, así que el body llega hasta el borde
/// inferior de la pantalla, por detrás de la barra del sistema.
Widget envoltorioHome() => DefaultTabController(
  length: 5,
  child: Scaffold(
    appBar: AppBar(title: const Text('Nurska')),
    body: const HomeDashboard(),
  ),
);

void main() {
  group('Dashboard de inicio', () {
    testWidgets('el Tip del día queda completo encima de la barra', (
      tester,
    ) async {
      await montar(tester, envoltorioHome(), inset: insetBotones);

      final tip = tester.getRect(find.byType(TarjetaDesplegable));
      final limite = pantalla.height - insetBotones - margenMinimo;

      // Antes del arreglo el tip empezaba DEBAJO de la barra del sistema y su
      // parte inferior se salía de la pantalla.
      expect(
        tip.bottom,
        lessThanOrEqualTo(limite),
        reason: 'El tip invade la barra del sistema',
      );
      expect(tip.top, greaterThan(0));
      expect(tester.takeException(), isNull);
    });

    testWidgets('los bloques quedan separados por el mismo espacio', (
      tester,
    ) async {
      await montar(tester, envoltorioHome(), inset: insetBotones);

      final grid = tester.getRect(find.byType(GridBotonesDashboard));
      final esenciales = tester.getRect(find.byType(BotonEsenciales));
      final procedimientos = tester.getRect(find.byType(BotonProcedimientos));
      final tip = tester.getRect(find.byType(TarjetaDesplegable));

      // El grid absorbe la holgura, así que ningún hueco se dispara: los tres
      // son exactamente el mismo espacio de 16.
      expect(esenciales.top - grid.bottom, closeTo(16, 0.01));
      expect(procedimientos.top - esenciales.bottom, closeTo(16, 0.01));
      expect(tip.top - procedimientos.bottom, closeTo(16, 0.01));
    });

    testWidgets('con barra de gestos hay más alto para los botones', (
      tester,
    ) async {
      await montar(tester, envoltorioHome(), inset: insetBotones);
      final conBotones = tester
          .getSize(find.byType(HomeNavButton).first)
          .height;

      await montar(tester, envoltorioHome(), inset: insetGestos);
      final conGestos = tester.getSize(find.byType(HomeNavButton).first).height;

      // Si no cambiara, el dashboard estaría ignorando la barra del sistema.
      expect(conBotones, lessThan(conGestos));
      // Y en ningún caso se aplasta por debajo de lo que mide su contenido.
      expect(
        conBotones,
        greaterThanOrEqualTo(GridBotonesDashboard.altoFilaMinima),
      );
    });
  });

  group('Molde de escalas', () {
    Widget escala() => MoldeEscalasScreen(
      heroTag: 'escala',
      title: 'RASS',
      icon: PhosphorIconsFill.brain,
      scaleTab: const SizedBox(),
      infoTab: const SizedBox(),
    );

    testWidgets(
      'el hueco entre el título y las pestañas no depende de la barra',
      (tester) async {
        await montar(tester, escala(), inset: 0);
        final huecoSinBarra =
            tester.getRect(find.byType(TabBar)).top -
            tester.getRect(find.text('RASS')).bottom;

        await montar(tester, escala(), inset: insetBotones);
        final huecoConBarra =
            tester.getRect(find.byType(TabBar)).top -
            tester.getRect(find.text('RASS')).bottom;

        // El encabezado está pegado ARRIBA: la barra de navegación, que está
        // abajo, no tiene por qué abrir un hueco debajo del título. Antes del
        // arreglo este hueco crecía 48 px con navegación por botones.
        expect(huecoConBarra, closeTo(huecoSinBarra, 0.01));
        expect(huecoConBarra, lessThan(24));
      },
    );

    testWidgets('el encabezado sigue esquivando la barra de estado', (
      tester,
    ) async {
      await montar(tester, escala(), inset: insetBotones);

      // El título no debe quedar debajo de la barra de estado (24 px).
      expect(tester.getRect(find.text('RASS')).top, greaterThanOrEqualTo(24.0));
    });
  });

  group('Footer de resultado de las escalas', () {
    Widget footer() => DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            const Expanded(child: SizedBox()),
            const ScaleResultFooter(visible: true, resultado: '15'),
          ],
        ),
      ),
    );

    testWidgets('los botones quedan encima de la barra del sistema', (
      tester,
    ) async {
      await montar(tester, footer(), inset: insetBotones);

      final finalizar = tester.getRect(find.text('Finalizar'));
      final verMas = tester.getRect(find.text('Ver más'));
      final limite = pantalla.height - insetBotones;

      expect(finalizar.bottom, lessThanOrEqualTo(limite));
      expect(verMas.bottom, lessThanOrEqualTo(limite));
      expect(tester.takeException(), isNull);
    });

    testWidgets('el fondo del panel sigue llegando al borde de la pantalla', (
      tester,
    ) async {
      await montar(tester, footer(), inset: insetBotones);

      // El SafeArea va por dentro: la tarjeta se ve anclada abajo, sin una
      // franja del color del fondo entre ella y el borde.
      final panel = tester.getRect(find.byType(ScaleResultFooter));
      expect(panel.bottom, closeTo(pantalla.height, 0.01));
    });
  });

  group('GridBotonesDashboard', () {
    Widget conAlto(double alto) => DefaultTabController(
      length: 5,
      child: Scaffold(
        body: SizedBox(
          height: alto,
          child: Column(
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: GridBotonesDashboard(
                  botones: const [
                    HomeNavButton(
                      title: 'Uno',
                      tabIndex: 0,
                      icon: PhosphorIconsFill.chartBarHorizontal,
                    ),
                    HomeNavButton(
                      title: 'Dos',
                      tabIndex: 4,
                      icon: PhosphorIconsFill.bookOpen,
                    ),
                    HomeNavButton(
                      title: 'Tres',
                      tabIndex: 1,
                      icon: PhosphorIconsFill.syringe,
                    ),
                    HomeNavButton(
                      title: 'Cuatro',
                      tabIndex: 3,
                      icon: PhosphorIconsFill.calculator,
                    ),
                  ],
                ),
              ),
              Container(height: 120, color: Colors.red),
            ],
          ),
        ),
      ),
    );

    testWidgets('no crece más allá del alto de diseño del botón', (
      tester,
    ) async {
      // Espacio de sobra: el grid se planta en su alto ideal y el resto se
      // queda al final de la columna, no como hueco entre bloques.
      await montar(tester, conAlto(700), inset: 0);

      final alto = tester.getSize(find.byType(HomeNavButton).first).height;
      expect(alto, closeTo(GridBotonesDashboard.altoFilaIdeal, 0.01));
      expect(tester.takeException(), isNull);
    });

    testWidgets('encoge cuando el espacio se reduce, hasta su mínimo', (
      tester,
    ) async {
      await montar(tester, conAlto(400), inset: 0);
      final altoApretado = tester
          .getSize(find.byType(HomeNavButton).first)
          .height;

      expect(altoApretado, lessThan(GridBotonesDashboard.altoFilaIdeal));
      expect(
        altoApretado,
        greaterThanOrEqualTo(GridBotonesDashboard.altoFilaMinima),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('sin espacio suficiente se desplaza por dentro, no desborda', (
      tester,
    ) async {
      // El bloque fijo de 120 casi no deja nada: el grid llega a su mínimo y
      // el GridView se encarga de recortar con scroll, sin franjas amarillas.
      await montar(tester, conAlto(260), inset: 0);

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(HomeNavButton).first).height,
        closeTo(GridBotonesDashboard.altoFilaMinima, 0.01),
      );
    });
  });
}
