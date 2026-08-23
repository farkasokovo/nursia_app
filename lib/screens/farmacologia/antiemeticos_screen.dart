// lib/screens/farmacologia/antiemeticos_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart';
import '../ficha_medicamento.dart';

class AntiemeticosScreen extends StatelessWidget {
  const AntiemeticosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "antiemeticos",
      title: "Antieméticos",
      icon: PhosphorIconsFill.pill,
      child: _AntiemeticosLayout(),
    );
  }
}

class _AntiemeticosLayout extends StatelessWidget {
  const _AntiemeticosLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "Metoclopramida",
              icon: PhosphorIconsRegular.pill,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Metoclopramida"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Ondansetrón",
              icon: PhosphorIconsRegular.pill,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Ondansetrón"),
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
