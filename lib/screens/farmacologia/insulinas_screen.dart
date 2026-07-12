// lib/screens/farmacologia/insulinas_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart';
import '../ficha_medicamento.dart';

class InsulinasScreen extends StatelessWidget {
  const InsulinasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "insulinas",
      title: "Insulinas",
      icon: PhosphorIconsFill.syringe,
      child: _InsulinasLayout(),
    );
  }
}

class _InsulinasLayout extends StatelessWidget {
  const _InsulinasLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "Insulina Lispro",
              icon: PhosphorIconsRegular.syringe,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Insulina Lispro"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Insulina NPH",
              icon: PhosphorIconsRegular.syringe,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Insulina NPH"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Insulina Glargina",
              icon: PhosphorIconsRegular.syringe,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FichaMedicamento(
                      nombreMedicamento: "Insulina Glargina",
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
