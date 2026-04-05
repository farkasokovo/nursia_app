import 'package:flutter/material.dart';
import 'package:nursia_app/repositories/repositorio_escalas.dart';
import 'package:nursia_app/widgets/estructura_ver_mas_screen.dart';
import 'package:nursia_app/widgets/scale_result_footer.dart';
import '../../../widgets/scale_parameter_selector.dart';
import '../../../theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../widgets/molde_escalas_screen.dart';
import '../../../utils/scale_result_formatter.dart';

class ScaleValue {
  final int? score;
  const ScaleValue(this.score);
}

class RamsayScreen extends StatelessWidget {
  const RamsayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MoldeEscalasScreen(
      heroTag: "ramsay",
      title: "Escala de Ramsay",
      icon: PhosphorIconsFill.moon,
      scaleTab: const _RamsayLayout(),
      infoTab: const _RamsayInfo(),
    );
  }
}

class _RamsayLayout extends StatefulWidget {
  const _RamsayLayout();

  @override
  State<_RamsayLayout> createState() => _RamsayLayoutState();
}

class _RamsayLayoutState extends State<_RamsayLayout> {
  ScaleValue? sedacion;

  bool get _todoCompleto => sedacion != null;

  String get resultado {
    return ScaleResultFormatter.formatWithNV(
      parameters: {"Nivel de sedación": sedacion?.score},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  ScaleParameterSelector(
                    title: "Nivel de sedación (Ramsay)",
                    onChanged: (int? value) =>
                        setState(() => sedacion = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 1,
                        label: "Agitado/Ansioso",
                        description:
                            "Paciente agitado, ansioso o inquieto. Sedación insuficiente.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Orientado/Cooperador",
                        description:
                            "Cooperador, orientado y tranquilo. Sedación óptima.",
                      ),
                      ScaleOption(
                        score: 3,
                        label: "Somnoliento/Con respuesta a órdenes",
                        description:
                            "Somnoliento, responde solo a órdenes verbales.",
                      ),
                      ScaleOption(
                        score: 4,
                        label: "Dormido /\nRespuesta ligera a estimulos",
                        description:
                            "Con respuestas rápidas a estimulos auditivos o percusión glabelar",
                      ),
                      ScaleOption(
                        score: 5,
                        label: "Dormido /\nRespuesta lenta a estimulos",
                        description:
                            "Con respuestas lentas a estímulos auditivos fuertes o percusión glabelar.",
                      ),
                      ScaleOption(
                        score: 6,
                        label:
                            "Profundamente dormido /\nSin respuesta a estimulos",
                        description:
                            "No responde a ningún estímulo físico o auditivo.",
                      ),
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
          colorResolver: _ramsayColor,
        ),
      ],
    );
  }
}

class _RamsayInfo extends StatelessWidget {
  const _RamsayInfo();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: FutureBuilder(
            future: RepositorioEscalas.getScale("ramsay"),
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

// Colores específicos de la escala Ramsay
Color _ramsayColor(String resultado) {
  final match = RegExp(r'^\d+').firstMatch(resultado);
  if (match == null) return AppColors.withoutAlert;
  final score = int.parse(match.group(0)!);
  switch (score) {
    case 1:
      return AppColors.redAlertv1;
    case 2:
      return AppColors.greenAlert;
    case 3:
      return AppColors.withoutAlert;
    case 4:
      return AppColors.redAlertv2;
    case 5:
      return AppColors.redAlertv3;
    case 6:
      return AppColors.redAlertv4;
    default:
      return AppColors.withoutAlert;
  }
}
