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

// ================== ENUM DE UNIDADES ==================
enum UnidadDosis { mcg, mg, g }

extension UnidadDosisExtension on UnidadDosis {
  String get label {
    switch (this) {
      case UnidadDosis.mcg:
        return 'mcg';
      case UnidadDosis.mg:
        return 'mg';
      case UnidadDosis.g:
        return 'g';
    }
  }

  /// Convierte el valor ingresado a mg para el cálculo
  double toMg(double valor) {
    switch (this) {
      case UnidadDosis.mcg:
        return valor / 1000.0;
      case UnidadDosis.mg:
        return valor;
      case UnidadDosis.g:
        return valor * 1000.0;
    }
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

  /// Unidad seleccionada para la dosis indicada (mg por defecto)
  UnidadDosis _unidadDosis = UnidadDosis.mg;

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

    final dosisRaw = double.tryParse(_dosisController.text);
    final dilucion = double.tryParse(_dilucionController.text);
    final presentacion = double.tryParse(_presentacionController.text);

    if (dosisRaw == null ||
        dilucion == null ||
        presentacion == null ||
        presentacion == 0) {
      _resultado.value = null;
      return;
    }

    // Convierte la dosis indicada a mg antes de calcular
    final dosisMg = _unidadDosis.toMg(dosisRaw);

    final calculo = (dosisMg * dilucion) / presentacion;

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
  }

  void _limpiar() {
    _dosisController.clear();
    _dilucionController.clear();
    _presentacionController.clear();
    _resultado.value = null;
    // Resetea la unidad a mg al limpiar
    setState(() {
      _unidadDosis = UnidadDosis.mg;
    });
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
            // ── Campo de dosis con selector de unidades debajo ──
            NumericInputField(
              label: "Dosis indicada (${_unidadDosis.label})",
              controller: _dosisController,
              focusNode: _dosisFocus,
              maxLength: 6,
              allowDecimal: true,
            ),
            const SizedBox(height: 10),
            _UnitSelector(
              selected: _unidadDosis,
              onChanged: (unidad) {
                setState(() {
                  _unidadDosis = unidad;
                  // Recalcula si ya hay un resultado visible
                  if (_resultado.value != null) _calcular();
                });
              },
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
            ValueListenableBuilder<double?>(
              valueListenable: _resultado,
              builder: (_, valor, _) {
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

// ================== SELECTOR DE UNIDADES ==================
class _UnitSelector extends StatelessWidget {
  const _UnitSelector({required this.selected, required this.onChanged});

  final UnidadDosis selected;
  final ValueChanged<UnidadDosis> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: UnidadDosis.values.map((unidad) {
        final isSelected = unidad == selected;
        return Expanded(
          child: Padding(
            // Espacio entre botones
            padding: EdgeInsets.only(
              right: unidad != UnidadDosis.values.last ? 8.0 : 0,
            ),
            child: OutlinedButton(
              onPressed: () => onChanged(unidad),
              style: OutlinedButton.styleFrom(
                backgroundColor: isSelected
                    ? colorScheme.primaryContainer
                    : colorScheme.primary,
                foregroundColor: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.primaryContainer,
                minimumSize: const Size(double.infinity, 44),
                padding: EdgeInsets.zero,
                side: BorderSide(color: colorScheme.primaryContainer),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.defaultRadius,
                ),
              ),
              child: Text(
                unidad.label,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,

                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
