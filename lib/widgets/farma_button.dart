// lib/widgets/farma_button.dart
// Widget reutilizable para botones de fármacos — idéntico en estructura a
// _ScaleButton de neurologicas_screen pero público y compartido
import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';
import 'alto_riesgo_badge.dart';

/// Alto de los botones en las pantallas de categoría de Escalas.
///
/// El doble del alto por omisión. Vive aquí, y no como un 140 suelto en cada
/// pantalla, para que las seis pantallas de Escalas que lo usan no se
/// desincronicen entre sí. Farmacología NO lo usa: sus botones se quedan en el
/// alto por omisión de [FarmaButton].
const double altoFarmaButtonEscalas = 140.0;

class FarmaButton extends StatelessWidget {
  final String title;
  final String? subtitle; // 1. Marcado como nullable con '?'
  final IconData icon;
  final VoidCallback onPressed;
  final bool altoRiesgo;

  /// Alto mínimo del botón.
  ///
  /// Por omisión 70, que es con el que se pintan los botones de Farmacología:
  /// al tener valor por omisión, esas diez pantallas quedan idénticas sin
  /// tocarlas. Las de Escalas pasan [altoFarmaButtonEscalas].
  ///
  /// Alimenta los DOS lugares donde se fija el alto (el ConstrainedBox y el
  /// minimumSize del ElevatedButton) para que no se desincronicen.
  final double altoMinimo;

  const FarmaButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.subtitle, // Ahora es opcional y puede ser null
    this.altoRiesgo = false,
    this.altoMinimo = 70,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Antes era una altura fija de 70. El chip de alto riesgo es más alto que
    // la línea de texto que reemplazó, así que en pantallas angostas (donde un
    // nombre largo como "Warfarina Sódica" cae a dos renglones) 70 se quedaba
    // corto y salía el overflow rayado. Con minHeight el botón conserva su
    // alto normal y solo crece cuando de verdad hace falta.
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: altoMinimo),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, altoMinimo),
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
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      color: ThemeColors.tituloSobrePrimary(context),
                    ),
                  ),

                  // 2. Renderizado condicional: Solo se crea si subtitle no es nulo
                  if (subtitle != null)
                    Text(
                      subtitle!, // Usamos '!' porque ya comprobamos que no es nulo
                      style: textTheme.titleSmall?.copyWith(
                        fontSize: 13,
                        color: ThemeColors.sobrePrimary(
                          context,
                          Colors.white70,
                        ),
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
            Icon(
              PhosphorIconsBold.caretRight,
              color: ThemeColors.sobrePrimary(context, Colors.white54),
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
