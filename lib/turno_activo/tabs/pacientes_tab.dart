import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:nursia_app/turno_activo/models/paciente_turno.dart';
import 'package:nursia_app/turno_activo/widgets/barra_acciones.dart';

class PacientesTab extends StatelessWidget {
  final List<Paciente> pacientes;
  final bool modoSeleccion;
  final Set<int> seleccionados;
  final VoidCallback onEntrarModoSeleccion;
  final VoidCallback onCancelarSeleccion;
  final Function(int index) onToggleSeleccion;
  final Function(int oldIndex, int newIndex) onReorder;

  const PacientesTab({
    super.key,
    required this.pacientes,
    required this.modoSeleccion,
    required this.seleccionados,
    required this.onEntrarModoSeleccion,
    required this.onCancelarSeleccion,
    required this.onToggleSeleccion,
    required this.onReorder,
  });

  // Altura fija compartida entre modo normal y modo selección

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Stack(
      children: [
        // ── PLACEHOLDER estático de fondo ──────────────────────────────────
        if (pacientes.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIconsRegular.users,
                    size: 100,
                    color: colorScheme.primary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Mis Pacientes",
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Aquí podrás gestionar la lista de pacientes asignados a tu servicio durante este turno.",
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

        // ── LISTA ──────────────────────────────────────────────────────────
        if (pacientes.isNotEmpty)
          Column(
            children: [
              BarraAcciones(
                modoSeleccion: modoSeleccion,
                totalItems: pacientes.length,
                seleccionados: seleccionados.length,
                onEntrarModo: onEntrarModoSeleccion,
                onCancelar: onCancelarSeleccion,
              ),
              Expanded(
                child: modoSeleccion
                    ? _buildListaSeleccion(context, colorScheme, textTheme)
                    : _buildListaNormal(context, theme, colorScheme, textTheme),
              ),
            ],
          ),
      ],
    );
  }

  // ── LISTA EN MODO SELECCIÓN ──────────────────────────────────────────────
  Widget _buildListaSeleccion(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: pacientes.length,
      itemBuilder: (context, index) {
        final paciente = pacientes[index];
        final estaSeleccionado = seleccionados.contains(index);

        return GestureDetector(
          onTap: () => onToggleSeleccion(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                // Checkbox circular
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: estaSeleccionado
                        ? colorScheme.error
                        : Colors.transparent,
                    border: Border.all(
                      color: estaSeleccionado
                          ? colorScheme.error
                          : colorScheme.outline.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: estaSeleccionado
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),

                // Avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: estaSeleccionado
                      ? colorScheme.error.withValues(alpha: 0.2)
                      : colorScheme.primaryContainer,
                  child: Icon(
                    PhosphorIconsBold.user,
                    size: 18,
                    color: estaSeleccionado
                        ? colorScheme.error
                        : colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),

                // Nombre
                Expanded(
                  child: Text(
                    paciente.nombre,
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

  // ── LISTA EN MODO NORMAL (reordenable) ──────────────────────────────────
  Widget _buildListaNormal(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: pacientes.length,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final double scale = lerpDouble(1.0, 0.92, animation.value)!;
            return Transform.scale(
              scale: scale,
              child: Theme(
                data: theme.copyWith(
                  colorScheme: colorScheme.copyWith(
                    primary: colorScheme.primaryContainer,
                  ),
                ),
                child: child!,
              ),
            );
          },
          child: child,
        );
      },
      onReorder: onReorder,
      itemBuilder: (context, index) {
        final paciente = pacientes[index];
        final itemKey = ValueKey(paciente.nombre + index.toString());

        return SizedBox(
          key: itemKey,

          child: Card(
            color: colorScheme.primary,
            margin: const EdgeInsets.only(bottom: 10),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: colorScheme.onPrimary.withValues(
                      alpha: 0.2,
                    ),
                    child: Icon(
                      PhosphorIconsBold.user,
                      size: 18,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      paciente.nombre,
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    PhosphorIconsBold.dotsSixVertical,
                    color: colorScheme.onPrimary.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
