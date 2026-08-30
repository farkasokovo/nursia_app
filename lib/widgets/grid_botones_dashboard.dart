// lib/widgets/grid_botones_dashboard.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Grid de 2 columnas de botones para los dashboards (el de inicio y el de
/// Esenciales).
///
/// **Cómo se usa:** dentro de una `Column`, envuelto en
/// `Flexible(fit: FlexFit.loose)`. Así recibe como `maxHeight` el espacio que
/// de verdad sobró después de los bloques fijos de esa columna, porque Flutter
/// ya los midió. No estima nada ni consulta el alto de la pantalla.
///
/// ```dart
/// Column(
///   children: [
///     Flexible(fit: FlexFit.loose, child: GridBotonesDashboard(botones: [...])),
///     const SizedBox(height: 16),
///     const OtroBloque(),
///   ],
/// )
/// ```
///
/// El grid crece hasta [altoFilaIdeal] y ahí se detiene: con `FlexFit.loose`
/// puede ocupar menos de lo que le tocaba, y ese sobrante se va al final de la
/// columna en vez de abrirse como un hueco entre bloques. Cuando el espacio se
/// reduce (una tarjeta desplegable que se abre abajo), encoge hasta
/// [altoFilaMinima] y de ahí en adelante se desplaza por dentro, sin desbordar.
class GridBotonesDashboard extends StatelessWidget {
  const GridBotonesDashboard({
    super.key,
    required this.botones,
    this.espacio = 16,
  });

  /// Los botones, en orden de lectura. Se acomodan en 2 columnas.
  final List<Widget> botones;

  /// Separación entre botones. Conviene que sea la misma que separa los
  /// bloques de la columna: si todos los huecos miden igual, ninguno resalta.
  final double espacio;

  /// Alto al que aspira cada fila. No es un número inventado: es el
  /// `minimumSize` que `HomeNavButton` declara como su tamaño de diseño.
  static const double altoFilaIdeal = 150;

  /// Alto mínimo de una fila, medido: 76 px del contenido de un
  /// `HomeNavButton` (ícono de 40, separación de 12 y un renglón de título de
  /// 24) más 28 px del padding propio del `ElevatedButton`. Por debajo de esto
  /// el contenido del botón se desborda, así que el grid deja de encoger y se
  /// desplaza por dentro.
  static const double altoFilaMinima = 104;

  @override
  Widget build(BuildContext context) {
    final filas = (botones.length / 2).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        assert(
          constraints.hasBoundedHeight,
          'GridBotonesDashboard mide el alto que le deja su Column. Va dentro '
          'de un Flexible(fit: FlexFit.loose), no en un espacio de alto '
          'infinito como un SingleChildScrollView.',
        );

        final altoFilaLibre =
            (constraints.maxHeight - (filas - 1) * espacio) / filas;
        final altoFila = altoFilaLibre
            .clamp(altoFilaMinima, altoFilaIdeal)
            .toDouble();
        final anchoBoton = (constraints.maxWidth - espacio) / 2;
        final altoGrid = math.min(
          constraints.maxHeight,
          altoFila * filas + (filas - 1) * espacio,
        );

        return SizedBox(
          height: altoGrid,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            // Cuando ya no hay de dónde encoger, el grid se desplaza por
            // dentro en vez de desbordar la columna.
            physics: const ClampingScrollPhysics(),
            itemCount: botones.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: espacio,
              crossAxisSpacing: espacio,
              // GridView exige un ratio positivo.
              childAspectRatio: math.max(anchoBoton, 1.0) / altoFila,
            ),
            itemBuilder: (context, index) => botones[index],
          ),
        );
      },
    );
  }
}
