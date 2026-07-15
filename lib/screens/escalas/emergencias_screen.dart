// lib/screens/escalas/emergencias_screen.dart
import 'package:flutter/material.dart';
import 'package:nursia_app/screens/escalas/emergencias/indice_shock_screen.dart';
import 'package:nursia_app/screens/escalas/emergencias/mews_screen.dart';
import 'package:nursia_app/screens/escalas/emergencias/qsofa_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart';

class EmergenciasScreen extends StatelessWidget {
  const EmergenciasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "emergencias",
      title: "Emergencias y Triaje",
      icon: PhosphorIconsFill.siren,
      child: _EmergenciasLayout(),
    );
  }
}

class _EmergenciasLayout extends StatelessWidget {
  const _EmergenciasLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "MEWS",
              subtitle: "Alerta temprana",
              icon: PhosphorIconsRegular.warning,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MewsScreen()),
              ),
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "qSOFA",
              subtitle: "Tamizaje de sepsis",
              icon: PhosphorIconsRegular.virus,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QsofaScreen()),
              ),
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Índice de Shock",
              subtitle: "FC ÷ PAS",
              icon: PhosphorIconsRegular.heartbeat,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const IndiceShockScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
