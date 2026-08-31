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

/// Resultado detallado de una verificación de versión.
///
/// Existe porque hay dos situaciones que [buscarActualizacion] no puede
/// distinguir: "estás al día" y "no se pudo verificar" devuelven las dos null.
/// Al banner eso le da igual (en ambos casos no muestra nada), pero la
/// pantalla de actualizaciones necesita separarlas: ahí el usuario pidió la
/// verificación a mano y merece saber si falló.
///
/// Es `sealed` para que todo `switch` cubra los tres casos.
sealed class ResultadoVerificacion {
  const ResultadoVerificacion();
}

/// La versión remota es más nueva que la instalada.
class HayActualizacion extends ResultadoVerificacion {
  const HayActualizacion(this.info, this.versionRemota);

  final InfoActualizacion info;
  final String versionRemota;
}

/// La versión instalada es la más reciente publicada.
class AlDia extends ResultadoVerificacion {
  const AlDia(this.versionInstalada);

  final String versionInstalada;
}

/// No se pudo verificar: sin red, timeout, respuesta rara o JSON inválido.
///
/// [motivo] es para el log, no para la pantalla: el mensaje que ve el usuario
/// lo decide la UI, en su propio tono.
class FalloVerificacion extends ResultadoVerificacion {
  const FalloVerificacion(this.motivo);

  final String motivo;
}

/// Consulta el version.json remoto y devuelve el resultado completo.
///
/// Nunca lanza excepciones: cualquier fallo se convierte en
/// [FalloVerificacion]. La usa la pantalla de actualizaciones, donde la
/// verificación es explícita y el error sí se muestra.
Future<ResultadoVerificacion> verificarActualizacion() async {
  try {
    final info = await PackageInfo.fromPlatform();
    final versionInstalada = info.version;

    final respuesta = await http
        .get(Uri.parse(_urlVersionJson))
        .timeout(_timeout);

    if (respuesta.statusCode != 200) {
      debugPrint('Verificador: respuesta ${respuesta.statusCode}, se ignora.');
      return FalloVerificacion('respuesta ${respuesta.statusCode}');
    }

    final data = json.decode(respuesta.body) as Map<String, dynamic>;
    final ultimaVersion = (data['ultimaVersion'] as String?)?.trim();
    final urlDescarga = (data['urlDescarga'] as String?)?.trim();
    final notas = (data['notas'] as String?)?.trim() ?? '';

    // Sin los campos mínimos no podemos hacer nada útil.
    if (ultimaVersion == null ||
        ultimaVersion.isEmpty ||
        urlDescarga == null ||
        urlDescarga.isEmpty) {
      debugPrint('Verificador: JSON sin campos requeridos, se ignora.');
      return const FalloVerificacion('JSON sin campos requeridos');
    }

    if (_compararVersiones(ultimaVersion, versionInstalada) > 0) {
      debugPrint(
        'Verificador: hay actualización ($versionInstalada -> $ultimaVersion).',
      );
      return HayActualizacion(
        InfoActualizacion(urlDescarga: urlDescarga, notas: notas),
        ultimaVersion,
      );
    }

    debugPrint(
      'Verificador: al día (instalada $versionInstalada, remota $ultimaVersion).',
    );
    return AlDia(versionInstalada);
  } catch (e) {
    // Cualquier fallo (sin red, timeout, parseo) se traga aquí: la app sigue
    // funcionando normal.
    debugPrint('Verificador: verificación omitida ($e).');
    return FalloVerificacion('$e');
  }
}

/// Consulta el version.json remoto y compara con la versión instalada.
///
/// Devuelve [InfoActualizacion] SOLO si la versión remota es estrictamente
/// mayor que la instalada. En cualquier otro caso (sin red, timeout, JSON
/// inválido, versión igual o menor) devuelve null. Nunca lanza excepciones.
///
/// REGLA DE ORO intacta: es la que usa el banner del arranque, que no debe
/// molestar nunca. Hoy es una cáscara de [verificarActualizacion], que hace el
/// trabajo; el comportamiento y la firma son los mismos de siempre.
Future<InfoActualizacion?> buscarActualizacion() async {
  final resultado = await verificarActualizacion();
  return switch (resultado) {
    HayActualizacion(:final info) => info,
    AlDia() || FalloVerificacion() => null,
  };
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
  return sinBuild.split('.').map((s) => int.tryParse(s.trim()) ?? 0).toList();
}
