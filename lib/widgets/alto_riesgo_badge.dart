// lib/widgets/alto_riesgo_badge.dart
// Etiqueta compartida para marcar medicamentos de alto riesgo (electrolitos
// concentrados, insulinas, anticoagulantes, citotóxicos) en la ficha
// individual y en los botones de categoría de Farmacología.
//
// Las dos variantes se ven distinto a propósito, porque viven sobre fondos
// distintos:
//
//   - Banner (ficha): va sobre la tarjeta crema. Ahí `redAlertv1` contrasta
//     4.24:1 contra el fondo, así que el relleno solo ya se impone.
//   - Chip: va sobre el café de `colorScheme.primary`, tanto en el
//     `FarmaButton` de las pantallas de categoría como en las tarjetas de
//     resultado del buscador. El café y los rojos de la paleta son tonos
//     cálidos vecinos, así que el relleno contrasta poco (`redAlertv3` queda
//     en 1.69:1) y quien recorta la marca es el contenido blanco: el ícono y
//     la leyenda dan 6.98:1 sobre ese rojo.
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';

class AltoRiesgoBadge extends StatelessWidget {
  /// true para el chip que va dentro de un `FarmaButton`; false para el banner
  /// de ancho completo que encabeza la ficha del medicamento.
  final bool compact;

  const AltoRiesgoBadge({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return compact ? _buildChip() : _buildBanner();
  }

  /// Banner de ancho completo para la ficha. Es el elemento con más peso
  /// visual de la pantalla: habla del fármaco entero, no de una sección, así
  /// que debe ganarle a los acentos de las secciones de seguridad.
  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.redAlertv1,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.redAlertv4.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(PhosphorIconsFill.warning, color: Colors.white, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "ALTO RIESGO",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Chip para el `FarmaButton`. Reemplaza a la línea de texto gris que se
  /// confundía con un subtítulo.
  ///
  /// Va dentro de un `FittedBox` porque el espacio que le queda en el botón
  /// depende del ancho de la pantalla y del largo del nombre del fármaco. Si
  /// no cabe, el chip se encoge en bloque en vez de desbordarse o de recortar
  /// la leyenda con puntos suspensivos: "ALTO RIE..." sería inaceptable en una
  /// marca de seguridad.
  Widget _buildChip() {
    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: _buildChipContent(),
      ),
    );
  }

  Widget _buildChipContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.redAlertv3,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIconsFill.warning, color: Colors.white, size: 12),
          SizedBox(width: 5),
          Text(
            "ALTO RIESGO",
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
