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

class MewsScreen extends StatelessWidget {
  const MewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MoldeEscalasScreen(
      heroTag: "mews",
      title: "MEWS",
      icon: PhosphorIconsFill.warning,
      scaleTab: const _MewsLayout(),
      infoTab: const _MewsInfo(),
    );
  }
}

class _MewsLayout extends StatefulWidget {
  const _MewsLayout();

  @override
  State<_MewsLayout> createState() => _MewsLayoutState();
}

class _MewsLayoutState extends State<_MewsLayout>
    with AutomaticKeepAliveClientMixin {
  ScaleValue? respiratoria;
  ScaleValue? cardiaca;
  ScaleValue? sistolica;
  ScaleValue? temperatura;
  ScaleValue? consciencia;

  bool get _todoCompleto =>
      respiratoria != null &&
      cardiaca != null &&
      sistolica != null &&
      temperatura != null &&
      consciencia != null;

  int get _puntajeTotal {
    int total = 0;
    total += respiratoria?.score ?? 0;
    total += cardiaca?.score ?? 0;
    total += sistolica?.score ?? 0;
    total += temperatura?.score ?? 0;
    total += consciencia?.score ?? 0;
    return total;
  }

  String get resultado {
    return ScaleResultFormatter.formatWithNV(
      parameters: {
        "Frecuencia respiratoria": respiratoria?.score,
        "Frecuencia cardíaca": cardiaca?.score,
        "Presión arterial sistólica": sistolica?.score,
        "Temperatura": temperatura?.score,
        "Nivel de consciencia": consciencia?.score,
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                    title: "Frecuencia respiratoria",
                    onChanged: (int? value) =>
                        setState(() => respiratoria = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 2,
                        label: "< 9 rpm",
                        description: "Bradipnea marcada.",
                      ),
                      ScaleOption(
                        score: 0,
                        label: "9 - 14 rpm",
                        description: "Rango normal.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "15 - 20 rpm",
                        description: "Taquipnea leve.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "21 - 29 rpm",
                        description: "Taquipnea moderada.",
                      ),
                      ScaleOption(
                        score: 3,
                        label: "≥ 30 rpm",
                        description: "Taquipnea severa.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== FRECUENCIA CARDÍACA ==================
                  ScaleParameterSelector(
                    title: "Frecuencia cardíaca",
                    onChanged: (int? value) =>
                        setState(() => cardiaca = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 2,
                        label: "< 40 lpm",
                        description: "Bradicardia marcada.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "41 - 50 lpm",
                        description: "Bradicardia leve.",
                      ),
                      ScaleOption(
                        score: 0,
                        label: "51 - 100 lpm",
                        description: "Rango normal.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "101 - 110 lpm",
                        description: "Taquicardia leve.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "111 - 129 lpm",
                        description: "Taquicardia moderada.",
                      ),
                      ScaleOption(
                        score: 3,
                        label: "≥ 130 lpm",
                        description: "Taquicardia severa.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== PRESIÓN ARTERIAL SISTÓLICA ==================
                  ScaleParameterSelector(
                    title: "Presión arterial sistólica",
                    onChanged: (int? value) =>
                        setState(() => sistolica = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 3,
                        label: "≤ 70 mmHg",
                        description: "Hipotensión severa.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "71 - 80 mmHg",
                        description: "Hipotensión moderada.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "81 - 100 mmHg",
                        description: "Hipotensión leve.",
                      ),
                      ScaleOption(
                        score: 0,
                        label: "101 - 199 mmHg",
                        description: "Rango normal.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "≥ 200 mmHg",
                        description: "Hipertensión marcada.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== TEMPERATURA ==================
                  ScaleParameterSelector(
                    title: "Temperatura",
                    onChanged: (int? value) =>
                        setState(() => temperatura = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 2,
                        label: "< 35 °C",
                        description: "Hipotermia.",
                      ),
                      ScaleOption(
                        score: 0,
                        label: "35 - 38.4 °C",
                        description: "Rango normal.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "≥ 38.5 °C",
                        description: "Fiebre.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== NIVEL DE CONSCIENCIA (AVPU) ==================
                  ScaleParameterSelector(
                    title: "Nivel de consciencia (AVPU)",
                    onChanged: (int? value) =>
                        setState(() => consciencia = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Alerta",
                        description: "Despierto y orientado (A).",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Responde a la voz",
                        description: "Reacciona ante estímulo verbal (V).",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Responde al dolor",
                        description: "Reacciona solo ante estímulo doloroso (P).",
                      ),
                      ScaleOption(
                        score: 3,
                        label: "Sin respuesta",
                        description: "No responde a ningún estímulo (U).",
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
          colorResolver: (resultado) => _mewsColor(_puntajeTotal),
          etiquetaResolver: (resultado) => _mewsEtiqueta(_puntajeTotal),
        ),
      ],
    );
  }
}

class _MewsInfo extends StatelessWidget {
  const _MewsInfo();

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
            future: context.read<EscalaRepository>().obtenerPorId("mews"),
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

// Etiqueta clínica corta de MEWS (mismos cortes que _mewsColor)
String _mewsEtiqueta(int puntajeTotal) {
  if (puntajeTotal >= 5) return "Riesgo alto";
  if (puntajeTotal >= 3) return "Riesgo intermedio";
  return "Riesgo bajo";
}

// Colores específicos de la escala MEWS
Color _mewsColor(int puntajeTotal) {
  if (puntajeTotal >= 5) return AppColors.redAlertv3; // Riesgo alto
  if (puntajeTotal >= 3) return AppColors.redAlertv1; // Riesgo intermedio
  return AppColors.withoutAlert; // Riesgo bajo
}
