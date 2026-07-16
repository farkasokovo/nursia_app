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

class MaddoxScreen extends StatelessWidget {
  const MaddoxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MoldeEscalasScreen(
      heroTag: "maddox",
      title: "Escala de Maddox",
      icon: PhosphorIconsFill.hand,
      scaleTab: const _MaddoxLayout(),
      infoTab: const _MaddoxInfo(),
    );
  }
}

class _MaddoxLayout extends StatefulWidget {
  const _MaddoxLayout();

  @override
  State<_MaddoxLayout> createState() => _MaddoxLayoutState();
}

class _MaddoxLayoutState extends State<_MaddoxLayout> {
  // Parámetros de la escala de Maddox (igual que Downton, pero con los 5 signos)
  ScaleValue? dolor;
  ScaleValue? eritema;
  ScaleValue? edema;
  ScaleValue? cordonVenoso;
  ScaleValue? exudado;

  bool get _todoCompleto =>
      dolor != null &&
      eritema != null &&
      edema != null &&
      cordonVenoso != null &&
      exudado != null;

  int get _puntajeTotal {
    int total = 0;
    total += dolor?.score ?? 0;
    total += eritema?.score ?? 0;
    total += edema?.score ?? 0;
    total += cordonVenoso?.score ?? 0;
    total += exudado?.score ?? 0;
    return total;
  }

  String get resultado {
    return ScaleResultFormatter.formatWithNV(
      parameters: {
        "Dolor": dolor?.score,
        "Eritema": eritema?.score,
        "Edema": edema?.score,
        "Cordón venoso": cordonVenoso?.score,
        "Exudado": exudado?.score,
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

                  // ================== DOLOR ==================
                  ScaleParameterSelector(
                    title: "Dolor",
                    onChanged: (int? value) =>
                        setState(() => dolor = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 1,
                        label: "Sí",
                        description: "Dolor en el sitio de inserción.",
                      ),
                      ScaleOption(
                        score: 0,
                        label: "No",
                        description: "Sin dolor.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== ERITEMA ==================
                  ScaleParameterSelector(
                    title: "Eritema",
                    onChanged: (int? value) =>
                        setState(() => eritema = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 1,
                        label: "Sí",
                        description:
                            "Enrojecimiento alrededor del punto de inserción.",
                      ),
                      ScaleOption(
                        score: 0,
                        label: "No",
                        description: "Sin enrojecimiento.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== EDEMA ==================
                  ScaleParameterSelector(
                    title: "Edema",
                    onChanged: (int? value) =>
                        setState(() => edema = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 1,
                        label: "Sí",
                        description:
                            "Inflamación o hinchazón de los tejidos circundantes.",
                      ),
                      ScaleOption(
                        score: 0,
                        label: "No",
                        description: "Sin edema.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== CORDÓN VENOSO ==================
                  ScaleParameterSelector(
                    title: "Cordón venoso",
                    onChanged: (int? value) =>
                        setState(() => cordonVenoso = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 1,
                        label: "Sí",
                        description: "Induración palpable de la vena.",
                      ),
                      ScaleOption(
                        score: 0,
                        label: "No",
                        description: "Sin cordón venoso palpable.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== EXUDADO ==================
                  ScaleParameterSelector(
                    title: "Exudado",
                    onChanged: (int? value) =>
                        setState(() => exudado = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 1,
                        label: "Sí",
                        description: "Presencia de material purulento (pus).",
                      ),
                      ScaleOption(
                        score: 0,
                        label: "No",
                        description: "Sin exudado.",
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
          colorResolver: (resultado) => _maddoxColor(_puntajeTotal),
        ),
      ],
    );
  }
}

class _MaddoxInfo extends StatelessWidget {
  const _MaddoxInfo();

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
            future: context.read<EscalaRepository>().obtenerPorId("maddox"),
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

// Colores específicos de la escala de Maddox
Color _maddoxColor(int puntajeTotal) {
  switch (puntajeTotal) {
    case 0:
      {
        return AppColors.greenAlert;
      }
    case 1:
      {
        return AppColors.withoutAlert;
      }
    case 2:
      {
        return AppColors.redAlertv1;
      }
    case 3:
      {
        return AppColors.redAlertv2;
      }
    case 4:
      {
        return AppColors.redAlertv3;
      }
    default:
      {
        return AppColors.redAlertv4;
      }
  }
}
