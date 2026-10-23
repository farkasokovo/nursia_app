// lib/screens/farmacologia/vasodilatadores_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart';
import '../ficha_medicamento.dart';

class VasodilatadoresScreen extends StatelessWidget {
  const VasodilatadoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "vasodilatadores",
      title: "Vasodilatadores",
      icon: PhosphorIconsFill.heart,
      child: _VasodilatadoresLayout(),
    );
  }
}

class _VasodilatadoresLayout extends StatelessWidget {
  const _VasodilatadoresLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "Nitroglicerina",
              icon: PhosphorIconsRegular.heart,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Nitroglicerina"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Dinitrato de Isosorbida",
              icon: PhosphorIconsRegular.heart,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Dinitrato de Isosorbida"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Nitroprusiato de Sodio",
              icon: PhosphorIconsRegular.heart,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Nitroprusiato de Sodio"),
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
