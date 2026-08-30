// test/category_grid_test.dart
//
// El bug que originó estas pruebas: en un dispositivo con navegación por
// BOTONES, los botones de categoría se encimaban con la barra del sistema.
// El grid estimaba el espacio con una constante (280) en vez de medirlo, y esa
// constante estaba calibrada contra un dispositivo con navegación por gestos,
// donde la barra ocupa mucho menos.
//
// Estas pruebas simulan las dos barras y comprueban que ningún botón invade la
// zona del sistema, sin necesidad de un dispositivo físico.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursia_app/widgets/category_button.dart';
import 'package:nursia_app/widgets/category_grid.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Margen mínimo que el grid deja entre el último botón y la zona del sistema.
const double margenInferiorMinimo = 12.0;

/// Alto del hueco que la pantalla contenedora le da al grid.
const double altoDisponible = 560.0;

List<CategoriaGridItem> itemsDePrueba(int cantidad, {String? titulo}) {
  return List.generate(
    cantidad,
    (i) => CategoriaGridItem(
      titulo: titulo ?? 'Categoría $i',
      icono: PhosphorIconsRegular.pill,
      heroTag: 'hero_$i',
      onTap: () {},
    ),
  );
}

/// Monta el grid dentro de un hueco de alto conocido, con la barra del sistema
/// que se le indique. `insetInferior` en 24 imita navegación por gestos y en 48
/// navegación por botones.
Future<void> montarGrid(
  WidgetTester tester, {
  required double insetInferior,
  int cantidadItems = 8,
  int crossAxisCount = 2,
  int itemsPorPagina = 8,
  double alto = altoDisponible,
  String? titulo,
}) async {
  // Superficie del tamaño de un celular chico. Sin esto, la ventana de prueba
  // (800x600) recorta el alto que se le pide al hueco y las medidas mienten.
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(360, 800),
          padding: EdgeInsets.only(bottom: insetInferior),
          viewPadding: EdgeInsets.only(bottom: insetInferior),
        ),
        // Mismo esqueleto que usan las pantallas reales: padding horizontal de
        // 16 y un hueco de alto acotado.
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: alto,
              child: CategoryGrid(
                items: itemsDePrueba(cantidadItems, titulo: titulo),
                crossAxisCount: crossAxisCount,
                itemsPorPagina: itemsPorPagina,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Borde inferior del botón que llega más abajo en la página visible.
double bordeInferiorDelUltimoBoton(WidgetTester tester) {
  final botones = find.byType(CategoryButton).evaluate();
  expect(botones, isNotEmpty, reason: 'No se dibujó ningún botón');
  return botones
      .map((e) => tester.getRect(find.byWidget(e.widget)).bottom)
      .reduce((a, b) => a > b ? a : b);
}

void main() {
  testWidgets('con navegación por botones ningún botón invade la barra', (
    tester,
  ) async {
    // 48 es el alto típico de la barra de 3 botones de Android.
    await montarGrid(tester, insetInferior: 48);

    // El grid arranca en y = 0 y mide 560. La barra ocupa los últimos 48, y
    // encima de ella va el margen mínimo de 12.
    final limite = altoDisponible - 48 - margenInferiorMinimo;
    expect(bordeInferiorDelUltimoBoton(tester), lessThanOrEqualTo(limite));
    expect(tester.takeException(), isNull);
  });

  testWidgets('con navegación por gestos tampoco invade la barra', (
    tester,
  ) async {
    await montarGrid(tester, insetInferior: 24);

    final limite = altoDisponible - 24 - margenInferiorMinimo;
    expect(bordeInferiorDelUltimoBoton(tester), lessThanOrEqualTo(limite));
    expect(tester.takeException(), isNull);
  });

  testWidgets('sin barra del sistema queda el margen mínimo', (tester) async {
    // Android sin edge-to-edge: la ventana ya viene recortada y el inset es 0.
    // Aun así los botones no deben quedar pegados al borde.
    await montarGrid(tester, insetInferior: 0);

    final limite = altoDisponible - margenInferiorMinimo;
    expect(bordeInferiorDelUltimoBoton(tester), lessThanOrEqualTo(limite));
    expect(tester.takeException(), isNull);
  });

  testWidgets('el alto del botón se adapta al tamaño de la barra', (
    tester,
  ) async {
    await montarGrid(tester, insetInferior: 0);
    final altoSinBarra = tester
        .getSize(find.byType(CategoryButton).first)
        .height;

    await montarGrid(tester, insetInferior: 48);
    final altoConBarra = tester
        .getSize(find.byType(CategoryButton).first)
        .height;

    // Con barra de botones hay menos espacio, así que los botones se ajustan.
    // Si no cambiara, el grid estaría ignorando la barra (el bug original).
    expect(altoConBarra, lessThan(altoSinBarra));
  });

  testWidgets('una sola columna (Normativa) también respeta la barra', (
    tester,
  ) async {
    await montarGrid(
      tester,
      insetInferior: 48,
      cantidadItems: 6,
      crossAxisCount: 1,
      itemsPorPagina: 4,
    );

    final limite = altoDisponible - 48 - margenInferiorMinimo;
    expect(bordeInferiorDelUltimoBoton(tester), lessThanOrEqualTo(limite));
    expect(tester.takeException(), isNull);
  });

  testWidgets('el placeholder "Próximamente" sobrevive al cambio', (
    tester,
  ) async {
    // Bloque impar en 2 columnas: se completa la fila con el placeholder.
    await montarGrid(tester, insetInferior: 48, cantidadItems: 5);

    expect(find.byType(ComingSoonButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el PageView vertical sigue paginando por bloques', (
    tester,
  ) async {
    await montarGrid(tester, insetInferior: 48, cantidadItems: 12);

    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.scrollDirection, Axis.vertical);
    // 12 items en bloques de 8 = 2 páginas.
    expect(find.text('Categoría 0'), findsOneWidget);
    expect(find.text('Categoría 8'), findsNothing);

    await tester.fling(find.byType(PageView), const Offset(0, -300), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Categoría 8'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
