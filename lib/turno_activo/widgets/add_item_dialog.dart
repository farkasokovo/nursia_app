import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// BottomSheet genérico para añadir items de texto con autocompletado.
/// Úsalo para Pendientes y Medicamentos del turno.
///
/// Llama a [onConfirm] con el texto ingresado/seleccionado.
Future<void> showAddItemDialog(
  BuildContext context, {
  required String titulo,
  required String label,
  required IconData icono,
  required List<String> sugerencias,
  required Function(String item) onConfirm,
}) async {
  // Controller para capturar el texto cuando el usuario escribe manualmente
  // (el Autocomplete maneja su propio controller interno)
  String? seleccion;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final textTheme = Theme.of(context).textTheme;
      final colorScheme = Theme.of(context).colorScheme;

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle visual
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text(titulo, style: textTheme.titleLarge),
            const SizedBox(height: 20),

            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return sugerencias.where((option) {
                  return option.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
                });
              },
              onSelected: (String value) {
                seleccion = value;
              },
              fieldViewBuilder:
                  (context, fieldController, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: fieldController,
                      focusNode: focusNode,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: label,
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(icono),
                      ),
                      onChanged: (value) => seleccion = value,
                      onSubmitted: (_) {
                        final texto = (seleccion ?? '').trim();
                        if (texto.isNotEmpty) {
                          onConfirm(texto);
                          Navigator.pop(context);
                        }
                      },
                    );
                  },
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final texto = (seleccion ?? '').trim();
                  if (texto.isNotEmpty) {
                    onConfirm(texto);
                    Navigator.pop(context);
                  }
                },
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
