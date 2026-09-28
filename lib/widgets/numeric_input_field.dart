// lib/widgets/numeric_input_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// Regex estático compartido — se compila una sola vez para toda la app
final _decimalRegex = RegExp(r'^\d*\.?\d*');

/// Convierte la coma en punto ANTES de que actúe el filtro decimal.
///
/// En un teclado numérico en español la tecla decimal puede ser coma. Sin esta
/// normalización el filtro de abajo conserva solo el prefijo válido y descarta
/// la coma junto con todo lo que venga después: "37,5" quedaba en "37" y
/// "2,5" en "2", sin marca de error y con un número que sigue siendo válido.
/// En la escala de signos vitales eso da una interpretación equivocada; en la
/// calculadora de dosis es un error de dosificación silencioso.
///
/// Solo se aplica cuando el campo acepta decimales. Con `allowDecimal: false`
/// la coma se sigue descartando, que es lo correcto: ahí no hay separador
/// decimal que valga.
class _ComaAPunto extends TextInputFormatter {
  const _ComaAPunto();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue anterior,
    TextEditingValue nuevo,
  ) {
    if (!nuevo.text.contains(',')) return nuevo;
    // replaceAll no cambia el largo del texto, así que la posición del cursor
    // que trae `nuevo` sigue siendo válida.
    return TextEditingValue(
      text: nuevo.text.replaceAll(',', '.'),
      selection: nuevo.selection,
      composing: TextRange.empty,
    );
  }
}

class NumericInputField extends StatelessWidget {
  /// Título grande arriba del campo: dice QUÉ dato se pide.
  final String label;

  /// Label flotante dentro del campo: dice CÓMO llenarlo.
  ///
  /// Sube y se encoge al enfocar el campo, y sigue visible mientras se escribe
  /// (a diferencia del hint anterior, que desaparecía con la primera tecla).
  /// Debe ser corto: al flotar ocupa el hueco del borde superior.
  final String? textoAyuda;

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
    this.textoAyuda,
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
              color: colorScheme.onSurface,
              //! TAMAÑO DE LOS TÍTULOS
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Sin SizedBox de altura fija: el campo se mide solo. Con altura fija de
        // 50 el label flotante y el texto de 25 px no caben juntos y se recortan.
        TextField(
          controller: controller,
          focusNode: focusNode,
          // Centra el número dentro del área de contenido. Con el padding
          // vertical ya recortado, es lo que evita que el texto quede pegado a
          // un borde y que el label flotante lo alcance.
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
          textAlign: TextAlign.center,
          enableInteractiveSelection: false,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            //! TAMAÑO DEL INPUT
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
          inputFormatters: [
            // El orden importa: la coma se normaliza antes de filtrar.
            if (allowDecimal) const _ComaAPunto(),
            allowDecimal
                ? FilteringTextInputFormatter.allow(_decimalRegex)
                : FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(maxLength),
          ],
          decoration: InputDecoration(
            // Label flotante en vez de hint: permanece visible al escribir.
            labelText: textoAyuda ?? "Ingresa un valor",
            // Estilo del label cuando está en reposo (dentro del campo, como el
            // hint de antes).
            labelStyle: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSecondaryContainer.withValues(alpha: 0.40),
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            // Estilo al flotar. Flutter lo encoge a 75% (18 -> 13.5), y aquí se
            // sube el contraste porque queda sobre el borde, no sobre el relleno.
            floatingLabelStyle: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),

            // El label flota al centro del borde superior. Con el radio de 30
            // del tema, al inicio caería encima de la curva de la esquina.
            filled: true,
            fillColor: colorScheme.secondary,
            // 1. Borde por defecto (cuando no tiene focus)
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.defaultRadius,
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                width: 2,
              ),
            ),

            // 2. Borde cuando tiene el focus (clicado)
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.defaultRadius,
              borderSide: BorderSide(
                color: colorScheme.onSurface, // Color más intenso
                width: 2.5, // Un poco más grueso para resaltar
              ),
            ),

            // Mantener el esquema base por si acaso (errores, etc)
            border: const OutlineInputBorder(
              borderRadius: AppRadius.defaultRadius,
            ),

            // Vertical 6: el campo queda en 50 px de alto (38 del texto de
            // 25 px + 12 de padding), contra los 66 de antes. Sigue por encima
            // del mínimo cómodo para el pulgar (48 px) y el label flotante no
            // se toca con el número porque flota sobre el borde, fuera del área
            // de contenido.
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 6,
            ),
          ),
        ),
      ],
    );
  }
}
