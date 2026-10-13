// lib/screens/farmacologia/electrolitos_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart';
import '../ficha_medicamento.dart';

class ElectrolitosScreen extends StatelessWidget {
  const ElectrolitosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "electrolitos",
      title: "Electrolitos",
      icon: PhosphorIconsFill.lightning,
      child: _ElectrolitosLayout(),
    );
  }
}

class _ElectrolitosLayout extends StatelessWidget {
  const _ElectrolitosLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "Cloruro de Potasio",
              icon: PhosphorIconsRegular.lightning,
              altoRiesgo: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FichaMedicamento(
                      nombreMedicamento: "Cloruro de Potasio",
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Sulfato de Magnesio",
              icon: PhosphorIconsRegular.lightning,
              altoRiesgo: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FichaMedicamento(
                      nombreMedicamento: "Sulfato de Magnesio",
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Gluconato de Calcio",
              icon: PhosphorIconsRegular.lightning,
              altoRiesgo: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FichaMedicamento(
                      nombreMedicamento: "Gluconato de Calcio",
                    ),
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
