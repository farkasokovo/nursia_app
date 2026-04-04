import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/escala_metadata.dart';

//! REPOSITORIO DE ESCALAS (METADATOS)

class RepositorioEscalasMetadata {
  static List<EscalaMetadata>? _cache;

  static Future<List<EscalaMetadata>> cargarEscalas() async {
    if (_cache != null) return _cache!;
    final jsonString = await rootBundle.loadString(
      'assets/data/escalas_lista.json',
    );
    final data = json.decode(jsonString);
    final List<dynamic> lista = data['escalas'];
    _cache = lista.map((e) => EscalaMetadata.fromJson(e)).toList();
    return _cache!;
  }
}
