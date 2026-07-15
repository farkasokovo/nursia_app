// lib/screens/escalas/dolor_screen.dart
import 'package:flutter/material.dart';
import 'package:nursia_app/screens/escalas/dolor/dn4_screen.dart';
import 'package:nursia_app/screens/escalas/dolor/evna_screen.dart';
import 'package:nursia_app/screens/escalas/dolor/painad_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart';

class DolorScreen extends StatelessWidget {
  const DolorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "dolor",
      title: "Evaluación del Dolor",
      icon: PhosphorIconsFill.smileyNervous,
      child: _DolorLayout(),
    );
  }
}

class _DolorLayout extends StatelessWidget {
  const _DolorLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "EVNA",
              subtitle: "Escala numérica (0-10)",
              icon: PhosphorIconsRegular.ruler,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EvnaScreen()),
              ),
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "PAINAD",
              subtitle: "Dolor en demencia avanzada",
              icon: PhosphorIconsRegular.brain,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PainadScreen()),
              ),
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "DN4",
              subtitle: "Dolor neuropático",
              icon: PhosphorIconsRegular.lightning,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Dn4Screen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
