import 'package:flutter/material.dart';
import 'package:nursia_app/repositories/escala_repository.dart';
import 'package:nursia_app/widgets/estructura_ver_mas_screen.dart';
import 'package:nursia_app/widgets/numeric_input_field.dart';
import 'package:nursia_app/widgets/scale_result_footer.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../widgets/molde_escalas_screen.dart';

// Rangos fisiológicos plausibles (criterio clínico). Fuera de estos límites,
// el valor se considera un error de captura: no se calcula y se avisa.
const int _fcMin = 20, _fcMax = 300; // Frecuencia cardíaca (lpm)
const int _pasMin = 30, _pasMax = 300; // Presión arterial sistólica (mmHg)

class IndiceShockScreen extends StatelessWidget {
  const IndiceShockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MoldeEscalasScreen(
      heroTag: "indice_shock",
      title: "Índice de Shock",
      icon: PhosphorIconsFill.heartbeat,
      scaleTab: const _IndiceShockLayout(),
      infoTab: const _IndiceShockInfo(),
    );
  }
}

class _IndiceShockLayout extends StatefulWidget {
  const _IndiceShockLayout();

  @override
  State<_IndiceShockLayout> createState() => _IndiceShockLayoutState();
}

class _IndiceShockLayoutState extends State<_IndiceShockLayout> {
  // A diferencia de las demás escalas, el Índice de Shock NO es una suma de
  // opciones categóricas: es una fórmula (FC ÷ PAS). Por eso usa dos campos
  // numéricos (NumericInputField) con cálculo en vivo.
  final TextEditingController _fcController = TextEditingController();
  final TextEditingController _pasController = TextEditingController();

  final FocusNode _fcFocus = FocusNode();
  final FocusNode _pasFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Recalculo en vivo: NumericInputField no expone onChanged, así que se
    // escucha directamente el controller.
    _fcController.addListener(_onInputChanged);
    _pasController.addListener(_onInputChanged);
    // El SnackBar de "valor implausible" se dispara al perder el foco, no en
    // cada tecla (evita avisar mientras el usuario aún está escribiendo).
    _fcFocus.addListener(_onFcFocusChange);
    _pasFocus.addListener(_onPasFocusChange);
  }

  @override
  void dispose() {
    _fcController.dispose();
    _pasController.dispose();
    _fcFocus.dispose();
    _pasFocus.dispose();
    super.dispose();
  }

  void _onInputChanged() => setState(() {});

  double? get _fc => double.tryParse(_fcController.text.trim());
  double? get _pas => double.tryParse(_pasController.text.trim());

  bool _fcPlausible(double? fc) => fc != null && fc >= _fcMin && fc <= _fcMax;
  bool _pasPlausible(double? pas) =>
      pas != null && pas >= _pasMin && pas <= _pasMax;

  // Válido solo si ambos están en rango fisiológico. Como _pasMin > 0, esto
  // también protege la división contra un denominador cero.
  bool get _valido => _fcPlausible(_fc) && _pasPlausible(_pas);

  double get _indice => _fc! / _pas!;

  String get resultado => _valido ? _indice.toStringAsFixed(2) : "";

  void _onFcFocusChange() {
    if (!mounted || _fcFocus.hasFocus) return;
    if (_fcController.text.trim().isEmpty) return;
    if (!_fcPlausible(_fc)) {
      _mostrarSnack(
        "Frecuencia cardíaca fuera de rango fisiológico ($_fcMin–$_fcMax lpm).",
      );
    }
  }

  void _onPasFocusChange() {
    if (!mounted || _pasFocus.hasFocus) return;
    if (_pasController.text.trim().isEmpty) return;
    if (_pas == 0) {
      _mostrarSnack("La presión arterial sistólica no puede ser 0.");
    } else if (!_pasPlausible(_pas)) {
      _mostrarSnack(
        "Presión arterial sistólica fuera de rango fisiológico "
        "($_pasMin–$_pasMax mmHg).",
      );
    }
  }

  void _mostrarSnack(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // ================== FRECUENCIA CARDÍACA ==================
                  NumericInputField(
                    label: "Frecuencia cardíaca (lpm)",
                    controller: _fcController,
                    focusNode: _fcFocus,
                    maxLength: 3, // hasta 999: cubre cualquier FC fisiológica
                    allowDecimal: false, // FC es un entero en la práctica
                  ),
                  const SizedBox(height: 20),

                  // ================== PRESIÓN ARTERIAL SISTÓLICA ==================
                  NumericInputField(
                    label: "Presión arterial sistólica (mmHg)",
                    controller: _pasController,
                    focusNode: _pasFocus,
                    maxLength: 3, // hasta 999: cubre cualquier PAS fisiológica
                    allowDecimal: false, // PAS es un entero en la práctica
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        ScaleResultFooter(
          visible: _valido,
          resultado: resultado,
          colorResolver: (resultado) => _shockColor(_indice),
        ),
      ],
    );
  }
}

class _IndiceShockInfo extends StatelessWidget {
  const _IndiceShockInfo();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: FutureBuilder(
            future: context.read<EscalaRepository>().obtenerPorId(
              "indice_shock",
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || snapshot.data == null) {
                return Center(
                  child: Text(
                    "No se pudo cargar la información de esta escala.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                );
              }
              return EstructuraVerMasScreen(info: snapshot.data!);
            },
          ),
        ),
      ),
    );
  }
}

// Colores específicos del Índice de Shock (según el valor del cociente)
Color _shockColor(double indice) {
  if (indice >= 1.0) return AppColors.redAlertv3; // Shock establecido
  if (indice >= 0.9) return AppColors.redAlertv2; // Alto
  if (indice >= 0.7) return AppColors.redAlertv1; // Elevado
  if (indice >= 0.5) return AppColors.greenAlert; // Normal
  return AppColors.withoutAlert; // < 0.5
}
