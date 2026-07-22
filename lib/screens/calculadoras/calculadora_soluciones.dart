import 'dart:math';

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
  final _segundaConcentracionController = TextEditingController();

  final _volumenFocus = FocusNode();
  final _indicadoFocus = FocusNode();
  final _disponibleFocus = FocusNode();
  final _segundaConcentracionFocus = FocusNode();

  final _resultado = ValueNotifier<_ResultadoSolucion?>(null);

  /// Controla si el usuario quiere ingresar una segunda solución disponible
  bool _usarSegundaSolucion = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _volumenController.dispose();
    _porcentajeIndicadoController.dispose();
    _porcentajeDisponibleController.dispose();
    _segundaConcentracionController.dispose();
    _volumenFocus.dispose();
    _indicadoFocus.dispose();
    _disponibleFocus.dispose();
    _segundaConcentracionFocus.dispose();
    _resultado.dispose();
    super.dispose();
  }

  void _calcular() {
    _volumenFocus.unfocus();
    _indicadoFocus.unfocus();
    _disponibleFocus.unfocus();
    _segundaConcentracionFocus.unfocus();

    final volumen = double.tryParse(_volumenController.text);
    final porcentajeIndicado = double.tryParse(
      _porcentajeIndicadoController.text,
    );
    final porcentajeDisponible = double.tryParse(
      _porcentajeDisponibleController.text,
    );

    // ── Validación de campos base ──
    if (volumen == null ||
        volumen == 0 ||
        porcentajeIndicado == null ||
        porcentajeIndicado == 0 ||
        porcentajeDisponible == null ||
        porcentajeDisponible == 0) {
      _resultado.value = null;
      return;
    }

    // ── Validación: concentración indicada ≤ 50% ──
    if (porcentajeIndicado > 50) {
      _resultado.value = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La concentración indicada no puede ser mayor a 50%"),
        ),
      );
      return;
    }

    // ── Validación: concentración disponible ≤ 50% ──
    if (porcentajeDisponible > 50) {
      _resultado.value = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La concentración disponible no puede ser mayor a 50%"),
        ),
      );
      return;
    }

    if (_usarSegundaSolucion) {
      // ══════════════════════════════════════════════════════════
      // MODO MEZCLA: siempre usa la fórmula de dos soluciones,
      // independientemente de la relación entre disponible e indicado.
      // ══════════════════════════════════════════════════════════

      // Parsear y validar la segunda concentración
      final segundaConcentracion = double.tryParse(
        _segundaConcentracionController.text,
      );

      if (segundaConcentracion == null || segundaConcentracion == 0) {
        _resultado.value = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ingresa la segunda concentración disponible."),
          ),
        );
        return;
      }

      // ── Validación: segunda concentración ≤ 50% ──
      if (segundaConcentracion > 50) {
        _resultado.value = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "La segunda concentración disponible no puede ser mayor a 50%",
            ),
          ),
        );
        return;
      }

      // ── Validación: las dos concentraciones no pueden ser iguales ──
      if (porcentajeDisponible == segundaConcentracion) {
        _resultado.value = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Las dos concentraciones disponibles no pueden ser iguales.",
            ),
          ),
        );
        return;
      }

      // Determinar cuál es la mayor y cuál la menor
      final concentracionMax = max(porcentajeDisponible, segundaConcentracion);
      final concentracionMin = min(porcentajeDisponible, segundaConcentracion);

      // ── Validación: la concentración máx debe ser ≥ indicada ──
      if (concentracionMax < porcentajeIndicado) {
        _resultado.value = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Al menos una de las soluciones disponibles debe ser mayor o igual a la concentración indicada.",
            ),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // ── Validación: indicado debe ser ≥ concentracionMin ──
      // Si indicado < min, ambas soluciones son demasiado concentradas
      // y la fórmula produciría resultados negativos.
      if (porcentajeIndicado < concentracionMin) {
        _resultado.value = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "La concentración indicada es menor que ambas soluciones disponibles. "
              "Desactiva la segunda solución y usa el modo de dilución con agua estéril.",
            ),
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      // ── Caso especial: indicado == concentracionMin → solo se usa la solución menor ──
      if (porcentajeIndicado == concentracionMin) {
        _resultado.value = _ResultadoSolucion(
          "${volumen.toStringAsFixed(0)} ml de SG ${concentracionMin.toInt()}%",
          "No requiere mezcla",
        );
        return;
      }

      // ── Caso especial: indicado == concentracionMax → solo se usa la solución mayor ──
      if (porcentajeIndicado == concentracionMax) {
        _resultado.value = _ResultadoSolucion(
          "${volumen.toStringAsFixed(0)} ml de SG ${concentracionMax.toInt()}%",
          "No requiere mezcla",
        );
        return;
      }

      // Fórmula de mezcla:
      // mlMax = volumen × (% indicado − % menor) / (% mayor − % menor)
      // mlMin = volumen − mlMax
      final mlSolucionMax =
          (volumen * (porcentajeIndicado - concentracionMin)) /
          (concentracionMax - concentracionMin);
      final mlSolucionMin = volumen - mlSolucionMax;

      // ── Red de seguridad: resultado inválido (NaN, infinito o negativo) ──
      if (mlSolucionMax.isNaN ||
          mlSolucionMin.isNaN ||
          mlSolucionMax.isInfinite ||
          mlSolucionMin.isInfinite ||
          mlSolucionMax < 0 ||
          mlSolucionMin < 0) {
        _resultado.value = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "El resultado no es válido. Revisa los valores ingresados.",
            ),
          ),
        );
        return;
      }

      _resultado.value = _ResultadoSolucion(
        "${mlSolucionMax.toStringAsFixed(0)} ml de SG ${concentracionMax.toInt()}%",
        "${mlSolucionMin.toStringAsFixed(0)} ml de SG ${concentracionMin.toInt()}%",
      );
    } else {
      // ══════════════════════════════════════════════════════════
      // MODO DILUCIÓN: una sola solución disponible + agua estéril.
      // ══════════════════════════════════════════════════════════

      if (porcentajeDisponible > porcentajeIndicado) {
        // Diluir con agua estéril
        final mlSolucionDisponible =
            ((volumen * porcentajeIndicado) / porcentajeDisponible).round();
        final mlAgua = volumen.round() - mlSolucionDisponible;

        // ── Caso límite: volumen demasiado pequeño para la diferencia de concentraciones ──
        if (mlSolucionDisponible == 0) {
          _resultado.value = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Las concentraciones son demasiado dispares para el volumen indicado. "
                "Intenta con un volumen mayor.",
              ),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }

        _resultado.value = _ResultadoSolucion(
          "${mlSolucionDisponible.toStringAsFixed(0)} ml de SG ${porcentajeDisponible.toInt()}%",
          "${mlAgua.toStringAsFixed(0)} ml de agua estéril",
        );
      } else if (porcentajeDisponible < porcentajeIndicado) {
        // No se puede calcular sin una segunda solución
        _resultado.value = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Activa la segunda solución disponible para calcular esta mezcla.",
            ),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // disponible == indicado → sin ajuste
        _resultado.value = _ResultadoSolucion(
          "${volumen.toStringAsFixed(0)} ml de SG ${porcentajeIndicado.toInt()}%",
          "No requiere ajuste",
        );
      }
    }
  }

  void _limpiar() {
    _volumenController.clear();
    _porcentajeIndicadoController.clear();
    _porcentajeDisponibleController.clear();
    _segundaConcentracionController.clear();
    _resultado.value = null;
    setState(() {
      _usarSegundaSolucion = false;
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
            const SizedBox(height: 10),

            // ── Checkbox: activar segunda solución ──
            InkWell(
              onTap: () {
                setState(() {
                  _usarSegundaSolucion = !_usarSegundaSolucion;
                  if (!_usarSegundaSolucion) {
                    _segundaConcentracionController.clear();
                    _resultado.value = null;
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _usarSegundaSolucion,
                        onChanged: (val) {
                          setState(() {
                            _usarSegundaSolucion = val ?? false;
                            if (!_usarSegundaSolucion) {
                              _segundaConcentracionController.clear();
                              _resultado.value = null;
                            }
                          });
                        },
                        activeColor: colorScheme.primaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: BorderSide(
                          color: colorScheme.primaryContainer,
                          width: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Agregar segunda solución\ndisponible",
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primaryContainer,
                        fontWeight: _usarSegundaSolucion
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Campo de segunda concentración (aparece solo si checkbox activo) ──
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _usarSegundaSolucion
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: NumericInputField(
                        label: "Segunda concentración disponible (%)",
                        controller: _segundaConcentracionController,
                        focusNode: _segundaConcentracionFocus,
                        maxLength: 2,
                        allowDecimal: false,
                      ),
                    )
                  : const SizedBox.shrink(),
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
