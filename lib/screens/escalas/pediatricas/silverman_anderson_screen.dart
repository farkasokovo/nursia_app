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

class SilvermanAndersonScreen extends StatelessWidget {
  const SilvermanAndersonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MoldeEscalasScreen(
      heroTag: "silverman_anderson",
      title: "Silverman-Anderson",
      icon: PhosphorIconsFill.wind,
      scaleTab: const _SilvermanLayout(),
      infoTab: const _SilvermanInfo(),
    );
  }
}

class _SilvermanLayout extends StatefulWidget {
  const _SilvermanLayout();

  @override
  State<_SilvermanLayout> createState() => _SilvermanLayoutState();
}

class _SilvermanLayoutState extends State<_SilvermanLayout> {
  ScaleValue? movimientos;
  ScaleValue? tiraje;
  ScaleValue? retraccion;
  ScaleValue? aleteo;
  ScaleValue? quejido;

  bool get _todoCompleto =>
      movimientos != null &&
      tiraje != null &&
      retraccion != null &&
      aleteo != null &&
      quejido != null;

  int get _puntajeTotal {
    int total = 0;
    total += movimientos?.score ?? 0;
    total += tiraje?.score ?? 0;
    total += retraccion?.score ?? 0;
    total += aleteo?.score ?? 0;
    total += quejido?.score ?? 0;
    return total;
  }

  String get resultado {
    return ScaleResultFormatter.formatWithNV(
      parameters: {
        "Movimientos toracoabdominales": movimientos?.score,
        "Tiraje intercostal": tiraje?.score,
        "Retracción xifoidea": retraccion?.score,
        "Aleteo nasal": aleteo?.score,
        "Quejido espiratorio": quejido?.score,
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

                  // ================== MOVIMIENTOS TORACOABDOMINALES ==================
                  ScaleParameterSelector(
                    title: "Movimientos toracoabdominales",
                    onChanged: (int? value) =>
                        setState(() => movimientos = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Rítmicos y regulares",
                        description: "Tórax y abdomen suben juntos.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Tórax inmóvil",
                        description: "El tórax no se mueve y el abdomen sí.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Disociación / balanceo",
                        description:
                            "El tórax se hunde mientras el abdomen se eleva.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== TIRAJE INTERCOSTAL ==================
                  ScaleParameterSelector(
                    title: "Tiraje intercostal",
                    onChanged: (int? value) =>
                        setState(() => tiraje = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Ausente",
                        description: "Sin retracción entre las costillas.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Leve",
                        description: "Retracción leve o apenas visible.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Marcado",
                        description: "Retracción marcada y constante.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== RETRACCIÓN XIFOIDEA ==================
                  ScaleParameterSelector(
                    title: "Retracción xifoidea",
                    onChanged: (int? value) =>
                        setState(() => retraccion = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Ausente",
                        description: "Sin hundimiento del apéndice xifoides.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Leve",
                        description: "Hundimiento leve.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Marcada",
                        description: "Hundimiento marcado.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== ALETEO NASAL ==================
                  ScaleParameterSelector(
                    title: "Aleteo nasal",
                    onChanged: (int? value) =>
                        setState(() => aleteo = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Ausente",
                        description: "Sin apertura de las fosas nasales.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Mínimo",
                        description: "Aleteo leve o mínimo.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Marcado",
                        description: "Aleteo nasal marcado.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== QUEJIDO ESPIRATORIO ==================
                  ScaleParameterSelector(
                    title: "Quejido espiratorio",
                    onChanged: (int? value) =>
                        setState(() => quejido = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Ausente",
                        description: "Sin quejido.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Audible con estetoscopio",
                        description: "Quejido audible solo con estetoscopio.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Audible sin estetoscopio",
                        description: "Quejido audible a distancia.",
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
          colorResolver: (resultado) => _silvermanColor(_puntajeTotal),
        ),
      ],
    );
  }
}

class _SilvermanInfo extends StatelessWidget {
  const _SilvermanInfo();

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
            future: context.read<EscalaRepository>().obtenerPorId(
              "silverman_anderson",
            ),
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

// Colores específicos de Silverman-Anderson.
// ¡INVERSO al APGAR! Aquí el puntaje ALTO significa PEOR dificultad respiratoria,
// por lo que se mapea a colores de alerta; el 0 (mejor estado) a verde.
Color _silvermanColor(int puntajeTotal) {
  if (puntajeTotal >= 7) return AppColors.redAlertv3; // Dificultad severa
  if (puntajeTotal >= 4) return AppColors.redAlertv1; // Dificultad moderada
  if (puntajeTotal >= 1) return AppColors.withoutAlert; // Dificultad leve
  return AppColors.greenAlert; // Sin dificultad (mejor)
}
