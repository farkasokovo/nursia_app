// lib/theme/theme_colors.dart
//
// Colores que dependen del tema pero no son alertas clínicas y no tienen
// ranura propia en el ColorScheme. Gemelo de `alert_colors.dart`.

import 'package:flutter/material.dart';

import 'app_theme.dart';

class ThemeColors {
  const ThemeColors._();

  static bool _esOscuro(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Color de una sombra proyectada.
  ///
  /// Sobre fondo claro una sombra negra al 12% basta para despegar una
  /// tarjeta. Sobre el fondo oscuro de la app esa misma sombra es invisible
  /// (negro sobre casi negro), así que las tarjetas pierden profundidad y
  /// todo se ve plano. En oscuro se sube la opacidad.
  ///
  /// Las dos opacidades se declaran en cada punto de uso en vez de deducir
  /// una de la otra: los valores de hoy no siguen una sola escala, y una
  /// regla automática cambiaría alguno sin querer.
  /// [claro] es el color literal que el sitio ya usaba, para que el modo
  /// claro quede idéntico sin depender de redondeos: `Colors.black12` es
  /// alpha 0.1216, no 0.12.
  static Color sombra(
    BuildContext context, {
    required Color claro,
    required double oscuro,
  }) => _esOscuro(context) ? Colors.black.withValues(alpha: oscuro) : claro;

  /// Contenido secundario (subtítulos, chevrons) sobre `colorScheme.primary`.
  ///
  /// En claro `primary` es el café medio y encima va blanco translúcido: se
  /// conserva el literal exacto que la app usa hoy. En oscuro `primary` es el
  /// acento CLARO (#CBA786), así que un blanco encima desaparece; ahí se usa
  /// `onPrimary`, que en ese tema sí es oscuro.
  /// Recibe el blanco translúcido literal de hoy ([enClaro]) y lo devuelve
  /// tal cual en modo claro. En oscuro conserva su misma transparencia pero
  /// sobre `onPrimary`.
  static Color sobrePrimary(BuildContext context, Color enClaro) =>
      _esOscuro(context)
      ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: enClaro.a)
      : enClaro;

  /// Acento cálido de la app (#CBA786).
  ///
  /// Es el mismo valor en los dos temas: es un tono medio que se lee tanto
  /// sobre el crema del modo claro como sobre el café oscuro. No tiene ranura
  /// en el ColorScheme claro (ahí `primary` es otro café), pero SÍ es
  /// `colorScheme.primary` del tema oscuro, así que vive aquí para que
  /// ninguna pantalla tenga que nombrar la paleta directamente.
  static Color acento(BuildContext context) =>
      _esOscuro(context) ? AppColorsDark.accent : AppColors.accentDarkColor;
}
