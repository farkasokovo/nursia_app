import 'package:flutter/material.dart';
import '../../widgets/expandable_category_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ValoracionScreen extends StatelessWidget {
  const ValoracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "valoracion",
      title: "Escalas de Valoración",
      icon: PhosphorIconsFill.stethoscope,

      child: Center(child: Text("Aquí aparecerán otras escalas.")),
    );
  }
}
