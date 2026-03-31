import 'package:flutter/material.dart';
import '../../widgets/expandable_category_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NeurologicasScreen extends StatelessWidget {
  const NeurologicasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "neurologicas",
      title: "Escalas Neurológicas",
      icon: PhosphorIconsFill.brain,

      child: Center(child: Text("Aquí aparecerán Glasgow, Ramsay y NIHSS")),
    );
  }
}
