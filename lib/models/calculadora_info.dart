import 'dart:convert';

class CalculadoraInfo {
  final String id;
  final String titulo;
  final String descripcion;
  final String formula;
  final List<String> notas;
  final List<Map<String, String>> referencias;

  CalculadoraInfo({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.formula,
    required this.notas,
    required this.referencias,
  });

  // Para el JSON original
  factory CalculadoraInfo.fromJson(Map<String, dynamic> json) {
    return CalculadoraInfo(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      formula: json['formula'],
      notas: List<String>.from(json['notas'] ?? []),
      referencias:
          (json['referencias'] as List?)
              ?.map((ref) => Map<String, String>.from(ref))
              .toList() ??
          [],
    );
  }

  // NUEVO: Para guardar en SQLite (convierte listas a texto)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'formula': formula,
      'notas': jsonEncode(notas),
      'referencias': jsonEncode(referencias),
    };
  }

  // NUEVO: Para leer de SQLite (convierte texto a listas)
  factory CalculadoraInfo.fromMap(Map<String, dynamic> map) {
    return CalculadoraInfo(
      id: map['id'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      formula: map['formula'],
      notas: List<String>.from(jsonDecode(map['notas'])),
      referencias: (jsonDecode(map['referencias']) as List)
          .map((ref) => Map<String, String>.from(ref))
          .toList(),
    );
  }
}
