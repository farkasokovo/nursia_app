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

class EvnaScreen extends StatelessWidget {
  const EvnaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MoldeEscalasScreen(
      heroTag: "evna",
      title: "EVNA",
      icon: PhosphorIconsFill.ruler,
      scaleTab: const _EvnaLayout(),
      infoTab: const _EvnaInfo(),
    );
  }
}

class _EvnaLayout extends StatefulWidget {
  const _EvnaLayout();

  @override
  State<_EvnaLayout> createState() => _EvnaLayoutState();
}

class _EvnaLayoutState extends State<_EvnaLayout> {
  // Escala de un solo parámetro (0-10 autoreportado por el paciente).
  ScaleValue? intensidad;

  bool get _todoCompleto => intensidad != null;

  int get _puntajeTotal => intensidad?.score ?? 0;

  String get resultado {
    return ScaleResultFormatter.formatWithNV(
      parameters: {"Intensidad del dolor": intensidad?.score},
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

                  // ================== INTENSIDAD DEL DOLOR ==================
                  ScaleParameterSelector(
                    title: "Intensidad del dolor (0-10)",
                    onChanged: (int? value) =>
                        setState(() => intensidad = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 0,
                        label: "Sin dolor",
                        description: "Ausencia total de dolor.",
                      ),
                      ScaleOption(score: 1, label: "Leve"),
                      ScaleOption(score: 2, label: "Leve"),
                      ScaleOption(
                        score: 3,
                        label: "Leve",
                        description: "Manejable con analgésicos no opioides.",
                      ),
                      ScaleOption(score: 4, label: "Moderado"),
                      ScaleOption(score: 5, label: "Moderado"),
                      ScaleOption(
                        score: 6,
                        label: "Moderado",
                        description: "Interfiere con la actividad.",
                      ),
                      ScaleOption(score: 7, label: "Intenso"),
                      ScaleOption(score: 8, label: "Intenso"),
                      ScaleOption(score: 9, label: "Intenso"),
                      ScaleOption(
                        score: 10,
                        label: "Peor dolor imaginable",
                        description:
                            "Dolor máximo; requiere intervención prioritaria.",
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
          colorResolver: (resultado) => _evnaColor(_puntajeTotal),
        ),
      ],
    );
  }
}

class _EvnaInfo extends StatelessWidget {
  const _EvnaInfo();

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
            future: context.read<EscalaRepository>().obtenerPorId("evna"),
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

// Colores específicos de la EVNA
Color _evnaColor(int puntajeTotal) {
  if (puntajeTotal >= 7) return AppColors.redAlertv3; // Intenso
  if (puntajeTotal >= 4) return AppColors.redAlertv1; // Moderado
  if (puntajeTotal >= 1) return AppColors.withoutAlert; // Leve
  return AppColors.greenAlert; // Sin dolor
}
