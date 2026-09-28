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

  /// Primitivo del que salen todos los demás: elige entre dos colores según
  /// el brillo del tema.
  ///
  /// Los helpers con nombre de abajo son preferibles en las pantallas: el
  /// nombre dice PARA QUÉ es el color, y el valor claro queda escrito una
  /// sola vez en lugar de repetirse en cada punto de uso. Este se usa
  /// directo solo cuando el caso es único y no vale la pena bautizarlo.
  static Color segunTema(
    BuildContext context, {
    required Color claro,
    required Color oscuro,
  }) => _esOscuro(context) ? oscuro : claro;

  /// Color de una sombra proyectada.
  ///
  /// Sobre fondo claro una sombra negra al 12% basta para despegar una
  /// tarjeta. Sobre el fondo oscuro de la app esa misma sombra es invisible
  /// (negro sobre casi negro), así que las tarjetas pierden profundidad y
  /// todo se ve plano. En oscuro se sube la opacidad.
  ///
  /// [claro] es el color literal que el sitio ya usaba, para que el modo
  /// claro quede idéntico sin depender de redondeos: `Colors.black12` es
  /// alpha 0.1216, no 0.12. Las dos opacidades se declaran en cada punto de
  /// uso en vez de deducir una de la otra: los valores de hoy no siguen una
  /// sola escala, y una regla automática cambiaría alguno sin querer.
  static Color sombra(
    BuildContext context, {
    required Color claro,
    required double oscuro,
  }) => segunTema(
    context,
    claro: claro,
    oscuro: Colors.black.withValues(alpha: oscuro),
  );

  /// Contenido secundario (subtítulos, chevrons) sobre `colorScheme.primary`.
  ///
  /// Recibe el blanco translúcido literal de hoy ([enClaro]) y lo devuelve
  /// tal cual en modo claro. En oscuro `primary` es el acento CLARO
  /// (#CBA786), así que un blanco encima desaparece: ahí se usa `onPrimary`,
  /// que en ese tema sí es oscuro, conservando la misma transparencia.
  static Color sobrePrimary(BuildContext context, Color enClaro) => segunTema(
    context,
    claro: enClaro,
    oscuro: Theme.of(
      context,
    ).colorScheme.onPrimary.withValues(alpha: enClaro.a),
  );

  /// Texto atenuado sobre la superficie de énfasis (la barra café oscura:
  /// AppBar, TabBar, encabezado del menú lateral).
  ///
  /// Va apagado a propósito, para que lo que sí está activo destaque. En
  /// claro eso lo daban ranuras `*Container`, que ahí resultan CLARAS sobre
  /// la barra café. En oscuro esas mismas ranuras son superficies oscuras
  /// sobre una barra casi igual de oscura, y caen a ~1.1:1.
  ///
  /// [claro] es la ranura exacta que el sitio ya usaba, así que el modo claro
  /// no se mueve. `ink3` es la tinta apagada del tema oscuro: 3.94:1 sobre la
  /// barra, suficiente para leerse sin competir con el contenido activo, que
  /// va en 8.21:1.
  static Color tenueSobreEnfasis(
    BuildContext context, {
    required Color claro,
  }) => segunTema(context, claro: claro, oscuro: AppColorsDark.ink3);

  /// Título de un botón o tarjeta que va sobre `colorScheme.primary`.
  ///
  /// Estos títulos usan `textTheme.titleSmall` sin color propio, y ese estilo
  /// es crema. En claro funciona: `primary` es el café medio. En oscuro
  /// `primary` es el acento CLARO (#CBA786) y el título queda en 1.85:1; con
  /// la tinta oscura sube a 7.58:1.
  ///
  /// El valor claro es el MISMO `#F6F3F0` que ya tiene `titleSmall`, no el
  /// `#EFE9E4` de `onPrimary`: así el modo claro no se mueve ni un tono.
  static Color tituloSobrePrimary(BuildContext context) => segunTema(
    context,
    claro: AppColors.lightSecondaryColor,
    oscuro: AppColorsDark.accentOn,
  );

  /// Relleno del campo de búsqueda.
  ///
  /// Antes se pedía a `colorScheme.onPrimaryContainer`, que es un color de
  /// CONTENIDO, no una superficie: en oscuro pintaba el campo de #EFE9E4,
  /// casi blanco. El contorno, los íconos y el texto de ayuda ya usan
  /// ranuras `on...` que en oscuro son claras, así que funcionan sobre este
  /// relleno oscuro sin tocarlos.
  static Color campoBusqueda(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return segunTema(
      context,
      claro: esquema.onPrimaryContainer,
      oscuro: esquema.surface,
    );
  }

  /// Fondo de las filas de datos de una tabla.
  ///
  /// Antes se pedía a `colorScheme.onPrimaryContainer`, que es un color de
  /// CONTENIDO, no una superficie: en oscuro pintaba las filas de #EFE9E4,
  /// casi blanco. El encabezado sí es una superficie de verdad y sigue en
  /// `primaryContainer`.
  static Color filaTabla(BuildContext context) => segunTema(
    context,
    claro: AppColors.lightSecondaryColor,
    oscuro: AppColorsDark.ruleSoft,
  );

  /// Texto de celda sobre [filaTabla].
  ///
  /// En oscuro el café medio de `bodySmall` sobre la fila queda en 3.98:1,
  /// debajo del mínimo para texto normal; con la tinta clara sube a 11.89:1.
  static Color sobreFilaTabla(BuildContext context) => segunTema(
    context,
    claro: AppColors.semiDarkPrimaryColor,
    oscuro: AppColorsDark.ink,
  );

  /// Acento cálido de la app (#CBA786).
  ///
  /// Es el mismo valor en los dos temas: es un tono medio que se lee tanto
  /// sobre el crema del modo claro como sobre el café oscuro. No tiene ranura
  /// en el ColorScheme claro (ahí `primary` es otro café), pero SÍ es
  /// `colorScheme.primary` del tema oscuro, así que vive aquí para que
  /// ninguna pantalla tenga que nombrar la paleta directamente.
  static Color acento(BuildContext context) => segunTema(
    context,
    claro: AppColors.accentDarkColor,
    oscuro: AppColorsDark.accent,
  );
}
