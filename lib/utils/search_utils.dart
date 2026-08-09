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

/// Filtra y ORDENA los items por relevancia respecto a la consulta.
///
/// El rank de cada item se calcula como (indiceDelCampo * 10 + tipoDeMatch),
/// tomando el MEJOR (menor) match entre sus campos. El factor 10 garantiza
/// que cualquier coincidencia en un campo prioritario (índice 0) gane a
/// cualquier coincidencia en un campo menos relevante. Se descartan los
/// items sin coincidencia; se ordena por rank ascendente y, como desempate,
/// alfabéticamente por el título normalizado.
///
/// [camposBuscables] devuelve los campos de un item EN ORDEN DE PRIORIDAD
/// (índice 0 = el más relevante). [titulo] es el texto que se usa para el
/// desempate alfabético.
List<T> buscarYRankear<T>({
  required List<T> items,
  required String consulta,
  required List<String> Function(T item) camposBuscables,
  required String Function(T item) titulo,
}) {
  final consultaNorm = normalizar(consulta);

  final conRank = <({T item, int rank})>[];
  for (final item in items) {
    final campos = camposBuscables(item);
    int? mejor;
    for (var i = 0; i < campos.length; i++) {
      final tipo = rankearCampo(normalizar(campos[i]), consultaNorm);
      if (tipo != null) {
        final rank = i * 10 + tipo;
        if (mejor == null || rank < mejor) mejor = rank;
      }
    }
    if (mejor != null) conRank.add((item: item, rank: mejor));
  }

  conRank.sort((a, b) {
    final porRank = a.rank.compareTo(b.rank);
    if (porRank != 0) return porRank;
    return normalizar(titulo(a.item)).compareTo(normalizar(titulo(b.item)));
  });

  return conRank.map((e) => e.item).toList();
}
