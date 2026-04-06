import 'package:flutter/material.dart';
import 'package:nursia_app/widgets/info_tab.dart';
import 'package:nursia_app/widgets/numeric_input_field.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../widgets/expandable_category_screen.dart';
import '../../widgets/tabbed_content.dart';
import '../../theme/app_theme.dart';

class CalculadoraDosis extends StatelessWidget {
  const CalculadoraDosis({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpandableCategoryScreen(
      heroTag: "dosis",
      title: "Regla de tres",
      icon: PhosphorIconsFill.mathOperations,
      child: TabbedContent(
        tabs: const [
          Tab(text: "Cálculo"),
          Tab(text: "Información"),
        ],
        tabViews: [
          const _CalculoDosisLayout(),
          const InfoTab(calculadoraId: "dosis"),
        ],
      ),
    );
  }
}

// ================== PESTAÑA DE CÁLCULO ==================
class _CalculoDosisLayout extends StatefulWidget {
  const _CalculoDosisLayout();

  @override
  State<_CalculoDosisLayout> createState() => _CalculoDosisLayoutState();
}

class _CalculoDosisLayoutState extends State<_CalculoDosisLayout>
    with AutomaticKeepAliveClientMixin {
  final _dosisController = TextEditingController();
  final _dilucionController = TextEditingController();
  final _presentacionController = TextEditingController();

  // FIX: FocusNodes para soltar el teclado al navegar o calcular
  final _dosisFocus = FocusNode();
  final _dilucionFocus = FocusNode();
  final _presentacionFocus = FocusNode();

  final _resultado = ValueNotifier<double?>(null);

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _dosisController.dispose();
    _dilucionController.dispose();
    _presentacionController.dispose();
    _dosisFocus.dispose();
    _dilucionFocus.dispose();
    _presentacionFocus.dispose();
    _resultado.dispose();
    super.dispose();
  }

  void _calcular() {
    // Quita el foco de todos los campos al calcular
    _dosisFocus.unfocus();
    _dilucionFocus.unfocus();
    _presentacionFocus.unfocus();

    final dosis = double.tryParse(_dosisController.text);
    final dilucion = double.tryParse(_dilucionController.text);
    final presentacion = double.tryParse(_presentacionController.text);

    if (dosis == null ||
        dilucion == null ||
        presentacion == null ||
        presentacion == 0) {
      _resultado.value = null;
      return;
    }

    final calculo = (dosis * dilucion) / presentacion;

    final parteEntera = calculo.toInt();
    if (parteEntera >= 10000) {
      _resultado.value = null;
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
    _resultado.value = calculo;
    _resultado.value = (dosis * dilucion) / presentacion;
  }

  void _limpiar() {
    _dosisController.clear();
    _dilucionController.clear();
    _presentacionController.clear();
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
          children: [
            NumericInputField(
              label: "Dosis indicada (mg)",
              controller: _dosisController,
              focusNode: _dosisFocus,
              maxLength: 4,
              allowDecimal: true,
            ),
            const SizedBox(height: 20),
            NumericInputField(
              label: "Diluyente (ml)",
              controller: _dilucionController,
              focusNode: _dilucionFocus,
              maxLength: 3,
              allowDecimal: true,
            ),
            const SizedBox(height: 20),
            NumericInputField(
              label: "Presentación del fármaco (mg)",
              controller: _presentacionController,
              focusNode: _presentacionFocus,
              maxLength: 4,
              allowDecimal: true,
            ),
            const SizedBox(height: 20),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Cantidad a administrar:",
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
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
