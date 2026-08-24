// lib/widgets/farma_button.dart
// Widget reutilizable para botones de fármacos — idéntico en estructura a
// _ScaleButton de neurologicas_screen pero público y compartido
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';
import 'alto_riesgo_badge.dart';

class FarmaButton extends StatelessWidget {
  final String title;
  final String? subtitle; // 1. Marcado como nullable con '?'
  final IconData icon;
  final VoidCallback onPressed;
  final bool altoRiesgo;

  const FarmaButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.subtitle, // Ahora es opcional y puede ser null
    this.altoRiesgo = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Antes era una altura fija de 70. El chip de alto riesgo es más alto que
    // la línea de texto que reemplazó, así que en pantallas angostas (donde un
    // nombre largo como "Warfarina Sódica" cae a dos renglones) 70 se quedaba
    // corto y salía el overflow rayado. Con minHeight el botón conserva los 70
    // de siempre y solo crece cuando de verdad hace falta.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 70),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 70),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

                  // Chip rojo con ícono. Antes era una línea de texto gris con
                  // el mismo estilo que el subtítulo, así que la marca de alto
                  // riesgo se leía como descripción y pasaba desapercibida.
                  if (altoRiesgo) ...[
                    const SizedBox(height: 5),
                    const AltoRiesgoBadge(compact: true),
                  ],
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
