import 'package:flutter/material.dart';
import '../models/ver_mas_screen.dart';
import '../utils/secciones_ficha.dart';
import '../utils/url_launcher_helper.dart';
import 'seccion_ficha_view.dart';

/// Pestaña "Ver más" de todas las escalas clínicas.
///
/// Los encabezados y el acento de "Limitaciones" salen de
/// `seccionesFichaEscala` y los pinta `SeccionFichaView`, el mismo widget que
/// usa la ficha de medicamento.
class EstructuraVerMasScreen extends StatelessWidget {
  final VerMasScreen info;

  const EstructuraVerMasScreen({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Se arman primero las secciones con contenido y luego se separan entre sí.
    // Hacerlo en dos pasos evita que una sección vacía deje un hueco doble.
    final secciones = <Widget?>[
      _buildSection(context, 'cuando_usarla', info.whenToUse),
      _buildSection(context, 'componentes', info.components),
      _buildSection(context, 'interpretacion', info.interpretation),
      _buildSection(context, 'limitaciones', info.limitations),
      _buildSection(context, 'notas_clinicas', info.clinicalNotes),
      _buildReferencias(context, info.references),
    ].whereType<Widget>().toList();

    return SingleChildScrollView(
      // Aire inferior + el alto real de la barra del sistema. El molde de las
      // escalas deja el borde inferior sin apartar a propósito (para que el
      // footer de resultado llegue hasta la orilla), así que el "Ver más" se
      // reserva su propio espacio.
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            info.description,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < secciones.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            secciones[i],
          ],
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  /// Devuelve null si la sección no tiene contenido, para que el llamador la
  /// omita junto con su separación.
  Widget? _buildSection(
    BuildContext context,
    String clave,
    List<String> contenido,
  ) {
    if (contenido.isEmpty) return null;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SeccionFichaView(
      seccion: seccionPorClave(seccionesFichaEscala, clave),
      children: [
        ...contenido.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              "• $item",
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildReferencias(
    BuildContext context,
    List<Map<String, dynamic>> refs,
  ) {
    if (refs.isEmpty) return null;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SeccionFichaView(
      seccion: seccionPorClave(seccionesFichaEscala, 'referencias'),
      children: [
        ...refs.map(
          (ref) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: GestureDetector(
              // FIX: Usa helper compartido — elimina código duplicado
              onTap: () => abrirUrl(context, ref["url"].toString()),
              child: Text(
                ref["text"],
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
