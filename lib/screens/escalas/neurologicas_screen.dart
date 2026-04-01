import 'package:flutter/material.dart';
import '../../widgets/expandable_category_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/app_theme.dart';
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
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 👇 AHORA PASAMOS EL TÍTULO Y EL ÍCONO
            _ScaleButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GlasgowScreen()),
                );
              },
              title: "Escala de Glasgow",
              icon: PhosphorIconsRegular.brain,
            ),

            const SizedBox(height: 20),

            _ScaleButton(
              onPressed: () {},
              title: "Escala de Ramsay",
              icon: PhosphorIconsRegular.moon, // Ícono de luna para sedación
            ),

            const SizedBox(height: 20),

            _ScaleButton(
              onPressed: () {},
              title: "Escala RASS",
              icon: PhosphorIconsRegular
                  .gauge, // Ícono de actividad para valoración
            ),
          ],
        ),
      ),
    );
  }
}

class _ScaleButton extends StatelessWidget {
  final String title;
  final IconData icon; // 👈 Nuevo parámetro para el ícono
  final VoidCallback onPressed;

  const _ScaleButton({
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          // Añadimos padding interno para que el ícono no pegue al borde
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.defaultRadius,
          ),
        ),
        child: Row(
          // 👈 Usamos Row para alinear Ícono + Espacio + Texto
          children: [
            Icon(
              icon,
              size: 35, // Tamaño para que resalte
              color: AppColors.secondaryColor, // Color crema/blanco de tu app
            ),

            const SizedBox(width: 20), // Espacio entre ícono y texto

            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleWhiteText.copyWith(fontSize: 20),
              ),
            ),

            // Opcional: Una flechita al final hace que parezca un menú navegable
            const Icon(
              PhosphorIconsBold.caretRight,
              color: Colors.white54,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
