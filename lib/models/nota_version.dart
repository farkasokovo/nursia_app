// lib/models/nota_version.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Notas de una versión del changelog local (`assets/data/changelog.json`).
///
/// El changelog vive dentro del APK a propósito: son las notas de la versión
/// que el usuario YA tiene instalada, así que pedirle internet para leerlas
/// iría contra el principio offline-first de la app.
class NotaVersion {
  /// Versión a la que corresponden las notas, ej. "1.2.1".
  final String version;

  /// Fecha en formato ISO (`YYYY-MM-DD`). Puede venir vacía.
  final String fecha;

  /// Cambios de esa versión, uno por renglón.
  final List<String> cambios;

  const NotaVersion({
    required this.version,
    required this.fecha,
    required this.cambios,
  });

  /// Fecha lista para mostrar, ej. "29 de agosto de 2026".
  ///
  /// Si la fecha no viene en formato ISO se devuelve tal cual, que es mejor
  /// que perderla o que mostrar un error.
  String get fechaLegible {
    final partes = fecha.split('-');
    if (partes.length != 3) return fecha;
    final anio = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final dia = int.tryParse(partes[2]);
    if (anio == null || mes == null || dia == null || mes < 1 || mes > 12) {
      return fecha;
    }
    return '$dia de ${_meses[mes - 1]} de $anio';
  }

  static const List<String> _meses = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
}

/// Convierte el JSON crudo del changelog en una lista de [NotaVersion].
///
/// Parseo tolerante a fallos, igual que el del módulo Esenciales: una entrada
/// mal escrita se salta con un `debugPrint()` y las demás siguen. Este archivo
/// se edita a mano en cada versión, y un error de dedo no puede tumbar la app.
/// Ante un JSON irrecuperable devuelve una lista vacía.
List<NotaVersion> parsearChangelog(String jsonCrudo) {
  final dynamic decodificado;
  try {
    decodificado = json.decode(jsonCrudo);
  } catch (e) {
    debugPrint('Changelog: JSON inválido, se ignora por completo ($e).');
    return const [];
  }

  if (decodificado is! List) {
    debugPrint('Changelog: se esperaba una lista de versiones, sin notas.');
    return const [];
  }

  final notas = <NotaVersion>[];
  for (final entrada in decodificado) {
    if (entrada is! Map) {
      debugPrint('Changelog: entrada que no es un objeto, se omite.');
      continue;
    }

    final version = (entrada['version'] as Object?)?.toString().trim() ?? '';
    if (version.isEmpty) {
      debugPrint('Changelog: entrada sin "version", se omite.');
      continue;
    }

    final crudoCambios = entrada['cambios'];
    if (crudoCambios is! List) {
      debugPrint('Changelog: la versión $version no trae "cambios", se omite.');
      continue;
    }

    // Un cambio vacío o que no es texto se descarta solo, sin tirar la entrada.
    final cambios = <String>[];
    for (final cambio in crudoCambios) {
      final texto = cambio?.toString().trim() ?? '';
      if (texto.isEmpty) {
        debugPrint('Changelog: cambio vacío en la versión $version, se omite.');
        continue;
      }
      cambios.add(texto);
    }

    if (cambios.isEmpty) {
      debugPrint('Changelog: la versión $version quedó sin cambios, se omite.');
      continue;
    }

    notas.add(
      NotaVersion(
        version: version,
        fecha: (entrada['fecha'] as Object?)?.toString().trim() ?? '',
        cambios: cambios,
      ),
    );
  }

  return notas;
}
