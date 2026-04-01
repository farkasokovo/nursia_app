import 'package:flutter/material.dart';

import '../models/scale_info_model.dart';

class ScaleInfoView extends StatelessWidget {
  final ScaleInfoModel info;

  const ScaleInfoView({super.key, required this.info});

  Widget buildSection(String title, List<String> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 6),

        ...content.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text("• $item"),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(info.description),

          const SizedBox(height: 16),

          buildSection("¿Cuándo usarla?", info.whenToUse),

          buildSection("Componentes", info.components),

          buildSection("Interpretación", info.interpretation),

          buildSection("Limitaciones", info.limitations),

          buildSection("Notas clínicas", info.clinicalNotes),

          buildSection("Referencias", info.references),
        ],
      ),
    );
  }
}
