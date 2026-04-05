// lib/screens/farmacologia/analgesicos_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart';
import '../ficha_medicamento.dart';

class DiureticosScreen extends StatelessWidget {
  const DiureticosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "diureticos",
      title: "Diuréticos",
      icon: PhosphorIconsFill.drop,
      child: _DiureticosLayout(),
    );
  }
}

class _DiureticosLayout extends StatelessWidget {
  const _DiureticosLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "Furosemida",
              icon: PhosphorIconsRegular.drop,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Furosemida"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Espironolactona",
              icon: PhosphorIconsRegular.drop,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Espironolactona"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Hidroclorotiazida",
              icon: PhosphorIconsRegular.drop,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FichaMedicamento(
                      nombreMedicamento: "Hidroclorotiazida",
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
