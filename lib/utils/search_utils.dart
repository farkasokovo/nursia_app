// lib/utils/search_utils.dart
//
// Utilidades de búsqueda compartidas por los buscadores de la app
// (Escalas, Farmacología, Normas). Todo ocurre en tiempo de búsqueda:
// los JSON de datos NUNCA se duplican sin acentos.

/// Mapa de diacríticos del español a su equivalente sin acento.
/// Solo minúsculas: `normalizar` pasa el texto a minúsculas primero, y
/// `toLowerCase()` ya convierte las mayúsculas acentuadas (Á → á).
const Map<String, String> _diacriticos = {
  'á': 'a',
  'é': 'e',
  'í': 'i',
  'ó': 'o',
  'ú': 'u',
  'ü': 'u',
  'ñ': 'n',
};

/// Normaliza un texto para búsqueda: minúsculas + sin diacríticos del español.
///
/// Ej: "Enfermería" → "enfermeria". Así "enfermeria" (sin acento) encuentra
/// contenido que dice "enfermería". La normalización es SIEMPRE en tiempo de
/// búsqueda; el contenido original de los JSON no se toca.
String normalizar(String texto) {
  final sb = StringBuffer();
  for (final rune in texto.toLowerCase().runes) {
    final ch = String.fromCharCode(rune);
    sb.write(_diacriticos[ch] ?? ch);
  }
  return sb.toString();
}

/// Rankea un campo (YA normalizado) contra una consulta (YA normalizada).
///
/// Devuelve el tipo de coincidencia, de más a menos relevante:
///   0 = el campo es exactamente igual a la consulta
///   1 = el campo empieza con la consulta
///   2 = alguna palabra del campo empieza con la consulta
///   3 = el campo contiene la consulta
///   null = no hay coincidencia
///
/// Las comprobaciones de igualdad/empieza/contiene operan sobre el campo
/// COMPLETO, de modo que un código como "nom-019-ssa3-2013" sigue coincidiendo
/// con la consulta "nom-019" por `startsWith`, aunque el guión no sea un
/// límite de palabra.
int? rankearCampo(String campoNorm, String consultaNorm) {
  if (consultaNorm.isEmpty) return null;
  if (campoNorm == consultaNorm) return 0;
  if (campoNorm.startsWith(consultaNorm)) return 1;

  // Match por límite de palabra: se parte el campo por cualquier carácter
  // que no sea alfanumérico (espacios, comas, guiones, etc.).
  for (final palabra in campoNorm.split(RegExp(r'[^a-z0-9]+'))) {
    if (palabra.isNotEmpty && palabra.startsWith(consultaNorm)) return 2;
  }

  if (campoNorm.contains(consultaNorm)) return 3;
  return null;
}
