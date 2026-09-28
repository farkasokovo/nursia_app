// lib/theme/alert_colors.dart
//
// Resuelve el color de una alerta clínica segun el tema activo Y segun el uso
// que se le va a dar.

import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Gravedad clinica, sin color. Es lo que devuelven las escalas y lo que
/// consume [AlertColors].
///
/// Separar el NIVEL del COLOR es lo que permite que una misma escala se pinte
/// distinto en claro y en oscuro sin tocar su logica: la escala dice "esto es
/// rojo 3" y el tema decide con que tono se dibuja.
enum NivelAlerta { sinAlerta, verde, rojo1, rojo2, rojo3, rojo4 }

/// Traduce un [NivelAlerta] al color que toca.
///
/// Hay DOS metodos porque un mismo nivel necesita dos colores opuestos en
/// modo oscuro:
///
///   - [onSurface] es para TEXTO, iconos y tintes que van directo sobre el
///     fondo de la pantalla. Sobre fondo oscuro tiene que ser un tono CLARO.
///   - [fill] es para RELLENOS solidos que llevan texto crema encima. Sobre
///     fondo oscuro tiene que ser un tono OSCURO, o el texto crema se pierde.
///
/// En modo claro los dos devuelven exactamente el mismo color de [AppColors]
/// que la app usa hoy: la distincion solo existe en oscuro, y por eso el modo
/// claro no cambia ni un pixel.
class AlertColors {
  const AlertColors._();

  static bool _esOscuro(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Color para texto, iconos y tintes sobre la superficie.
  static Color onSurface(BuildContext context, NivelAlerta nivel) =>
      _esOscuro(context) ? _oscuroOnSurface(nivel) : _claro(nivel);

  /// Color para rellenos solidos que llevan texto crema encima.
  static Color fill(BuildContext context, NivelAlerta nivel) =>
      _esOscuro(context) ? _oscuroFill(nivel) : _claro(nivel);

  /// Relleno neutro, FUERA de la escala de alertas: para un resultado que
  /// todavia no se puede valorar.
  ///
  /// En oscuro no es el espejo literal del claro. El cafe medio (#9D826C)
  /// contra texto crema da 2.99:1, por debajo del minimo; `accentLightColor`
  /// da 9.53:1 y queda igual de oscuro que las variantes [fill], asi que la
  /// pastilla conserva su peso visual.
  static Color neutro(BuildContext context) => _esOscuro(context)
      ? AppColorsDark.accentLightColor
      : AppColors.semiDarkPrimaryColor;

  /// Paleta clara. Un solo color por nivel: sobre el crema de la app el mismo
  /// tono funciona igual de relleno que de texto.
  static Color _claro(NivelAlerta nivel) => switch (nivel) {
    NivelAlerta.sinAlerta => AppColors.withoutAlert,
    NivelAlerta.verde => AppColors.greenAlert,
    NivelAlerta.rojo1 => AppColors.redAlertv1,
    NivelAlerta.rojo2 => AppColors.redAlertv2,
    NivelAlerta.rojo3 => AppColors.redAlertv3,
    NivelAlerta.rojo4 => AppColors.redAlertv4,
  };

  static Color _oscuroOnSurface(NivelAlerta nivel) => switch (nivel) {
    NivelAlerta.sinAlerta => AppColorsDark.withoutAlertOnSurface,
    NivelAlerta.verde => AppColorsDark.greenAlertOnSurface,
    NivelAlerta.rojo1 => AppColorsDark.redAlertv1OnSurface,
    NivelAlerta.rojo2 => AppColorsDark.redAlertv2OnSurface,
    NivelAlerta.rojo3 => AppColorsDark.redAlertv3OnSurface,
    NivelAlerta.rojo4 => AppColorsDark.redAlertv4OnSurface,
  };

  static Color _oscuroFill(NivelAlerta nivel) => switch (nivel) {
    NivelAlerta.sinAlerta => AppColorsDark.withoutAlertFill,
    NivelAlerta.verde => AppColorsDark.greenAlertFill,
    NivelAlerta.rojo1 => AppColorsDark.redAlertv1Fill,
    NivelAlerta.rojo2 => AppColorsDark.redAlertv2Fill,
    NivelAlerta.rojo3 => AppColorsDark.redAlertv3Fill,
    NivelAlerta.rojo4 => AppColorsDark.redAlertv4Fill,
  };
}
