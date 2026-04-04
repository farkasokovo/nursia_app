// lib/screens/farmacologia/cardiovascular_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart';

class CardiovascularScreen extends StatelessWidget {
  const CardiovascularScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "antihipertensivos",
      title: "Antihipertensivos",
      icon: PhosphorIconsFill.heartbeat,
      child: _CardiovascularLayout(),
    );
  }
}

class _CardiovascularLayout extends StatelessWidget {
  const _CardiovascularLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "Metoprolol",
              icon: PhosphorIconsRegular.heartbeat,
              onPressed: () {},
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Enalapril",
              icon: PhosphorIconsRegular.heartbeat,
              onPressed: () {},
            ),
            const SizedBox(height: 20),
            FarmaButton(
              title: "Digoxina",
              icon: PhosphorIconsRegular.heartbeat,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
