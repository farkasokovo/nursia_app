// lib/screens/farmacologia/cardiovascular_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart';
import '../ficha_medicamento.dart';

class AntiinflamatoriosScreen extends StatelessWidget {
  const AntiinflamatoriosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "antiinflamatorios",
      title: "Antiinflamatorios",
      icon: PhosphorIconsFill.thermometer,
      child: _AntiinflamatoriosScreen(),
    );
  }
}

class _AntiinflamatoriosScreen extends StatelessWidget {
  const _AntiinflamatoriosScreen();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "Metamizol",
              icon: PhosphorIconsRegular.thermometer,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Metamizol"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Dexametasona",
              icon: PhosphorIconsRegular.thermometer,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Dexametasona"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Naproxeno",
              icon: PhosphorIconsRegular.thermometer,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Naproxeno"),
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
