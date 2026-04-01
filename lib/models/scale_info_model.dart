class ScaleInfoModel {
  final String name;
  final String description;

  final List<String> whenToUse;
  final List<String> components;
  final List<String> interpretation;
  final List<String> limitations;
  final List<String> clinicalNotes;
  final List<String> references;

  ScaleInfoModel({
    required this.name,
    required this.description,

    required this.whenToUse,
    required this.components,
    required this.interpretation,
    required this.limitations,
    required this.clinicalNotes,
    required this.references,
  });

  factory ScaleInfoModel.fromJson(Map<String, dynamic> json) {
    return ScaleInfoModel(
      name: json["name"],
      description: json["description"],

      whenToUse: List<String>.from(json["when_to_use"]),
      components: List<String>.from(json["components"]),
      interpretation: List<String>.from(json["interpretation"]),
      limitations: List<String>.from(json["limitations"]),
      clinicalNotes: List<String>.from(json["clinical_notes"]),
      references: List<String>.from(json["references"]),
    );
  }
}
