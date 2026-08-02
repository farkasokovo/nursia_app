// lib/widgets/alto_riesgo_badge.dart
// Etiqueta compartida para marcar medicamentos de alto riesgo (electrolitos
// concentrados, insulinas, anticoagulantes, citotóxicos) en la ficha
// individual y en los botones de categoría de Farmacología.
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AltoRiesgoBadge extends StatelessWidget {
  final bool compact;

  const AltoRiesgoBadge({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.redAlertv1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Alto riesgo",
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 11 : 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
