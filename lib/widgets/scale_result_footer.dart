import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScaleResultFooter extends StatelessWidget {
  final bool visible;
  final String resultado;
  final Color Function(String resultado)?
  colorResolver; // 👈 Opcional, por si alguna escala no necesita colores

  const ScaleResultFooter({
    super.key,
    required this.visible,
    required this.resultado,
    this.colorResolver,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible)
      return const SizedBox.shrink(); // 👈 Si no es visible, no ocupa espacio

    final esNumero = int.tryParse(resultado) != null; // 👈
    final colorResultado = colorResolver?.call(resultado);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Resultado:",
            textAlign: TextAlign.center,
            style: AppTextStyles.titleBrownTextv2,
          ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color:
                  colorResultado ??
                  Colors.transparent, // 👈 Sin color si no hay resolver
              borderRadius: BorderRadius.circular(40),
            ),
            child: Text(
              resultado,
              textAlign: TextAlign.center,
              softWrap: true,
              style: esNumero
                  ? AppTextStyles.titleWhiteText.copyWith(
                      fontSize: 60,
                    ) // 👈 Número grande y llamativo
                  : AppTextStyles.titleWhiteText.copyWith(
                      fontSize: 22,
                    ), // 👈 Texto más pequeño para la respuesta larga
            ),
          ),
        ],
      ),
    );
  }
}
