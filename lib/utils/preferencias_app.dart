// lib/utils/preferencias_app.dart
//
// Almacén de preferencias de la app, encima de `shared_preferences`.
//
// Guarda cosas mínimas y no clínicas (hoy solo el marcador de la última versión
// cuya bienvenida ya se mostró). Los datos de referencia y los del usuario
// viven en SQLite; esto no los toca.
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contrato mínimo de un almacén clave-valor persistente.
///
/// Es una interfaz para que la lógica que la usa se pueda probar sin tocar el
/// almacenamiento del dispositivo (ver [AlmacenMemoria]).
abstract class AlmacenPreferencias {
  Future<String?> leer(String clave);
  Future<void> guardar(String clave, String valor);
}

/// Implementación real, sobre `shared_preferences`.
///
/// Usa el almacenamiento nativo de Android, con escrituras atómicas: si la app
/// muere a media escritura, el valor anterior queda intacto en vez de dejar un
/// archivo a medias.
///
/// Ningún error se propaga. Si la lectura falla se comporta como si no hubiera
/// valor guardado, y si la escritura falla la app sigue igual. Lo peor que
/// puede pasar es que la pantalla de bienvenida se muestre otra vez en el
/// siguiente arranque, no que la app se caiga.
class AlmacenPersistente implements AlmacenPreferencias {
  @override
  Future<String?> leer(String clave) async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      return preferencias.getString(clave);
    } catch (e) {
      debugPrint('Preferencias: no se pudo leer "$clave" ($e).');
      return null;
    }
  }

  @override
  Future<void> guardar(String clave, String valor) async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      await preferencias.setString(clave, valor);
    } catch (e) {
      debugPrint('Preferencias: no se pudo guardar "$clave" ($e).');
    }
  }
}

/// Implementación en memoria, para pruebas.
@visibleForTesting
class AlmacenMemoria implements AlmacenPreferencias {
  AlmacenMemoria([Map<String, String>? inicial]) : _datos = {...?inicial};

  final Map<String, String> _datos;

  Map<String, String> get datos => Map.unmodifiable(_datos);

  @override
  Future<String?> leer(String clave) async => _datos[clave];

  @override
  Future<void> guardar(String clave, String valor) async {
    _datos[clave] = valor;
  }
}
