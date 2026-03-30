import 'package:flutter/material.dart';
import '../widgets/category_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CalculadoraScreen extends StatelessWidget {
  const CalculadoraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Row(
            children: [
              Expanded(
                child: CategoryButton(
                  heroTag: "dosis",
                  title: "Calculadora de dosis",
                  icon: PhosphorIconsRegular.syringe,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          Row(
            children: const [
              Expanded(
                child: CategoryButton(
                  heroTag: "soluciones",
                  title: "Calculadora de Soluciones",
                  icon: PhosphorIconsRegular.drop,
                ),
              ),
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }
}
