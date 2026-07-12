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

class DowntonScreen extends StatelessWidget {
  const DowntonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MoldeEscalasScreen(
      heroTag: "downton",
      title: "Escala de Downton",
      icon: PhosphorIconsFill.boot,
      scaleTab: const _DowntonLayout(),
      infoTab: const _DowntonInfo(),
    );
  }
}

class _DowntonLayout extends StatefulWidget {
  const _DowntonLayout();

  @override
  State<_DowntonLayout> createState() => _DowntonLayoutState();
}

class _DowntonLayoutState extends State<_DowntonLayout> {
  ScaleValue? caidas;
  ScaleValue? medicamentos;
  ScaleValue? deficitSensorial;
  ScaleValue? deambulacion;
  ScaleValue? estadoMental;

  bool get _todoCompleto =>
      caidas != null &&
      medicamentos != null &&
      deficitSensorial != null &&
      deambulacion != null &&
      estadoMental != null;

  int get _puntajeTotal {
    int total = 0;
    total += caidas?.score ?? 0;
    total += medicamentos?.score ?? 0;
    total += deficitSensorial?.score ?? 0;
    total += deambulacion?.score ?? 0;
    total += estadoMental?.score ?? 0;
    return total;
  }

  String get resultado {
    return ScaleResultFormatter.formatWithNV(
      parameters: {
        "Caídas previas": caidas?.score,
        "Medicamentos": medicamentos?.score,
        "Déficit sensorial": deficitSensorial?.score,
        "Deambulación": deambulacion?.score,
        "Estado mental": estadoMental?.score,
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

                  // ================== CAÍDAS PREVIAS ==================
                  ScaleParameterSelector(
                    title: "Caídas previas",
                    onChanged: (int? value) =>
                        setState(() => caidas = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 1,
                        label: "Sí",
                        description:
                            "El paciente ha sufrido caídas en los meses previos.",
                      ),
                      ScaleOption(
                        score: 0,
                        label: "No",
                        description:
                            "El paciente no ha sufrido caídas recientes.",
                      ),
                      ScaleOption(
                        score: null,
                        label: "No valorable",
                        description: "No se puede obtener la información.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== MEDICAMENTOS ==================
                  ScaleParameterSelector(
                    title: "Medicamentos",
                    onChanged: (int? value) =>
                        setState(() => medicamentos = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 1,
                        label: "Sí",
                        description:
                            "Consume fármacos de riesgo: tranquilizantes, sedantes, diuréticos, antidepresivos o antiparkinsonianos.",
                      ),
                      ScaleOption(
                        score: 0,
                        label: "No",
                        description: "No consume ninguno de estos fármacos.",
                      ),
                      ScaleOption(
                        score: null,
                        label: "No valorable",
                        description: "No se puede obtener la información.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== DÉFICIT SENSORIAL ==================
                  ScaleParameterSelector(
                    title: "Déficit sensorial",
                    onChanged: (int? value) =>
                        setState(() => deficitSensorial = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 1,
                        label: "Sí",
                        description:
                            "Presencia comprobada de alteraciones visuales, auditivas o déficits motores en extremidades.",
                      ),
                      ScaleOption(
                        score: 0,
                        label: "No",
                        description:
                            "Sin alteraciones visuales, auditivas ni motoras.",
                      ),
                      ScaleOption(
                        score: null,
                        label: "No valorable",
                        description: "No se puede evaluar adecuadamente.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== DEAMBULACIÓN ==================
                  ScaleParameterSelector(
                    title: "Deambulación",
                    onChanged: (int? value) =>
                        setState(() => deambulacion = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 1,
                        label: "Insegura / Imposible",
                        description:
                            "Marcha insegura con o sin ayuda, o imposibilidad para deambular.",
                      ),
                      ScaleOption(
                        score: 0,
                        label: "Normal / Segura con ayuda",
                        description:
                            "Marcha normal o segura con ayuda de dispositivos.",
                      ),
                      ScaleOption(
                        score: null,
                        label: "No valorable",
                        description: "No se puede evaluar la marcha.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== ESTADO MENTAL ==================
                  ScaleParameterSelector(
                    title: "Estado mental",
                    onChanged: (int? value) =>
                        setState(() => estadoMental = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 1,
                        label: "Confuso",
                        description:
                            "Paciente desorientado o con alteración cognitiva.",
                      ),
                      ScaleOption(
                        score: 0,
                        label: "Orientado",
                        description:
                            "Paciente alerta y orientado en sus tres esferas.",
                      ),
                      ScaleOption(
                        score: null,
                        label: "No valorable",
                        description: "No se puede evaluar el estado mental.",
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
          colorResolver: (resultado) => _downtonColor(_puntajeTotal),
        ),
      ],
    );
  }
}

class _DowntonInfo extends StatelessWidget {
  const _DowntonInfo();

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
            future: context.read<EscalaRepository>().obtenerPorId("downton"),
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

// Colores específicos de la escala de Downton
Color _downtonColor(int puntajeTotal) {
  if (puntajeTotal >= 3) return AppColors.redAlertv3; // Riesgo alto
  if (puntajeTotal >= 0) return AppColors.withoutAlert; // Riesgo bajo
  return AppColors.withoutAlert;
}
