import 'package:flutter/material.dart';
import 'package:nursia_app/widgets/info_tab.dart';
import 'package:nursia_app/widgets/numeric_input_field.dart';
import 'package:nursia_app/widgets/scale_parameter_selector.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../widgets/expandable_category_screen.dart';
import '../../widgets/tabbed_content.dart';
import '../../theme/app_theme.dart';

class PerdidasInsensibles extends StatelessWidget {
  const PerdidasInsensibles({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpandableCategoryScreen(
      heroTag: "perdidasinsensibles",
      title: "Pérdidas insensibles\n(Adultos)",
      icon: PhosphorIconsFill.waves,
      child: TabbedContent(
        tabs: const [
          Tab(text: "Cálculo"),
          Tab(text: "Información"),
        ],
        tabViews: [
          const _PerdidadInsensiblesLayout(),
          const InfoTab(calculadoraId: "perdidasinsensibles"),
        ],
      ),
    );
  }
}

// ================== PESTAÑA DE CÁLCULO ==================
class _PerdidadInsensiblesLayout extends StatefulWidget {
  const _PerdidadInsensiblesLayout();

  @override
  State<_PerdidadInsensiblesLayout> createState() =>
      _PerdidadInsensiblesLayoutState();
}

class _PerdidadInsensiblesLayoutState extends State<_PerdidadInsensiblesLayout>
    with AutomaticKeepAliveClientMixin {
  final _pesoController = TextEditingController();
  final _hrsTurnoController = TextEditingController();
  final _frController = TextEditingController(); // para taquipnea

  final _pesoFocus = FocusNode();
  final _hrsTurnoFocus = FocusNode();
  final _frFocus = FocusNode();

  final _resultado = ValueNotifier<double?>(null);
  String _desglose = "";

  // Variables para los selectores
  int? _tempRango;
  int? _tipoRespiracion;
  int? _sudor;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _pesoController.dispose();
    _hrsTurnoController.dispose();
    _frController.dispose();
    _pesoFocus.dispose();
    _hrsTurnoFocus.dispose();
    _frFocus.dispose();
    _resultado.dispose();
    super.dispose();
  }

  void _calcular() {
    _pesoFocus.unfocus();
    _hrsTurnoFocus.unfocus();
    _frFocus.unfocus();

    final peso = double.tryParse(_pesoController.text);
    final horas = double.tryParse(_hrsTurnoController.text);

    if (peso == null || horas == null || peso <= 0 || horas <= 0) {
      _resultado.value = null;
      _desglose = "";
      return;
    }

    // 1. Pérdidas basales (0.5 ml/kg/h)
    double perdidasBase = 0.5 * peso * horas;
    double perdidasTotales = perdidasBase;
    String desgloseBase = "Base: ${perdidasBase.toStringAsFixed(1)} ml";

    // 2. Ajuste por fiebre
    double ajusteFiebre = 0;
    String textoFiebre = "";
    if (_tempRango != null && _tempRango != 0) {
      switch (_tempRango) {
        case 1:
          ajusteFiebre = 20 * horas;
          textoFiebre =
              "Fiebre 38-39°C: +${ajusteFiebre.toStringAsFixed(1)} ml";
          break;
        case 2:
          ajusteFiebre = 40 * horas;
          textoFiebre =
              "Fiebre 39-40°C: +${ajusteFiebre.toStringAsFixed(1)} ml";
          break;
        case 3:
          ajusteFiebre = 60 * horas;
          textoFiebre =
              "Fiebre 40-41°C: +${ajusteFiebre.toStringAsFixed(1)} ml";
          break;
      }
      perdidasTotales += ajusteFiebre;
    }

    // 3. Ajuste por respiración
    double ajusteResp = 0;
    String textoResp = "";
    if (_tipoRespiracion != null) {
      switch (_tipoRespiracion) {
        case 1: // taquipnea
          final fr = double.tryParse(_frController.text);
          if (fr != null && fr > 20) {
            int extras = ((fr - 20) / 5).floor();
            if (extras > 0) {
              ajusteResp = (4 * extras) * horas;
              textoResp =
                  "Taquipnea (+${5 * extras} ml/h): +${ajusteResp.toStringAsFixed(1)} ml";
            }
          }
          break;
        case 2: // VM intubada
          ajusteResp = 20 * horas;
          textoResp = "VM intubada: +${ajusteResp.toStringAsFixed(1)} ml";
          break;
        case 3: // Tubo T
          ajusteResp = 40 * horas;
          textoResp = "Tubo en T: +${ajusteResp.toStringAsFixed(1)} ml";
          break;
      }
      perdidasTotales += ajusteResp;
    }

    // 4. Ajuste por sudor
    double ajusteSudor = 0;
    String textoSudor = "";
    if (_sudor != null && _sudor != 0) {
      switch (_sudor) {
        case 1:
          ajusteSudor = 10 * horas;
          textoSudor = "Sudor moderado: +${ajusteSudor.toStringAsFixed(1)} ml";
          break;
        case 2:
          ajusteSudor = 20 * horas;
          textoSudor = "Sudor moderado: +${ajusteSudor.toStringAsFixed(1)} ml";
          break;
        case 3:
          ajusteSudor = 40 * horas;
          textoSudor = "Sudor intenso: +${ajusteSudor.toStringAsFixed(1)} ml";
          break;
      }
      perdidasTotales += ajusteSudor;
    }

    // Validación de resultado demasiado grande
    if (perdidasTotales.toInt() >= 4000) {
      _resultado.value = null;
      _desglose = "";
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El resultado es demasiado grande. Revisa los valores ingresados.',
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _resultado.value = perdidasTotales;

    // Construir desglose
    List<String> partes = [desgloseBase];
    if (textoFiebre.isNotEmpty) partes.add(textoFiebre);
    if (textoResp.isNotEmpty) partes.add(textoResp);
    if (textoSudor.isNotEmpty) partes.add(textoSudor);
    _desglose = partes.join("\n");
  }

  void _limpiar() {
    _pesoController.clear();
    _hrsTurnoController.clear();
    _frController.clear();
    _tempRango = null;
    _tipoRespiracion = null;
    _sudor = null;
    _resultado.value = null;
    _desglose = "";
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Campos básicos
            NumericInputField(
              label: "Peso del paciente (kg)",
              controller: _pesoController,
              focusNode: _pesoFocus,
              maxLength: 3,
              allowDecimal: true,
            ),
            const SizedBox(height: 20),
            NumericInputField(
              label: "Horas del turno (h)",
              controller: _hrsTurnoController,
              focusNode: _hrsTurnoFocus,
              maxLength: 2,
              allowDecimal: true,
            ),
            const SizedBox(height: 20),

            // Selector de fiebre
            ScaleParameterSelector(
              title: "Fiebre (temperatura)",
              onChanged: (int? value) => setState(() => _tempRango = value),
              options: const [
                ScaleOption(
                  score: 0,
                  label: "Sin fiebre (≤37.5°C)",
                  description: "Sin ajuste",
                ),
                ScaleOption(
                  score: 1,
                  label: "38-39°C",
                  description: "+20 ml/h",
                ),
                ScaleOption(
                  score: 2,
                  label: "39-40°C",
                  description: "+40 ml/h",
                ),
                ScaleOption(
                  score: 3,
                  label: "40-41°C",
                  description: "+60 ml/h",
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Selector de respiración
            ScaleParameterSelector(
              title: "Tipo de respiración / ventilación",
              onChanged: (int? value) =>
                  setState(() => _tipoRespiracion = value),
              options: const [
                ScaleOption(
                  score: 0,
                  label: "Normal (FR ≤20 rpm)",
                  description: "Sin ajuste",
                ),
                ScaleOption(
                  score: 1,
                  label: "Taquipnea",
                  description: "+5 ml/h por cada 5 rpm extras",
                ),
                ScaleOption(
                  score: 2,
                  label: "Ventilación mecánica intubada",
                  description: "+20 ml/h",
                ),
                ScaleOption(
                  score: 3,
                  label: "Tubo en T (destete)",
                  description: "+40 ml/h",
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo adicional para frecuencia respiratoria (solo si taquipnea)
            if (_tipoRespiracion == 1)
              NumericInputField(
                label: "Frecuencia respiratoria (rpm)",
                controller: _frController,
                focusNode: _frFocus,
                maxLength: 2,
                allowDecimal: false,
              ),
            if (_tipoRespiracion == 1) const SizedBox(height: 20),

            // Selector de sudor
            ScaleParameterSelector(
              title: "Sudoración",
              onChanged: (int? value) => setState(() => _sudor = value),
              options: const [
                ScaleOption(
                  score: 0,
                  label: "Normal",
                  description: "Sin ajuste",
                ),
                ScaleOption(
                  score: 1,
                  label: "Sudor leve",
                  description: "+10 ml/h",
                ),
                ScaleOption(
                  score: 2,
                  label: "Sudor moderado",
                  description: "+20 ml/h",
                ),
                ScaleOption(
                  score: 3,
                  label: "Sudor intenso",
                  description: "+40 ml/h",
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Botones
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _calcular,
                    style: ElevatedButton.styleFrom(
                      overlayColor: colorScheme.primaryContainer,
                      minimumSize: const Size(double.infinity, 60),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.defaultRadius,
                      ),
                    ),
                    child: Text(
                      "Calcular",
                      style: textTheme.titleSmall?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _limpiar,
                    style: OutlinedButton.styleFrom(
                      overlayColor: colorScheme.primaryContainer,
                      minimumSize: const Size(double.infinity, 60),
                      side: BorderSide(
                        color: colorScheme.primaryContainer,
                        width: 2,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.defaultRadius,
                      ),
                    ),
                    child: Text(
                      "Limpiar",
                      style: textTheme.titleSmall?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primaryContainer,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Resultado y desglose
            ValueListenableBuilder<double?>(
              valueListenable: _resultado,
              builder: (_, valor, __) {
                return Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 180),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    borderRadius: AppRadius.defaultRadius,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Pérdidas insensibles totales:",
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.primaryContainer,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        valor == null
                            ? "0 ml"
                            : "${valor.toStringAsFixed(1)} ml",
                        style: textTheme.displayLarge?.copyWith(
                          color: colorScheme.primaryContainer,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_desglose.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Divider(
                          thickness: 3,
                          color: colorScheme.primaryContainer.withValues(
                            alpha: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _desglose,
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
