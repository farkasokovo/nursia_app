import 'package:flutter/material.dart';
import 'package:nursia_app/widgets/info_tab.dart';
import 'package:nursia_app/widgets/numeric_input_field.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../utils/calculo_dosis.dart';
import '../../widgets/expandable_category_screen.dart';
import '../../widgets/opcion_selector.dart';
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
        // Tres pestañas y "Conversor" es la etiqueta más larga del módulo: con
        // el aire de 20 px por lado, el texto de 20 px de la pestaña activa no
        // cabía y se cortaba. Bajarlo a 8 le da lugar a la palabra completa sin
        // mover ni el alto de la barra ni el subrayado, que siguen a la pestaña
        // y no al padding.
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: [_pestana("Cálculo"), _pestana("Conversor"), _pestana("Ver más")],
        tabViews: [
          const _CalculoDosisLayout(),
          const _ConversorLayout(),
          const InfoTab(calculadoraId: "dosis"),
        ],
      ),
    );
  }
}

/// Pestaña cuyo texto se encoge en vez de cortarse.
///
/// Es una salvaguarda, no el arreglo: con el `labelPadding` de esta pantalla el
/// texto ya cabe entero en un celular normal. El `FittedBox` entra solo cuando
/// no cabe (pantalla muy angosta, o el tamaño de fuente del sistema en grande),
/// y ahí encoge lo mínimo necesario. Sin él, `Tab` desvanece el texto por la
/// orilla.
///
/// El `Text` va sin estilo a propósito: hereda el del `TabBar`, que es el que
/// anima el crecimiento de la pestaña activa.
Tab _pestana(String texto) => Tab(
  child: FittedBox(fit: BoxFit.scaleDown, child: Text(texto)),
);

// El enum UnidadDosis y toda la lógica de conversión viven en
// lib/utils/calculo_dosis.dart para poder probarse con pruebas unitarias y
// para que la pestaña "Cálculo" y la pestaña "Conversor" usen exactamente la
// misma conversión.

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

  /// Unidad seleccionada para la presentación del fármaco (mg por defecto)
  UnidadDosis _unidadPresentacion = UnidadDosis.mg;

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

    final resultado = calcularDosis(
      dosisTexto: _dosisController.text,
      diluyenteTexto: _dilucionController.text,
      presentacionTexto: _presentacionController.text,
      unidadDosis: _unidadDosis,
      unidadPresentacion: _unidadPresentacion,
    );

    switch (resultado) {
      case DosisInvalida():
        _resultado.value = null;
      case DosisDemasiadoGrande():
        _resultado.value = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'El resultado es demasiado grande. Revisa los valores ingresados.',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      case DosisCalculada(:final ml):
        // El resultado se muestra siempre: el número es correcto. El aviso
        // solo orienta cuando sale tan chico que en pantalla se lee "0.0 ml".
        _resultado.value = ml;
        if (resultado.esMuyPequena) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'El resultado es muy pequeño. Conviene verificar las unidades '
                'de medida seleccionadas.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
    }
  }

  void _limpiar() {
    _dosisController.clear();
    _dilucionController.clear();
    _presentacionController.clear();
    _resultado.value = null;
    // Resetea ambas unidades a mg al limpiar
    setState(() {
      _unidadDosis = UnidadDosis.mg;
      _unidadPresentacion = UnidadDosis.mg;
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
              textoAyuda: "Cantidad prescrita",
              controller: _dosisController,
              focusNode: _dosisFocus,
              maxLength: 4,
              allowDecimal: true,
            ),
            const SizedBox(height: 10),
            OpcionSelector<UnidadDosis>(
              opciones: UnidadDosis.values,
              seleccionada: _unidadDosis,
              etiqueta: (unidad) => unidad.label,
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
              textoAyuda: "Volumen de dilución",
              controller: _dilucionController,
              focusNode: _dilucionFocus,
              maxLength: 3,
              allowDecimal: true,
            ),
            const SizedBox(height: 20),
            // ── Campo de presentación con su propio selector de unidades ──
            NumericInputField(
              label: "Presentación del fármaco (${_unidadPresentacion.label})",
              textoAyuda: "Contenido de la ámpula",
              controller: _presentacionController,
              focusNode: _presentacionFocus,
              maxLength: 4,
              allowDecimal: true,
            ),
            const SizedBox(height: 10),
            OpcionSelector<UnidadDosis>(
              opciones: UnidadDosis.values,
              seleccionada: _unidadPresentacion,
              etiqueta: (unidad) => unidad.label,
              onChanged: (unidad) {
                setState(() {
                  _unidadPresentacion = unidad;
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
            ValueListenableBuilder<double?>(
              valueListenable: _resultado,
              builder: (_, valor, _) {
                return _ResultadoContainer(
                  titulo: "Cantidad a administrar:",
                  valor: valor == null
                      ? "0 ml"
                      : "${valor.toStringAsFixed(1)} ml",
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ================== PESTAÑA DE CONVERSOR ==================
class _ConversorLayout extends StatefulWidget {
  const _ConversorLayout();

  @override
  State<_ConversorLayout> createState() => _ConversorLayoutState();
}

class _ConversorLayoutState extends State<_ConversorLayout>
    with AutomaticKeepAliveClientMixin {
  final _valorController = TextEditingController();
  final _valorFocus = FocusNode();

  /// Resultado ya convertido y formateado, en la unidad de destino.
  /// Null = el campo todavía no tiene un número válido.
  final _resultado = ValueNotifier<String?>(null);

  UnidadDosis _origen = UnidadDosis.mg;
  UnidadDosis _destino = UnidadDosis.mcg;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // La conversión es en vivo: no hay botón "Convertir". NumericInputField no
    // expone onChanged, así que se escucha el controller (mismo patrón que
    // indice_shock_screen.dart).
    _valorController.addListener(_convertir);
  }

  @override
  void dispose() {
    _valorController.removeListener(_convertir);
    _valorController.dispose();
    _valorFocus.dispose();
    _resultado.dispose();
    super.dispose();
  }

  void _convertir() {
    _resultado.value = convertirTexto(
      texto: _valorController.text,
      origen: _origen,
      destino: _destino,
    );
  }

  void _limpiar() {
    _valorFocus.unfocus();
    _valorController.clear();
    setState(() {
      _origen = UnidadDosis.mg;
      _destino = UnidadDosis.mcg;
    });
    _convertir();
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
              label: "Unidad a convertir (${_origen.label})",
              textoAyuda: "Ingresa un valor",
              controller: _valorController,
              focusNode: _valorFocus,
              // 8 caracteres, no 7: el punto decimal ocupa un lugar del
              // límite, así que con 7 no cabían 7 dígitos más el punto.
              maxLength: 8,
              allowDecimal: true,
            ),
            const SizedBox(height: 20),
            _TituloSelector(texto: "Unidad original"),
            OpcionSelector<UnidadDosis>(
              opciones: UnidadDosis.values,
              seleccionada: _origen,
              etiqueta: (unidad) => unidad.label,
              onChanged: (unidad) {
                setState(() => _origen = unidad);
                _convertir();
              },
            ),
            const SizedBox(height: 20),
            _TituloSelector(texto: "Convertir a:"),
            OpcionSelector<UnidadDosis>(
              opciones: UnidadDosis.values,
              seleccionada: _destino,
              etiqueta: (unidad) => unidad.label,
              onChanged: (unidad) {
                setState(() => _destino = unidad);
                _convertir();
              },
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: _limpiar,
              style: OutlinedButton.styleFrom(
                overlayColor: colorScheme.primaryContainer,
                minimumSize: const Size(double.infinity, 60),
                side: BorderSide(color: colorScheme.primaryContainer, width: 2),
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
            const SizedBox(height: 20),
            ValueListenableBuilder<String?>(
              valueListenable: _resultado,
              builder: (_, valor, _) {
                return _ResultadoContainer(
                  titulo: "Equivale a:",
                  valor: "${valor ?? "0"} ${_destino.label}",
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ================== CONTENEDOR DE RESULTADO ==================
// Compartido por las pestañas "Cálculo" y "Conversor" para que se vean igual.
class _ResultadoContainer extends StatelessWidget {
  const _ResultadoContainer({required this.titulo, required this.valor});

  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
            titulo,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primaryContainer,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // El conversor puede producir "1000000 mcg" o "0.000001 g": el
          // FittedBox encoge el texto en vez de desbordarlo.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                valor,
                style: textTheme.displayLarge?.copyWith(
                  color: colorScheme.primaryContainer,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================== TÍTULO DE UN SELECTOR ==================
// Mismo estilo que el título de NumericInputField, para que el conversor no se
// vea distinto al resto de las calculadoras.
class _TituloSelector extends StatelessWidget {
  const _TituloSelector({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        texto,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primaryContainer,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
