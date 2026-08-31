// lib/utils/changelog_local.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/nota_version.dart';

/// Ruta del changelog dentro del APK. Está registrado en `pubspec.yaml`.
const String _rutaChangelog = 'assets/data/changelog.json';

/// Acceso al changelog local: el historial de versiones que viaja dentro del
/// APK, sin red de por medio.
///
/// Se lee una sola vez por sesión y se guarda en memoria: son unos cuantos
/// kilobytes y lo consultan tanto la pantalla de actualizaciones como la de
/// bienvenida.
class ChangelogLocal {
  ChangelogLocal._();

  static List<NotaVersion>? _cache;

  /// Todas las versiones del changelog, de la más nueva a la más vieja (el
  /// orden del archivo). Ante cualquier fallo devuelve una lista vacía.
  static Future<List<NotaVersion>> cargar() async {
    final enCache = _cache;
    if (enCache != null) return enCache;

    try {
      final crudo = await rootBundle.loadString(_rutaChangelog);
      final notas = parsearChangelog(crudo);
      _cache = notas;
      return notas;
    } catch (e) {
      // Si el asset no está registrado en pubspec.yaml o no se puede leer, la
      // app sigue funcionando: simplemente no hay notas que mostrar.
      debugPrint('Changelog: no se pudo leer $_rutaChangelog ($e).');
      _cache = const [];
      return const [];
    }
  }

  /// Notas de una versión concreta, o null si el changelog no la incluye.
  static Future<NotaVersion?> notasDe(String version) async {
    final notas = await cargar();
    for (final nota in notas) {
      if (nota.version == version) return nota;
    }
    debugPrint('Changelog: sin entrada para la versión $version.');
    return null;
  }

  /// Solo para pruebas: olvida lo que haya en memoria.
  @visibleForTesting
  static void limpiarCache() => _cache = null;
}
