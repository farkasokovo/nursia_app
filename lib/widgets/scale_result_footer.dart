import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ScaleResultFooter extends StatelessWidget {
  final bool visible;
  final String resultado;
  final Color Function(String resultado)? colorResolver;
  // Gemela de colorResolver: mapea el resultado a una etiqueta clínica corta
  // (ej. "Riesgo alto", "Dolor moderado"). Cada escala usa su propio
  // vocabulario clínico.
  final String Function(String resultado)? etiquetaResolver;

  const ScaleResultFooter({
    super.key,
    required this.visible,
    required this.resultado,
    this.colorResolver,
    this.etiquetaResolver,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final esNumero = RegExp(r'^-?\d+').hasMatch(resultado);
    final colorResultado = colorResolver?.call(resultado);
    // La etiqueta clínica corta solo tiene sentido cuando el resultado es un
    // número limpio. Si algún parámetro se marcó como "No valorable"
    // (Glasgow/Downton), el resultado deja de ser numérico: en ese caso se
    // muestra explícitamente "No valorable" en vez de una gravedad engañosa.
    final etiqueta = etiquetaResolver == null
        ? null
        : (esNumero ? etiquetaResolver!(resultado) : "No valorable");

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
          // Etiqueta clínica corta, en el mismo color de gravedad del resultado.
          if (etiqueta != null && etiqueta.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              etiqueta,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: colorResultado ?? colorScheme.primaryContainer,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              // Botón secundario: sale por completo de la pantalla de la escala.
              Expanded(
                flex: 3,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Finalizar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Botón principal: lleva a la pestaña "Ver más" de la MISMA
              // pantalla usando el DefaultTabController del molde (índice 1),
              // sin salir de la escala.
              Expanded(
                flex: 4,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  onPressed: () =>
                      DefaultTabController.of(context).animateTo(1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Flexible(
                        child: Text(
                          "Ver más",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      PhosphorIcon(
                        PhosphorIconsBold.caretRight,
                        size: 20,
                        color: colorScheme.onPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
