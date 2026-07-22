// lib/widgets/category_grid.dart
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
class CategoryGrid extends StatefulWidget {
  final List<CategoriaGridItem> items;
  final int crossAxisCount;
  final int itemsPorPagina;
  final double espacioSuperiorEstimado;

  const CategoryGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 2,
    this.itemsPorPagina = 8,
    this.espacioSuperiorEstimado = 280,
  });

  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> {
  static const double _spacing = 16.0;

  late List<List<CategoriaGridItem>> _bloques;

  Size? _ultimoTamano;
  double _espacioDisponible = 0;
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

  // El aspect ratio y el alto disponible solo dependen del tamaño de
  // pantalla, así que se cachean y se recalculan únicamente cuando ese
  // tamaño realmente cambia (rotación, resize) — no en cada rebuild que
  // dispara la pantalla contenedora (ej. al escribir en el buscador).
  void _recalcularLayout(Size tamano) {
    final filas = (widget.itemsPorPagina / widget.crossAxisCount).ceil();
    final espacioDisponible = tamano.height - widget.espacioSuperiorEstimado;
    final anchoBoton =
        (tamano.width - 32 - (widget.crossAxisCount - 1) * _spacing) /
        widget.crossAxisCount;
    final altoTotalParaBotones = espacioDisponible - (filas - 1) * _spacing;
    final altoBotonIdeal = altoTotalParaBotones / filas;

    _espacioDisponible = espacioDisponible;
    _ratioDinamico = anchoBoton / altoBotonIdeal;
    _ultimoTamano = tamano;
  }

  @override
  Widget build(BuildContext context) {
    final tamano = MediaQuery.sizeOf(context);
    if (_ultimoTamano != tamano) {
      _recalcularLayout(tamano);
    }

    return SizedBox(
      height: _espacioDisponible,
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        itemCount: _bloques.length,
        itemBuilder: (context, index) {
          final bloque = _bloques[index];

          // Cuando el bloque tiene un número impar de ítems en 2 columnas, el
          // último quedaría huérfano a media pantalla. En vez de eso, sumamos
          // un cell "Próximamente" para completar la fila. Al ser una celda
          // más del grid, hereda el mismo childAspectRatio dinámico. Con
          // crossAxisCount == 1 nunca aplica (cada botón ya llena su fila).
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
            padding: const EdgeInsets.only(bottom: 16),
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
                // La celda extra (índice fuera del bloque) es el placeholder.
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
      ),
    );
  }
}
