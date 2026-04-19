// lib/screens/escalas/neurologicas_screen.dart
import 'package:flutter/material.dart';
import 'package:nursia_app/screens/escalas/neurologicas/ramsay_screen.dart';
import 'package:nursia_app/screens/escalas/neurologicas/rass_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart'; // ← reemplaza a _ScaleButton
import 'package:nursia_app/screens/escalas/neurologicas/glasgow_screen.dart';

class NeurologicasScreen extends StatelessWidget {
  const NeurologicasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "neurologicas",
      title: "Escalas Neurológicas",
      icon: PhosphorIconsFill.brain,
      child: _NeurologicasLayout(),
    );
  }
}

class _NeurologicasLayout extends StatelessWidget {
  const _NeurologicasLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "Escala de Glasgow",
              subtitle: "Nivel de Conciencia",
              icon: PhosphorIconsRegular.brain,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GlasgowScreen()),
              ),
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Escala de Ramsay",
              subtitle: "Agitación y Sedación",
              icon: PhosphorIconsRegular.moon,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RamsayScreen()),
              ),
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Escala RASS",
              subtitle: "Nivel de Sedación",
              icon: PhosphorIconsRegular.gauge,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RassScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// _ScaleButton eliminado — ahora usa FarmaButton de lib/widgets/farma_button.dart
