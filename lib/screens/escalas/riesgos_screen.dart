// lib/screens/escalas/neurologicas_screen.dart
import 'package:flutter/material.dart';
import 'package:nursia_app/screens/escalas/riesgos/downton_screen.dart';
import 'package:nursia_app/screens/escalas/riesgos/maddox.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart';

class RiesgosScreen extends StatelessWidget {
  const RiesgosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "riesgos",
      title: "Valoración de riesgos",
      icon: PhosphorIconsFill.shieldCheck,
      child: _RiesgosLayout(),
    );
  }
}

class _RiesgosLayout extends StatelessWidget {
  const _RiesgosLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "Escala de Downton",
              subtitle: "Riesgo de Caídas",
              icon: PhosphorIconsRegular.boot,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DowntonScreen()),
              ),
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Escala de Braden",
              subtitle: "Riesgo de UPP",
              icon: PhosphorIconsRegular.selectionBackground,
              onPressed: () {},
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Escala de Maddox",
              subtitle: "Riesgo de flebitis",
              icon: PhosphorIconsRegular.hand,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MaddoxScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
