// lib/screens/bienvenida_screen.dart
import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/nota_version.dart';
import '../theme/app_theme.dart';
import '../widgets/lista_cambios.dart';

/// Pantalla de novedades que aparece UNA sola vez después de actualizar.
///
/// Decisiones de diseño, todas a propósito:
/// - No lleva equis, no se cierra tocando fuera y el botón atrás del sistema no
///   la descarta (`PopScope` con `canPop: false` y sin acción). La única salida
///   es el botón de abajo, así el contenido se recorre con la vista.
/// - No usa el verde de alerta: ese color ya significa "hay una actualización
///   disponible para descargar". Aquí la actualización YA se instaló, así que
///   se usa el café de marca de la app con el acento claro del tema.
class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key, required this.notas});

  final NotaVersion notas;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return PopScope(
      // Sin salida por el botón atrás: se cierra solo con "Entendido".
      canPop: false,
      child: Scaffold(
        backgroundColor: colorScheme.primaryContainer,
        // `bottom: false`: la barra de navegación del sistema la aparta el
        // bloque del botón, no la columna entera. Así el papel claro llega
        // hasta la orilla de la pantalla en vez de cortarse 48 px antes y
        // dejar ver una franja del café del Scaffold. Mismo criterio que
        // `scale_result_footer.dart`.
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildEncabezado(context, colorScheme, textTheme),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Novedades',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListaCambios(
                          cambios: notas.cambios,
                          colorTexto: colorScheme.onSurface,
                          colorVinieta: ThemeColors.acento(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBoton(context, colorScheme, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEncabezado(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        children: [
          PhosphorIcon(
            PhosphorIconsFill.cloudCheck,
            size: 56,
            color: ThemeColors.acento(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Nueva actualización',
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 10),
          // Pastilla con la versión, en el acento claro del tema.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: ThemeColors.acento(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Versión ${notas.version}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoton(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      width: double.infinity,
      // El color va en el Container y el SafeArea por dentro: el fondo cubre
      // también la zona de la barra del sistema, y lo único que se aparta es
      // el botón. Con navegación por botones queda 20 px sobre la barra, igual
      // que con gestos; sin barra (Android sin edge-to-edge) esos mismos 20 px
      // hacen de margen mínimo contra el borde.
      color: colorScheme.secondary,
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
              minimumSize: const Size(double.infinity, 56),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.defaultRadius,
              ),
            ),
            child: Text(
              'Entendido',
              style: textTheme.titleSmall?.copyWith(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
