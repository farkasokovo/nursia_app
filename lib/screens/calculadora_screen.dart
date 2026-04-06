// lib/screens/calculadora_screen.dart
import 'package:flutter/material.dart';
import 'package:nursia_app/screens/calculadoras/calculadora_dosis.dart';
import 'package:nursia_app/screens/calculadoras/calculadora_soluciones.dart';
import '../widgets/category_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CalculadoraScreen extends StatelessWidget {
  const CalculadoraScreen({super.key});

  /// Método para construir los botones de forma estandarizada
  Widget _buildButton(
    BuildContext context,
    String title,
    IconData icon,
    String hero,
    Widget? target,
  ) {
    return CategoryButton(
      title: title,
      icon: icon,
      heroTag: hero,
      onTap: target == null
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'La calculadora de $title aún está en desarrollo',
                  ),
                ),
              );
            }
          : () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => target),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 98, 16, 16),
      child: SizedBox(
        // Ajustamos la altura para que 3 filas de botones (6 en total) quepan cómodamente
        height: screenHeight * 0.65,
        child: PageView(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          children: [
            // BLOQUE 1: 6 botones (3 filas x 2 columnas)
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9,
              children: [
                _buildButton(
                  context,
                  "Regla de tres",
                  PhosphorIconsRegular.mathOperations,
                  "dosis",
                  const CalculadoraDosis(),
                ),
                _buildButton(
                  context,
                  "Soluciones\nglucosadas (%)",
                  PhosphorIconsRegular.drop,
                  "soluciones",
                  const CalculadoraSoluciones(),
                ),
                _buildButton(
                  context,
                  "Balance de\nlíquidos",
                  PhosphorIconsRegular.scales,
                  "imc",
                  null,
                ),
                _buildButton(
                  context,
                  "Goteo IV",
                  PhosphorIconsRegular.dropHalfBottom,
                  "goteo",
                  null,
                ),

                _buildButton(
                  context,
                  "Déficit Agua",
                  PhosphorIconsRegular.waves,
                  "agua",
                  null,
                ),
                _buildButton(
                  context,
                  "Unidades",
                  PhosphorIconsRegular.arrowsLeftRight,
                  "unidades",
                  null,
                ),
              ],
            ),

            // BLOQUE 2: Siguientes 6 botones
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
              children: [
                _buildButton(
                  context,
                  "Balance\nHídrico",
                  PhosphorIconsRegular.testTube,
                  "balance",
                  null,
                ),
                _buildButton(
                  context,
                  "Regla de Tres",
                  PhosphorIconsRegular.mathOperations,
                  "regla3",
                  null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
