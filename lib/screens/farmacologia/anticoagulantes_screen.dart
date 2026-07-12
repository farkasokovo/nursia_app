// lib/screens/farmacologia/anticoagulantes_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart';
import '../ficha_medicamento.dart';

class AnticoagulantesScreen extends StatelessWidget {
  const AnticoagulantesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "anticoagulantes",
      title: "Anticoagulantes",
      icon: PhosphorIconsFill.drop,
      child: _AnticoagulantesLayout(),
    );
  }
}

class _AnticoagulantesLayout extends StatelessWidget {
  const _AnticoagulantesLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "Heparina Sódica",
              icon: PhosphorIconsRegular.drop,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Heparina Sódica"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Enoxaparina",
              icon: PhosphorIconsRegular.drop,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Enoxaparina"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Warfarina Sódica",
              icon: PhosphorIconsRegular.drop,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FichaMedicamento(
                      nombreMedicamento: "Warfarina Sódica",
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
