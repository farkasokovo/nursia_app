// lib/widgets/farma_button.dart
// Widget reutilizable para botones de fármacos — idéntico en estructura a
// _ScaleButton de neurologicas_screen pero público y compartido
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';

class FarmaButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  const FarmaButton({
    super.key,
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
            Icon(icon, size: 30, color: colorScheme.onPrimary),
            const SizedBox(width: 20),
            Expanded(child: Text(title, style: textTheme.titleSmall)),
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
