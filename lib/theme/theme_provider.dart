// lib/theme/theme_provider.dart
//
// Estado del tema (claro / oscuro / el del sistema) y su persistencia.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda y expone la preferencia de tema del usuario.
///
/// Es el unico `ChangeNotifier` de la app: el resto de los providers son
/// repositorios sin estado propio. Aqui si hace falta notificar, porque un
/// cambio de tema tiene que reconstruir el `MaterialApp` completo.
///
/// Igual que [AlmacenPersistente], ningun error de disco se propaga: si la
/// lectura falla se queda con el valor por defecto, y si la escritura falla el
/// cambio se ve en pantalla pero no sobrevive al proximo arranque. Nunca
/// tumba la app por no poder guardar una preferencia visual.
class ThemeProvider extends ChangeNotifier {
  /// Clave en `shared_preferences`. Guarda el `index` de [ThemeMode].
  static const String claveTema = 'tema_preferido';

  ThemeMode _themeMode = ThemeMode.system;

  /// Modo actual. Arranca en [ThemeMode.system] hasta que [cargar] diga otra
  /// cosa: seguir al sistema es el comportamiento que el usuario espera si
  /// nunca eligio nada.
  ThemeMode get themeMode => _themeMode;

  /// Lee la preferencia guardada. Se llama antes de `runApp` para que la app
  /// ya arranque con el tema correcto y no haya un parpadeo de claro a oscuro.
  Future<void> cargar() async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      final indice = preferencias.getInt(claveTema);
      // Se valida el rango porque el indice viene de disco: un valor viejo o
      // corrupto no debe reventar el acceso a la lista.
      if (indice != null && indice >= 0 && indice < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[indice];
      }
    } catch (e) {
      debugPrint('Tema: no se pudo leer la preferencia ($e).');
    }
  }

  /// Cambia el tema y lo persiste. Notifica primero para que la interfaz
  /// responda al toque sin esperar al disco.
  Future<void> cambiar(ThemeMode modo) async {
    if (modo == _themeMode) return;
    _themeMode = modo;
    notifyListeners();

    try {
      final preferencias = await SharedPreferences.getInstance();
      await preferencias.setInt(claveTema, modo.index);
    } catch (e) {
      debugPrint('Tema: no se pudo guardar la preferencia ($e).');
    }
  }
}
