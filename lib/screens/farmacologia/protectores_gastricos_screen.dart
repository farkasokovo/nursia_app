// lib/screens/farmacologia/protectores_gastricos_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart';
import '../ficha_medicamento.dart';

class ProtectoresGastricosScreen extends StatelessWidget {
  const ProtectoresGastricosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "protectores_gastricos",
      title: "Protectores gástricos",
      icon: PhosphorIconsFill.shield,
      child: _ProtectoresGastricosLayout(),
    );
  }
}

class _ProtectoresGastricosLayout extends StatelessWidget {
  const _ProtectoresGastricosLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "Omeprazol",
              icon: PhosphorIconsRegular.shield,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Omeprazol"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Pantoprazol",
              icon: PhosphorIconsRegular.shield,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Pantoprazol"),
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
