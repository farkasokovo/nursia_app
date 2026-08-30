// lib/widgets/category_grid.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'category_button.dart';

/// Datos de un botón de categoría, sin construir el widget todavía.
class CategoriaGridItem {
  final String titulo;
  final IconData icono;
  final String heroTag;
  final VoidCallback onTap;

  const CategoriaGridItem({
    required this.titulo,
    required this.icono,
    required this.heroTag,
    required this.onTap,
  });
}

/// Grid paginado de [CategoryButton], en bloques verticales deslizables.
///
/// Encapsula la lógica de paginación en bloques y el cálculo de aspect
/// ratio dinámico que antes estaba duplicada en farmacologia_screen,
/// escalas_screen y normativa_screen.
///
/// **Contrato de layout:** se adapta al espacio que le da su padre, así que
/// necesita un alto acotado (dentro de un `Expanded`, un `SizedBox` o el hijo
/// de un `TabBarView`, que es como lo usan hoy las cuatro pantallas). No
/// estima el espacio ni consulta el alto total de la pantalla: lo mide con un
/// `LayoutBuilder` y descuenta él mismo la barra de navegación del sistema.
class CategoryGrid extends StatefulWidget {
  final List<CategoriaGridItem> items;
  final int crossAxisCount;
  final int itemsPorPagina;

  const CategoryGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 2,
    this.itemsPorPagina = 8,
  });

  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> {
  static const double _spacing = 16.0;

  /// Aire al final de cada página, para que al deslizar se note el corte
  /// entre un bloque y el siguiente. Solo se reserva cuando hay más de una
  /// página: con un solo bloque no hay nada que separar y ese espacio le hace
  /// falta a los botones.
  static const double _espacioEntrePaginas = 16.0;

  /// Margen mínimo entre el último botón y la zona del sistema. Va sumado
  /// al inset real de la barra de navegación, no en su lugar: aunque el
  /// cálculo sea exacto, los botones nunca quedan pegados a la barra.
  static const double _margenInferiorMinimo = 12.0;

  /// Piso del alto de botón. Solo entra en juego cuando el espacio se reduce
  /// mucho (el teclado abierto sobre la pantalla de búsqueda, una pantalla muy
  /// baja). Por debajo de esto el ícono y el título ya no caben en la celda,
  /// así que es preferible que el bloque se recorte a que los botones queden
  /// aplastados y con el texto encimado.
  static const double _altoBotonMinimo = 96.0;

  late List<List<CategoriaGridItem>> _bloques;

  Size? _ultimoEspacio;
  double _ratioDinamico = 1;

  @override
  void initState() {
    super.initState();
    _bloques = _chunkList(widget.items, widget.itemsPorPagina);
  }

  @override
  void didUpdateWidget(covariant CategoryGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length ||
        oldWidget.itemsPorPagina != widget.itemsPorPagina) {
      _bloques = _chunkList(widget.items, widget.itemsPorPagina);
    }
    // El número de filas por página depende de itemsPorPagina y de las
    // columnas: si cambian, el ratio cacheado ya no sirve.
    if (oldWidget.itemsPorPagina != widget.itemsPorPagina ||
        oldWidget.crossAxisCount != widget.crossAxisCount) {
      _ultimoEspacio = null;
    }
  }

  List<List<CategoriaGridItem>> _chunkList(
    List<CategoriaGridItem> list,
    int chunkSize,
  ) {
    final chunks = <List<CategoriaGridItem>>[];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
          i,
          i + chunkSize > list.length ? list.length : i + chunkSize,
        ),
      );
    }
    return chunks;
  }

  /// Espacio reservado al final de cada página. Ver [_espacioEntrePaginas].
  double get _separacionPaginas =>
      _bloques.length > 1 ? _espacioEntrePaginas : 0.0;

  // El aspect ratio solo depende del espacio que el padre le da al grid, así
  // que se cachea y se recalcula únicamente cuando ese espacio realmente
  // cambia (rotación, teclado, barra del sistema) — no en cada rebuild que
  // dispara la pantalla contenedora (ej. al escribir en el buscador).
  void _recalcularLayout(Size espacio) {
    final filas = (widget.itemsPorPagina / widget.crossAxisCount).ceil();

    // El ancho ya viene descontado del padding horizontal de la pantalla: es
    // el que mide el LayoutBuilder, no el de la pantalla completa.
    final anchoBoton =
        (espacio.width - (widget.crossAxisCount - 1) * _spacing) /
        widget.crossAxisCount;

    final altoParaBotones =
        espacio.height - _separacionPaginas - (filas - 1) * _spacing;
    final altoBoton = math.max(altoParaBotones / filas, _altoBotonMinimo);

    // GridView exige un ratio positivo; el max evita que un espacio degenerado
    // (ancho casi cero) lo tire.
    _ratioDinamico = math.max(anchoBoton, 1.0) / altoBoton;
    _ultimoEspacio = espacio;
  }

  @override
  Widget build(BuildContext context) {
    // SafeArea aparta la barra de navegación del sistema (de gestos o de
    // botones, según el dispositivo) y el Padding agrega el margen mínimo
    // encima de ella. El LayoutBuilder va adentro para que mida el espacio
    // que queda DESPUÉS de apartar esa zona.
    return SafeArea(
      // Solo el borde inferior: arriba manda el AppBar y a los lados cada
      // pantalla ya pone su propio padding.
      top: false,
      left: false,
      right: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: _margenInferiorMinimo),
        child: LayoutBuilder(
          builder: (context, constraints) {
            assert(
              constraints.hasBoundedHeight,
              'CategoryGrid mide el alto que le da su padre. Colócalo dentro '
              'de un Expanded, un SizedBox o un TabBarView, no en un espacio '
              'de alto infinito como una Column sin acotar.',
            );

            final espacio = constraints.biggest;
            if (_ultimoEspacio != espacio) {
              _recalcularLayout(espacio);
            }

            return PageView.builder(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemCount: _bloques.length,
              itemBuilder: (context, index) {
                final bloque = _bloques[index];

                // Cuando el bloque tiene un número impar de ítems en 2 columnas,
                // el último quedaría huérfano a media pantalla. En vez de eso,
                // sumamos un cell "Próximamente" para completar la fila. Al ser
                // una celda más del grid, hereda el mismo childAspectRatio
                // dinámico. Con crossAxisCount == 1 nunca aplica (cada botón ya
                // llena su fila).
                final tieneHuerfano =
                    widget.crossAxisCount == 2 && bloque.length.isOdd;
                if (tieneHuerfano) {
                  debugPrint(
                    'CategoryGrid: bloque $index impar (${bloque.length}) -> '
                    'se agrega placeholder "Próximamente"',
                  );
                }
                final itemCount = bloque.length + (tieneHuerfano ? 1 : 0);

                return Padding(
                  padding: EdgeInsets.only(bottom: _separacionPaginas),
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: widget.crossAxisCount,
                      mainAxisSpacing: _spacing,
                      crossAxisSpacing: _spacing,
                      childAspectRatio: _ratioDinamico,
                    ),
                    itemCount: itemCount,
                    itemBuilder: (context, i) {
                      // La celda extra (índice fuera del bloque) es el
                      // placeholder.
                      if (i >= bloque.length) {
                        return const ComingSoonButton();
                      }
                      final item = bloque[i];
                      return CategoryButton(
                        title: item.titulo,
                        icon: item.icono,
                        heroTag: item.heroTag,
                        onTap: item.onTap,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
