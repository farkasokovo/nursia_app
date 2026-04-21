import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Barra que aparece arriba de la lista en cada pestaña.
/// - En modo normal: botón compacto [trash] Eliminar.
/// - En modo selección: contenedor expandido con contador y botón Cancelar.
class BarraAcciones extends StatelessWidget {
  final bool modoSeleccion;
  final int totalItems;
  final int seleccionados;
  final VoidCallback onEntrarModo;
  final VoidCallback onCancelar;

  const BarraAcciones({
    super.key,
    required this.modoSeleccion,
    required this.totalItems,
    required this.seleccionados,
    required this.onEntrarModo,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // ── MODO NORMAL: botón pequeño estilo píldora ──────────────────────────
    if (!modoSeleccion) {
      return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
          child: GestureDetector(
            onTap: onEntrarModo,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIconsBold.trash,
                    size: 20,
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "Eliminar selección",
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ── MODO SELECCIÓN: barra expandida ───────────────────────────────────
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIconsFill.checkSquare,
            size: 18,
            color: colorScheme.error,
          ),
          const SizedBox(width: 10),
          Text(
            seleccionados == 0
                ? "Toca los items a eliminar"
                : "$seleccionados de $totalItems seleccionados",
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onCancelar,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Cancelar",
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
