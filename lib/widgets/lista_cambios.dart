// lib/widgets/lista_cambios.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Lista de cambios de una versión, con viñeta.
///
/// La comparten la pantalla de actualizaciones y la de bienvenida, que muestran
/// el mismo contenido en dos contextos distintos (fondo claro y fondo oscuro),
/// de ahí que los colores se reciban desde afuera.
class ListaCambios extends StatelessWidget {
  const ListaCambios({
    super.key,
    required this.cambios,
    required this.colorTexto,
    required this.colorVinieta,
  });

  final List<String> cambios;
  final Color colorTexto;
  final Color colorVinieta;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final cambio in cambios)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  // Alinea la viñeta con la primera línea del texto.
                  padding: const EdgeInsets.only(top: 3),
                  child: PhosphorIcon(
                    PhosphorIconsFill.circle,
                    size: 8,
                    color: colorVinieta,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    cambio,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorTexto,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
