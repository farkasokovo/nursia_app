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

class FlaccScreen extends StatelessWidget {
  const FlaccScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MoldeEscalasScreen(
      heroTag: "flacc",
      title: "FLACC",
      icon: PhosphorIconsFill.smiley,
      scaleTab: const _FlaccLayout(),
      infoTab: const _FlaccInfo(),
    );
  }
}

class _FlaccLayout extends StatefulWidget {
  const _FlaccLayout();

  @override
  State<_FlaccLayout> createState() => _FlaccLayoutState();
}

class _FlaccLayoutState extends State<_FlaccLayout>
    with AutomaticKeepAliveClientMixin {
  ScaleValue? cara;
  ScaleValue? piernas;
  ScaleValue? actividad;
  ScaleValue? llanto;
  ScaleValue? consolabilidad;

  bool get _todoCompleto =>
      cara != null &&
      piernas != null &&
      actividad != null &&
      llanto != null &&
      consolabilidad != null;

  int get _puntajeTotal {
    int total = 0;
    total += cara?.score ?? 0;
    total += piernas?.score ?? 0;
    total += actividad?.score ?? 0;
    total += llanto?.score ?? 0;
    total += consolabilidad?.score ?? 0;
    return total;
  }

  String get resultado {
    return ScaleResultFormatter.formatWithNV(
      parameters: {
        "Cara": cara?.score,
        "Piernas": piernas?.score,
        "Actividad": actividad?.score,
        "Llanto": llanto?.score,
        "Consolabilidad": consolabilidad?.score,
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

                  // ================== CARA ==================
                  ScaleParameterSelector(
                    title: "Cara (Face)",
                    onChanged: (int? value) =>
                        setState(() => cara = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Sin expresión / sonriente",
                        description: "Sin expresión particular o sonriente.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Muecas ocasionales",
                        description:
                            "Muecas o ceño fruncido ocasional, retraído o desinteresado.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Temblor de mentón",
                        description: "Temblor frecuente del mentón, mandíbula apretada.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== PIERNAS ==================
                  ScaleParameterSelector(
                    title: "Piernas (Legs)",
                    onChanged: (int? value) =>
                        setState(() => piernas = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Posición normal / relajada",
                        description: "Piernas en posición normal o relajadas.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Inquietas / tensas",
                        description: "Piernas inquietas o tensas.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Pataleo / rígidas",
                        description: "Pataleo o piernas encogidas/rígidas.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== ACTIVIDAD ==================
                  ScaleParameterSelector(
                    title: "Actividad (Activity)",
                    onChanged: (int? value) =>
                        setState(() => actividad = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Tranquilo / se mueve con facilidad",
                        description: "Acostado tranquilo, posición normal.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Se retuerce / tenso",
                        description: "Se retuerce, cambia de posición, tenso.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Rígido / movimientos bruscos",
                        description: "Encorvado, rígido o con movimientos bruscos.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== LLANTO ==================
                  ScaleParameterSelector(
                    title: "Llanto (Cry)",
                    onChanged: (int? value) =>
                        setState(() => llanto = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Sin llanto",
                        description: "Sin llanto (despierto o dormido).",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Gemidos / quejas ocasionales",
                        description: "Gemidos o quejidos, quejas ocasionales.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Llanto sostenido / gritos",
                        description: "Llanto sostenido, gritos o sollozos, quejas frecuentes.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== CONSOLABILIDAD ==================
                  ScaleParameterSelector(
                    title: "Consolabilidad (Consolability)",
                    onChanged: (int? value) =>
                        setState(() => consolabilidad = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Contento / relajado",
                        description: "Contento y relajado.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Se tranquiliza",
                        description:
                            "Se tranquiliza con el contacto, el abrazo o la voz.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Difícil de consolar",
                        description: "Difícil de consolar o confortar.",
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
          colorResolver: (resultado) => _flaccColor(_puntajeTotal),
          etiquetaResolver: (resultado) => _flaccEtiqueta(_puntajeTotal),
        ),
      ],
    );
  }
}

class _FlaccInfo extends StatelessWidget {
  const _FlaccInfo();

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
            future: context.read<EscalaRepository>().obtenerPorId("flacc"),
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

// Etiqueta clínica corta de FLACC (mismos cortes que _flaccColor)
String _flaccEtiqueta(int puntajeTotal) {
  if (puntajeTotal >= 7) return "Dolor intenso";
  if (puntajeTotal >= 4) return "Dolor moderado";
  if (puntajeTotal >= 1) return "Dolor leve";
  return "Sin dolor";
}

// Colores específicos de la escala FLACC
Color _flaccColor(int puntajeTotal) {
  if (puntajeTotal >= 7) return AppColors.redAlertv3; // Dolor intenso
  if (puntajeTotal >= 4) return AppColors.redAlertv1; // Dolor moderado
  if (puntajeTotal >= 1) return AppColors.withoutAlert; // Dolor leve
  return AppColors.greenAlert; // Sin dolor
}
