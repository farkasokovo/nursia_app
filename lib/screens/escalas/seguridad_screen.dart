import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';

class SeguridadScreen extends StatelessWidget {
  const SeguridadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return ExpandableCategoryScreen(
      heroTag: "seguridad",
      title: "Escalas de Seguridad",
      icon: PhosphorIconsFill.shieldCheck,
      child: Center(
        child: Text(
          "Aquí aparecerán Dowton, Morse, etc.",
          style: textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
