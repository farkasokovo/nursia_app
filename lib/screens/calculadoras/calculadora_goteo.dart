import 'package:flutter/material.dart';
import 'package:nursia_app/widgets/info_tab.dart';
import 'package:nursia_app/widgets/numeric_input_field.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../widgets/expandable_category_screen.dart';
import '../../widgets/tabbed_content.dart';
import '../../theme/app_theme.dart';

class CalculadoraGoteo extends StatelessWidget {
  const CalculadoraGoteo({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpandableCategoryScreen(
      heroTag: "goteo",
      title: "Goteo IV",
      icon: PhosphorIconsFill.dropHalfBottom,
      child: TabbedContent(
        tabs: const [
          Tab(text: "Cálculo"),
          Tab(text: "Información"),
        ],
        tabViews: [
          const _CalculoGoteoLayout(),
          const InfoTab(calculadoraId: "goteo"),
        ],
      ),
    );
  }
}

// ================== ENUM DE EQUIPO ==================
enum TipoEquipo { micro, normo, macro }

extension TipoEquipoExtension on TipoEquipo {
  String get label {
    switch (this) {
      case TipoEquipo.micro:
        return 'Micro';
      case TipoEquipo.normo:
        return 'Normo';
      case TipoEquipo.macro:
        return 'Macro';
    }
  }

  /// Factor de goteo del equipo (gotas por ml)
  int get factorGoteo {
    switch (this) {
      case TipoEquipo.micro:
        return 60;
      case TipoEquipo.normo:
        return 20;
      case TipoEquipo.macro:
        return 15;
    }
  }

  /// Constante de la fórmula = 60 ÷ factor de goteo
  int get constante {
    switch (this) {
      case TipoEquipo.micro:
        return 1; // 60 / 60
      case TipoEquipo.normo:
        return 3; // 60 / 20
      case TipoEquipo.macro:
        return 4; // 60 / 15
    }
  }

  /// Nombre largo para el desglose del resultado
  String get nombreLargo {
    switch (this) {
      case TipoEquipo.micro:
        return 'Microgotero';
      case TipoEquipo.normo:
        return 'Normogotero';
      case TipoEquipo.macro:
        return 'Macrogotero';
    }
  }
}

// ================== RESULTADO (clase auxiliar) ==================
class _ResultadoGoteo {
  final int gotasPorMinuto; // resultado redondeado
  final TipoEquipo equipo; // equipo con el que se calculó
  const _ResultadoGoteo(this.gotasPorMinuto, this.equipo);
}

// ================== PESTAÑA DE CÁLCULO ==================
class _CalculoGoteoLayout extends StatefulWidget {
  const _CalculoGoteoLayout();

  @override
  State<_CalculoGoteoLayout> createState() => _CalculoGoteoLayoutState();
}

class _CalculoGoteoLayoutState extends State<_CalculoGoteoLayout>
    with AutomaticKeepAliveClientMixin {
  final _volumenController = TextEditingController();
  final _tiempoController = TextEditingController();

  final _volumenFocus = FocusNode();
  final _tiempoFocus = FocusNode();

  final _resultado = ValueNotifier<_ResultadoGoteo?>(null);

  /// Equipo seleccionado (normogotero por defecto)
  TipoEquipo _equipo = TipoEquipo.normo;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _volumenController.dispose();
    _tiempoController.dispose();
    _volumenFocus.dispose();
    _tiempoFocus.dispose();
    _resultado.dispose();
    super.dispose();
  }

  void _calcular() {
    // Quita el foco de los campos al calcular
    _volumenFocus.unfocus();
    _tiempoFocus.unfocus();

    final volumen = double.tryParse(_volumenController.text);
    final tiempo = double.tryParse(_tiempoController.text);

    // ── Validación de campos base (evita también la división por cero) ──
    if (volumen == null || tiempo == null || volumen <= 0 || tiempo <= 0) {
      _resultado.value = null;
      return;
    }

    // gotas/min = Volumen / (Tiempo × Constante del equipo)
    final gotasPorMinuto = (volumen / (tiempo * _equipo.constante)).round();

    // ── Red de seguridad: resultado sin sentido clínico ──
    if (gotasPorMinuto <= 0) {
      _resultado.value = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "El volumen es demasiado pequeño para el tiempo indicado. "
            "Revisa los valores ingresados.",
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    if (gotasPorMinuto >= 1000) {
      _resultado.value = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "El resultado es demasiado grande. Revisa los valores ingresados.",
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _resultado.value = _ResultadoGoteo(gotasPorMinuto, _equipo);
  }

  void _limpiar() {
    _volumenController.clear();
    _tiempoController.clear();
    _resultado.value = null;
    // Resetea el equipo a normogotero al limpiar
    setState(() {
      _equipo = TipoEquipo.normo;
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
            NumericInputField(
              label: "Volumen total (ml)",
              controller: _volumenController,
              focusNode: _volumenFocus,
              maxLength: 4,
              allowDecimal: false,
            ),
            const SizedBox(height: 20),
            NumericInputField(
              label: "Tiempo (horas)",
              controller: _tiempoController,
              focusNode: _tiempoFocus,
              maxLength: 3,
              allowDecimal: false,
            ),
            const SizedBox(height: 20),

            // ── Selector de tipo de equipo (aplica la constante) ──
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                "Tipo de equipo",
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primaryContainer,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _EquipoSelector(
              selected: _equipo,
              onChanged: (equipo) {
                setState(() {
                  _equipo = equipo;
                  // Recalcula si ya hay un resultado visible
                  if (_resultado.value != null) _calcular();
                });
              },
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
            ValueListenableBuilder<_ResultadoGoteo?>(
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
                        "Velocidad de infusión:",
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.primaryContainer,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        valor == null
                            ? "0 gotas/min"
                            : "${valor.gotasPorMinuto} gotas/min",
                        style: textTheme.displayLarge?.copyWith(
                          color: colorScheme.primaryContainer,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (valor != null) ...[
                        const SizedBox(height: 16),
                        Divider(
                          thickness: 3,
                          color: colorScheme.primaryContainer,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${valor.equipo.nombreLargo} "
                          "(${valor.equipo.factorGoteo} gotas/ml)",
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

// ================== SELECTOR DE EQUIPO ==================
class _EquipoSelector extends StatelessWidget {
  const _EquipoSelector({required this.selected, required this.onChanged});

  final TipoEquipo selected;
  final ValueChanged<TipoEquipo> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: TipoEquipo.values.map((equipo) {
        final isSelected = equipo == selected;
        return Expanded(
          child: Padding(
            // Espacio entre botones
            padding: EdgeInsets.only(
              right: equipo != TipoEquipo.values.last ? 8.0 : 0,
            ),
            child: OutlinedButton(
              onPressed: () => onChanged(equipo),
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
                equipo.label,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
