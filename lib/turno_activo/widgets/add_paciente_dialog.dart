import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:nursia_app/database/database_helper.dart';
import 'package:nursia_app/turno_activo/models/paciente.dart';

/// Muestra el diálogo flotante para registrar un nuevo paciente.
/// Llama a [onGuardado] con el objeto ya persistido en DB (con su id).
Future<void> showAddPacienteDialog(
  BuildContext context, {
  required int ordenSiguiente,
  required Function(Paciente guardado) onGuardado,
}) async {
  final nombreController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) {
      final textTheme = Theme.of(context).textTheme;
      final colorScheme = Theme.of(context).colorScheme;

      return MediaQuery(
        // Evita que el diálogo suba cuando aparece el teclado
        data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
        child: Padding(
          padding: const EdgeInsets.only(top: 90.0),
          child: Dialog(
            alignment: Alignment.topCenter,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 40,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Registrar Paciente", style: textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    "Ingresa el nombre del paciente asignado a tu turno.",
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: nombreController,
                    textCapitalization: TextCapitalization.words,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: "Nombre completo",
                      hintText: "Ej: Juan Pérez García",
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                      ),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(PhosphorIconsRegular.user),
                    ),
                    onSubmitted: (_) => _confirmar(
                      context,
                      nombreController,
                      ordenSiguiente,
                      onGuardado,
                    ),
                  ),

                  // Aquí en el futuro puedes añadir más campos:
                  // Edad, Diagnóstico, Cama, etc.
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text("Cancelar", style: textTheme.bodyMedium),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _confirmar(
                            context,
                            nombreController,
                            ordenSiguiente,
                            onGuardado,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
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

Future<void> _confirmar(
  BuildContext context,
  TextEditingController controller,
  int ordenSiguiente,
  Function(Paciente) onGuardado,
) async {
  final nombre = controller.text.trim();
  if (nombre.isEmpty) return;

  final nuevo = Paciente(nombre: nombre, orden: ordenSiguiente);
  final guardado = await DatabaseHelper.instance.insertarPacienteTurno(nuevo);
  onGuardado(guardado);
  Navigator.pop(context);
}
