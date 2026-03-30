import 'package:flutter/material.dart';
import '../widgets/category_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../screens/escalas/neurologicas_screen.dart';

class EscalasScreen extends StatelessWidget {
  const EscalasScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: CategoryButton(
                  title: "Neurológicas",
                  icon: PhosphorIconsRegular.brain,
                  heroTag: "neurologicas",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NeurologicasScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: CategoryButton(
                  title: "Seguridad\ndel paciente",
                  icon: PhosphorIconsRegular.shieldCheck,
                  heroTag: "seguridad",
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: CategoryButton(
                  title: "Valoración clínica",
                  icon: PhosphorIconsRegular.stethoscope,
                  heroTag: "valoracion",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
