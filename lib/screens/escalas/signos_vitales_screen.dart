// lib/screens/escalas/signos_vitales_screen.dart
import 'package:flutter/material.dart';
import 'package:nursia_app/screens/escalas/signos_vitales/adulto_screen.dart';
import 'package:nursia_app/screens/escalas/signos_vitales/pediatricos_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart';

class SignosVitalesScreen extends StatelessWidget {
  const SignosVitalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "signos_vitales",
      title: "Signos Vitales",
      icon: PhosphorIconsFill.heartbeat,
      child: _SignosVitalesLayout(),
    );
  }
}

class _SignosVitalesLayout extends StatelessWidget {
  const _SignosVitalesLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "Pediátricos",
              subtitle: "Valores por grupo de edad",
              icon: PhosphorIconsRegular.babyCarriage,
              altoMinimo: altoFarmaButtonEscalas,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SignosVitalesPediatricosScreen(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Adulto",
              subtitle: "Valores de referencia",
              icon: PhosphorIconsRegular.person,
              altoMinimo: altoFarmaButtonEscalas,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SignosVitalesAdultoScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
