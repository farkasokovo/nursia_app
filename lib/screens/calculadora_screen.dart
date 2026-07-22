// lib/screens/calculadora_screen.dart
import 'package:flutter/material.dart';
import 'package:nursia_app/screens/calculadoras/calculadora_dosis.dart';
import 'package:nursia_app/screens/calculadoras/calculadora_goteo.dart';
import 'package:nursia_app/screens/calculadoras/calculadora_pam.dart';
import 'package:nursia_app/screens/calculadoras/calculadora_soluciones.dart';
import 'package:nursia_app/screens/calculadoras/perdidas_insensibles.dart';
import '../widgets/category_grid.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CalculadoraScreen extends StatelessWidget {
  const CalculadoraScreen({super.key});

  CategoriaGridItem _buildButton(
    BuildContext context,
    String title,
    IconData icon,
    String hero,
    Widget? target,
  ) {
    return CategoriaGridItem(
      titulo: title,
      icono: icon,
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
    // Lista completa de calculadoras. Se paginan y acomodan solas dentro de
    // CategoryGrid, que también agrega el placeholder "Próximamente" cuando un
    // bloque queda con número impar de botones.
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
      _buildButton(
        context,
        "Presión arterial\nmedia (PAM)",
        PhosphorIconsRegular.heartbeat,
        "pam",
        const CalculadoraPam(),
      ),
      _buildButton(
        context,
        "Goteo IV\n(gotas/min)",
        PhosphorIconsRegular.dropHalfBottom,
        "goteo",
        const CalculadoraGoteo(),
      ),
      // Puedes seguir agregando más aquí y se paginarán solas
    ];

    // En esta pantalla el padding superior es 98 y el espacio superior
    // estimado para el cálculo de alto de botón es 220 (distinto al default
    // porque no lleva barra de búsqueda arriba).
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 98, 16, 0),
      child: CategoryGrid(
        items: todasLasCalculadoras,
        espacioSuperiorEstimado: 220,
      ),
    );
  }
}
