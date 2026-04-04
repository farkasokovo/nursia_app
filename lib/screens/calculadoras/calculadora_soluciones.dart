import 'package:flutter/material.dart';
import 'package:nursia_app/widgets/info_tab.dart';
import 'package:nursia_app/widgets/numeric_input_field.dart';
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
        tabViews: [
          const _CalculoSolucionesLayout(),
          const InfoTab(calculadoraId: "soluciones"),
        ],
      ),
    );
  }
}

// ================== RESULTADO (clase auxiliar) ==================
class _ResultadoSolucion {
  final String linea1;
  final String linea2;
  const _ResultadoSolucion(this.linea1, this.linea2);
}

// ================== PESTAÑA DE CÁLCULO ==================
class _CalculoSolucionesLayout extends StatefulWidget {
  const _CalculoSolucionesLayout();

  @override
  State<_CalculoSolucionesLayout> createState() =>
      _CalculoSolucionesLayoutState();
}

class _CalculoSolucionesLayoutState extends State<_CalculoSolucionesLayout>
    with AutomaticKeepAliveClientMixin {
  final _volumenController = TextEditingController();
  final _porcentajeIndicadoController = TextEditingController();
  final _porcentajeDisponibleController = TextEditingController();

  // FIX: FocusNodes para soltar el teclado al navegar o calcular
  final _volumenFocus = FocusNode();
  final _indicadoFocus = FocusNode();
  final _disponibleFocus = FocusNode();

  final _resultado = ValueNotifier<_ResultadoSolucion?>(null);

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _volumenController.dispose();
    _porcentajeIndicadoController.dispose();
    _porcentajeDisponibleController.dispose();
    _volumenFocus.dispose();
    _indicadoFocus.dispose();
    _disponibleFocus.dispose();
    _resultado.dispose();
    super.dispose();
  }

  void _calcular() {
    // Quita el foco de todos los campos al calcular
    _volumenFocus.unfocus();
    _indicadoFocus.unfocus();
    _disponibleFocus.unfocus();

    final volumen = double.tryParse(_volumenController.text);
    final porcentajeIndicado = double.tryParse(
      _porcentajeIndicadoController.text,
    );
    final porcentajeDisponible = double.tryParse(
      _porcentajeDisponibleController.text,
    );

    if (volumen == null ||
        porcentajeIndicado == null ||
        porcentajeDisponible == null) {
      _resultado.value = null;
      return;
    }

    if (porcentajeIndicado > 50) {
      _resultado.value = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La concentración indicada no puede ser mayor a 50%"),
        ),
      );
      return;
    }

    if (porcentajeDisponible > porcentajeIndicado) {
      final mlSolucionDisponible =
          ((volumen * porcentajeIndicado) / porcentajeDisponible).round();
      final mlAgua = volumen.round() - mlSolucionDisponible;
      _resultado.value = _ResultadoSolucion(
        "${mlSolucionDisponible.toStringAsFixed(0)} ml de SG ${porcentajeDisponible.toInt()}%",
        "${mlAgua.toStringAsFixed(0)} ml de agua estéril",
      );
    } else if (porcentajeDisponible < porcentajeIndicado) {
      final diferencia = porcentajeIndicado - porcentajeDisponible;
      final mlGlucosa50 = (volumen * diferencia) / 50;
      final mlOtraSolucion = volumen - mlGlucosa50;
      _resultado.value = _ResultadoSolucion(
        "${mlGlucosa50.toStringAsFixed(0)} ml de SG 50%",
        "${mlOtraSolucion.toStringAsFixed(0)} ml de SG ${porcentajeDisponible.toInt()}%",
      );
    } else {
      _resultado.value = _ResultadoSolucion(
        "$volumen ml de SG ${porcentajeIndicado.toInt()}%",
        "No requiere ajuste",
      );
    }
  }

  void _limpiar() {
    _volumenController.clear();
    _porcentajeIndicadoController.clear();
    _porcentajeDisponibleController.clear();
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
              label: "Cantidad indicada (ml)",
              controller: _volumenController,
              focusNode: _volumenFocus,
              maxLength: 4,
              allowDecimal: false,
            ),
            const SizedBox(height: 20),
            NumericInputField(
              label: "Concentración indicada (%)",
              controller: _porcentajeIndicadoController,
              focusNode: _indicadoFocus,
              maxLength: 2,
              allowDecimal: false,
            ),
            const SizedBox(height: 20),
            NumericInputField(
              label: "Concentración disponible (%)",
              controller: _porcentajeDisponibleController,
              focusNode: _disponibleFocus,
              maxLength: 2,
              allowDecimal: false,
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
                    onPressed: _calcular,
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
                    onPressed: _limpiar,
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
            ValueListenableBuilder<_ResultadoSolucion?>(
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
                        "Preparación:",
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.primaryContainer,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        valor?.linea1 ?? "0 ml",
                        style: textTheme.headlineMedium?.copyWith(
                          color: colorScheme.primaryContainer,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        valor?.linea2 ?? "0 ml",
                        style: textTheme.headlineMedium?.copyWith(
                          color: colorScheme.primaryContainer,
                          fontSize: 25,
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
