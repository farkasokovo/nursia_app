import 'package:flutter/material.dart';
import '../models/ver_mas_screen.dart';
import '../utils/url_launcher_helper.dart';

class EstructuraVerMasScreen extends StatelessWidget {
  final VerMasScreen info;

  const EstructuraVerMasScreen({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
          _buildSection(context, "¿Cuándo usarla?", info.whenToUse),
          _buildSection(context, "Componentes", info.components),
          _buildSection(context, "Interpretación", info.interpretation),
          _buildSection(context, "Limitaciones", info.limitations),
          _buildSection(context, "Notas clínicas", info.clinicalNotes),
          _buildReferencias(context, info.references),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String titulo,
    List<String> contenido,
  ) {
    if (contenido.isEmpty) return const SizedBox();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          titulo,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.primaryContainer,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
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

  Widget _buildReferencias(
    BuildContext context,
    List<Map<String, dynamic>> refs,
  ) {
    if (refs.isEmpty) return const SizedBox();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          "Material de apoyo",
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.primaryContainer,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
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
        const SizedBox(height: 10),
      ],
    );
  }
}
