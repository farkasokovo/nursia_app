import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:nursia_app/repositories/pendiente_turno_repository.dart';
import 'package:nursia_app/turno_activo/models/pendiente_turno.dart';
import 'package:nursia_app/turno_activo/utils/icon_mapper_turno.dart';
import 'package:nursia_app/utils/search_utils.dart';

/// Filtra y ordena `catalogo` por relevancia respecto a `consultaCruda`,
/// usando la misma lógica de ranking que las pantallas principales
/// (lib/widgets/searchable_screen.dart): coincidencia al inicio del nombre
/// primero, luego coincidencias parciales, con desempate alfabético.
Iterable<T> _ordenarPorRelevancia<T>(
  List<T> catalogo,
  String Function(T item) campo,
  String consultaCruda,
) {
  final consulta = normalizar(consultaCruda);
  final conRank = <({T item, int rank})>[];
  for (final item in catalogo) {
    final rank = rankearCampo(normalizar(campo(item)), consulta);
    if (rank != null) conRank.add((item: item, rank: rank));
  }
  conRank.sort((a, b) {
    final porRank = a.rank.compareTo(b.rank);
    if (porRank != 0) return porRank;
    return normalizar(campo(a.item)).compareTo(normalizar(campo(b.item)));
  });
  return conRank.map((e) => e.item);
}

Future<void> showAddPendienteDialog(
  BuildContext context, {
  required int ordenSiguiente,
  required Function(PendienteInfo guardado) onGuardado,
}) async {
  final pendienteTurnoRepo = context.read<PendienteTurnoRepository>();
  // Obtenemos el catálogo ya cargado en DB
  final catalogo = await pendienteTurnoRepo.obtenerCatalogo();

  if (!context.mounted) return;

  await showDialog(
    context: context,
    builder: (context) {
      final textTheme = Theme.of(context).textTheme;
      final colorScheme = Theme.of(context).colorScheme;

      PendienteInfo? seleccionTemporal;

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
                  Text("Añadir Pendiente", style: textTheme.titleMedium),

                  const SizedBox(height: 6),

                  Text(
                    "Busca y selecciona una tarea o procedimiento para agregar a tu lista.",
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Autocomplete<PendienteInfo>(
                    displayStringForOption: (option) => option.nombre,

                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable.empty();
                      }

                      return _ordenarPorRelevancia(
                        catalogo,
                        (p) => p.nombre,
                        textEditingValue.text,
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
                              labelText: "Buscar tarea",
                              hintText: "Ej: Baño de esponja",

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
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 280),
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
                                      IconMapper.getIcon(option.icono),
                                    ),
                                    title: Text(option.nombre),
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

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
                              // 🔧 CORRECCIÓN: ya no usamos el id del catálogo
                              final nuevo = PendienteInfo(
                                nombre: seleccionTemporal!.nombre,
                                icono: seleccionTemporal!.icono,
                                orden: ordenSiguiente,
                              );

                              final guardado = await pendienteTurnoRepo
                                  .insertarActivo(nuevo);

                              onGuardado(guardado);

                              if (context.mounted) {
                                Navigator.pop(context);
                              }
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
