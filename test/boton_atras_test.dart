// test/boton_atras_test.dart
//
// El botón atrás de Android ya se rompió dos veces en esta app: una dejando
// pantalla negra (un Navigator.pop() sobre la ruta raíz) y otra cerrando la app
// con el teclado abierto en vez de cerrar el teclado. Estas pruebas fijan el
// contrato de los tres estados del buscador.
//
// Cómo se simula el atrás del sistema: `tester.binding.handlePopRoute()` es
// exactamente lo que el engine llama cuando llega el gesto o el botón. Si nadie
// lo atiende, el framework termina llamando a SystemNavigator.pop(), que aquí
// se intercepta con un handler falso del canal de plataforma.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursia_app/screens/home_screen.dart';
import 'package:nursia_app/theme/app_theme.dart';
import 'package:nursia_app/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:nursia_app/widgets/searchable_screen.dart';

/// Registro de las llamadas al canal de plataforma durante una prueba.
class _EspiaPlataforma {
  final List<String> metodos = [];

  bool get pidioCerrarLaApp => metodos.contains('SystemNavigator.pop');

  void instalar(WidgetTester tester) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        metodos.add(call.method);
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });
  }
}

/// Monta el buscador como ruta RAÍZ, que es donde vive de verdad: dentro del
/// TabBarView de home_screen, sin ninguna ruta empujada encima.
Future<void> montarBuscador(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme(),
      home: Scaffold(
        body: SearchableScreen<String>(
          items: const ['Glasgow', 'Braden', 'Downton'],
          searchableFields: (item) => [item],
          hintText: 'Buscar escala...',
          onItemTap: (_) {},
          itemTitle: (item) => item,
          emptyWidget: const Text('Sin resultados'),
          categoriesBuilder: (context) => const Text('CATEGORIAS'),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Dispara el atrás del sistema tal como llega desde Android.
Future<void> presionarAtras(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

void main() {
  group('Buscador de las pestañas (SearchableScreen)', () {
    testWidgets('con texto: el atrás limpia el texto y no cierra la app', (
      tester,
    ) async {
      final espia = _EspiaPlataforma()..instalar(tester);
      await montarBuscador(tester);

      await tester.enterText(find.byType(TextField), 'Glas');
      await tester.pumpAndSettle();
      expect(find.text('Glasgow'), findsOneWidget);

      await presionarAtras(tester);

      // El texto se fue y los botones de categoría volvieron.
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(find.text('CATEGORIAS'), findsOneWidget);
      expect(espia.pidioCerrarLaApp, isFalse);
      // Y la pantalla sigue ahí: nada de pantalla negra.
      expect(find.byType(SearchableScreen<String>), findsOneWidget);
    });

    testWidgets(
      'con foco y sin texto: el atrás suelta el foco y no cierra la app',
      (tester) async {
        final espia = _EspiaPlataforma()..instalar(tester);
        await montarBuscador(tester);

        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
          isTrue,
        );

        await presionarAtras(tester);

        // Esta es la regresión que reportó Diego: aquí la app se cerraba en vez
        // de cerrar el teclado.
        expect(
          tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
          isFalse,
        );
        expect(espia.pidioCerrarLaApp, isFalse);
        expect(find.byType(SearchableScreen<String>), findsOneWidget);
      },
    );

    testWidgets(
      'sin foco ni texto: el atrás llega al sistema y cierra la app',
      (tester) async {
        final espia = _EspiaPlataforma()..instalar(tester);
        await montarBuscador(tester);

        await presionarAtras(tester);

        // El buscador ya no bloquea, así que el evento sigue su curso y termina
        // en SystemNavigator.pop() al PRIMER intento.
        expect(espia.pidioCerrarLaApp, isTrue);
      },
    );

    testWidgets('el atrás nunca hace pop de la ruta raíz (pantalla negra)', (
      tester,
    ) async {
      _EspiaPlataforma().instalar(tester);
      await montarBuscador(tester);

      // Tres veces seguidas en el peor caso: sin texto ni foco, que es cuando
      // el código viejo llamaba a Navigator.pop() y vaciaba el navegador.
      for (var i = 0; i < 3; i++) {
        await presionarAtras(tester);
      }

      expect(find.byType(SearchableScreen<String>), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('texto y foco a la vez: limpia y suelta, sin cerrar la app', (
      tester,
    ) async {
      final espia = _EspiaPlataforma()..instalar(tester);
      await montarBuscador(tester);

      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'Braden');
      await tester.pumpAndSettle();

      await presionarAtras(tester);

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(espia.pidioCerrarLaApp, isFalse);
    });

    testWidgets('después de limpiar, el siguiente atrás sí cierra la app', (
      tester,
    ) async {
      final espia = _EspiaPlataforma()..instalar(tester);
      await montarBuscador(tester);

      await tester.enterText(find.byType(TextField), 'Downton');
      await tester.pumpAndSettle();

      await presionarAtras(tester);
      expect(espia.pidioCerrarLaApp, isFalse, reason: 'El primero limpia');

      await presionarAtras(tester);
      expect(espia.pidioCerrarLaApp, isTrue, reason: 'El segundo ya sale');
    });
  });

  group('Pantalla raíz (home_screen)', () {
    // HomeScreen se monta completo: la pestaña inicial es el dashboard, que no
    // necesita repositories, y el TabBarView no construye las otras pestañas.
    Future<void> montarHome(
      WidgetTester tester, {
      required bool teclado,
    }) async {
      // Pantalla alta a propósito: al simular el teclado, el Scaffold encoge el
      // body 300 px y en 800 px el dashboard ya no cabría. En la app real ese
      // caso no existe (el dashboard no tiene campos de texto; el teclado solo
      // se abre sobre las pestañas con buscador, que sí se adaptan), y lo que
      // se prueba aquí es el PopScope, no el acomodo.
      tester.view.physicalSize = const Size(360 * 3, 1100 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(360, 1100),
              viewInsets: EdgeInsets.only(bottom: teclado ? 300 : 0),
            ),
            // El selector de tema del menu lee ThemeProvider, asi que la
            // pantalla necesita uno arriba igual que en la app real. Se
            // construye sin cargar() : basta con el valor por defecto.
            child: ChangeNotifierProvider<ThemeProvider>(
              create: (_) => ThemeProvider(),
              child: const HomeScreen(),
            ),
          ),
        ),
      );
      // pump con duración en vez de pumpAndSettle: la verificación de versión
      // corre en un post-frame y no interesa esperarla.
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('sin teclado: el primer atrás cierra la app', (tester) async {
      final espia = _EspiaPlataforma()..instalar(tester);
      await montarHome(tester, teclado: false);

      await tester.binding.handlePopRoute();
      await tester.pump();

      // Síntoma A: antes hacían falta cuatro intentos, porque cualquier nodo
      // enfocado del TabBarView bloqueaba la salida.
      expect(espia.pidioCerrarLaApp, isTrue);
    });

    testWidgets('con teclado abierto: el atrás no cierra la app', (
      tester,
    ) async {
      final espia = _EspiaPlataforma()..instalar(tester);
      await montarHome(tester, teclado: true);

      await tester.binding.handlePopRoute();
      await tester.pump();

      // La regresión que reportó Diego: con el teclado abierto el atrás tiene
      // que cerrar el teclado, nunca la app.
      expect(espia.pidioCerrarLaApp, isFalse);
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
