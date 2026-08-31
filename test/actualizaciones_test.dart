// test/actualizaciones_test.dart
//
// Cubre las dos piezas sin UI de la función de actualizaciones: el parseo del
// changelog local (que Diego edita a mano en cada versión, así que tiene que
// aguantar errores de dedo) y la decisión de mostrar la bienvenida una sola vez
// por versión.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursia_app/screens/actualizaciones_screen.dart';
import 'package:nursia_app/screens/bienvenida_screen.dart';
import 'package:nursia_app/theme/app_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nursia_app/models/nota_version.dart';
import 'package:nursia_app/utils/bienvenida_version.dart';
import 'package:nursia_app/utils/changelog_local.dart';
import 'package:nursia_app/widgets/tarjeta_desplegable.dart';
import 'package:nursia_app/utils/preferencias_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ================================================================
  // GUARDIÁN DEL INTERRUPTOR DE DESARROLLO
  // ================================================================
  test('el interruptor de desarrollo de la bienvenida está apagado', () {
    // Si esta prueba falla, `forzarBienvenida` quedó en true en
    // lib/utils/bienvenida_version.dart. En un APK de release no tendría
    // efecto (va condicionado a kDebugMode), pero no debe subirse así.
    expect(
      forzarBienvenida,
      isFalse,
      reason:
          'forzarBienvenida quedó en true. Regrésalo a false en '
          'lib/utils/bienvenida_version.dart antes de compilar el APK.',
    );
  });

  group('interruptor de desarrollo encendido (solo en debug)', () {
    test('muestra la bienvenida sin importar el marcador guardado', () async {
      final almacen = AlmacenMemoria({claveBienvenidaVista: '1.2.0'});

      final mostrar = await debeMostrarBienvenida(
        versionInstalada: '1.2.0', // la misma que ya se vio
        almacen: almacen,
        forzar: true,
      );

      expect(mostrar, isTrue);
    });

    test('no escribe el marcador mientras está forzada', () async {
      final almacen = AlmacenMemoria();

      await debeMostrarBienvenida(
        versionInstalada: '1.2.0',
        almacen: almacen,
        forzar: true,
      );

      // El estado real del dispositivo queda intacto: al apagar el
      // interruptor, la lógica normal sigue viendo lo que había.
      expect(almacen.datos, isEmpty);
    });
  });

  // ================================================================
  // PARSEO DEL CHANGELOG
  // ================================================================
  group('parsearChangelog: entradas válidas', () {
    test('lee versión, fecha y cambios', () {
      final notas = parsearChangelog('''
        [
          {
            "version": "1.2.1",
            "fecha": "2026-08-30",
            "cambios": ["Uno.", "Dos."]
          }
        ]
      ''');

      expect(notas, hasLength(1));
      expect(notas.first.version, '1.2.1');
      expect(notas.first.fecha, '2026-08-30');
      expect(notas.first.cambios, ['Uno.', 'Dos.']);
    });

    test('conserva el orden del archivo', () {
      final notas = parsearChangelog('''
        [
          {"version": "1.2.1", "cambios": ["a"]},
          {"version": "1.2.0", "cambios": ["b"]}
        ]
      ''');

      expect(notas.map((n) => n.version), ['1.2.1', '1.2.0']);
    });

    test('la fecha es opcional', () {
      final notas = parsearChangelog(
        '[{"version": "1.0.0", "cambios": ["a"]}]',
      );
      expect(notas.single.fecha, isEmpty);
    });
  });

  group('parsearChangelog: tolerancia a errores de dedo', () {
    test('JSON inválido devuelve lista vacía, no excepción', () {
      expect(parsearChangelog('{esto no es json'), isEmpty);
      expect(parsearChangelog(''), isEmpty);
    });

    test('si la raíz no es una lista, devuelve vacío', () {
      expect(parsearChangelog('{"version": "1.0.0"}'), isEmpty);
    });

    test('una entrada mala no tumba a las buenas', () {
      final notas = parsearChangelog('''
        [
          {"version": "1.2.1", "cambios": ["buena"]},
          {"cambios": ["sin version"]},
          {"version": "1.1.0"},
          {"version": "1.0.9", "cambios": "no es lista"},
          "ni siquiera es un objeto",
          {"version": "1.0.0", "cambios": ["también buena"]}
        ]
      ''');

      expect(notas.map((n) => n.version), ['1.2.1', '1.0.0']);
    });

    test('los cambios vacíos se descartan sin perder la entrada', () {
      final notas = parsearChangelog('''
        [{"version": "1.2.1", "cambios": ["bueno", "", "   ", "otro"]}]
      ''');

      expect(notas.single.cambios, ['bueno', 'otro']);
    });

    test('una versión que se queda sin cambios se omite', () {
      final notas = parsearChangelog(
        '[{"version": "1.2.1", "cambios": ["", " "]}]',
      );
      expect(notas, isEmpty);
    });
  });

  group('NotaVersion.fechaLegible', () {
    test('convierte la fecha ISO a texto', () {
      const nota = NotaVersion(
        version: '1.2.0',
        fecha: '2026-08-29',
        cambios: ['x'],
      );
      expect(nota.fechaLegible, '29 de agosto de 2026');
    });

    test('una fecha que no es ISO se muestra tal cual', () {
      const nota = NotaVersion(
        version: '1.2.0',
        fecha: 'agosto 2026',
        cambios: ['x'],
      );
      expect(nota.fechaLegible, 'agosto 2026');
    });

    test('un mes fuera de rango no revienta', () {
      const nota = NotaVersion(
        version: '1.2.0',
        fecha: '2026-13-01',
        cambios: ['x'],
      );
      expect(nota.fechaLegible, '2026-13-01');
    });
  });

  // ================================================================
  // EL ARCHIVO REAL
  // ================================================================
  group('changelog real (assets/data/changelog.json)', () {
    late List<NotaVersion> notas;

    setUpAll(() {
      final crudo = File('assets/data/changelog.json').readAsStringSync();
      notas = parsearChangelog(crudo);
    });

    test('se parsea y trae versiones', () {
      expect(notas, isNotEmpty);
    });

    test('ninguna versión se repite', () {
      final versiones = notas.map((n) => n.version).toList();
      expect(versiones.toSet(), hasLength(versiones.length));
    });

    test('toda versión trae fecha en formato ISO', () {
      for (final nota in notas) {
        expect(
          RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(nota.fecha),
          isTrue,
          reason: 'La versión ${nota.version} tiene la fecha "${nota.fecha}"',
        );
      }
    });

    test('ningún cambio usa raya larga (regla de estilo de CLAUDE.md)', () {
      for (final nota in notas) {
        for (final cambio in nota.cambios) {
          expect(
            cambio.contains('—') || cambio.contains('–'),
            isFalse,
            reason: 'En ${nota.version}: "$cambio"',
          );
        }
      }
    });

    test('la versión de pubspec.yaml tiene su entrada en el changelog', () {
      // Guarda para no publicar una versión sin notas: la pantalla de
      // novedades y la de bienvenida leen justo esta entrada.
      final pubspec = File('pubspec.yaml').readAsLinesSync();
      final linea = pubspec.firstWhere((l) => l.startsWith('version:'));
      final version = linea.split(':')[1].trim().split('+').first;

      expect(
        notas.map((n) => n.version),
        contains(version),
        reason:
            'pubspec.yaml declara $version y changelog.json no la incluye. '
            'Al subir de versión hay que agregar su entrada.',
      );
    });

    test('el asset está registrado en pubspec.yaml', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('assets/data/changelog.json'));
    });

    test('ChangelogLocal lo lee desde el bundle', () async {
      ChangelogLocal.limpiarCache();
      final desdeBundle = await ChangelogLocal.cargar();
      expect(desdeBundle.map((n) => n.version), notas.map((n) => n.version));
    });
  });

  // ================================================================
  // BIENVENIDA: UNA SOLA VEZ POR VERSIÓN
  // ================================================================
  group('decidirBienvenida', () {
    test('instalación nueva: no se muestra, pero se recuerda la versión', () {
      final d = decidirBienvenida(
        versionInstalada: '1.2.1',
        versionRecordada: null,
        hayNotas: true,
      );
      expect(d.mostrar, isFalse);
      expect(d.recordar, isTrue);
    });

    test('misma versión ya vista: ni se muestra ni hace falta guardar', () {
      final d = decidirBienvenida(
        versionInstalada: '1.2.1',
        versionRecordada: '1.2.1',
        hayNotas: true,
      );
      expect(d.mostrar, isFalse);
      expect(d.recordar, isFalse);
    });

    test('recién actualizado con notas: se muestra y se recuerda', () {
      final d = decidirBienvenida(
        versionInstalada: '1.2.1',
        versionRecordada: '1.2.0',
        hayNotas: true,
      );
      expect(d.mostrar, isTrue);
      expect(d.recordar, isTrue);
    });

    test(
      'recién actualizado sin notas: no se muestra vacía, pero se recuerda',
      () {
        final d = decidirBienvenida(
          versionInstalada: '1.3.0',
          versionRecordada: '1.2.0',
          hayNotas: false,
        );
        expect(d.mostrar, isFalse);
        expect(d.recordar, isTrue);
      },
    );

    test('una instalación vieja también dispara la bienvenida', () {
      // Reinstalar una versión anterior es un cambio de versión como
      // cualquier otro: lo que importa es que sea distinta de la recordada.
      final d = decidirBienvenida(
        versionInstalada: '1.1.0',
        versionRecordada: '1.2.0',
        hayNotas: true,
      );
      expect(d.mostrar, isTrue);
    });
  });

  group('debeMostrarBienvenida (con el changelog real)', () {
    late String versionConNotas;

    setUpAll(() async {
      ChangelogLocal.limpiarCache();
      final notas = await ChangelogLocal.cargar();
      versionConNotas = notas.first.version;
    });

    test('se muestra una vez y ya no vuelve a mostrarse', () async {
      final almacen = AlmacenMemoria({claveBienvenidaVista: '0.9.0'});

      // forzar: false explícito. Estas pruebas son del flujo normal, así que
      // no deben depender de cómo esté el interruptor de desarrollo.
      final primera = await debeMostrarBienvenida(
        versionInstalada: versionConNotas,
        almacen: almacen,
        forzar: false,
      );
      expect(primera, isTrue);
      expect(almacen.datos[claveBienvenidaVista], versionConNotas);

      // Segundo arranque con la misma versión: ya no.
      final segunda = await debeMostrarBienvenida(
        versionInstalada: versionConNotas,
        almacen: almacen,
        forzar: false,
      );
      expect(segunda, isFalse);
    });

    test('instalación nueva no la muestra y deja la versión anotada', () async {
      final almacen = AlmacenMemoria();

      final mostrar = await debeMostrarBienvenida(
        versionInstalada: versionConNotas,
        almacen: almacen,
        forzar: false,
      );

      expect(mostrar, isFalse);
      expect(almacen.datos[claveBienvenidaVista], versionConNotas);
    });

    test(
      'una versión sin entrada en el changelog no muestra nada, pero se anota',
      () async {
        final almacen = AlmacenMemoria({claveBienvenidaVista: '1.0.0'});

        final mostrar = await debeMostrarBienvenida(
          versionInstalada: '9.9.9',
          almacen: almacen,
        );

        expect(mostrar, isFalse);
        expect(almacen.datos[claveBienvenidaVista], '9.9.9');
      },
    );
  });

  group('AlmacenPersistente (shared_preferences)', () {
    test('guarda y lee una clave', () async {
      SharedPreferences.setMockInitialValues({});
      final almacen = AlmacenPersistente();

      expect(await almacen.leer(claveBienvenidaVista), isNull);
      await almacen.guardar(claveBienvenidaVista, '1.2.1');
      expect(await almacen.leer(claveBienvenidaVista), '1.2.1');
    });

    test('lee lo que ya estaba guardado de antes', () async {
      SharedPreferences.setMockInitialValues({claveBienvenidaVista: '1.2.0'});
      final almacen = AlmacenPersistente();

      expect(await almacen.leer(claveBienvenidaVista), '1.2.0');
    });

    test('sirve para el ciclo completo de la bienvenida', () async {
      SharedPreferences.setMockInitialValues({claveBienvenidaVista: '1.2.0'});
      final almacen = AlmacenPersistente();
      ChangelogLocal.limpiarCache();
      final notas = await ChangelogLocal.cargar();

      final mostrar = await debeMostrarBienvenida(
        versionInstalada: notas.first.version,
        almacen: almacen,
        forzar: false,
      );

      expect(mostrar, isTrue);
      expect(await almacen.leer(claveBienvenidaVista), notas.first.version);
    });
  });

  group('AlmacenMemoria', () {
    test('guarda y devuelve lo guardado', () async {
      final almacen = AlmacenMemoria();
      expect(await almacen.leer('x'), isNull);
      await almacen.guardar('x', '1');
      expect(await almacen.leer('x'), '1');
    });
  });

  test('el changelog real es JSON válido y con la forma esperada', () {
    final data = json.decode(
      File('assets/data/changelog.json').readAsStringSync(),
    );
    expect(data, isA<List>());
    for (final entrada in data as List) {
      expect(entrada, isA<Map>());
      expect((entrada as Map)['version'], isA<String>());
      expect(entrada['cambios'], isA<List>());
    }
  });

  // ================================================================
  // PANTALLA DE BIENVENIDA: SOLO SE CIERRA CON EL BOTÓN
  // ================================================================
  group('BienvenidaScreen', () {
    const nota = NotaVersion(
      version: '1.2.1',
      fecha: '2026-08-30',
      cambios: ['Un cambio.', 'Otro cambio.'],
    );

    Future<void> abrir(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BienvenidaScreen(notas: nota),
                    fullscreenDialog: true,
                  ),
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    testWidgets('muestra la versión y sus cambios', (tester) async {
      await abrir(tester);

      // El encabezado es texto de presentación y se ajusta seguido; lo que la
      // prueba fija es el contenido: la versión y sus cambios.
      expect(find.text('Versión 1.2.1'), findsOneWidget);
      expect(find.text('Un cambio.'), findsOneWidget);
      expect(find.text('Otro cambio.'), findsOneWidget);
    });

    testWidgets('el botón atrás del sistema NO la cierra', (tester) async {
      await abrir(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // Sigue ahí: la única salida es el botón de abajo.
      expect(find.byType(BienvenidaScreen), findsOneWidget);
    });

    testWidgets('se cierra con "Entendido"', (tester) async {
      await abrir(tester);

      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();

      expect(find.byType(BienvenidaScreen), findsNothing);
      expect(find.text('abrir'), findsOneWidget);
    });

    /// Monta la pantalla con la barra del sistema que se le indique.
    /// 48 imita navegación por botones; 24, gestos; 0, un Android sin
    /// edge-to-edge, donde la ventana ya viene recortada.
    Future<void> montarConBarra(WidgetTester tester, double inset) async {
      tester.view.physicalSize = const Size(360 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(360, 800),
              padding: EdgeInsets.only(top: 24, bottom: inset),
              viewPadding: EdgeInsets.only(top: 24, bottom: inset),
            ),
            child: const BienvenidaScreen(notas: nota),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'el botón "Entendido" no queda debajo de la barra del sistema',
      (tester) async {
        for (final inset in [48.0, 24.0]) {
          await montarConBarra(tester, inset);

          final boton = tester.getRect(find.byType(ElevatedButton));
          expect(
            boton.bottom,
            lessThanOrEqualTo(800 - inset),
            reason: 'El botón invade la barra del sistema con inset de $inset',
          );
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets('el fondo claro llega hasta el borde inferior de la pantalla', (
      tester,
    ) async {
      await montarConBarra(tester, 48);

      // El SafeArea va DENTRO del bloque del botón: aparta el botón, pero deja
      // que el color cubra la zona de la barra. Si envolviera la columna
      // entera, ahí se vería una franja del café del Scaffold.
      final franja = tester.getRect(
        find
            .ancestor(
              of: find.byType(ElevatedButton),
              matching: find.byType(SafeArea),
            )
            .first,
      );
      expect(franja.bottom, closeTo(800, 0.01));
    });

    testWidgets('sin barra del sistema el botón no queda pegado al borde', (
      tester,
    ) async {
      await montarConBarra(tester, 0);

      final boton = tester.getRect(find.byType(ElevatedButton));
      expect(800 - boton.bottom, greaterThanOrEqualTo(12.0));
    });

    testWidgets('no tiene botón de cerrar en la esquina', (tester) async {
      await abrir(tester);

      // Ni AppBar ni ícono de cerrar: se recorre el contenido y se sale abajo.
      expect(find.byType(AppBar), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
    });
  });

  // ================================================================
  // PANTALLA DE ACTUALIZACIONES (humo, sin tocar la red)
  // ================================================================
  group('ActualizacionesScreen', () {
    testWidgets('muestra la versión instalada y sus novedades', (tester) async {
      PackageInfo.setMockInitialValues(
        appName: 'Nurska',
        packageName: 'com.nurska.app',
        version: '1.2.0',
        buildNumber: '3',
        buildSignature: '',
      );
      // El asset se carga con I/O real, que dentro de testWidgets no resuelve
      // con el reloj falso. runAsync lo lee de verdad y deja el caché listo.
      ChangelogLocal.limpiarCache();
      await tester.runAsync(ChangelogLocal.cargar);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          home: const ActualizacionesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Versión instalada'), findsOneWidget);
      expect(find.text('1.2.0'), findsOneWidget);
      expect(find.text('Buscar actualizaciones'), findsOneWidget);
      // La tarjeta de novedades arranca expandida. El texto esperado sale del
      // changelog real, no de una copia aquí: así la prueba no se rompe cada
      // vez que se editan las notas de una versión.
      final nota = (await ChangelogLocal.cargar()).firstWhere(
        (n) => n.version == '1.2.0',
      );
      expect(find.byType(TarjetaDesplegable), findsOneWidget);
      expect(find.text(nota.cambios.first), findsOneWidget);
      expect(find.text(nota.fechaLegible), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sin entrada en el changelog avisa en vez de dejar el hueco', (
      tester,
    ) async {
      PackageInfo.setMockInitialValues(
        appName: 'Nurska',
        packageName: 'com.nurska.app',
        version: '9.9.9',
        buildNumber: '1',
        buildSignature: '',
      );
      // El asset se carga con I/O real, que dentro de testWidgets no resuelve
      // con el reloj falso. runAsync lo lee de verdad y deja el caché listo.
      ChangelogLocal.limpiarCache();
      await tester.runAsync(ChangelogLocal.cargar);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          home: const ActualizacionesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Esta versión no trae notas registradas.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
