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

class BradenScreen extends StatelessWidget {
  const BradenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MoldeEscalasScreen(
      heroTag: "braden",
      title: "Escala de Braden",
      icon: PhosphorIconsFill.selectionBackground,
      scaleTab: const _BradenLayout(),
      infoTab: const _BradenInfo(),
    );
  }
}

class _BradenLayout extends StatefulWidget {
  const _BradenLayout();

  @override
  State<_BradenLayout> createState() => _BradenLayoutState();
}

class _BradenLayoutState extends State<_BradenLayout>
    with AutomaticKeepAliveClientMixin {
  ScaleValue? percepcionSensorial;
  ScaleValue? humedad;
  ScaleValue? actividad;
  ScaleValue? movilidad;
  ScaleValue? nutricion;
  ScaleValue? friccion;

  bool get _todoCompleto =>
      percepcionSensorial != null &&
      humedad != null &&
      actividad != null &&
      movilidad != null &&
      nutricion != null &&
      friccion != null;

  int get _puntajeTotal {
    int total = 0;
    total += percepcionSensorial?.score ?? 0;
    total += humedad?.score ?? 0;
    total += actividad?.score ?? 0;
    total += movilidad?.score ?? 0;
    total += nutricion?.score ?? 0;
    total += friccion?.score ?? 0;
    return total;
  }

  String get resultado {
    return ScaleResultFormatter.formatWithNV(
      parameters: {
        "Percepción sensorial": percepcionSensorial?.score,
        "Humedad": humedad?.score,
        "Actividad": actividad?.score,
        "Movilidad": movilidad?.score,
        "Nutrición": nutricion?.score,
        "Fricción y cizallamiento": friccion?.score,
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

                  // ================== PERCEPCIÓN SENSORIAL ==================
                  ScaleParameterSelector(
                    title: "Percepción sensorial",
                    onChanged: (int? value) =>
                        setState(() => percepcionSensorial = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 1,
                        label: "Completamente limitada",
                        description:
                            "No responde ante estímulos dolorosos por bajo nivel de conciencia o sedación, o capacidad limitada para sentir dolor en la mayoría del cuerpo.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Muy limitada",
                        description:
                            "Responde solo a estímulos dolorosos; no puede comunicar el disconfort excepto por quejido o agitación, o tiene un deterioro sensorial que limita percibir dolor en la mitad del cuerpo.",
                      ),
                      ScaleOption(
                        score: 3,
                        label: "Levemente limitada",
                        description:
                            "Responde a órdenes verbales pero no siempre puede comunicar el disconfort, o tiene alteración sensorial en una o dos extremidades.",
                      ),
                      ScaleOption(
                        score: 4,
                        label: "No alterada",
                        description:
                            "Responde a órdenes verbales. Sin déficit sensorial que limite sentir o manifestar dolor.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== HUMEDAD ==================
                  ScaleParameterSelector(
                    title: "Humedad",
                    onChanged: (int? value) =>
                        setState(() => humedad = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 1,
                        label: "Constantemente húmeda",
                        description:
                            "La piel permanece húmeda casi todo el tiempo por sudor, orina o líquidos corporales; se encuentra mojada cada vez que se moviliza.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Muy húmeda",
                        description:
                            "La piel está frecuentemente húmeda; las sábanas deben cambiarse al menos una vez por turno (cada 8 horas).",
                      ),
                      ScaleOption(
                        score: 3,
                        label: "Ocasionalmente húmeda",
                        description:
                            "La piel está ocasionalmente húmeda; requiere un cambio extra de sábanas aproximadamente una vez al día (cada 12 horas).",
                      ),
                      ScaleOption(
                        score: 4,
                        label: "Raramente húmeda",
                        description:
                            "La piel está usualmente seca; las sábanas se cambian con intervalos de rutina (cada 24 horas).",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== ACTIVIDAD ==================
                  ScaleParameterSelector(
                    title: "Actividad",
                    onChanged: (int? value) =>
                        setState(() => actividad = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 1,
                        label: "En cama",
                        description: "Confinado a la cama.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "En silla",
                        description:
                            "Capacidad para caminar severamente limitada o inexistente; no soporta su propio peso o requiere asistencia para la silla.",
                      ),
                      ScaleOption(
                        score: 3,
                        label: "Camina ocasionalmente",
                        description:
                            "Camina ocasionalmente durante el día, distancias muy cortas, con o sin ayuda; pasa la mayor parte del turno en silla o cama.",
                      ),
                      ScaleOption(
                        score: 4,
                        label: "Camina con frecuencia",
                        description:
                            "Camina fuera del cuarto al menos dos veces al día y dentro de él al menos una vez cada dos horas.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== MOVILIDAD ==================
                  ScaleParameterSelector(
                    title: "Movilidad",
                    onChanged: (int? value) =>
                        setState(() => movilidad = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 1,
                        label: "Completamente inmóvil",
                        description:
                            "No realiza ni ligeros cambios de posición del cuerpo o extremidades sin ayuda.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Muy limitada",
                        description:
                            "Realiza cambios mínimos y ocasionales de posición, pero no puede hacerlo con frecuencia o de forma significativa por sí solo.",
                      ),
                      ScaleOption(
                        score: 3,
                        label: "Ligeramente limitada",
                        description:
                            "Realiza cambios frecuentes, aunque ligeros, en la posición del cuerpo o extremidades de forma independiente.",
                      ),
                      ScaleOption(
                        score: 4,
                        label: "Sin limitaciones",
                        description:
                            "Realiza cambios mayores y frecuentes en la posición sin ayuda.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== NUTRICIÓN ==================
                  ScaleParameterSelector(
                    title: "Nutrición",
                    onChanged: (int? value) =>
                        setState(() => nutricion = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 1,
                        label: "Muy pobre",
                        description:
                            "Nunca come una comida completa; rara vez come más de un tercio de lo ofrecido; poca ingesta de proteínas y líquidos, o dieta líquida/intravenosa por más de 5 días.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Probablemente inadecuada",
                        description:
                            "Rara vez come una comida completa; generalmente solo la mitad de lo ofrecido; ingesta de proteínas limitada.",
                      ),
                      ScaleOption(
                        score: 3,
                        label: "Adecuada",
                        description:
                            "Come más de la mitad de la mayoría de las comidas; ingesta de proteínas adecuada; ocasionalmente rechaza una comida pero acepta suplemento si se ofrece.",
                      ),
                      ScaleOption(
                        score: 4,
                        label: "Excelente",
                        description:
                            "Come la mayoría de las comidas, nunca las rechaza, buena ingesta de proteínas; no requiere suplemento.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================== FRICCIÓN Y CIZALLAMIENTO ==================
                  ScaleParameterSelector(
                    title: "Fricción y cizallamiento",
                    onChanged: (int? value) =>
                        setState(() => friccion = ScaleValue(value)),
                    options: const [
                      ScaleOption(
                        score: 1,
                        label: "Es un problema",
                        description:
                            "Requiere asistencia moderada a máxima para movilizarse; se desliza frecuentemente en la cama o silla.",
                      ),
                      ScaleOption(
                        score: 2,
                        label: "Es un problema potencial",
                        description:
                            "Se mueve con cierta torpeza o requiere mínima asistencia; la piel se desliza en algún grado durante el movimiento.",
                      ),
                      ScaleOption(
                        score: 3,
                        label: "Sin problema aparente",
                        description:
                            "Se mueve con fuerza muscular suficiente para sostenerse completamente durante el movimiento.",
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
          colorResolver: (resultado) => _bradenColor(_puntajeTotal),
          etiquetaResolver: (resultado) => _bradenEtiqueta(_puntajeTotal),
        ),
      ],
    );
  }
}

class _BradenInfo extends StatelessWidget {
  const _BradenInfo();

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
            future: context.read<EscalaRepository>().obtenerPorId("braden"),
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

// Etiqueta clínica corta de Braden (riesgo de úlceras por presión).
// ¡INVERTIDA! Puntaje BAJO (≤12) = MAYOR riesgo; 19-23 = sin riesgo.
String _bradenEtiqueta(int puntajeTotal) {
  if (puntajeTotal <= 12) return "Riesgo alto";
  if (puntajeTotal <= 14) return "Riesgo moderado";
  if (puntajeTotal <= 18) return "Riesgo bajo";
  return "Sin riesgo";
}

// Colores específicos de Braden.
// ¡Escala INVERTIDA! (a diferencia de Downton): aquí el puntaje BAJO significa
// MAYOR riesgo de úlceras por presión, por lo que se mapea a colores de alerta;
// el puntaje más alto (19-23, mejor estado) va a verde.
Color _bradenColor(int puntajeTotal) {
  if (puntajeTotal <= 12) return AppColors.redAlertv3; // Riesgo alto / muy alto
  if (puntajeTotal <= 14) return AppColors.redAlertv1; // Riesgo moderado
  if (puntajeTotal <= 18) return AppColors.withoutAlert; // Riesgo bajo
  return AppColors.greenAlert; // Sin riesgo (19-23)
}
