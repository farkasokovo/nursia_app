import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nursia_app/repositories/escala_repository.dart';
import 'package:nursia_app/widgets/estructura_ver_mas_screen.dart';
import 'package:nursia_app/widgets/scale_result_footer.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../widgets/molde_escalas_screen.dart';

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
  // numéricos con cálculo en vivo en lugar de ScaleParameterSelector.
  final TextEditingController _fcController = TextEditingController();
  final TextEditingController _pasController = TextEditingController();

  @override
  void dispose() {
    _fcController.dispose();
    _pasController.dispose();
    super.dispose();
  }

  double? get _fc =>
      double.tryParse(_fcController.text.trim().replaceAll(',', '.'));
  double? get _pas =>
      double.tryParse(_pasController.text.trim().replaceAll(',', '.'));

  // Válido solo si ambos son números positivos (evita división entre cero).
  bool get _valido => _fc != null && _pas != null && _fc! > 0 && _pas! > 0;

  double get _indice => _fc! / _pas!;

  String get resultado => _valido ? _indice.toStringAsFixed(2) : "";

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
                  _buildInput(
                    context,
                    title: "Frecuencia cardíaca",
                    hint: "Ej. 110",
                    suffix: "lpm",
                    controller: _fcController,
                  ),
                  const SizedBox(height: 20),

                  // ================== PRESIÓN ARTERIAL SISTÓLICA ==================
                  _buildInput(
                    context,
                    title: "Presión arterial sistólica",
                    hint: "Ej. 100",
                    suffix: "mmHg",
                    controller: _pasController,
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

  Widget _buildInput(
    BuildContext context, {
    required String title,
    required String hint,
    required String suffix,
    required TextEditingController controller,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: AppRadius.defaultRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.primaryContainer,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            onChanged: (_) => setState(() {}),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.primaryContainer,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: hint,
              suffixText: suffix,
              filled: true,
              fillColor: colorScheme.onPrimaryContainer,
              border: OutlineInputBorder(
                borderRadius: AppRadius.defaultRadius,
                borderSide: BorderSide(color: colorScheme.primaryContainer),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.defaultRadius,
                borderSide: BorderSide(color: colorScheme.primaryContainer),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.defaultRadius,
                borderSide: BorderSide(
                  color: colorScheme.primaryContainer,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
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
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
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
