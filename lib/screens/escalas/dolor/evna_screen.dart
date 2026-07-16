import 'package:flutter/material.dart';
import 'package:nursia_app/repositories/escala_repository.dart';
import 'package:nursia_app/widgets/estructura_ver_mas_screen.dart';
import 'package:nursia_app/widgets/scale_result_footer.dart';
import 'package:provider/provider.dart';
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

  // Categoría clínica del valor 0-10 (misma partición que _evnaColor).
  String _categoria(int valor) {
    if (valor == 0) return "Sin dolor";
    if (valor <= 3) return "Leve";
    if (valor <= 6) return "Moderado";
    return "Intenso";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // El slider siempre necesita un value no nulo; mientras no se evalúa se
    // dibuja el thumb en 0, pero el estado interno sigue en null ("Sin
    // evaluar") para distinguirlo del 0 real ("Sin dolor").
    final int? valor = intensidad?.score;
    final bool evaluado = valor != null;
    final Color colorValor = evaluado
        ? _evnaColor(valor)
        : colorScheme.onSecondaryContainer.withValues(alpha: 0.4);

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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      borderRadius: AppRadius.defaultRadius,
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Intensidad del dolor (0-10)",
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(
                            color: colorScheme.primaryContainer,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Valor grande y sin ambigüedad ("—" si no se evalúa).
                        Text(
                          evaluado ? "$valor" : "—",
                          style: textTheme.displayLarge?.copyWith(
                            color: colorValor,
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          evaluado ? _categoria(valor) : "Sin evaluar",
                          style: textTheme.titleMedium?.copyWith(
                            color: colorValor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Listener: registra el primer toque incluso si es en 0
                        // (que el Slider no notificaría por no cambiar de valor).
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: colorScheme.primaryContainer,
                            inactiveTrackColor: colorScheme.primaryContainer
                                .withValues(alpha: 0.3),
                            thumbColor: colorScheme.primaryContainer,
                            overlayColor: colorScheme.primaryContainer
                                .withValues(alpha: 0.15),
                            valueIndicatorColor: colorScheme.primaryContainer,
                          ),
                          child: Listener(
                            onPointerDown: (_) {
                              if (intensidad == null) {
                                setState(() => intensidad = const ScaleValue(0));
                              }
                            },
                            child: Slider(
                              value: (valor ?? 0).toDouble(),
                              min: 0,
                              max: 10,
                              divisions: 10,
                              label: "${valor ?? 0}",
                              onChanged: (v) => setState(
                                () => intensidad = ScaleValue(v.round()),
                              ),
                            ),
                          ),
                        ),

                        // Etiquetas de los extremos de la escala.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "0 · Sin dolor",
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                            Text(
                              "10 · Peor dolor",
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

// Colores específicos de la EVNA
Color _evnaColor(int puntajeTotal) {
  if (puntajeTotal >= 7) return AppColors.redAlertv3; // Intenso
  if (puntajeTotal >= 4) return AppColors.redAlertv1; // Moderado
  if (puntajeTotal >= 1) return AppColors.withoutAlert; // Leve
  return AppColors.greenAlert; // Sin dolor
}
