import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ExpandableCategoryScreen extends StatelessWidget {
  final String heroTag;
  final String title;
  final IconData icon;
  final Widget child;

  const ExpandableCategoryScreen({
    super.key,
    required this.heroTag,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Hero(
        tag: heroTag,
        child: Material(
          color: colorScheme.primaryContainer,
          child: SafeArea(
            child: Column(
              spacing: 8,
              children: [
                // AppBar personalizada
                Row(
                  children: [
                    IconButton(
                      icon: PhosphorIcon(
                        PhosphorIconsBold.caretLeft,
                        color: colorScheme.onPrimaryContainer,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    PhosphorIcon(
                      icon,
                      size: 28,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Resto del contenido
                Expanded(
                  child: Container(
                    color: colorScheme.secondaryContainer,
                    child: child,
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
