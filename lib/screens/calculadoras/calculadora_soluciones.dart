// lib/screens/calculadoras/calculadora_soluciones.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/tabbed_content.dart';
import '../../theme/app_theme.dart';

class CalculadoraSoluciones extends StatelessWidget {
  const CalculadoraSoluciones({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpandableCategoryScreen(
      heroTag: "soluciones",
      title: "Soluciones glucosadas",
      icon: PhosphorIconsFill.drop,
      child: TabbedContent(
        tabs: const [
          Tab(text: "Cálculo"),
          Tab(text: "Información"),
        ],
        tabViews: [const _CalculadoraSolucionesLayout(), const _InfoTab()],
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Text(
          "Esta calculadora permite ajustar concentraciones de soluciones glucosadas.\n\n"
          "• Si la solución disponible tiene mayor concentración que la indicada, se diluye con agua estéril.\n"
          "• Si la concentración disponible es menor, se enriquece con glucosa al 50%.\n\n"
          "Siempre verificar la compatibilidad y la osmolaridad final antes de administrar.",
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}

class _CalculadoraSolucionesLayout extends StatefulWidget {
  const _CalculadoraSolucionesLayout();

  @override
  State<_CalculadoraSolucionesLayout> createState() =>
      _CalculadoraSolucionesLayoutState();
}

class _CalculadoraSolucionesLayoutState
    extends State<_CalculadoraSolucionesLayout> {
  final volumenController = TextEditingController();
  final porcentajeIndicadoController = TextEditingController();
  final porcentajeDisponibleController = TextEditingController();

  String resultadoLinea1 = "";
  String resultadoLinea2 = "";

  void calcular() {
    final volumen = double.tryParse(volumenController.text);
    final porcentajeIndicado = double.tryParse(
      porcentajeIndicadoController.text,
    );
    final porcentajeDisponible = double.tryParse(
      porcentajeDisponibleController.text,
    );

    if (volumen == null ||
        porcentajeIndicado == null ||
        porcentajeDisponible == null) {
      setState(() {
        resultadoLinea1 = "";
        resultadoLinea2 = "";
      });
      return;
    }

    if (porcentajeDisponible > porcentajeIndicado) {
      final mlSolucionDisponible =
          ((volumen * porcentajeIndicado) / porcentajeDisponible).round();
      final mlAgua = volumen.round() - mlSolucionDisponible;
      setState(() {
        resultadoLinea1 =
            "${mlSolucionDisponible.toStringAsFixed(0)} ml de SG ${porcentajeDisponible.toInt()}%";
        resultadoLinea2 = "${mlAgua.toStringAsFixed(0)} ml de agua estéril";
      });
    } else if (porcentajeDisponible < porcentajeIndicado) {
      final diferencia = porcentajeIndicado - porcentajeDisponible;
      final mlGlucosa50 = (volumen * diferencia) / 50;
      final mlOtraSolucion = volumen - mlGlucosa50;
      setState(() {
        resultadoLinea1 = "${mlGlucosa50.toStringAsFixed(0)} ml de SG 50%";
        resultadoLinea2 =
            "${mlOtraSolucion.toStringAsFixed(0)} ml de SG ${porcentajeDisponible.toInt()}%";
      });
    } else {
      setState(() {
        resultadoLinea1 = "$volumen ml de SG ${porcentajeIndicado.toInt()}%";
        resultadoLinea2 = "No requiere ajuste";
      });
    }
  }

  void limpiar() {
    volumenController.clear();
    porcentajeIndicadoController.clear();
    porcentajeDisponibleController.clear();
    setState(() {
      resultadoLinea1 = "";
      resultadoLinea2 = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _SolutionInputField(
              label: "Cantidad indicada (ml)",
              maxLength: 4,
              controller: volumenController,
            ),
            const SizedBox(height: 20),
            _SolutionInputField(
              label: "Glucosada indicada (%)",
              maxLength: 2,
              controller: porcentajeIndicadoController,
            ),
            const SizedBox(height: 20),
            _SolutionInputField(
              label: "Glucosada disponible (%)",
              maxLength: 2,
              controller: porcentajeDisponibleController,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      overlayColor: colorScheme.primaryContainer,
                      minimumSize: const Size(double.infinity, 60),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.defaultRadius,
                      ),
                    ),
                    onPressed: calcular,
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
                    onPressed: limpiar,
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
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 180),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: AppRadius.defaultRadius,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Preparación:",
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primaryContainer,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      resultadoLinea1.isEmpty ? "0 ml" : resultadoLinea1,
                      style: textTheme.headlineMedium?.copyWith(
                        color: colorScheme.primaryContainer,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      resultadoLinea2.isEmpty ? "0 ml" : resultadoLinea2,
                      style: textTheme.headlineMedium?.copyWith(
                        color: colorScheme.primaryContainer,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SolutionInputField extends StatelessWidget {
  final String label;
  final int maxLength;
  final TextEditingController controller;

  const _SolutionInputField({
    required this.label,
    required this.maxLength,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            label,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primaryContainer,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primaryContainer,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
            enableInteractiveSelection: false,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(maxLength),
            ],
            decoration: InputDecoration(
              hintText: label,
              hintStyle: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              filled: true,
              fillColor: colorScheme.secondary,
              border: OutlineInputBorder(
                borderRadius: AppRadius.defaultRadius,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
      ],
    );
  }
}
