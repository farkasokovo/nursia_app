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

class ApgarScreen extends StatelessWidget {
  const ApgarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MoldeEscalasScreen(
      heroTag: "apgar",
      title: "APGAR",
      icon: PhosphorIconsFill.baby,
      scaleTab: const _ApgarLayout(),
      infoTab: const _ApgarInfo(),
    );
  }
}

class _ApgarLayout extends StatefulWidget {
  const _ApgarLayout();

  @override
  State<_ApgarLayout> createState() => _ApgarLayoutState();
}

class _ApgarLayoutState extends State<_ApgarLayout>
    with AutomaticKeepAliveClientMixin {
  ScaleValue? frecuenciaCardiaca;
  ScaleValue? esfuerzoRespiratorio;
  ScaleValue? tonoMuscular;
  ScaleValue? respuestaEstimulos;
  ScaleValue? color;

  bool get _todoCompleto =>
      frecuenciaCardiaca != null &&
      esfuerzoRespiratorio != null &&
      tonoMuscular != null &&
      respuestaEstimulos != null &&
      color != null;

  int get _puntajeTotal {
    int total = 0;
    total += frecuenciaCardiaca?.score ?? 0;
    total += esfuerzoRespiratorio?.score ?? 0;
    total += tonoMuscular?.score ?? 0;
    total += respuestaEstimulos?.score ?? 0;
    total += color?.score ?? 0;
    return total;
  }

  String get resultado {
    return ScaleResultFormatter.formatWithNV(
      parameters: {
        "Frecuencia cardíaca": frecuenciaCardiaca?.score,
        "Esfuerzo respiratorio": esfuerzoRespiratorio?.score,
        "Tono muscular": tonoMuscular?.score,
        "Respuesta a estímulos": respuestaEstimulos?.score,
        "Color de la piel": color?.score,
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Recordatorio: se valora al minuto 1 y a los 5 minutos.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      borderRadius: AppRadius.defaultRadius,
                    ),
                    child: Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIconsFill.clock,
                          color: colorScheme.primaryContainer,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Recuerda: el APGAR se evalúa al minuto 1 y a los 5 minutos de vida. Realiza una captura por cada toma.",
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primaryContainer,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ================== FRECUENCIA CARDÍACA ==================
                  ScaleParameterSelector(
                    title: "Frecuencia cardíaca (Pulso)",
                    onChanged: (int? value) =>
                        setState(() => frecuenciaCardiaca = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Ausente",
                        description: "Sin latido cardíaco.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "< 100 lpm",
                        description: "Frecuencia cardíaca menor de 100 lpm.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "≥ 100 lpm",
                        description: "Frecuencia cardíaca de 100 lpm o más.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== ESFUERZO RESPIRATORIO ==================
                  ScaleParameterSelector(
                    title: "Esfuerzo respiratorio",
                    onChanged: (int? value) => setState(
                      () => esfuerzoRespiratorio = ScaleValue(value),
                    ),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Ausente",
                        description: "Sin respiración.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Lento / irregular",
                        description: "Respiración lenta, irregular o llanto débil.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Llanto vigoroso",
                        description: "Llanto vigoroso, respiración regular.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== TONO MUSCULAR ==================
                  ScaleParameterSelector(
                    title: "Tono muscular (Actividad)",
                    onChanged: (int? value) =>
                        setState(() => tonoMuscular = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Flácido",
                        description: "Sin tono muscular.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Cierta flexión",
                        description: "Alguna flexión de las extremidades.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Movimientos activos",
                        description: "Movimientos activos, buena flexión.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== RESPUESTA A ESTÍMULOS ==================
                  ScaleParameterSelector(
                    title: "Respuesta a estímulos",
                    onChanged: (int? value) => setState(
                      () => respuestaEstimulos = ScaleValue(value),
                    ),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Sin respuesta",
                        description: "No responde a la estimulación.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Mueca / gesto leve",
                        description: "Mueca o gesto leve ante el estímulo.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Tos / estornudo / llanto",
                        description: "Tos, estornudo, llanto o retirada enérgica.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== COLOR DE LA PIEL ==================
                  ScaleParameterSelector(
                    title: "Color de la piel (Apariencia)",
                    onChanged: (int? value) =>
                        setState(() => color = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Cianosis / palidez",
                        description: "Cianosis generalizada o palidez.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Acrocianosis",
                        description: "Cuerpo rosado con extremidades azules.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Totalmente rosado",
                        description: "Piel completamente rosada.",
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
          colorResolver: (resultado) => _apgarColor(_puntajeTotal),
          etiquetaResolver: (resultado) => _apgarEtiqueta(_puntajeTotal),
        ),
      ],
    );
  }
}

class _ApgarInfo extends StatelessWidget {
  const _ApgarInfo();

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
            future: context.read<EscalaRepository>().obtenerPorId("apgar"),
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

// Etiqueta clínica corta de APGAR (vitalidad neonatal; puntaje alto = mejor).
String _apgarEtiqueta(int puntajeTotal) {
  if (puntajeTotal >= 7) return "Buen estado";
  if (puntajeTotal >= 4) return "Depresión moderada";
  return "Depresión severa";
}

// Colores específicos de la escala APGAR (puntaje alto = mejor)
Color _apgarColor(int puntajeTotal) {
  if (puntajeTotal >= 7) return AppColors.greenAlert; // Buen estado
  if (puntajeTotal >= 4) return AppColors.redAlertv1; // Depresión moderada
  return AppColors.redAlertv3; // Depresión severa
}
