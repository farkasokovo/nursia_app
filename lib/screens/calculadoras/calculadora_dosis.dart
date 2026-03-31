import 'package:flutter/material.dart';
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

      child: Padding(
        padding: const EdgeInsets.only(
          top: 10,
          left: 20,
          right: 20,
          bottom: 20,
        ),

        child: Column(
          children: [
            /// DOSIS INDICADA (mg)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  style: AppTextStyles.titleBrownText.copyWith(fontSize: 25),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Dosis indicada (mg)",
                    labelStyle: AppTextStyles.bodyBrownText.copyWith(
                      color: AppColors.primaryColor,
                    ),
                    fillColor: AppColors.secondaryColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// DILUYENTE (ml)
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  style: AppTextStyles.titleBrownText.copyWith(fontSize: 25),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Diluyente (ml)",
                    labelStyle: AppTextStyles.bodyBrownText.copyWith(
                      color: AppColors.primaryColor,
                    ),
                    fillColor: AppColors.secondaryColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// PRESENTACIÓN (mg)
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  style: AppTextStyles.titleBrownText.copyWith(fontSize: 25),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Presentación del fármaco (mg)",
                    labelStyle: AppTextStyles.bodyBrownText.copyWith(
                      color: AppColors.primaryColor,
                    ),
                    fillColor: AppColors.secondaryColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // Cambia el 20 por el valor que quieras
                      ),
                      minimumSize: const Size(
                        double.infinity,
                        60,
                      ), // 👈 4. Ancho y alto infinitos
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
                      side: const BorderSide(
                        color:
                            AppColors.darkPrimaryColor, // El color que desees
                        width: 2.0, // El grosor de la línea
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // Cambia el 20 por el valor que quieras
                      ),
                      minimumSize: const Size(
                        double.infinity,
                        60,
                      ), // 👈 4. Ancho y alto infinitos
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

            /// RESULTADO
            Flexible(
              flex: 2,
              child: Container(
                width: double.infinity,

                decoration: const BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: AppRadius.defaultRadius,
                ),

                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Text("Resultado:", style: AppTextStyles.titleBrownText),

                    SizedBox(height: 8),

                    Text("-- ml", style: AppTextStyles.titleBrownTextv2),
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
