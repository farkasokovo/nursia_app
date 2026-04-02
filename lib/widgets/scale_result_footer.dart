import 'package:flutter/material.dart';

class ScaleResultFooter extends StatelessWidget {
  final bool visible;
  final String resultado;
  final Color Function(String resultado)? colorResolver;

  const ScaleResultFooter({
    super.key,
    required this.visible,
    required this.resultado,
    this.colorResolver,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final esNumero = RegExp(r'^\d+').hasMatch(resultado);
    final colorResultado = colorResolver?.call(resultado);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primaryContainer.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Resultado:",
            textAlign: TextAlign.center,
            style: textTheme.headlineLarge?.copyWith(
              color: colorScheme.primaryContainer,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: colorResultado ?? Colors.transparent,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Text(
              resultado,
              textAlign: TextAlign.center,
              softWrap: true,
              style: esNumero
                  ? textTheme.displayLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    )
                  : textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
