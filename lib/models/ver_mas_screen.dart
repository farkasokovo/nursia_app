import 'dart:convert';

class VerMasScreen {
  final String name;
  final String description;
  final List<String> whenToUse;
  final List<String> components;
  final List<String> interpretation;
  final List<String> limitations;
  final List<String> clinicalNotes;
  final List<Map<String, dynamic>> references;

  VerMasScreen({
    required this.name,
    required this.description,
    required this.whenToUse,
    required this.components,
    required this.interpretation,
    required this.limitations,
    required this.clinicalNotes,
    required this.references,
  });

  // NUEVO: Crea el objeto desde los datos de la base de datos
  factory VerMasScreen.fromMap(Map<String, dynamic> map) {
    return VerMasScreen(
      name:
          map['nombre'] ?? '', // Nota: usamos el nombre de la columna de la DB
      description: map['description'] ?? '',
      whenToUse: List<String>.from(jsonDecode(map['when_to_use'] ?? '[]')),
      components: List<String>.from(jsonDecode(map['components'] ?? '[]')),
      interpretation: List<String>.from(
        jsonDecode(map['interpretation'] ?? '[]'),
      ),
      limitations: List<String>.from(jsonDecode(map['limitations'] ?? '[]')),
      clinicalNotes: List<String>.from(
        jsonDecode(map['clinical_notes'] ?? '[]'),
      ),
      references: List<Map<String, dynamic>>.from(
        jsonDecode(map['references_data'] ?? '[]'),
      ),
    );
  }

  // Mantenemos tu factory fromJson original para la migración inicial
  factory VerMasScreen.fromJson(Map<String, dynamic> json) {
    return VerMasScreen(
      name: json["name"] ?? '',
      description: json["description"] ?? '',
      whenToUse: List<String>.from(json["when_to_use"] ?? []),
      components: List<String>.from(json["components"] ?? []),
      interpretation: List<String>.from(json["interpretation"] ?? []),
      limitations: List<String>.from(json["limitations"] ?? []),
      clinicalNotes: List<String>.from(json["clinical_notes"] ?? []),
      references: List<Map<String, dynamic>>.from(json["references"] ?? []),
    );
  }
}
