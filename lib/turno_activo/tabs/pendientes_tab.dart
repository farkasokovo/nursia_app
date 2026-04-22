import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:nursia_app/turno_activo/widgets/barra_acciones.dart';

class PendientesTab extends StatelessWidget {
  final List<String> items;
  final bool modoSeleccion;
  final Set<int> seleccionados;
  final VoidCallback onEntrarModoSeleccion;
  final VoidCallback onCancelarSeleccion;
  final Function(int index) onToggleSeleccion;

  const PendientesTab({
    super.key,
    required this.items,
    required this.modoSeleccion,
    required this.seleccionados,
    required this.onEntrarModoSeleccion,
    required this.onCancelarSeleccion,
    required this.onToggleSeleccion,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIconsRegular.listChecks,
                size: 100,
                color: colorScheme.primary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 24),
              Text(
                "Tareas Pendientes",
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Control de procedimientos y cuidados pendientes por realizar.",
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        BarraAcciones(
          modoSeleccion: modoSeleccion,
          totalItems: items.length,
          seleccionados: seleccionados.length,
          onEntrarModo: onEntrarModoSeleccion,
          onCancelar: onCancelarSeleccion,
        ),
        Expanded(
          child: modoSeleccion
              ? _buildListaSeleccion(context, colorScheme, textTheme)
              : _buildListaNormal(colorScheme, textTheme),
        ),
      ],
    );
  }

  Widget _buildListaNormal(ColorScheme colorScheme, TextTheme textTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: items.map((item) {
          return Chip(
            label: Text(item),
            backgroundColor: colorScheme.primaryContainer,
            labelStyle: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListaSeleccion(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final estaSeleccionado = seleccionados.contains(index);

        return GestureDetector(
          onTap: () => onToggleSeleccion(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 56,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: estaSeleccionado
                  ? colorScheme.error.withValues(alpha: 0.15)
                  : colorScheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: estaSeleccionado
                    ? colorScheme.error
                    : colorScheme.primaryContainer,
                width: estaSeleccionado ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                _Checkbox(
                  seleccionado: estaSeleccionado,
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item,
                    style: textTheme.titleSmall?.copyWith(
                      color: estaSeleccionado ? colorScheme.error : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Checkbox circular reutilizable (privado a este archivo)
class _Checkbox extends StatelessWidget {
  final bool seleccionado;
  final ColorScheme colorScheme;

  const _Checkbox({required this.seleccionado, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: seleccionado ? colorScheme.error : Colors.transparent,
        border: Border.all(
          color: seleccionado
              ? colorScheme.error
              : colorScheme.outline.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: seleccionado
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}
