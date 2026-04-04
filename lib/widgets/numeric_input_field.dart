// lib/widgets/numeric_input_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// Regex estático compartido — se compila una sola vez para toda la app
final _decimalRegex = RegExp(r'^\d*\.?\d*');

class NumericInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final int maxLength;
  // Si es true acepta decimales (ej: dosis en mg), si es false solo enteros (ej: porcentajes)
  final bool allowDecimal;

  const NumericInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.maxLength,
    this.focusNode,
    this.allowDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            label,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primaryContainer,
              //! TAMAÑO DE LOS TÍTULOS
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: TextField(
            textAlignVertical: const TextAlignVertical(y: -0.8),
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.numberWithOptions(
              decimal: allowDecimal,
            ),
            textAlign: TextAlign.center,
            enableInteractiveSelection: false,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primaryContainer,
              //! TAMAÑO DEL INPUT
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
            inputFormatters: [
              allowDecimal
                  ? FilteringTextInputFormatter.allow(_decimalRegex)
                  : FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(maxLength),
            ],
            decoration: InputDecoration(
              hintText: "Ingresa un valor",
              hintStyle: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSecondaryContainer.withValues(alpha: 0.40),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),

              floatingLabelAlignment: FloatingLabelAlignment.start,
              filled: true,
              fillColor: colorScheme.secondary,
              border: const OutlineInputBorder(
                borderRadius: AppRadius.defaultRadius,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }
}
