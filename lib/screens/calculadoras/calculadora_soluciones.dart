import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nursia_app/widgets/info_tab.dart';
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

  // FIX: ValueNotifier evita reconstruir todo el árbol al cambiar el resultado
  final _resultado = ValueNotifier<_ResultadoSolucion?>(null);

  // FIX: Mantiene el estado del tab al cambiar entre "Cálculo" e "Información"
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    // FIX: Libera controllers y notifier para evitar memory leaks
    _volumenController.dispose();
    _porcentajeIndicadoController.dispose();
    _porcentajeDisponibleController.dispose();
    _resultado.dispose();
    super.dispose();
  }

  void _calcular() {
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
    super.build(context); // requerido por AutomaticKeepAliveClientMixin
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
              controller: _volumenController,
            ),
            const SizedBox(height: 20),
            _SolutionInputField(
              label: "Glucosada indicada (%)",
              maxLength: 2,
              controller: _porcentajeIndicadoController,
            ),
            const SizedBox(height: 20),
            _SolutionInputField(
              label: "Glucosada disponible (%)",
              maxLength: 2,
              controller: _porcentajeDisponibleController,
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
            // FIX: Solo reconstruye el Container del resultado, no toda la pantalla
            ValueListenableBuilder<_ResultadoSolucion?>(
              valueListenable: _resultado,
              builder: (_, valor, __) {
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

// ================== CAMPO DE ENTRADA REUTILIZABLE ==================
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
