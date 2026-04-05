import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';

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
  int? selectedScore;

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
              color: colorScheme.primaryContainer,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Column(
            children: widget.options.map((option) {
              final isSelected = selectedScore == option.score;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedScore = option.score;
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
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.onPrimaryContainer,
                      borderRadius: AppRadius.defaultRadius,
                      border: Border.all(
                        color: colorScheme.primaryContainer,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Checkmark cuando está seleccionado
                            if (isSelected) ...[
                              PhosphorIcon(
                                PhosphorIconsBold.check,
                                size: 25,
                                color: colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                "${option.score ?? "NV"} — ${option.label}",
                                softWrap: true,
                                style: isSelected
                                    ? textTheme.bodyLarge?.copyWith(
                                        color: colorScheme.onPrimaryContainer,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )
                                    : textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSecondaryContainer,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                              ),
                            ),
                          ],
                        ),
                        // 👇 NUEVO: Mostrar descripción si existe
                        if (option.description != null) ...[
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              option.description!,
                              style: isSelected
                                  ? textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    )
                                  : textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSecondaryContainer,
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
