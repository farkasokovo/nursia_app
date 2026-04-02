import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../theme/app_theme.dart'; // Solo para AppRadius (constante)
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
              icon: PhosphorIconsRegular.moon,
            ),
            const SizedBox(height: 20),
            _ScaleButton(
              onPressed: () {},
              title: "Escala RASS",
              icon: PhosphorIconsRegular.gauge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScaleButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  const _ScaleButton({
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.defaultRadius,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 35,
              color: colorScheme.onPrimary, // antes AppColors.secondaryColor
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
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
