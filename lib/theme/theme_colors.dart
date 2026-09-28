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

  /// Etiqueta de la pestaña NO seleccionada de un `TabBar`.
  ///
  /// Va atenuada a propósito, para que la pestaña activa destaque. En claro
  /// eso lo daba `colorScheme.tertiaryContainer` (#D6C9BE): claro sobre la
  /// barra café, 5.14:1. En oscuro esa misma ranura es una SUPERFICIE oscura
  /// (#453729) sobre una barra casi igual de oscura, y cae a 1.13:1.
  ///
  /// `ink3` es la tinta apagada del tema oscuro: 4.19:1 sobre la barra, lo
  /// bastante para leerse sin competir con la pestaña activa, que va en
  /// `onPrimaryContainer`.
  static Color pestanaInactiva(BuildContext context) => _esOscuro(context)
      ? AppColorsDark.ink3
      : Theme.of(context).colorScheme.tertiaryContainer;

  /// Título de un botón o tarjeta que va sobre `colorScheme.primary`.
  ///
  /// Estos títulos usan `textTheme.titleSmall` sin color propio, y ese estilo
  /// es crema. En claro funciona: `primary` es el café medio. En oscuro
  /// `primary` es el acento CLARO (#CBA786) y el título queda en 1.85:1; con
  /// la tinta oscura sube a 7.58:1.
  ///
  /// El valor claro es el MISMO `#F6F3F0` que ya tiene `titleSmall`, no el
  /// `#EFE9E4` de `onPrimary`: así el modo claro no se mueve ni un tono.
  static Color tituloSobrePrimary(BuildContext context) => _esOscuro(context)
      ? AppColorsDark.accentOn
      : AppColors.lightSecondaryColor;

  /// Fondo de las filas de datos de una tabla.
  ///
  /// Antes se pedía a `colorScheme.onPrimaryContainer`, que es un color de
  /// CONTENIDO, no una superficie: en oscuro pintaba las filas de #EFE9E4,
  /// casi blanco. El encabezado sí es una superficie de verdad y sigue en
  /// `primaryContainer`.
  static Color filaTabla(BuildContext context) => _esOscuro(context)
      ? AppColorsDark.ruleSoft
      : AppColors.lightSecondaryColor;

  /// Texto de celda sobre [filaTabla].
  ///
  /// En oscuro el café medio de `bodySmall` sobre la fila queda en 3.98:1,
  /// debajo del mínimo para texto normal; con la tinta clara sube a 11.89:1.
  static Color sobreFilaTabla(BuildContext context) =>
      _esOscuro(context) ? AppColorsDark.ink : AppColors.semiDarkPrimaryColor;

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
