// lib/screens/calculadora_screen.dart
import 'package:flutter/material.dart';
import 'package:nursia_app/screens/calculadoras/calculadora_dosis.dart';
import 'package:nursia_app/screens/calculadoras/calculadora_soluciones.dart';
import 'package:nursia_app/screens/calculadoras/perdidas_insensibles.dart';
import '../widgets/category_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CalculadoraScreen extends StatelessWidget {
  const CalculadoraScreen({super.key});

  // --- LÓGICA DE PAGINACIÓN ---
  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
          i,
          i + chunkSize > list.length ? list.length : i + chunkSize,
        ),
      );
    }
    return chunks;
  }

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
    return OrientationBuilder(
      builder: (context, orientation) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // 1. Lista completa de calculadoras
        final todasLasCalculadoras = [
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
            "Pérdidas\ninsensibles\n(Adultos)",
            PhosphorIconsRegular.waves,
            "perdidasinsensibles",
            const PerdidasInsensibles(),
          ),
          // _buildButton(
          //   context,
          //   "Goteo IV",
          //   PhosphorIconsRegular.dropHalfBottom,
          //   "goteo",
          //   null,
          // ),
          // _buildButton(
          //   context,
          //   "Déficit Agua",
          //   PhosphorIconsRegular.waves,
          //   "agua",
          //   null,
          // ),
          // _buildButton(
          //   context,
          //   "Unidades",
          //   PhosphorIconsRegular.arrowsLeftRight,
          //   "unidades",
          //   null,
          // ),
          // _buildButton(
          //   context,
          //   "Balance\nHídrico",
          //   PhosphorIconsRegular.testTube,
          //   "balance",
          //   null,
          // ),
          // _buildButton(
          //   context,
          //   "Regla de Tres",
          //   PhosphorIconsRegular.mathOperations,
          //   "regla3",
          //   null,
          // ),
          // Puedes seguir agregando más aquí y se paginarán solas
        ];

        // 2. Parámetros de diseño (Iguales a Escalas y Farmaco)
        const int botonesPorPagina = 8;
        const double spacing = 16.0;

        // Ajustamos el estimado superior. En esta pantalla el padding top es 98.
        const double espacioSuperiorEstimado = 220;

        final double espacioDisponible = screenHeight - espacioSuperiorEstimado;
        final double anchoBoton = (screenWidth - 48) / 2;
        final double altoTotalParaBotones = espacioDisponible - (3 * spacing);
        final double altoBotonIdeal = altoTotalParaBotones / 4;

        double ratioDinamico = anchoBoton / altoBotonIdeal;

        final bloques = _chunkList(todasLasCalculadoras, botonesPorPagina);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 98, 16, 0),
          child: SizedBox(
            height: espacioDisponible,
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemCount: bloques.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                      childAspectRatio: ratioDinamico,
                    ),
                    itemCount: bloques[index].length,
                    itemBuilder: (context, i) => bloques[index][i],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
