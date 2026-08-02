// lib/utils/verificador_actualizacion.dart
//
// Verificación OPCIONAL de nuevas versiones. Nurska es offline-first y se
// distribuye por APK fuera de Google Play, así que las actualizaciones no
// llegan solas: consultamos un pequeño version.json en GitHub Pages para
// avisar dentro de la app cuando hay una versión más nueva.
//
// REGLA DE ORO: esta es la única parte de la app que toca la red y NUNCA debe
// molestar. Si no hay internet, si el timeout se cumple, si el JSON no existe o
// está mal formado, o si la versión remota es igual/menor a la instalada,
// devolvemos null en silencio. Ningún error se propaga ni se muestra al usuario.
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// URL del manifiesto remoto de versión (GitHub Pages de la landing).
const String _urlVersionJson =
    'https://farkasokovo.github.io/nurska-app/version.json';

/// Tiempo máximo que esperamos la respuesta antes de rendirnos en silencio.
const Duration _timeout = Duration(seconds: 5);

/// Datos que el banner necesita cuando SÍ hay una actualización disponible.
class InfoActualizacion {
  final String urlDescarga;
  final String notas;

  const InfoActualizacion({required this.urlDescarga, required this.notas});
}

/// Consulta el version.json remoto y compara con la versión instalada.
///
/// Devuelve [InfoActualizacion] SOLO si la versión remota es estrictamente
/// mayor que la instalada. En cualquier otro caso (sin red, timeout, JSON
/// inválido, versión igual o menor) devuelve null. Nunca lanza excepciones.
Future<InfoActualizacion?> buscarActualizacion() async {
  try {
    final info = await PackageInfo.fromPlatform();
    final versionInstalada = info.version;

    final respuesta = await http
        .get(Uri.parse(_urlVersionJson))
        .timeout(_timeout);

    if (respuesta.statusCode != 200) {
      debugPrint(
        'Verificador: respuesta ${respuesta.statusCode}, se ignora.',
      );
      return null;
    }

    final data = json.decode(respuesta.body) as Map<String, dynamic>;
    final ultimaVersion = (data['ultimaVersion'] as String?)?.trim();
    final urlDescarga = (data['urlDescarga'] as String?)?.trim();
    final notas = (data['notas'] as String?)?.trim() ?? '';

    // Sin los campos mínimos no podemos hacer nada útil: silencio.
    if (ultimaVersion == null ||
        ultimaVersion.isEmpty ||
        urlDescarga == null ||
        urlDescarga.isEmpty) {
      debugPrint('Verificador: JSON sin campos requeridos, se ignora.');
      return null;
    }

    if (_compararVersiones(ultimaVersion, versionInstalada) > 0) {
      debugPrint(
        'Verificador: hay actualización ($versionInstalada -> $ultimaVersion).',
      );
      return InfoActualizacion(urlDescarga: urlDescarga, notas: notas);
    }

    debugPrint(
      'Verificador: al día (instalada $versionInstalada, remota $ultimaVersion).',
    );
    return null;
  } catch (e) {
    // Cualquier fallo (sin red, timeout, parseo) se traga aquí: la app sigue
    // funcionando normal, sin banner y sin quejas.
    debugPrint('Verificador: verificación omitida ($e).');
    return null;
  }
}

/// Compara dos versiones "major.minor.patch" por segmentos NUMÉRICOS.
///
/// Devuelve >0 si [a] > [b], 0 si son iguales, <0 si [a] < [b]. Compara número
/// por número (no como texto), así 1.0.10 es mayor que 1.0.9. Tolera segmentos
/// faltantes (los trata como 0) y segmentos no numéricos (los trata como 0).
int _compararVersiones(String a, String b) {
  final segmentosA = _parsearSegmentos(a);
  final segmentosB = _parsearSegmentos(b);
  final longitud = segmentosA.length > segmentosB.length
      ? segmentosA.length
      : segmentosB.length;

  for (var i = 0; i < longitud; i++) {
    final valorA = i < segmentosA.length ? segmentosA[i] : 0;
    final valorB = i < segmentosB.length ? segmentosB[i] : 0;
    if (valorA != valorB) return valorA - valorB;
  }
  return 0;
}

/// Convierte "1.0.10" en [1, 0, 10]. Ignora un posible sufijo "+build" y
/// cualquier caracter no numérico dentro de un segmento (lo vuelve 0).
List<int> _parsearSegmentos(String version) {
  final sinBuild = version.split('+').first;
  return sinBuild
      .split('.')
      .map((s) => int.tryParse(s.trim()) ?? 0)
      .toList();
}
