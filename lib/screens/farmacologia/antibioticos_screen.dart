// lib/screens/farmacologia/antibioticos_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart';
import '../ficha_medicamento.dart';

class AntibioticosScreen extends StatelessWidget {
  const AntibioticosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "antibioticos",
      title: "Antibióticos",
      icon: PhosphorIconsFill.shieldPlus,
      child: _AntibioticosLayout(),
    );
  }
}

class _AntibioticosLayout extends StatelessWidget {
  const _AntibioticosLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "Amoxicilina",
              icon: PhosphorIconsRegular.shieldPlus,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Amoxicilina"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Ciprofloxacino",
              icon: PhosphorIconsRegular.shieldPlus,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Ciprofloxacino"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Ceftriaxona",
              icon: PhosphorIconsRegular.shieldPlus,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Ceftriaxona"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
