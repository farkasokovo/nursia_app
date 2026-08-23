// lib/screens/farmacologia/broncodilatadores_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/farma_button.dart';
import '../ficha_medicamento.dart';

class BroncodilatadoresScreen extends StatelessWidget {
  const BroncodilatadoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "broncodilatadores",
      title: "Broncodilatadores",
      icon: PhosphorIconsFill.wind,
      child: _BroncodilatadoresLayout(),
    );
  }
}

class _BroncodilatadoresLayout extends StatelessWidget {
  const _BroncodilatadoresLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FarmaButton(
              title: "Salbutamol",
              icon: PhosphorIconsRegular.wind,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FichaMedicamento(nombreMedicamento: "Salbutamol"),
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
