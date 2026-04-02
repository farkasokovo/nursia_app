import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nursia_app/widgets/info_tab.dart';
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
      title: "Calculadora de dosis",
      icon: PhosphorIconsFill.syringe,
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
  // FIX: RegExp estático — se compila una sola vez, no en cada keystroke
  static final _decimalRegex = RegExp(r'^\d*\.?\d*');

  final _dosisController = TextEditingController();
  final _dilucionController = TextEditingController();
  final _presentacionController = TextEditingController();

  // FIX: ValueNotifier evita reconstruir todo el árbol al cambiar el resultado
  final _resultado = ValueNotifier<double?>(null);

  // FIX: Mantiene el estado del tab al cambiar entre "Cálculo" e "Información"
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    // FIX: Libera controllers y notifier para evitar memory leaks
    _dosisController.dispose();
    _dilucionController.dispose();
    _presentacionController.dispose();
    _resultado.dispose();
    super.dispose();
  }

  void _calcular() {
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
    super.build(context); // requerido por AutomaticKeepAliveClientMixin
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _DoseInputField(
              label: "Dosis indicada (mg)",
              controller: _dosisController,
              maxLength: 4,
              decimalRegex: _decimalRegex,
            ),
            const SizedBox(height: 20),
            _DoseInputField(
              label: "Diluyente (ml)",
              controller: _dilucionController,
              maxLength: 3,
              decimalRegex: _decimalRegex,
            ),
            const SizedBox(height: 20),
            _DoseInputField(
              label: "Presentación del fármaco (mg)",
              controller: _presentacionController,
              maxLength: 4,
              decimalRegex: _decimalRegex,
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
            // FIX: Solo reconstruye el Container del resultado, no toda la pantalla
            ValueListenableBuilder<double?>(
              valueListenable: _resultado,
              builder: (_, valor, _) {
                return Container(
                  width: double.infinity,
                  // FIX: ConstrainedBox colapsado en un solo Container
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

// ================== CAMPO DE ENTRADA REUTILIZABLE ==================
class _DoseInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLength;
  final RegExp decimalRegex;

  const _DoseInputField({
    required this.label,
    required this.controller,
    required this.maxLength,
    required this.decimalRegex,
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
            // FIX: const en el keyboardType
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primaryContainer,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
            inputFormatters: [
              // FIX: Usa el regex pre-compilado recibido como parámetro
              FilteringTextInputFormatter.allow(decimalRegex),
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
              border: const OutlineInputBorder(
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
