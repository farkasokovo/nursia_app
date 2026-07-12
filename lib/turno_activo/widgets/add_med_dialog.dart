import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:nursia_app/repositories/medicamento_turno_repository.dart';
import 'package:nursia_app/turno_activo/models/medicamento_turno.dart';
import 'package:nursia_app/utils/icon_mapper.dart'; // Tu IconMapper de lib/utils

// Modelo liviano sólo para el catálogo en memoria
class _MedCatalogEntry {
  final String nombre;
  final String icono;
  const _MedCatalogEntry({required this.nombre, required this.icono});
}

Future<void> showAddMedicamentoTurnoDialog(
  BuildContext context, {
  required int ordenSiguiente,
  required Function(MedicamentoTurno guardado) onGuardado,
}) async {
  final medicamentoTurnoRepo = context.read<MedicamentoTurnoRepository>();

  // Cargamos el catálogo desde assets
  final response = await rootBundle.loadString('assets/data/medicamentos.json');
  final data = json.decode(response) as List<dynamic>;
  final catalogo = data
      .map(
        (m) => _MedCatalogEntry(
          nombre: m['nombre'] as String,
          icono: m['icono'] as String,
        ),
      )
      .toList();

  if (!context.mounted) return;

  await showDialog(
    context: context,
    builder: (context) {
      final textTheme = Theme.of(context).textTheme;
      final colorScheme = Theme.of(context).colorScheme;

      _MedCatalogEntry? seleccionTemporal;

      return MediaQuery(
        data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
        child: Padding(
          padding: const EdgeInsets.only(top: 90.0),
          child: Dialog(
            alignment: Alignment.topCenter,
            insetPadding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Título ──────────────────────────────────────────────────
                  Text("Añadir Medicamento", style: textTheme.titleMedium),

                  const SizedBox(height: 6),

                  Text(
                    "Busca y selecciona un fármaco para agregar al turno.",
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Autocomplete ────────────────────────────────────────────
                  Autocomplete<_MedCatalogEntry>(
                    displayStringForOption: (option) => option.nombre,

                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable.empty();
                      }
                      return catalogo.where(
                        (m) => m.nombre.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        ),
                      );
                    },

                    onSelected: (selection) {
                      seleccionTemporal = selection;
                    },

                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            autofocus: true,
                            decoration: InputDecoration(
                              labelText: "Buscar fármaco",
                              hintText: "Ej: Amoxicilina",
                              hintStyle: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(
                                PhosphorIconsRegular.magnifyingGlass,
                              ),
                            ),
                          );
                        },

                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 96,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return ListTile(
                                  leading: Icon(
                                    IconMapper.fromString(option.icono),
                                  ),
                                  title: Text(option.nombre),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Botones ─────────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: colorScheme.outline),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Cancelar",
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (seleccionTemporal != null) {
                              final nuevo = MedicamentoTurno(
                                nombre: seleccionTemporal!.nombre,
                                icono: seleccionTemporal!.icono,
                                orden: ordenSiguiente,
                              );

                              final guardado = await medicamentoTurnoRepo
                                  .insertar(nuevo);

                              onGuardado(guardado);

                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Confirmar",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
