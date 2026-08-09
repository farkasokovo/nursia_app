import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Maneja la preferencia de tema de la app (sistema / claro / oscuro) y la
/// persiste con shared_preferences.
///
/// Es el primer [ChangeNotifier] del proyecto. Los demás providers son
/// repositorios sin estado (se registran con `Provider.value`), pero aquí sí
/// hay estado que cambia en caliente: cuando DIEGO toca "Oscuro", toda la app
/// tiene que redibujarse. Por eso este va con `ChangeNotifierProvider` y
/// `notifyListeners()`.
///
/// Uso desde la UI:
/// - Para LEER y redibujar al cambiar: `context.watch<ThemeProvider>()`
/// - Para solo disparar el cambio: `context.read<ThemeProvider>().cambiarTema(...)`
class ThemeProvider extends ChangeNotifier {
  /// Clave bajo la que se guarda la preferencia en el almacenamiento nativo.
  static const String _claveTema = 'tema';

  ThemeMode _themeMode;

  ThemeProvider._(this._themeMode);

  /// Modo actual. Por defecto [ThemeMode.system]: la app sigue el ajuste de
  /// claro/oscuro del teléfono mientras el usuario no elija otra cosa.
  ThemeMode get themeMode => _themeMode;

  /// Crea el provider ya con la preferencia guardada cargada.
  ///
  /// Se construye así (async, antes de `runApp`) y no leyendo las
  /// preferencias después del primer frame, para que la app no arranque en
  /// claro y "parpadee" a oscuro un instante después.
  static Future<ThemeProvider> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final guardado = prefs.getString(_claveTema);
    return ThemeProvider._(_desdeTexto(guardado));
  }

  /// Cambia el tema y guarda la preferencia.
  ///
  /// Si el modo es el mismo que ya estaba, no hace nada: evita un redibujo y
  /// una escritura a disco innecesarios.
  Future<void> cambiarTema(ThemeMode modo) async {
    if (modo == _themeMode) return;

    _themeMode = modo;
    notifyListeners();

    // La escritura va DESPUÉS de notificar: la UI responde de inmediato y no
    // se queda esperando al disco. Si la escritura fallara, lo peor que pasa
    // es que la preferencia no sobreviva al próximo arranque.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveTema, _aTexto(modo));
  }

  // ===== Conversión ThemeMode <-> String =====
  // Se guarda como texto legible ('system'/'light'/'dark') en vez del índice
  // del enum: si algún día Flutter reordena los valores de ThemeMode, un
  // índice guardado apuntaría al modo equivocado; un texto no.

  static String _aTexto(ThemeMode modo) {
    switch (modo) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static ThemeMode _desdeTexto(String? texto) {
    switch (texto) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      // Cubre tanto 'system' explícito como null (primera vez que se abre la
      // app) o un valor corrupto/desconocido.
      default:
        return ThemeMode.system;
    }
  }
}
