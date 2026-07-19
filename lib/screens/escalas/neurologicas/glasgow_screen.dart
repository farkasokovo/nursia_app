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

class _GlasgowLayoutState extends State<_GlasgowLayout>
    with AutomaticKeepAliveClientMixin {
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
                  // ================== RESPUESTA OCULAR ==================
                  ScaleParameterSelector(
                    title: "Respuesta ocular",
                    onChanged: (int? value) =>
                        setState(() => ocular = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 4,
                        label: "Espontánea",
                        description: "Abre los ojos sin estimulación.",
                      ),
                      ScaleOption(
                        score: 3,
                        label: "Al orden verbal",
                        description: "Abre los ojos al llamado verbal.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Al dolor",
                        description: "Abre los ojos ante estímulo doloroso.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Sin respuesta",
                        description: "No abre los ojos ante ningún estímulo.",
                      ),
                      ScaleOption(
                        score: null,
                        label: "No valorable",
                        description:
                            "No se puede evaluar (ej. edema palpebral).",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== RESPUESTA VERBAL ==================
                  ScaleParameterSelector(
                    title: "Respuesta verbal",
                    onChanged: (int? value) =>
                        setState(() => verbal = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 5,
                        label: "Orientado",
                        description:
                            "Responde coherentemente: sabe quién es, dónde está, fecha.",
                      ),
                      ScaleOption(
                        score: 4,
                        label: "Confuso",
                        description:
                            "Responde frases coherentes pero desorientado.",
                      ),
                      ScaleOption(
                        score: 3,
                        label: "Palabras inapropiadas",
                        description:
                            "Palabras sueltas, sin formar frases coherentes.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Sonidos incomprensibles",
                        description: "Emite gemidos o quejidos sin palabras.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Sin respuesta",
                        description: "No emite ningún sonido.",
                      ),
                      ScaleOption(
                        score: null,
                        label: "No valorable",
                        description:
                            "No se puede evaluar (ej. paciente intubado, afasia).",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== RESPUESTA MOTORA ==================
                  ScaleParameterSelector(
                    title: "Respuesta motora",
                    onChanged: (int? value) =>
                        setState(() => motora = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 6,
                        label: "Obedece órdenes",
                        description:
                            "Realiza acciones como 'abra los ojos' o 'apriete mi mano'.",
                      ),
                      ScaleOption(
                        score: 5,
                        label: "Localiza estímulo doloroso",
                        description:
                            "Lleva la mano al punto de estímulo doloroso.",
                      ),
                      ScaleOption(
                        score: 4,
                        label: "Retirada al dolor",
                        description:
                            "Retira la extremidad ante el dolor (sin localizar).",
                      ),
                      ScaleOption(
                        score: 3,
                        label: "Flexión anormal",
                        description:
                            "Flexión del brazo con rotación interna (decorticación).",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Extensión anormal",
                        description:
                            "Extensión del brazo con rotación externa (descerebración).",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Sin respuesta",
                        description: "No responde a ningún estímulo doloroso.",
                      ),
                      ScaleOption(
                        score: null,
                        label: "No valorable",
                        description:
                            "No se puede evaluar (ej. sedación, parálisis).",
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
          colorResolver: _glasgowColor,
          etiquetaResolver: _glasgowEtiqueta,
        ),
      ],
    );
  }
}

class _GlasgowInfo extends StatelessWidget {
  const _GlasgowInfo();

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
            future: context.read<EscalaRepository>().obtenerPorId("glasgow"),
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

// Etiqueta clínica corta de Glasgow (consciencia; parsea el puntaje total).
// Si el resultado no es numérico (algún parámetro "No valorable"), lo indica.
String _glasgowEtiqueta(String resultado) {
  final match = RegExp(r'^\d+').firstMatch(resultado);
  if (match == null) return "No valorable";
  final score = int.parse(match.group(0)!);
  if (score == 15) return "Normal / Orientado";
  if (score >= 13) return "Deterioro leve"; // 13-14
  if (score >= 9) return "Deterioro moderado"; // 9-12
  return "Deterioro grave"; // 3-8
}

// Colores específicos de la escala (no dependen del tema)
Color _glasgowColor(String resultado) {
  final match = RegExp(r'^\d+').firstMatch(resultado);
  if (match == null) {
    return AppColors.withoutAlert;
  }
  final score = int.parse(match.group(0)!);
  if (score == 15) return AppColors.greenAlert;
  if (score >= 13) return AppColors.withoutAlert;
  if (score >= 9) return AppColors.redAlertv1;
  return AppColors.redAlertv3;
}
