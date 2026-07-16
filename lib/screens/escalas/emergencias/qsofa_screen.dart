import 'package:flutter/material.dart';
import 'package:nursia_app/repositories/escala_repository.dart';
import 'package:nursia_app/widgets/estructura_ver_mas_screen.dart';
import 'package:nursia_app/widgets/scale_result_footer.dart';
import 'package:provider/provider.dart';
import '../../../widgets/scale_parameter_selector.dart';
import '../../../theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../widgets/molde_escalas_screen.dart';
import '../../../utils/scale_result_formatter.dart';

class ScaleValue {
  final int? score;
  const ScaleValue(this.score);
}

class QsofaScreen extends StatelessWidget {
  const QsofaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MoldeEscalasScreen(
      heroTag: "qsofa",
      title: "qSOFA",
      icon: PhosphorIconsFill.virus,
      scaleTab: const _QsofaLayout(),
      infoTab: const _QsofaInfo(),
    );
  }
}

class _QsofaLayout extends StatefulWidget {
  const _QsofaLayout();

  @override
  State<_QsofaLayout> createState() => _QsofaLayoutState();
}

class _QsofaLayoutState extends State<_QsofaLayout> {
  ScaleValue? respiratoria;
  ScaleValue? mental;
  ScaleValue? sistolica;

  bool get _todoCompleto =>
      respiratoria != null && mental != null && sistolica != null;

  int get _puntajeTotal {
    int total = 0;
    total += respiratoria?.score ?? 0;
    total += mental?.score ?? 0;
    total += sistolica?.score ?? 0;
    return total;
  }

  String get resultado {
    return ScaleResultFormatter.formatWithNV(
      parameters: {
        "Frecuencia respiratoria ≥ 22": respiratoria?.score,
        "Alteración del estado mental": mental?.score,
        "PAS ≤ 100 mmHg": sistolica?.score,
      },
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

                  // ================== FRECUENCIA RESPIRATORIA ==================
                  ScaleParameterSelector(
                    title: "Frecuencia respiratoria ≥ 22 rpm",
                    onChanged: (int? value) =>
                        setState(() => respiratoria = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 1,
                        label: "Sí",
                        description: "Taquipnea de 22 respiraciones por minuto o más.",
                      ),
                      ScaleOption(
                        score: 0,
                        label: "No",
                        description: "Frecuencia respiratoria menor de 22 rpm.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== ESTADO MENTAL ==================
                  ScaleParameterSelector(
                    title: "Alteración del estado mental",
                    onChanged: (int? value) =>
                        setState(() => mental = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 1,
                        label: "Sí",
                        description:
                            "Glasgow < 15 respecto al basal del paciente.",
                      ),
                      ScaleOption(
                        score: 0,
                        label: "No",
                        description: "Paciente alerta y orientado (Glasgow 15).",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== PRESIÓN ARTERIAL SISTÓLICA ==================
                  ScaleParameterSelector(
                    title: "PAS ≤ 100 mmHg",
                    onChanged: (int? value) =>
                        setState(() => sistolica = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 1,
                        label: "Sí",
                        description:
                            "Presión arterial sistólica de 100 mmHg o menos.",
                      ),
                      ScaleOption(
                        score: 0,
                        label: "No",
                        description: "Presión arterial sistólica mayor de 100 mmHg.",
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
          colorResolver: (resultado) => _qsofaColor(_puntajeTotal),
        ),
      ],
    );
  }
}

class _QsofaInfo extends StatelessWidget {
  const _QsofaInfo();

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
            future: context.read<EscalaRepository>().obtenerPorId("qsofa"),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || snapshot.data == null) {
                return Center(
                  child: Text(
                    "No se pudo cargar la información de esta escala.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                );
              }
              return EstructuraVerMasScreen(info: snapshot.data!);
            },
          ),
        ),
      ),
    );
  }
}

// Colores específicos de la escala qSOFA
Color _qsofaColor(int puntajeTotal) {
  if (puntajeTotal >= 2) return AppColors.redAlertv3; // Alto riesgo
  return AppColors.withoutAlert; // Bajo riesgo
}
