// lib/models/calculadora_info.dart
class CalculadoraInfo {
  final String id;
  final String titulo;
  final String descripcion;
  final String formula;
  final List<String> notas;
  final List<Map<String, String>> referencias; // 👈 Cambiado

  CalculadoraInfo({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.formula,
    required this.notas,
    required this.referencias,
  });

  factory CalculadoraInfo.fromJson(Map<String, dynamic> json) {
    return CalculadoraInfo(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      formula: json['formula'],
      notas: List<String>.from(json['notas']),
      referencias: (json['referencias'] as List)
          .map((ref) => Map<String, String>.from(ref))
          .toList(),
    );
  }
}
