import 'package:flutter/material.dart';
import 'package:nursia_app/screens/calculadoras/calculadora_dosis.dart';
import 'package:nursia_app/screens/calculadoras/calculadora_soluciones.dart';
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CalculadoraDosis(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: CategoryButton(
                  heroTag: "soluciones",
                  title: "Calculadora de Soluciones glucosadas (%)",
                  icon: PhosphorIconsRegular.drop,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CalculadoraSoluciones(),
                      ),
                    );
                  },
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
