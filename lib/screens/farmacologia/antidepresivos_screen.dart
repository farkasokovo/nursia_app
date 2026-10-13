// lib/screens/farmacologia/antidepresivos_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart';
import '../ficha_medicamento.dart';

class AntidepresivosScreen extends StatelessWidget {
  const AntidepresivosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "antidepresivos",
      title: "Antidepresivos",
      icon: PhosphorIconsFill.brain,
      child: _AntidepresivosLayout(),
    );
  }
}

class _AntidepresivosLayout extends StatelessWidget {
  const _AntidepresivosLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "Escitalopram",
              icon: PhosphorIconsRegular.brain,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Escitalopram"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Fluoxetina",
              icon: PhosphorIconsRegular.brain,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Fluoxetina"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Sertralina",
              icon: PhosphorIconsRegular.brain,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Sertralina"),
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
