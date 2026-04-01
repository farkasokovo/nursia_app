import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';

class ScaleOption {
  final String label;
  final int? score;

  const ScaleOption({required this.label, required this.score});
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
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: const BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: AppRadius.defaultRadius,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          Text(
            widget.title,
            style: AppTextStyles.titleBrownText,
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
                  // ANIMACIÓN DEL BOTÓN
                  borderRadius: AppRadius.defaultRadius,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.darkPrimaryColor
                          : AppColors.lightSecondaryColor,
                      borderRadius: AppRadius.defaultRadius,
                      border: Border.all(
                        color: AppColors.darkPrimaryColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Checkmark cuando está seleccionado
                        if (isSelected) ...[
                          PhosphorIcon(
                            PhosphorIconsBold.check,
                            size: 25,
                            color: AppColors.secondaryColor,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            "${option.score ?? "NV"} — ${option.label}",
                            softWrap: true,
                            style: isSelected
                                ? AppTextStyles.bodyLightWhiteText
                                : AppTextStyles.bodyDarkBrownText,
                          ),
                        ),
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
