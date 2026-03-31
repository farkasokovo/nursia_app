import 'package:flutter/material.dart';
import '../../widgets/expandable_category_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SeguridadScreen extends StatelessWidget {
  const SeguridadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "seguridad",
      title: "Escalas de Seguridad",
      icon: PhosphorIconsFill.shieldCheck,

      child: Center(child: Text("Aquí aparecerán Dowton, Morse, etc.")),
    );
  }
}
