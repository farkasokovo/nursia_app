// lib/screens/escalas/pediatricas_screen.dart
import 'package:flutter/material.dart';
import 'package:nursia_app/screens/escalas/pediatricas/apgar_screen.dart';
import 'package:nursia_app/screens/escalas/pediatricas/flacc_screen.dart';
import 'package:nursia_app/screens/escalas/pediatricas/silverman_anderson_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart';

class PediatricasScreen extends StatelessWidget {
  const PediatricasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "pediatricas",
      title: "Escalas Pediátricas y Neonatales",
      icon: PhosphorIconsFill.baby,
      child: _PediatricasLayout(),
    );
  }
}

class _PediatricasLayout extends StatelessWidget {
  const _PediatricasLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "Escala de APGAR",
              subtitle: "Vitalidad del recién nacido",
              icon: PhosphorIconsRegular.baby,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ApgarScreen()),
              ),
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Silverman-Anderson",
              subtitle: "Dificultad respiratoria neonatal",
              icon: PhosphorIconsRegular.wind,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SilvermanAndersonScreen(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Escala FLACC",
              subtitle: "Dolor en no verbales",
              icon: PhosphorIconsRegular.smiley,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FlaccScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
