import 'package:flutter/material.dart';
import 'package:nursia_app/widgets/info_tab.dart';
import 'package:nursia_app/widgets/numeric_input_field.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../utils/calculo_goteo.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/opcion_selector.dart';
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

// Los enums TipoEquipo y UnidadTiempo, y toda la fórmula, viven en
// lib/utils/calculo_goteo.dart para poder probarse con pruebas unitarias.

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

  final _resultado = ValueNotifier<GoteoCalculado?>(null);

  /// Equipo seleccionado (normogotero por defecto)
  TipoEquipo _equipo = TipoEquipo.normo;

  /// Unidad del campo de tiempo (horas por defecto)
  UnidadTiempo _unidadTiempo = UnidadTiempo.horas;

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

    final resultado = calcularGoteo(
      volumenTexto: _volumenController.text,
      tiempoTexto: _tiempoController.text,
      equipo: _equipo,
      unidadTiempo: _unidadTiempo,
    );

    switch (resultado) {
      case GoteoInvalido():
        _resultado.value = null;
      case GoteoDemasiadoLento():
        _resultado.value = null;
        _mostrarSnack(
          "El volumen es demasiado pequeño para el tiempo indicado. "
          "Revisa los valores ingresados.",
          segundos: 3,
        );
      case GoteoDemasiadoRapido():
        _resultado.value = null;
        _mostrarSnack(
          "El resultado es demasiado grande. Revisa los valores ingresados.",
        );
      case GoteoCalculado():
        _resultado.value = resultado;
    }
  }

  void _mostrarSnack(String mensaje, {int segundos = 2}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: Duration(seconds: segundos),
      ),
    );
  }

  void _limpiar() {
    _volumenController.clear();
    _tiempoController.clear();
    _resultado.value = null;
    // Resetea el equipo a normogotero y el tiempo a horas al limpiar
    setState(() {
      _equipo = TipoEquipo.normo;
      _unidadTiempo = UnidadTiempo.horas;
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
              textoAyuda: "Volumen a infundir",
              controller: _volumenController,
              focusNode: _volumenFocus,
              maxLength: 4,
              allowDecimal: false,
            ),
            const SizedBox(height: 20),
            // ── Campo de tiempo con su selector de unidad debajo ──
            // Sigue sin aceptar decimales a propósito: teniendo minutos
            // disponibles, "0.5 horas" se captura como "30 minutos".
            NumericInputField(
              label: "Tiempo (${_unidadTiempo.label})",
              textoAyuda: _unidadTiempo.textoAyuda,
              controller: _tiempoController,
              focusNode: _tiempoFocus,
              maxLength: 3,
              allowDecimal: false,
            ),
            const SizedBox(height: 10),
            OpcionSelector<UnidadTiempo>(
              opciones: UnidadTiempo.values,
              seleccionada: _unidadTiempo,
              etiqueta: (unidad) => unidad.label,
              onChanged: (unidad) {
                setState(() {
                  _unidadTiempo = unidad;
                  // Recalcula si ya hay un resultado visible
                  if (_resultado.value != null) _calcular();
                });
              },
            ),
            const SizedBox(height: 20),

            // ── Selector de tipo de equipo (aplica el factor de goteo) ──
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
            OpcionSelector<TipoEquipo>(
              opciones: TipoEquipo.values,
              seleccionada: _equipo,
              etiqueta: (equipo) => equipo.label,
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
                const SizedBox(width: 20),
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
              ],
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<GoteoCalculado?>(
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
