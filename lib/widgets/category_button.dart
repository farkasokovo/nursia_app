import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CategoryButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final String heroTag;

  const CategoryButton({
    super.key,
    required this.title,
    required this.icon,
    required this.heroTag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Hero(
      tag: heroTag,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          overlayColor: WidgetStateProperty.all(colorScheme.tertiaryContainer),
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            // 👇 Cerrar teclado antes de ejecutar la acción
            FocusManager.instance.primaryFocus?.unfocus();
            onTap?.call();
          },
          child: Ink(
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhosphorIcon(
                  icon,
                  size: 40,
                  color: colorScheme.primaryContainer,
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.primaryContainer,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
