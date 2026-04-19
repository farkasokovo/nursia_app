// lib/widgets/farma_button.dart
// Widget reutilizable para botones de fármacos — idéntico en estructura a
// _ScaleButton de neurologicas_screen pero público y compartido
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';

class FarmaButton extends StatelessWidget {
  final String title;
  final String? subtitle; // 1. Marcado como nullable con '?'
  final IconData icon;
  final VoidCallback onPressed;

  const FarmaButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.subtitle, // Ahora es opcional y puede ser null
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SizedBox(
      width: double.infinity,
      height: 70, // Subí un poco el height para que quepan bien las dos líneas
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
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Centra el contenido verticalmente
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Alinea el texto a la izquierda
                children: [
                  Text(title, style: textTheme.titleSmall),

                  // 2. Renderizado condicional: Solo se crea si subtitle no es nulo
                  if (subtitle != null)
                    Text(
                      subtitle!, // Usamos '!' porque ya comprobamos que no es nulo
                      style: textTheme.titleSmall?.copyWith(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                ],
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
