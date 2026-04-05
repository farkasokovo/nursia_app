import 'package:flutter/material.dart';
import 'package:nursia_app/repositories/repositorio_escalas.dart';
import 'package:nursia_app/widgets/estructura_ver_mas_screen.dart';
import 'package:nursia_app/widgets/scale_result_footer.dart';
import '../../../widgets/scale_parameter_selector.dart';
import '../../../theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../widgets/molde_escalas_screen.dart';
import '../../../utils/scale_result_formatter.dart';

//! CAMBIA LOS VALORES
class ScaleValue {
  final int? score;
  const ScaleValue(this.score);
}

//! CAMBIA EL NOMBRE
class RassScreen extends StatelessWidget {
  const RassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MoldeEscalasScreen(
      heroTag: "rass",
      title: "Escala de RASS",
      icon: PhosphorIconsFill.gauge,
      scaleTab: const _RassLayout(),
      infoTab: const _RassInfo(),
    );
  }
}

//! CAMBIA EL NOMBRE
class _RassLayout extends StatefulWidget {
  const _RassLayout();

  @override
  State<_RassLayout> createState() => _RassLayoutState();
}

//! CAMBIA EL NOMBRE
class _RassLayoutState extends State<_RassLayout> {
  //! CAMBIA EL NOMBRE
  ScaleValue? nivelSedacion;

  bool get _todoCompleto => nivelSedacion != null;

  String get resultado {
    return ScaleResultFormatter.formatWithNV(
      //! CAMBIA EL NOMBRE Y PARÁMETROS
      parameters: {"Nivel de sedación RASS": nivelSedacion?.score},
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
                  ScaleParameterSelector(
                    title: "Nivel de sedación (RASS)",
                    onChanged: (int? value) =>
                        setState(() => nivelSedacion = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 4,
                        label: "Combativo",
                        description:
                            "Francamente combativo o violento; representa un peligro inmediato para el personal de salud.",
                      ),
                      ScaleOption(
                        score: 3,
                        label: "Muy agitado",
                        description:
                            "Intenta arrancarse tubos, catéteres o sondas; muestra un comportamiento agresivo.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Agitado",
                        description:
                            "Presenta movimientos frecuentes sin propósito y lucha contra el ventilador mecánico.",
                      ),
                      ScaleOption(
                        score: 1,
                        label: "Inquieto",
                        description:
                            "Ansioso o aprensivo, pero sus movimientos no son agresivos ni vigorosos.",
                      ),
                      ScaleOption(
                        score: 0,
                        label: "Alerta y tranquilo",
                        description:
                            "Paciente despierto y calmado con su entorno.",
                      ),
                      ScaleOption(
                        score: -1,
                        label: "Somnoliento",
                        description:
                            "No está plenamente alerta, pero se mantiene despierto con contacto visual a la voz por más de 10 segundos.",
                      ),
                      ScaleOption(
                        score: -2,
                        label: "Sedación leve",
                        description:
                            "Despierta brevemente con contacto visual a la voz por menos de 10 segundos.",
                      ),
                      ScaleOption(
                        score: -3,
                        label: "Sedación moderada",
                        description:
                            "Presenta cualquier movimiento o apertura ocular a la voz, pero no logra realizar contacto visual.",
                      ),
                      ScaleOption(
                        score: -4,
                        label: "Sedación profunda",
                        description:
                            "No responde a la voz, pero presenta algún movimiento o apertura ocular ante el estímulo físico.",
                      ),
                      ScaleOption(
                        score: -5,
                        label: "Sin respuesta",
                        description:
                            "No presenta ninguna respuesta a la voz ni al estímulo físico.",
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
          colorResolver: _rassColor,
        ),
      ],
    );
  }
}

//! CAMBIA EL NOMBRE
class _RassInfo extends StatelessWidget {
  const _RassInfo();

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
            //! CAMBIA EL NOMBRE
            future: RepositorioEscalas.getScale("rass"),
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

//! CAMBIA EL NOMBRE
// Colores específicos de la escala RASS
Color _rassColor(String resultado) {
  final match = RegExp(r'-?\d+').firstMatch(resultado);
  if (match == null) return AppColors.withoutAlert;
  final score = int.parse(match.group(0)!);
  switch (score) {
    case 4:
      return AppColors.redAlertv3; // +4 Combativo - muy grave
    case 3:
      return AppColors.redAlertv2; // +3 Muy agitado - grave
    case 2:
      return AppColors.redAlertv1; // +2 Agitado - moderado
    case 1:
      return AppColors.withoutAlert; // +1 Inquieto - leve
    case 0:
      return AppColors.greenAlert; // 0 Alerta y tranquilo - óptimo
    case -1:
      return AppColors.withoutAlert; // -1 Somnoliento
    case -2:
      return AppColors.withoutAlert; // -2 Sedación leve
    case -3:
      return AppColors.redAlertv1; // -3 Sedación moderada
    case -4:
      return AppColors.redAlertv2; // -4 Sedación profunda
    case -5:
      return AppColors.redAlertv3; // -5 Sin respuesta - grave
    default:
      return AppColors.withoutAlert;
  }
}
