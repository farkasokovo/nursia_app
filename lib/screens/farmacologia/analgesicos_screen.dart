// lib/screens/farmacologia/analgesicos_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart';
import '../ficha_medicamento.dart';

class AnalgesicosScreen extends StatelessWidget {
  const AnalgesicosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "analgesicos",
      title: "Analgésicos",
      icon: PhosphorIconsFill.bandaids,
      child: _AnalgesicosLayout(),
    );
  }
}

class _AnalgesicosLayout extends StatelessWidget {
  const _AnalgesicosLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "Paracetamol",
              icon: PhosphorIconsRegular.bandaids,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Paracetamol"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Ibuprofeno",
              icon: PhosphorIconsRegular.bandaids,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Ibuprofeno"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Ketorolaco",
              icon: PhosphorIconsRegular.bandaids,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Ketorolaco"),
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
