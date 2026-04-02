import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../widgets/expandable_category_screen.dart';
import '../../widgets/tabbed_content.dart'; // 👈 IMPORTANTE: importa el nuevo widget
import '../../theme/app_theme.dart'; // solo para AppRadius

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
          const _CalculoDosisLayout(), // contenido del cálculo
          const _InfoDosisTab(), // contenido de información
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

class _CalculoDosisLayoutState extends State<_CalculoDosisLayout> {
  final dosisController = TextEditingController();
  final dilucionController = TextEditingController();
  final presentacionController = TextEditingController();
  double? resultado;

  void calcular() {
    final dosis = double.tryParse(dosisController.text);
    final dilucion = double.tryParse(dilucionController.text);
    final presentacion = double.tryParse(presentacionController.text);

    if (dosis == null ||
        dilucion == null ||
        presentacion == null ||
        presentacion == 0) {
      setState(() => resultado = null);
      return;
    }

    setState(() {
      resultado = (dosis * dilucion) / presentacion;
    });
  }

  void limpiar() {
    dosisController.clear();
    dilucionController.clear();
    presentacionController.clear();
    setState(() => resultado = null);
  }

  @override
  Widget build(BuildContext context) {
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
              controller: dosisController,
              maxLength: 4,
            ),
            const SizedBox(height: 20),
            _DoseInputField(
              label: "Diluyente (ml)",
              controller: dilucionController,
              maxLength: 3,
            ),
            const SizedBox(height: 20),
            _DoseInputField(
              label: "Presentación del fármaco (mg)",
              controller: presentacionController,
              maxLength: 4,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: calcular,
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
                    onPressed: limpiar,
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
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 180),
              child: Container(
                width: double.infinity,
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
                      resultado == null
                          ? "0 ml"
                          : "${resultado!.toStringAsFixed(1)} ml",
                      style: textTheme.displayLarge?.copyWith(
                        color: colorScheme.primaryContainer,
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== PESTAÑA DE INFORMACIÓN ==================
class _InfoDosisTab extends StatelessWidget {
  const _InfoDosisTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Text(
          "Esta calculadora permite determinar la cantidad "
          "exacta de medicamento en mililitros que debe "
          "administrarse al paciente con base en la dosis "
          "indicada, el volumen del diluyente y la "
          "presentación disponible del fármaco.\n\n"
          "Fórmula aplicada:\n"
          "(Dosis indicada × Diluyente) ÷ Presentación.\n\n"
          "Siempre verificar unidades antes de administrar.",
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSecondaryContainer,
          ),
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

  const _DoseInputField({
    required this.label,
    required this.controller,
    required this.maxLength,
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
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primaryContainer,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
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
              border: OutlineInputBorder(
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
