import 'package:flutter/material.dart';

// ============================================================
// COLORES (valores estáticos, solo para referencia)
// ============================================================

class AppColors {
  static const Color primaryColor = Color(0xff96775b);
  static const Color secondaryColor = Color(0xffefe9e4);

  static const Color accentLightColor = Color(0xffd6c9be);
  static const Color accentDarkColor = Color(0xffcba786);

  static const Color darkPrimaryColor = Color(0xff624933);
  static const Color lightSecondaryColor = Color(0xffF6F3F0);

  static const Color widgetLightBrown = Color(0xffDFD3C9);

  static const Color greenAlert = Color(0xff9C965C);
  static const Color withoutAlert = Color(0xff9C785C);

  static const Color redAlertv1 = Color(0xff9C5C61);
  static const Color redAlertv2 = Color(0xff8D5458);
  static const Color redAlertv3 = Color(0xff7E4B4F);
  static const Color redAlertv4 = Color(0xff6F4346);

  static const Color semiDarkPrimaryColor = Color(0xff7E6754);
}

// ============================================================
// COLORES — MODO OSCURO
// ============================================================

/// Paleta del modo oscuro.
///
/// Es un ESPEJO EXACTO de [AppColors]: mismos nombres de constante, mismos
/// valores, en el mismo orden. Ahora mismo el modo oscuro se ve idéntico al
/// claro — eso es a propósito.
///
/// La idea es que este archivo sea el único lugar donde tocar el modo oscuro:
/// cambia aquí el valor de una constante y solo el modo oscuro se entera,
/// porque [AppColors] (el modo claro) queda intacto. Se pueden ir ajustando
/// de una en una, comparando cada línea con su gemela de arriba, sin que
/// nada más de la app se mueva.
class AppColorsDark {
  static const Color primaryColor = Color(0xff6C5137);
  static const Color secondaryColor = Color(0xff2F2318);

  static const Color accentLightColor = Color(0xffd6c9be);
  static const Color accentDarkColor = Color(0xffcba786);

  static const Color darkPrimaryColor = Color(0xff4D3A28);
  static const Color lightSecondaryColor = Color(0xffF6F3F0);

  static const Color widgetLightBrown = Color(0xffDFD3C9);

  static const Color greenAlert = Color(0xff9C965C);
  static const Color withoutAlert = Color(0xff9C785C);

  static const Color redAlertv1 = Color(0xff9C5C61);
  static const Color redAlertv2 = Color(0xff8D5458);
  static const Color redAlertv3 = Color(0xff7E4B4F);
  static const Color redAlertv4 = Color(0xff6F4346);

  static const Color semiDarkPrimaryColor = Color(0xff7E6754);
}

// ============================================================
// ESTILOS DE TEXTO (se mantienen igual, se usan en textTheme)
// ============================================================

class AppTextStyles {
  static const String fontFamily = "Poppins";

  static const TextStyle appBarTitle = TextStyle(
    color: AppColors.lightSecondaryColor,
    fontSize: 22,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleWhiteText = TextStyle(
    color: AppColors.lightSecondaryColor,
    fontSize: 20,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyLightWhiteText = TextStyle(
    color: AppColors.lightSecondaryColor,
    fontSize: 18,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleBrownTextv0 = TextStyle(
    color: AppColors.darkPrimaryColor,
    fontSize: 20,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleBrownText = TextStyle(
    color: AppColors.darkPrimaryColor,
    fontSize: 25,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleBrownTextv2 = TextStyle(
    color: AppColors.darkPrimaryColor,
    fontSize: 30,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleBrownTextv3 = TextStyle(
    color: AppColors.darkPrimaryColor,
    fontSize: 60,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyDarkBrownText = TextStyle(
    color: AppColors.semiDarkPrimaryColor,
    fontSize: 18,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle verMasBodyText = TextStyle(
    color: AppColors.semiDarkPrimaryColor,
    fontSize: 15,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyBrownText = TextStyle(
    color: AppColors.withoutAlert,
    fontSize: 16,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
  );
}

// ============================================================
// ESTILOS DE TEXTO — MODO OSCURO
// ============================================================

/// Estilos de texto del modo oscuro.
///
/// Espejo exacto de [AppTextStyles]: mismos nombres, mismos tamaños, mismos
/// pesos y los mismos colores. Lo único distinto es que apuntan a
/// [AppColorsDark] en vez de a [AppColors].
///
/// Hay que duplicarlos porque las [TextStyle] de [AppTextStyles] son `const`
/// con el color ya incrustado: no existe forma de reusarlas y que cambien de
/// color según el tema. Al apuntar a [AppColorsDark], en cuanto se ajuste una
/// constante de esa paleta, estos estilos la siguen solos — no hay que tocar
/// nada aquí.
class AppTextStylesDark {
  static const String fontFamily = "Poppins";

  static const TextStyle appBarTitle = TextStyle(
    color: AppColorsDark.lightSecondaryColor,
    fontSize: 22,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleWhiteText = TextStyle(
    color: AppColorsDark.lightSecondaryColor,
    fontSize: 20,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyLightWhiteText = TextStyle(
    color: AppColorsDark.lightSecondaryColor,
    fontSize: 18,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleBrownTextv0 = TextStyle(
    color: AppColorsDark.darkPrimaryColor,
    fontSize: 20,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleBrownText = TextStyle(
    color: AppColorsDark.darkPrimaryColor,
    fontSize: 25,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleBrownTextv2 = TextStyle(
    color: AppColorsDark.darkPrimaryColor,
    fontSize: 30,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleBrownTextv3 = TextStyle(
    color: AppColorsDark.darkPrimaryColor,
    fontSize: 60,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyDarkBrownText = TextStyle(
    color: AppColorsDark.semiDarkPrimaryColor,
    fontSize: 18,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle verMasBodyText = TextStyle(
    color: AppColorsDark.semiDarkPrimaryColor,
    fontSize: 15,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyBrownText = TextStyle(
    color: AppColorsDark.withoutAlert,
    fontSize: 16,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
  );
}

// ============================================================
// RADIOS COMUNES
// ============================================================

class AppRadius {
  static const BorderRadius defaultRadius = BorderRadius.all(
    Radius.circular(30),
  );
}

// ============================================================
// TEMA GLOBAL
// ============================================================

class AppTheme {
  static ThemeData lightTheme() {
    // Construimos el colorScheme usando los valores de AppColors
    const ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryColor,
      onPrimary: AppColors.secondaryColor,
      primaryContainer: AppColors.darkPrimaryColor,
      onPrimaryContainer: AppColors.lightSecondaryColor,
      secondary: AppColors.secondaryColor,
      onSecondary: AppColors.darkPrimaryColor,
      secondaryContainer: AppColors.widgetLightBrown,
      onSecondaryContainer: AppColors.semiDarkPrimaryColor,
      tertiary: AppColors.widgetLightBrown,
      onTertiary: AppColors.darkPrimaryColor,
      tertiaryContainer: AppColors.accentLightColor,
      onTertiaryContainer: AppColors.darkPrimaryColor,
      error: AppColors.redAlertv1,
      onError: Colors.white,
      errorContainer: AppColors.redAlertv4,
      onErrorContainer: AppColors.lightSecondaryColor,
      surface: AppColors.secondaryColor,
      onSurface: AppColors.darkPrimaryColor,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: colorScheme.surface,
      colorScheme: colorScheme,

      // ===== BOTONES =====
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.defaultRadius),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 2),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.defaultRadius),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
      ),

      // ===== APPBAR =====
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.appBarTitle,
      ),

      // ===== TARJETAS =====
      cardTheme: CardThemeData(
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.defaultRadius),
      ),

      // ===== INPUTS =====
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.defaultRadius,
          borderSide: BorderSide.none,
        ),
      ),

      // ===== TEXTOS =====
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.titleBrownTextv3,
        headlineLarge: AppTextStyles.titleBrownTextv2,
        headlineMedium: AppTextStyles.titleBrownText,
        titleLarge: AppTextStyles.appBarTitle,
        titleMedium: AppTextStyles.titleBrownText,
        titleSmall: AppTextStyles.titleWhiteText,
        bodyLarge: AppTextStyles.bodyDarkBrownText,
        bodyMedium: AppTextStyles.bodyBrownText,
        bodySmall: AppTextStyles.verMasBodyText,
      ),
    );
  }

  // ==========================================================
  // TEMA OSCURO
  // ==========================================================

  /// Tema oscuro.
  ///
  /// Es una COPIA LITERAL de [lightTheme], línea por línea, en el mismo
  /// orden. Los únicos cambios son mecánicos:
  ///   - `AppColors`     →  `AppColorsDark`
  ///   - `AppTextStyles` →  `AppTextStylesDark`
  ///   - `brightness: Brightness.light` → `Brightness.dark`
  ///
  /// Cada rol del ColorScheme recibe EXACTAMENTE la misma constante que
  /// recibe arriba en el tema claro. No hay ninguna reinterpretación: si en
  /// claro `primaryContainer` es `darkPrimaryColor`, aquí también lo es.
  ///
  /// Por eso hoy el modo oscuro se ve idéntico al claro. Para diferenciarlo,
  /// el único lugar a tocar es el valor de las constantes en [AppColorsDark]
  /// — este método no hace falta modificarlo.
  static ThemeData darkTheme() {
    // Construimos el colorScheme usando los valores de AppColorsDark
    const ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColorsDark.primaryColor,
      onPrimary: AppColorsDark.secondaryColor,
      primaryContainer: AppColorsDark.darkPrimaryColor,
      onPrimaryContainer: AppColorsDark.lightSecondaryColor,
      secondary: AppColorsDark.secondaryColor,
      onSecondary: AppColorsDark.darkPrimaryColor,
      secondaryContainer: AppColorsDark.widgetLightBrown,
      onSecondaryContainer: AppColorsDark.semiDarkPrimaryColor,
      tertiary: AppColorsDark.widgetLightBrown,
      onTertiary: AppColorsDark.darkPrimaryColor,
      tertiaryContainer: AppColorsDark.accentLightColor,
      onTertiaryContainer: AppColorsDark.darkPrimaryColor,
      error: AppColorsDark.redAlertv1,
      onError: Colors.white,
      errorContainer: AppColorsDark.redAlertv4,
      onErrorContainer: AppColorsDark.lightSecondaryColor,
      surface: AppColorsDark.secondaryColor,
      onSurface: AppColorsDark.darkPrimaryColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTextStylesDark.fontFamily,
      scaffoldBackgroundColor: colorScheme.surface,
      colorScheme: colorScheme,

      // ===== BOTONES =====
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.defaultRadius),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 2),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.defaultRadius),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
      ),

      // ===== APPBAR =====
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStylesDark.appBarTitle,
      ),

      // ===== TARJETAS =====
      cardTheme: CardThemeData(
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.defaultRadius),
      ),

      // ===== INPUTS =====
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.defaultRadius,
          borderSide: BorderSide.none,
        ),
      ),

      // ===== TEXTOS =====
      textTheme: const TextTheme(
        displayLarge: AppTextStylesDark.titleBrownTextv3,
        headlineLarge: AppTextStylesDark.titleBrownTextv2,
        headlineMedium: AppTextStylesDark.titleBrownText,
        titleLarge: AppTextStylesDark.appBarTitle,
        titleMedium: AppTextStylesDark.titleBrownText,
        titleSmall: AppTextStylesDark.titleWhiteText,
        bodyLarge: AppTextStylesDark.bodyDarkBrownText,
        bodyMedium: AppTextStylesDark.bodyBrownText,
        bodySmall: AppTextStylesDark.verMasBodyText,
      ),
    );
  }
}
