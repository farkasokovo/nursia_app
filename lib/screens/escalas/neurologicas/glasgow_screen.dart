import 'package:flutter/material.dart';
import 'package:nursia_app/widgets/scale_result_footer.dart';
import '../../../widgets/scale_parameter_selector.dart';
import '../../../theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../widgets/scale_screen_template.dart';
import '../../../utils/scale_result_formatter.dart';

// 👇 Wrapper para distinguir "sin selección" de "No valorable"
class ScaleValue {
  final int? score;
  const ScaleValue(this.score);
}

class GlasgowScreen extends StatelessWidget {
  const GlasgowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaleScreenTemplate(
      heroTag: "glasgow",
      title: "Escala de Glasgow",
      icon: PhosphorIconsFill.brain,
      scaleTab: const _GlasgowLayout(),
      infoTab: const _GlasgowInfo(),
    );
  }
}

class _GlasgowLayout extends StatefulWidget {
  const _GlasgowLayout();

  @override
  State<_GlasgowLayout> createState() => _GlasgowLayoutState();
}

class _GlasgowLayoutState extends State<_GlasgowLayout> {
  ScaleValue? ocular;
  ScaleValue? verbal;
  ScaleValue? motora;

  bool get _todoCompleto => ocular != null && verbal != null && motora != null;

  String get resultado {
    return ScaleResultFormatter.formatWithNV(
      parameters: {
        "Respuesta ocular": ocular?.score,
        "Respuesta verbal": verbal?.score,
        "Respuesta motora": motora?.score,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // 👈 Column en lugar de Stack
      children: [
        Expanded(
          // 👈 El scroll ocupa todo el espacio disponible
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  ScaleParameterSelector(
                    title: "Respuesta ocular",
                    onChanged: (int? value) =>
                        setState(() => ocular = ScaleValue(value)),
                    options: const [
                      ScaleOption(score: 4, label: "Espontánea"),
                      ScaleOption(score: 3, label: "Al orden verbal"),
                      ScaleOption(score: 2, label: "Al dolor"),
                      ScaleOption(score: 1, label: "Sin respuesta"),
                      ScaleOption(score: null, label: "No valorable"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ScaleParameterSelector(
                    title: "Respuesta verbal",
                    onChanged: (int? value) =>
                        setState(() => verbal = ScaleValue(value)),
                    options: const [
                      ScaleOption(score: 5, label: "Orientado"),
                      ScaleOption(score: 4, label: "Confuso"),
                      ScaleOption(score: 3, label: "Palabras inapropiadas"),
                      ScaleOption(score: 2, label: "Sonidos incomprensibles"),
                      ScaleOption(score: 1, label: "Sin respuesta"),
                      ScaleOption(score: null, label: "No valorable"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ScaleParameterSelector(
                    title: "Respuesta motora",
                    onChanged: (int? value) =>
                        setState(() => motora = ScaleValue(value)),
                    options: const [
                      ScaleOption(score: 6, label: "Obedece órdenes"),
                      ScaleOption(
                        score: 5,
                        label: "Localiza estímulo doloroso",
                      ),
                      ScaleOption(score: 4, label: "Retirada al dolor"),
                      ScaleOption(score: 3, label: "Flexión anormal"),
                      ScaleOption(score: 2, label: "Extensión anormal"),
                      ScaleOption(score: 1, label: "Sin respuesta"),
                      ScaleOption(score: null, label: "No valorable"),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),

        ScaleResultFooter(
          visible: _todoCompleto,
          resultado: resultado,
          colorResolver: _glasgowColor,
        ),
      ],
    );
  }
}

class _ResultFooter extends StatelessWidget {
  final String resultado;

  const _ResultFooter({required this.resultado});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.2,
      maxChildSize: 0.5,
      snap: true,
      snapSizes: const [0.2, 0.5],
      builder: (context, scrollController) {
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.darkPrimaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Resultado:",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.titleBrownTextv0,
                      ),
                      Text(
                        resultado,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.titleBrownTextv2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlasgowInfo extends StatelessWidget {
  const _GlasgowInfo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: const Text(
            "Aquí podrás colocar información clínica "
            "sobre la escala Glasgow:\n\n"
            "• Interpretación\n"
            "• Indicaciones\n"
            "• Limitaciones\n"
            "• Uso en paciente intubado\n"
            "• Valores críticos",
          ),
        ),
      ),
    );
  }
}

// COLORES DEPENDIENDO DE LOS RESULTADOS OBTENIDOS EN LA ESCALA

Color _glasgowColor(String resultado) {
  final score = int.tryParse(resultado);
  if (score == null) return AppColors.withoutAlert; // NV — gris neutro
  if (score == 15) return AppColors.greenAlert; // Leve — verde
  if (score >= 13) return AppColors.withoutAlert; // Leve — verde
  if (score >= 9) return AppColors.redAlertv1; // Moderado — amarillo
  if (score >= 3) return AppColors.redAlertv3;
  return AppColors.redAlertv3; // Grave — rojo
}
