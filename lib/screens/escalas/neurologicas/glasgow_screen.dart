import 'package:flutter/material.dart';
import 'package:nursia_app/repositories/repositorio_escalas.dart';
import 'package:nursia_app/widgets/estructura_ver_mas_screen.dart';
import 'package:nursia_app/widgets/scale_result_footer.dart';
import '../../../widgets/scale_parameter_selector.dart';
import '../../../theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../widgets/molde_escalas_screen.dart';
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
    return MoldeEscalasScreen(
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
          child: FutureBuilder(
            future: RepositorioEscalas.getScale("glasgow"),

            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return EstructuraVerMasScreen(info: snapshot.data!);
            },
          ),
        ),
      ),
    );
  }
}

// COLORES DEPENDIENDO DE LOS RESULTADOS OBTENIDOS EN LA ESCALA

Color _glasgowColor(String resultado) {
  final match = RegExp(r'^\d+').firstMatch(resultado);

  if (match == null) {
    return AppColors.withoutAlert; // NV u otro texto
  }

  final score = int.parse(match.group(0)!);

  if (score == 15) return AppColors.greenAlert;

  if (score >= 13) return AppColors.withoutAlert;

  if (score >= 9) return AppColors.redAlertv1;

  return AppColors.redAlertv3;
}
