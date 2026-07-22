import 'package:flutter/material.dart';
import 'package:nursia_app/widgets/info_tab.dart';
import 'package:nursia_app/widgets/numeric_input_field.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../widgets/expandable_category_screen.dart';
import '../../widgets/tabbed_content.dart';
import '../../theme/app_theme.dart';

class CalculadoraPam extends StatelessWidget {
  const CalculadoraPam({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpandableCategoryScreen(
      heroTag: "pam",
      title: "Presión arterial media",
      icon: PhosphorIconsFill.heartbeat,
      child: TabbedContent(
        tabs: const [
          Tab(text: "Cálculo"),
          Tab(text: "Información"),
        ],
        tabViews: [
          const _CalculoPamLayout(),
          const InfoTab(calculadoraId: "pam"),
        ],
      ),
    );
  }
}

// ================== RESULTADO (clase auxiliar) ==================
class _ResultadoPam {
  final int pam; // PAM redondeada en mmHg
  const _ResultadoPam(this.pam);
}

// ================== INTERPRETACIÓN (ADULTO) ==================
// Rangos aprobados en Fase 1. La interpretación aplica SOLO a población
// adulta; por seguridad, esta calculadora no evalúa población pediátrica.
String _pamEtiqueta(int pam) {
  if (pam < 65) return "Hipoperfusión";
  if (pam < 70) return "Límite inferior";
  if (pam <= 100) return "Normal";
  return "Elevada";
}

String _pamDetalle(int pam) {
  if (pam < 65) {
    return "Por debajo de la meta mínima habitual (≥ 65 mmHg). "
        "Riesgo de perfusión insuficiente a órganos vitales.";
  }
  if (pam < 70) {
    return "Cumple el mínimo habitual pero con poco margen.";
  }
  if (pam <= 100) {
    return "Perfusión adecuada en el adulto.";
  }
  return "Posible hipertensión o aumento de la poscarga; "
      "correlaciona con el estado clínico.";
}

Color _pamColor(int pam) {
  if (pam < 65) return AppColors.redAlertv3;
  if (pam < 70) return AppColors.withoutAlert;
  if (pam <= 100) return AppColors.greenAlert;
  return AppColors.redAlertv1;
}

// ================== PESTAÑA DE CÁLCULO ==================
class _CalculoPamLayout extends StatefulWidget {
  const _CalculoPamLayout();

  @override
  State<_CalculoPamLayout> createState() => _CalculoPamLayoutState();
}

class _CalculoPamLayoutState extends State<_CalculoPamLayout>
    with AutomaticKeepAliveClientMixin {
  final _pasController = TextEditingController();
  final _padController = TextEditingController();

  final _pasFocus = FocusNode();
  final _padFocus = FocusNode();

  final _resultado = ValueNotifier<_ResultadoPam?>(null);

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _pasController.dispose();
    _padController.dispose();
    _pasFocus.dispose();
    _padFocus.dispose();
    _resultado.dispose();
    super.dispose();
  }

  void _calcular() {
    // Quita el foco de los campos al calcular
    _pasFocus.unfocus();
    _padFocus.unfocus();

    final pas = double.tryParse(_pasController.text);
    final pad = double.tryParse(_padController.text);

    // ── Validación de campos base ──
    if (pas == null || pad == null || pas <= 0 || pad <= 0) {
      _resultado.value = null;
      return;
    }

    // ── Validación clínica: la diastólica debe ser menor que la sistólica ──
    if (pad >= pas) {
      _resultado.value = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "La presión diastólica debe ser menor que la sistólica.",
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // ── Red de seguridad: valores fuera de todo rango fisiológico ──
    if (pas > 300 || pad > 200) {
      _resultado.value = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Revisa los valores ingresados."),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // PAM = (PAS + 2 × PAD) / 3
    final pam = ((pas + 2 * pad) / 3).round();
    _resultado.value = _ResultadoPam(pam);
  }

  void _limpiar() {
    _pasController.clear();
    _padController.clear();
    _resultado.value = null;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NumericInputField(
              label: "Presión sistólica (mmHg)",
              controller: _pasController,
              focusNode: _pasFocus,
              maxLength: 3,
              allowDecimal: false,
            ),
            const SizedBox(height: 20),
            NumericInputField(
              label: "Presión diastólica (mmHg)",
              controller: _padController,
              focusNode: _padFocus,
              maxLength: 3,
              allowDecimal: false,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _calcular,
                    style: ElevatedButton.styleFrom(
                      overlayColor: colorScheme.tertiaryContainer,
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
            ValueListenableBuilder<_ResultadoPam?>(
              valueListenable: _resultado,
              builder: (_, valor, _) {
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
                        "Presión arterial media:",
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.primaryContainer,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        valor == null ? "0 mmHg" : "${valor.pam} mmHg",
                        style: textTheme.displayLarge?.copyWith(
                          color: colorScheme.primaryContainer,
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // ── Interpretación (adulto) ──
                      if (valor != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: _pamColor(valor.pam),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Text(
                            _pamEtiqueta(valor.pam),
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _pamDetalle(valor.pam),
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
