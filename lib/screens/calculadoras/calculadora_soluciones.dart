import 'package:flutter/material.dart';
import '../../widgets/expandable_category_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CalculadoraSoluciones extends StatelessWidget {
  const CalculadoraSoluciones({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "soluciones",
      title: "Calculadora de\nSoluciones",
      icon: PhosphorIconsFill.drop,

      child: Center(
        child: Text("Aquí aparecerá la calculadora de Soluciones."),
      ),
    );
  }
}
