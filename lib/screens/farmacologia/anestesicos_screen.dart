// lib/screens/farmacologia/anestesicos_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart';
import '../ficha_medicamento.dart';

class AnestesicosScreen extends StatelessWidget {
  const AnestesicosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "anestesicos",
      title: "Anestésicos",
      icon: PhosphorIconsFill.needle,
      child: _AnestesicosLayout(),
    );
  }
}

class _AnestesicosLayout extends StatelessWidget {
  const _AnestesicosLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "Lidocaína",
              icon: PhosphorIconsRegular.needle,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Lidocaína"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Bupivacaína",
              icon: PhosphorIconsRegular.needle,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Bupivacaína"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Propofol",
              icon: PhosphorIconsRegular.needle,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Propofol"),
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
