import 'package:flutter/material.dart';

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

  factory VerMasScreen.fromJson(Map<String, dynamic> json) {
    return VerMasScreen(
      name: json["name"],

      description: json["description"],

      whenToUse: List<String>.from(json["when_to_use"] ?? []),

      components: List<String>.from(json["components"] ?? []),

      interpretation: List<String>.from(json["interpretation"] ?? []),

      limitations: List<String>.from(json["limitations"] ?? []),

      clinicalNotes: List<String>.from(json["clinical_notes"] ?? []),

      references: List<Map<String, dynamic>>.from(json["references"] ?? []),
    );
  }
}
