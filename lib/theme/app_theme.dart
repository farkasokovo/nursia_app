import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  static const Color darkestColor = Color(0xff2F2318);
}

// ============================================================
// COLORES EN MODO OSCURO
// ============================================================
//
// Paleta paralela a [AppColors]. No reemplaza ni modifica nada de la clara:
// el modo claro sigue leyendo AppColors tal cual, y el oscuro lee esta.
//
// Las alertas vienen en dos variantes porque un mismo color no puede servir
// para ambos usos sobre fondo oscuro: `...OnSurface` es para TEXTO o iconos
// (mas claro, contrasta contra el fondo cafe oscuro) y `...Fill` es para
// RELLENO solido de una pastilla o tarjeta, con texto crema encima.

class AppColorsDark {
  // Superficies y texto
  static const Color ground = Color(0xff14100B);
  static const Color paper = Color(0xff271F18);

  /// Color de borde. Ya no lo consume ningun tema; queda como referencia
  /// del cafe medio de la paleta.
  static const Color rule = Color(0xff3B2F25);

  /// Superficie de enfasis: AppBar, TabBar y las tarjetas grandes del
  /// inicio. Es `primaryContainer` del tema oscuro.
  static const Color enfasis = Color(0xff51402F);

  /// Fondo de los botones de categoria y de las pantallas de ficha. Es
  /// `secondaryContainer` del tema oscuro.
  static const Color botonCat = Color(0xff2B241D);
  static const Color ruleSoft = Color(0xff332822);
  static const Color ink = Color(0xffEFE9E4);
  static const Color ink2 = Color(0xffDFD3C9);
  // Tinta apagada, para texto atenuado sobre [enfasis]. Subio de #A38F7C
  // cuando `enfasis` aclaro: sobre el cafe nuevo aquel caia a 3.19:1.
  static const Color ink3 = Color(0xffB5A08B);
  static const Color accent = Color(0xffCBA786);
  static const Color accentOn = Color(0xff241B14);

  // Neutros derivados
  static const Color primaryColor = Color(0xffAB937C);
  static const Color semiDarkPrimaryColor = Color(0xff9D826C);
  static const Color accentLightColor = Color(0xff453729);

  // Alertas, variante para TEXTO sobre fondo oscuro
  static const Color withoutAlertOnSurface = Color(0xffC59F81);
  static const Color greenAlertOnSurface = Color(0xffBDB679);
  static const Color redAlertv1OnSurface = Color(0xffC58187);
  static const Color redAlertv2OnSurface = Color(0xffC9787E);
  static const Color redAlertv3OnSurface = Color(0xffCF6E75);
  static const Color redAlertv4OnSurface = Color(0xffD5626B);

  // Alertas, variante para RELLENO solido con texto crema encima
  static const Color withoutAlertFill = Color(0xff987152);
  static const Color greenAlertFill = Color(0xff8A8551);
  static const Color redAlertv1Fill = Color(0xff985258);
  static const Color redAlertv2Fill = Color(0xff894349);
  static const Color redAlertv3Fill = Color(0xff78363B);
  static const Color redAlertv4Fill = Color(0xff66292D);
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
// ESTILOS DE TEXTO EN MODO OSCURO
// ============================================================
//
// Espejo exacto de [AppTextStyles]: mismos nombres, tamanos, pesos y fuente.
// Lo unico que cambia es el color, remapeado a la paleta oscura. Se duplica en
// vez de parametrizar para que el modo claro quede intacto, byte por byte.

class AppTextStylesDark {
  static const String fontFamily = AppTextStyles.fontFamily;

  static const TextStyle appBarTitle = TextStyle(
    color: AppColorsDark.ink,
    fontSize: 22,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleWhiteText = TextStyle(
    color: AppColorsDark.ink,
    fontSize: 20,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyLightWhiteText = TextStyle(
    color: AppColorsDark.ink,
    fontSize: 18,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleBrownTextv0 = TextStyle(
    color: AppColorsDark.ink,
    fontSize: 20,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleBrownText = TextStyle(
    color: AppColorsDark.ink,
    fontSize: 25,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleBrownTextv2 = TextStyle(
    color: AppColorsDark.ink,
    fontSize: 30,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleBrownTextv3 = TextStyle(
    color: AppColorsDark.ink,
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
    color: AppColorsDark.withoutAlertOnSurface,
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
    // OJO: en claro, primaryContainer y onSurface son la MISMA constante
    // (darkPrimaryColor). En oscuro NO lo son: primaryContainer es superficie
    // (#3B2F25) y onSurface es tinta (#EFE9E4). Para color de texto, ícono o
    // borde usa SIEMPRE onSurface. Usar primaryContainer como tinta se ve bien
    // en claro por coincidencia y queda invisible en oscuro.
    //
    // Esto vale para CUALQUIER ranura *Container usada como color de texto,
    // ícono o borde: en claro salen claras sobre fondos oscuros y funcionan;
    // en oscuro son superficies y desaparecen. Ya pasó con primaryContainer
    // (~100 sitios) y con tertiaryContainer (5 TabBar). Antes de usar una
    // ranura *Container como tinta, para y usa la ranura "on..." o un helper
    // de ThemeColors.
    //
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
      tertiary: AppColors.darkestColor,
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
        // Barras del sistema. Se fijan explicitamente porque Android no las
        // deduce bien: la AppBar es cafe oscura en ambos temas, asi que los
        // iconos de la barra de estado van claros en los dos. La barra de
        // navegacion, en cambio, se pinta del color del Scaffold, que si
        // cambia entre temas, y sus iconos siguen ese contraste.
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarColor: colorScheme.surface,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
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

  /// Tema oscuro. Espeja la estructura de [lightTheme] ranura por ranura:
  /// mismos sub-temas, mismos radios, misma fuente. Solo cambian los colores.
  static ThemeData darkTheme() {
    const ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColorsDark.accent,
      onPrimary: AppColorsDark.accentOn,
      primaryContainer: AppColorsDark.enfasis,
      onPrimaryContainer: AppColorsDark.ink,
      secondary: AppColorsDark.paper,
      onSecondary: AppColorsDark.ink2,
      secondaryContainer: AppColorsDark.botonCat,
      onSecondaryContainer: AppColorsDark.ink2,
      tertiary: AppColorsDark.ink,
      onTertiary: AppColorsDark.accentOn,
      tertiaryContainer: AppColorsDark.accentLightColor,
      onTertiaryContainer: AppColorsDark.ink2,
      error: AppColorsDark.redAlertv1OnSurface,
      onError: AppColorsDark.accentOn,
      errorContainer: AppColorsDark.redAlertv4Fill,
      onErrorContainer: AppColorsDark.ink,
      surface: AppColorsDark.paper,
      onSurface: AppColorsDark.ink,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStylesDark.fontFamily,
      // A diferencia del claro, el fondo NO es colorScheme.surface: en oscuro
      // conviene que el lienzo (ground) sea mas profundo que las tarjetas
      // (paper), para que estas se despeguen sin depender de la sombra, que
      // casi no se ve sobre fondo oscuro.
      scaffoldBackgroundColor: AppColorsDark.ground,
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
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarColor: AppColorsDark.ground,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      // ===== TARJETAS =====
      cardTheme: CardThemeData(
        elevation: 4,
        color: AppColorsDark.paper,
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
