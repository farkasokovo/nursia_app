import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/expandable_category_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/app_theme.dart';

class CalculadoraSoluciones extends StatelessWidget {
  const CalculadoraSoluciones({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableCategoryScreen(
      heroTag: "soluciones",
      title: "Soluciones glucosadas",
      icon: PhosphorIconsFill.drop,
      child: _CalculadoraSolucionesLayout(),
    );
  }
}

class _CalculadoraSolucionesLayout extends StatelessWidget {
  const _CalculadoraSolucionesLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),

      child: SingleChildScrollView(
        child: Column(
          children: [
            const _SolutionInputField(
              label: "Glucosada indicada (ml)",
              maxLength: 4,
            ),

            const SizedBox(height: 20),

            const _SolutionInputField(
              label: "Glucosada indicada (%)",
              maxLength: 2,
            ),

            const SizedBox(height: 20),

            const _SolutionInputField(
              label: "Glucosada disponible (%)",
              maxLength: 2,
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},

                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.defaultRadius,
                      ),
                    ),

                    child: Text(
                      "Calcular",
                      style: AppTextStyles.titleWhiteText.copyWith(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},

                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),

                      side: const BorderSide(
                        color: AppColors.darkPrimaryColor,
                        width: 2,
                      ),

                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.defaultRadius,
                      ),
                    ),

                    child: Text(
                      "Limpiar",
                      style: AppTextStyles.titleBrownText.copyWith(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 180),

              child: Container(
                width: double.infinity,

                decoration: const BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: AppRadius.defaultRadius,
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: const [
                    Text("Resultado:", style: AppTextStyles.titleBrownTextv0),

                    SizedBox(height: 8),

                    Text("0", style: AppTextStyles.titleBrownTextv3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SolutionInputField extends StatelessWidget {
  final String label;
  final int maxLength;

  const _SolutionInputField({required this.label, required this.maxLength});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),

          child: Text(label, style: AppTextStyles.titleBrownTextv0),
        ),

        SizedBox(
          height: 50, //! DICTAMINA LA SEPARACIÓN ENTRE TEXTFIELDS

          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: false),

            textAlign: TextAlign.center,

            style: AppTextStyles.titleBrownText.copyWith(fontSize: 25),

            enableInteractiveSelection: false,

            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,

              LengthLimitingTextInputFormatter(maxLength),
            ],

            decoration: InputDecoration(
              hintText: label,

              hintStyle: AppTextStyles.bodyBrownText,

              filled: true,

              fillColor: AppColors.secondaryColor,

              border: OutlineInputBorder(
                borderRadius: AppRadius.defaultRadius,
                borderSide: BorderSide.none,
              ),

              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}
