import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../theme/theme_provider.dart';

/// Pantalla de ajustes de la app. Por ahora solo contiene la apariencia
/// (tema claro/oscuro), pero está pensada como el lugar donde vivirán los
/// próximos ajustes generales.
///
/// Sigue la misma estructura visual que `AcercaDeScreen`: fondo
/// `secondaryContainer`, una tarjeta redondeada de `secondary` con el
/// contenido, y AppBar con el `caretLeft` de vuelta.
class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // `watch`: al tocar una opción, la palomita tiene que moverse sola.
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: colorScheme.secondaryContainer,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            PhosphorIconsBold.caretLeft,
            color: colorScheme.onPrimaryContainer,
            size: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ajustes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIconsBold.paintBrush,
                    size: 28,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Apariencia',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Elige cómo se ve Nurska. Con "Sistema", la app sigue el '
                'ajuste de claro u oscuro de tu teléfono.',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              _buildOpcionTema(
                colorScheme: colorScheme,
                textTheme: textTheme,
                icon: PhosphorIconsBold.deviceMobile,
                titulo: 'Sistema',
                subtitulo: 'Sigue el ajuste del teléfono',
                modo: ThemeMode.system,
                seleccionado: themeProvider.themeMode == ThemeMode.system,
                onTap: () => themeProvider.cambiarTema(ThemeMode.system),
              ),
              const SizedBox(height: 12),
              _buildOpcionTema(
                colorScheme: colorScheme,
                textTheme: textTheme,
                icon: PhosphorIconsBold.sun,
                titulo: 'Claro',
                subtitulo: 'Siempre en modo claro',
                modo: ThemeMode.light,
                seleccionado: themeProvider.themeMode == ThemeMode.light,
                onTap: () => themeProvider.cambiarTema(ThemeMode.light),
              ),
              const SizedBox(height: 12),
              _buildOpcionTema(
                colorScheme: colorScheme,
                textTheme: textTheme,
                icon: PhosphorIconsBold.moon,
                titulo: 'Oscuro',
                subtitulo: 'Siempre en modo oscuro',
                modo: ThemeMode.dark,
                seleccionado: themeProvider.themeMode == ThemeMode.dark,
                onTap: () => themeProvider.cambiarTema(ThemeMode.dark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Un renglón del selector de tema. Misma anatomía que el `_buildEnlaceTile`
  /// de "Acerca de" (ícono + título + subtítulo + indicador a la derecha),
  /// pero con estado de selección: la opción activa se marca con un borde en
  /// `primary` y una palomita en vez del `caretRight`.
  Widget _buildOpcionTema({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required ThemeMode modo,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              // El borde siempre existe (aunque sea transparente) para que la
              // tarjeta no cambie de tamaño al seleccionarla y el renglón no
              // "salte" al tocar otra opción.
              color: seleccionado ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 24, color: colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                seleccionado
                    ? PhosphorIconsFill.checkCircle
                    : PhosphorIconsBold.circle,
                size: 22,
                color: seleccionado
                    ? colorScheme.primary
                    : colorScheme.onSecondaryContainer.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
