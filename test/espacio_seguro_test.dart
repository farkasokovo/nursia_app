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
import 'package:nursia_app/models/norma.dart';
import 'package:nursia_app/models/ver_mas_screen.dart';
import 'package:nursia_app/screens/ficha_normativa_screen.dart';
import 'package:nursia_app/widgets/estructura_ver_mas_screen.dart';
import 'package:nursia_app/widgets/searchable_screen.dart';
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

  group('Resultados del buscador (NOMs, Escalas, Farmacología)', () {
    Future<void> buscar(WidgetTester tester, double inset) async {
      await montar(
        tester,
        Scaffold(
          body: SearchableScreen<String>(
            // Suficientes resultados para que la lista se desborde y la última
            // tarjeta llegue de verdad hasta abajo: con pocos items el bug no
            // se manifiesta.
            items: List.generate(20, (i) => 'Escala número $i'),
            searchableFields: (item) => [item],
            hintText: 'Buscar escala...',
            onItemTap: (_) {},
            itemTitle: (item) => item,
            emptyWidget: const Text('Sin resultados'),
            categoriesBuilder: (context) => const Text('CATEGORIAS'),
          ),
        ),
        inset: inset,
      );
      // Con el buscador vacío se ven las categorías; hay que escribir para que
      // aparezca la lista de resultados.
      await tester.enterText(find.byType(TextField), 'Escala');
      await tester.pumpAndSettle();
    }

    testWidgets('la lista reserva la barra del sistema más el aire mínimo', (
      tester,
    ) async {
      await buscar(tester, insetBotones);

      final lista = tester.widget<ListView>(find.byType(ListView));
      expect(
        lista.padding,
        const EdgeInsets.only(bottom: 16 + insetBotones),
        reason: 'La última tarjeta quedaría debajo de la barra del sistema',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('con gestos reserva menos, pero conserva el aire', (
      tester,
    ) async {
      await buscar(tester, insetGestos);

      final lista = tester.widget<ListView>(find.byType(ListView));
      expect(lista.padding, const EdgeInsets.only(bottom: 16 + insetGestos));
    });

    testWidgets('sin barra del sistema queda solo el aire mínimo', (
      tester,
    ) async {
      await buscar(tester, 0);

      final lista = tester.widget<ListView>(find.byType(ListView));
      expect(lista.padding, const EdgeInsets.only(bottom: 16));
    });

    testWidgets('la última tarjeta queda con aire sobre la barra', (
      tester,
    ) async {
      await buscar(tester, insetBotones);

      // Hasta el tope del scroll, que es donde se veía el problema. Con
      // jumpTo en vez de fling la posición es exacta y no depende del rebote.
      final posicion = tester
          .state<ScrollableState>(
            find.descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            ),
          )
          .position;
      posicion.jumpTo(posicion.maxScrollExtent);
      await tester.pumpAndSettle();

      // El buscador ordena por relevancia, así que no se asume cuál item
      // quedó al final: se mide la tarjeta que llegue más abajo.
      final bordeMasBajo = tester
          .widgetList<Card>(find.byType(Card))
          .map((tarjeta) => tester.getRect(find.byWidget(tarjeta)).bottom)
          .reduce((a, b) => a > b ? a : b);

      // Se exige el aire, no solo que no invada: un ListView sin `padding`
      // propio ya reservaba el inset por su cuenta (Flutter lo aplica solo
      // cuando el padding es null), pero dejaba la tarjeta pegada a la barra.
      expect(
        bordeMasBajo,
        lessThanOrEqualTo(pantalla.height - insetBotones - 16),
        reason: 'La última tarjeta queda pegada a la barra del sistema',
      );
      expect(tester.takeException(), isNull);
    });
  });

  // Las pantallas de contenido de NOMs, Farmacología y las escalas tienen
  // Scaffold propio y NO heredan el SafeArea del molde de las calculadoras, que
  // es lo que hace que la pestaña "Ver más" de una calculadora se vea bien. Sin
  // reservar la barra, la tarjeta que envuelve el texto se corta contra ella en
  // vez de verse cerrada.
  group('Contenido de las fichas', () {
    /// Desplaza hasta el tope y devuelve el borde inferior de la tarjeta que
    /// envuelve el contenido.
    Future<double> fondoDeLaTarjeta(WidgetTester tester) async {
      final posicion = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      posicion.jumpTo(posicion.maxScrollExtent);
      await tester.pumpAndSettle();

      return tester
          .getRect(
            find
                .descendant(
                  of: find.byType(SingleChildScrollView),
                  matching: find.byType(Container),
                )
                .first,
          )
          .bottom;
    }

    testWidgets('la ficha de una NOM cierra su tarjeta sobre la barra', (
      tester,
    ) async {
      final norma = Norma(
        codigo: 'NOM-004',
        titulo: 'Del expediente clínico',
        tituloCorto: 'Expediente',
        areaSalud: 'general',
        resumen: 'Resumen de la norma. ' * 20,
        palabrasClave: 'expediente',
        puntosClave: List.generate(
          8,
          (i) => const PuntoClave(icono: 'check', texto: 'Punto clave. '),
        ),
        dofReferencia: 'DOF 15/10/2012',
      );

      // Superficie ancha a propósito: la fuente de las pruebas es mucho más
      // ancha que Poppins y desborda el renglón del DOF a 360 px, lo que
      // ensuciaría la medición vertical, que es lo que interesa aquí.
      const alto = 900.0;
      tester.view.physicalSize = const Size(800 * 3, alto * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(800, alto),
              padding: EdgeInsets.only(top: 24, bottom: insetBotones),
              viewPadding: EdgeInsets.only(top: 24, bottom: insetBotones),
            ),
            child: FichaNormativaScreen(norma: norma),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 20 px de aire, los mismos que deja info_tab en las calculadoras.
      expect(
        await fondoDeLaTarjeta(tester),
        lessThanOrEqualTo(alto - insetBotones - 20),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('el "Ver más" de las escalas también', (tester) async {
      final info = VerMasScreen(
        name: 'Downton',
        description: 'Descripción de la escala. ' * 10,
        whenToUse: ['Uno.', 'Dos.'],
        components: ['Tres.', 'Cuatro.'],
        interpretation: ['Cinco.'],
        limitations: ['Seis.'],
        clinicalNotes: ['Siete.'],
        references: const [
          {'text': 'Referencia de ejemplo.', 'url': ''},
        ],
      );

      await montar(
        tester,
        Scaffold(body: EstructuraVerMasScreen(info: info)),
        inset: insetBotones,
      );

      final posicion = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      posicion.jumpTo(posicion.maxScrollExtent);
      await tester.pumpAndSettle();

      // Aquí el aire propio de la pantalla es 16.
      final ultimo = tester.getRect(find.byType(SingleChildScrollView));
      final contenido = tester.getRect(
        find
            .descendant(
              of: find.byType(SingleChildScrollView),
              matching: find.byType(Column),
            )
            .first,
      );
      expect(
        ultimo.bottom - contenido.bottom,
        greaterThanOrEqualTo(16 + insetBotones),
      );
    });
  });

  // Pestaña "Escala": mientras la escala está incompleta no hay panel de
  // resultado, así que el propio ScaleResultFooter reserva la barra del
  // sistema. Las 15 escalas comparten esta estructura (lista desplazable
  // dentro de un Expanded y el footer como último hijo de la columna).
  group('Lista de parámetros de las escalas', () {
    Widget escalaIncompleta({required bool conResultado}) {
      return Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Suficientes para que la lista se desborde: con pocas
                      // tarjetas la última nunca llega hasta abajo y el bug no
                      // se manifiesta.
                      for (var i = 0; i < 14; i++)
                        Card(
                          child: SizedBox(
                            height: 90,
                            width: double.infinity,
                            child: Center(child: Text('Parámetro $i')),
                          ),
                        ),
                      // Las 15 escalas cierran su lista con este aire.
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            ScaleResultFooter(visible: conResultado, resultado: '12'),
          ],
        ),
      );
    }

    testWidgets('sin resultado, el footer reserva la barra del sistema', (
      tester,
    ) async {
      await montar(
        tester,
        escalaIncompleta(conResultado: false),
        inset: insetBotones,
      );

      // Antes devolvía SizedBox.shrink() y la lista llegaba hasta el borde.
      expect(
        tester.getSize(find.byType(ScaleResultFooter)).height,
        insetBotones,
      );
    });

    testWidgets(
      'la última tarjeta de parámetros queda con aire sobre la barra',
      (tester) async {
        await montar(
          tester,
          escalaIncompleta(conResultado: false),
          inset: insetBotones,
        );

        final posicion = tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position;
        posicion.jumpTo(posicion.maxScrollExtent);
        await tester.pumpAndSettle();

        final bordeMasBajo = tester
            .widgetList<Card>(find.byType(Card))
            .map((tarjeta) => tester.getRect(find.byWidget(tarjeta)).bottom)
            .reduce((a, b) => a > b ? a : b);

        // Los 20 de la propia escala, encima de la barra.
        expect(
          bordeMasBajo,
          lessThanOrEqualTo(pantalla.height - insetBotones - 20),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('sin barra del sistema no se cuela ningún hueco extra', (
      tester,
    ) async {
      await montar(tester, escalaIncompleta(conResultado: false), inset: 0);

      expect(tester.getSize(find.byType(ScaleResultFooter)).height, 0);
    });

    testWidgets('con resultado manda el panel, que ya aparta la barra', (
      tester,
    ) async {
      await montar(
        tester,
        escalaIncompleta(conResultado: true),
        inset: insetBotones,
      );

      // El panel llega hasta la orilla y sus botones quedan por encima.
      final panel = tester.getRect(find.byType(ScaleResultFooter));
      expect(panel.bottom, closeTo(pantalla.height, 0.01));
      expect(
        tester.getRect(find.text('Finalizar')).bottom,
        lessThanOrEqualTo(pantalla.height - insetBotones),
      );
    });
  });
}
