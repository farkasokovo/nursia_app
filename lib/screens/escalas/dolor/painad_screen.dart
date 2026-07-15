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

class PainadScreen extends StatelessWidget {
  const PainadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MoldeEscalasScreen(
      heroTag: "painad",
      title: "PAINAD",
      icon: PhosphorIconsFill.brain,
      scaleTab: const _PainadLayout(),
      infoTab: const _PainadInfo(),
    );
  }
}

class _PainadLayout extends StatefulWidget {
  const _PainadLayout();

  @override
  State<_PainadLayout> createState() => _PainadLayoutState();
}

class _PainadLayoutState extends State<_PainadLayout> {
  ScaleValue? respiracion;
  ScaleValue? vocalizacion;
  ScaleValue? expresionFacial;
  ScaleValue? lenguajeCorporal;
  ScaleValue? consolabilidad;

  bool get _todoCompleto =>
      respiracion != null &&
      vocalizacion != null &&
      expresionFacial != null &&
      lenguajeCorporal != null &&
      consolabilidad != null;

  int get _puntajeTotal {
    int total = 0;
    total += respiracion?.score ?? 0;
    total += vocalizacion?.score ?? 0;
    total += expresionFacial?.score ?? 0;
    total += lenguajeCorporal?.score ?? 0;
    total += consolabilidad?.score ?? 0;
    return total;
  }

  String get resultado {
    return ScaleResultFormatter.formatWithNV(
      parameters: {
        "Respiración": respiracion?.score,
        "Vocalización negativa": vocalizacion?.score,
        "Expresión facial": expresionFacial?.score,
        "Lenguaje corporal": lenguajeCorporal?.score,
        "Consolabilidad": consolabilidad?.score,
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

                  // ================== RESPIRACIÓN ==================
                  ScaleParameterSelector(
                    title: "Respiración",
                    onChanged: (int? value) =>
                        setState(() => respiracion = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Normal",
                        description: "Respiración normal.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Dificultad ocasional",
                        description:
                            "Respiración dificultosa ocasional o hiperventilación corta.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Dificultad ruidosa",
                        description:
                            "Ruidosa y dificultosa, hiperventilación larga o Cheyne-Stokes.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== VOCALIZACIÓN NEGATIVA ==================
                  ScaleParameterSelector(
                    title: "Vocalización negativa",
                    onChanged: (int? value) =>
                        setState(() => vocalizacion = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Ninguna",
                        description: "Sin vocalización negativa.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Ocasional",
                        description:
                            "Quejidos ocasionales o habla con tono de desaprobación.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Repetida / llanto",
                        description:
                            "Llamadas agitadas repetidas, quejidos en voz alta o llanto.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== EXPRESIÓN FACIAL ==================
                  ScaleParameterSelector(
                    title: "Expresión facial",
                    onChanged: (int? value) =>
                        setState(() => expresionFacial = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Sonriente / inexpresiva",
                        description: "Cara sonriente o sin expresión.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Triste / ceño fruncido",
                        description: "Triste, atemorizada o con el ceño fruncido.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Muecas de disgusto",
                        description: "Muecas de disgusto o desagrado.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== LENGUAJE CORPORAL ==================
                  ScaleParameterSelector(
                    title: "Lenguaje corporal",
                    onChanged: (int? value) =>
                        setState(() => lenguajeCorporal = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Relajado",
                        description: "Cuerpo relajado.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Tenso",
                        description: "Tenso, movimientos nerviosos, no para quieto.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Rígido / agresivo",
                        description:
                            "Rígido, puños cerrados, rodillas flexionadas, agarra/empuja o agresividad.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== CONSOLABILIDAD ==================
                  ScaleParameterSelector(
                    title: "Consolabilidad",
                    onChanged: (int? value) =>
                        setState(() => consolabilidad = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Sin necesidad de consuelo",
                        description: "Contento, no necesita consuelo.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Se tranquiliza",
                        description: "Se distrae o tranquiliza con la voz o el tacto.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Imposible de consolar",
                        description:
                            "Imposible de consolar, distraer o tranquilizar.",
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
          colorResolver: (resultado) => _painadColor(_puntajeTotal),
        ),
      ],
    );
  }
}

class _PainadInfo extends StatelessWidget {
  const _PainadInfo();

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
            future: context.read<EscalaRepository>().obtenerPorId("painad"),
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

// Colores específicos de la escala PAINAD
Color _painadColor(int puntajeTotal) {
  if (puntajeTotal >= 7) return AppColors.redAlertv3; // Dolor intenso
  if (puntajeTotal >= 4) return AppColors.redAlertv1; // Dolor moderado
  if (puntajeTotal >= 1) return AppColors.withoutAlert; // Dolor leve
  return AppColors.greenAlert; // Sin dolor
}
