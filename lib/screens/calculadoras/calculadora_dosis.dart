import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/expandable_category_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/app_theme.dart';

class CalculadoraDosis extends StatelessWidget {
  const CalculadoraDosis({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpandableCategoryScreen(
      heroTag: "dosis",
      title: "Calculadora de dosis",
      icon: PhosphorIconsFill.syringe,
      child: const _CalculadoraDosisLayout(),
    );
  }
}

class _CalculadoraDosisLayout extends StatefulWidget {
  const _CalculadoraDosisLayout();

  @override
  State<_CalculadoraDosisLayout> createState() =>
      _CalculadoraDosisLayoutState();
}

class _CalculadoraDosisLayoutState extends State<_CalculadoraDosisLayout> {
  final dosisController = TextEditingController();
  final dilucionController = TextEditingController();
  final presentacionController = TextEditingController();

  double? resultado;

  void calcular() {
    final dosis = double.tryParse(dosisController.text);
    final dilucion = double.tryParse(dilucionController.text);
    final presentacion = double.tryParse(presentacionController.text);

    if (dosis == null ||
        dilucion == null ||
        presentacion == null ||
        presentacion == 0) {
      setState(() => resultado = null);
      return;
    }

    setState(() {
      resultado = (dosis * dilucion) / presentacion;
    });
  }

  void limpiar() {
    dosisController.clear();
    dilucionController.clear();
    presentacionController.clear();

    setState(() => resultado = null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),

      child: SingleChildScrollView(
        child: Column(
          children: [
            _DoseInputField(
              label: "Dosis indicada (mg)",
              controller: dosisController,
              maxLength: 4,
            ),

            const SizedBox(height: 20),

            _DoseInputField(
              label: "Diluyente (ml)",
              controller: dilucionController,
              maxLength: 3,
            ),

            const SizedBox(height: 20),

            _DoseInputField(
              label: "Presentación del fármaco (mg)",
              controller: presentacionController,
              maxLength: 4,
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      overlayColor: AppColors.darkPrimaryColor,
                      minimumSize: const Size(double.infinity, 60),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.defaultRadius,
                      ),
                    ),
                    onPressed: calcular,
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
                    style: OutlinedButton.styleFrom(
                      overlayColor: AppColors.darkPrimaryColor,
                      minimumSize: const Size(double.infinity, 60),

                      side: const BorderSide(
                        color: AppColors.darkPrimaryColor,
                        width: 2,
                      ),

                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.defaultRadius,
                      ),
                    ),
                    onPressed: limpiar,
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
                  children: [
                    const Text(
                      "Cantidad a administrar:",
                      style: AppTextStyles.titleBrownTextv0,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      resultado == null
                          ? "0 ml"
                          : "${resultado!.toStringAsFixed(1)} ml",

                      style: AppTextStyles.titleBrownTextv3,
                    ),
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

class _DoseInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLength;

  const _DoseInputField({
    required this.label,
    required this.controller,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Alinea la leyenda a la izquierda
        children: [
          // LEYENDA SUPERIOR
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(label, style: AppTextStyles.titleBrownTextv0),
          ),
          // CAMPO DE TEXTO
          SizedBox(
            height: 50,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              style: AppTextStyles.titleBrownText.copyWith(fontSize: 25),
              enableInteractiveSelection: false,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
