import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';

class ValoracionGeneralScreen extends StatelessWidget {
  const ValoracionGeneralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return ExpandableCategoryScreen(
      heroTag: "clinica",
      title: "Valoración general",
      icon: PhosphorIconsFill.stethoscope,
      child: Center(
        child: Text(
          "Aquí aparecerán otras escalas.",
          style: textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
