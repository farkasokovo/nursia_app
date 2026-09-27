import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:nursia_app/models/ficha_esencial.dart' show ItemReferencia;

/// Un término del glosario central de Esenciales.
///
/// La definición vive UNA sola vez, aquí, y las fichas la citan por [id]
/// desde un bloque de contenido "glosario". Así una misma definición (FiO2,
/// PEEP, volumen tidal) se escribe una vez y la usan todas las fichas que la
/// necesiten, en vez de repetirla dentro del contenido de cada una.
///
/// [ItemReferencia] se reutiliza a propósito desde `ficha_esencial.dart`: un
/// término y un bloque de referencias citan igual, y tener dos clases con el
/// mismo contrato solo invitaría a que se separen con el tiempo.
class TerminoGlosario {
  /// Identificador que escribe el autor del contenido, no la base de datos.
  /// Convención obligatoria: minúsculas, palabras separadas por guion, sin
  /// acentos ni espacios ("peep", "volumen-tidal", "bias-flow").
  final String id;

  /// El término tal como se lee en la ficha ("PEEP", "Volumen tidal").
  final String termino;

  /// Desarrollo de las siglas o sinónimo. Opcional: no todo término lo tiene.
  final String? desglose;

  final String definicion;

  /// De dónde salió la definición.
  ///
  /// NO ES CÓDIGO MUERTO aunque la app no lo pinte: la pantalla dejó de
  /// mostrar las citas de los términos a propósito, y el campo se conserva
  /// como registro de la fuente de cada definición, para quien revise el repo
  /// o tenga que actualizar un dato. Se siembra, se guarda y se lee completo.
  ///
  /// Opcional: un término de conocimiento general no necesita fuente; uno con
  /// un dato específico sí.
  final List<ItemReferencia> referencias;

  const TerminoGlosario({
    required this.id,
    required this.termino,
    this.desglose,
    required this.definicion,
    this.referencias = const [],
  });

  // Desde el JSON semilla (assets): referencias es una lista real de objetos.
  factory TerminoGlosario.fromJson(Map<String, dynamic> json) =>
      TerminoGlosario(
        id: json['id'] ?? '',
        termino: json['termino'] ?? '',
        desglose: _textoOpcional(json['desglose']),
        definicion: json['definicion'] ?? '',
        referencias: _referenciasDesdeJson(json['referencias']),
      );

  // Desde SQLite: referencias viene como un String con JSON adentro (la
  // columna es TEXT), igual que "contenido" en la tabla esenciales.
  factory TerminoGlosario.fromMap(Map<String, dynamic> map) => TerminoGlosario(
    id: map['id'] ?? '',
    termino: map['termino'] ?? '',
    desglose: _textoOpcional(map['desglose']),
    definicion: map['definicion'] ?? '',
    referencias: _referenciasDesdeJson(jsonDecode(map['referencias'] ?? '[]')),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'termino': termino,
    if (desglose != null) 'desglose': desglose,
    'definicion': definicion,
    if (referencias.isNotEmpty)
      'referencias': referencias.map((r) => r.toJson()).toList(),
  };

  // Para guardar en SQLite: las referencias se serializan a JSON en TEXT.
  Map<String, dynamic> toMap() => {
    'id': id,
    'termino': termino,
    'desglose': desglose,
    'definicion': definicion,
    'referencias': jsonEncode(referencias.map((r) => r.toJson()).toList()),
  };
}

/// Devuelve el String si tiene contenido; null si falta, está vacío o no es
/// un String. Mismo criterio que usa el parseo de bloques en
/// `ficha_esencial.dart`.
String? _textoOpcional(dynamic valor) {
  if (valor is! String) return null;
  final limpio = valor.trim();
  return limpio.isEmpty ? null : limpio;
}

/// Parseo defensivo: el JSON semilla se edita a mano, así que una referencia
/// sin "texto" se salta con un aviso y el término sobrevive sin ella. Nunca
/// se lanza una excepción: un error de dedo no puede tumbar el arranque.
List<ItemReferencia> _referenciasDesdeJson(dynamic crudo) {
  if (crudo is! List) return const [];
  final items = <ItemReferencia>[];
  for (final item in crudo) {
    if (item is! Map) continue;
    final mapa = item.cast<String, dynamic>();
    final texto = _textoOpcional(mapa['texto']);
    if (texto == null) {
      debugPrint('Glosario: referencia sin "texto", se omite el item: $mapa');
      continue;
    }
    // Sin url es válido: una referencia puede ser un libro impreso.
    items.add(ItemReferencia(texto: texto, url: _textoOpcional(mapa['url'])));
  }
  return items;
}
