// lib/screens/farmacologia/hemostaticos_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart';
import '../ficha_medicamento.dart';

class HemostaticosScreen extends StatelessWidget {
  const HemostaticosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "hemostaticos",
      title: "Hemostáticos",
      icon: PhosphorIconsFill.firstAidKit,
      child: _HemostaticosLayout(),
    );
  }
}

class _HemostaticosLayout extends StatelessWidget {
  const _HemostaticosLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "Ácido Tranexámico",
              icon: PhosphorIconsRegular.firstAidKit,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FichaMedicamento(
                      nombreMedicamento: "Ácido Tranexámico",
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Fitomenadiona",
              icon: PhosphorIconsRegular.firstAidKit,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Fitomenadiona"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Protamina",
              icon: PhosphorIconsRegular.firstAidKit,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Protamina"),
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
