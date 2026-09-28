import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';
import '../theme/theme_colors.dart';

class ScaleOption {
  final String label;
  final int? score;
  final String? description; // 👈 NUEVO: descripción clínica opcional

  const ScaleOption({
    required this.label,
    required this.score,
    this.description,
  });
}

class ScaleParameterSelector extends StatefulWidget {
  final String title;
  final List<ScaleOption> options;
  final Function(int?) onChanged;

  const ScaleParameterSelector({
    super.key,
    required this.title,
    required this.options,
    required this.onChanged,
  });

  @override
  State<ScaleParameterSelector> createState() => _ScaleParameterSelectorState();
}

class _ScaleParameterSelectorState extends State<ScaleParameterSelector> {
  // Se rastrea por ÍNDICE (no por score) para soportar escalas como MEWS donde
  // dos rangos distintos de un mismo parámetro comparten puntaje (ej. FC <40 y
  // 111-129 = 2 pts). Rastrear por score iluminaría ambas opciones a la vez.
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: AppRadius.defaultRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.title,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Column(
            children: widget.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = selectedIndex == index;

              // El chip y su contenido se invierten entre sí. En claro el
              // seleccionado es el OSCURO; en oscuro es el CLARO.
              //
              // No es un descuido: en claro seleccionado y sin seleccionar se
              // separan por 7.54 de contraste y la selección se ve de un
              // vistazo. Si en oscuro los dos fueran oscuros se separarían por
              // 1.10 y solo los distinguiría el borde. Son escalas clínicas
              // que se leen con prisa, así que la separación pesa más que
              // conservar cuál de los dos es el oscuro.
              //
              // `onSecondaryContainer` no aparece aquí porque en oscuro YA es
              // ink2, que es justo el valor que le toca al texto del chip sin
              // seleccionar.
              final fondoChip = isSelected
                  ? ThemeColors.segunTema(
                      context,
                      claro: colorScheme.primaryContainer,
                      oscuro: AppColorsDark.ink2,
                    )
                  : ThemeColors.segunTema(
                      context,
                      claro: colorScheme.onPrimaryContainer,
                      oscuro: AppColorsDark.ruleSoft,
                    );
              final sobreChip = isSelected
                  ? ThemeColors.segunTema(
                      context,
                      claro: colorScheme.onPrimaryContainer,
                      oscuro: AppColorsDark.accentOn,
                    )
                  : colorScheme.onSecondaryContainer;
              final fondoInsignia = isSelected
                  ? ThemeColors.segunTema(
                      context,
                      claro: colorScheme.onPrimaryContainer,
                      oscuro: AppColorsDark.accentOn,
                    )
                  : ThemeColors.segunTema(
                      context,
                      claro: colorScheme.primaryContainer,
                      oscuro: AppColorsDark.ink2,
                    );
              final sobreInsignia = isSelected
                  ? ThemeColors.segunTema(
                      context,
                      claro: colorScheme.onSurface,
                      oscuro: AppColorsDark.ink2,
                    )
                  : ThemeColors.segunTema(
                      context,
                      claro: colorScheme.onPrimaryContainer,
                      oscuro: AppColorsDark.accentOn,
                    );

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                      widget.onChanged(option.score);
                    });
                  },
                  borderRadius: AppRadius.defaultRadius,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: fondoChip,
                      borderRadius: AppRadius.defaultRadius,
                      border: Border.all(
                        color: colorScheme.onSurface,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Insignia con el valor (puntaje) del ítem. Va en un
                            // recuadro con color invertido respecto al chip, para
                            // que el número resalte y NO se confunda con los
                            // números de la etiqueta (ej. rangos de MEWS). Esto
                            // reemplaza al antiguo "valor — etiqueta".
                            Container(
                              constraints: const BoxConstraints(minWidth: 36),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: fondoInsignia,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "${option.score ?? "NV"}",
                                textAlign: TextAlign.center,
                                style: textTheme.titleMedium?.copyWith(
                                  color: sobreInsignia,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                option.label,
                                softWrap: true,
                                style: isSelected
                                    ? textTheme.bodyLarge?.copyWith(
                                        color: sobreChip,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )
                                    : textTheme.bodyMedium?.copyWith(
                                        color: sobreChip,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                              ),
                            ),
                            // Palomita a la derecha cuando está seleccionado.
                            if (isSelected) ...[
                              const SizedBox(width: 10),
                              PhosphorIcon(
                                PhosphorIconsBold.checkCircle,
                                size: 24,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ],
                          ],
                        ),
                        // Descripción clínica opcional, alineada bajo la etiqueta
                        // (indentada el ancho de la insignia + separación).
                        if (option.description != null) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 50),
                            child: Text(
                              option.description!,
                              style: textTheme.bodySmall?.copyWith(
                                color: sobreChip,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
