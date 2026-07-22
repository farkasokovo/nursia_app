import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Botón placeholder "Próximamente" para rellenar el hueco cuando un bloque
/// del grid tiene un número impar de categorías (evita el botón huérfano a
/// media pantalla). Comparte forma y tamaño con [CategoryButton] pero se
/// muestra atenuado para leerse claramente como contenido aún no disponible.
///
/// No navega ni usa Hero: al tocarlo solo avisa que habrá contenido a futuro.
class ComingSoonButton extends StatelessWidget {
  const ComingSoonButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        overlayColor: WidgetStateProperty.all(
          colorScheme.tertiaryContainer.withValues(alpha: 0.4),
        ),
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Más contenido próximamente!')),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            // Atenuado: mismo color base pero translúcido y sin sombra, para
            // distinguirlo de las categorías activas.
            color: colorScheme.secondaryContainer.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20),
          ),
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhosphorIcon(
                PhosphorIconsRegular.dotsThreeCircle,
                size: 40,
                color: colorScheme.primaryContainer.withValues(alpha: 0.55),
              ),
              const SizedBox(height: 10),
              Text(
                'Próximamente',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.55),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
                    fontSize: 17,
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
