import 'package:flutter/material.dart';
import 'package:nursia_app/models/norma.dart';
import 'package:nursia_app/utils/url_launcher_helper.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class FichaNormativaScreen extends StatelessWidget {
  final Norma norma;

  const FichaNormativaScreen({super.key, required this.norma});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.secondaryContainer,
      appBar: AppBar(
        title: Text(
          norma.codigo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primaryContainer,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TÍTULO COMPLETO
              Text(
                norma.titulo,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // LA "PASTILLA" GENIAL (Badge de Área de Salud)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  norma.areaSalud,
                  style: TextStyle(
                    color: colorScheme.onSecondaryContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // SEPARADOR DINÁMICO
              Divider(
                height: 32,
                color: colorScheme.primary.withValues(alpha: 0.5),
              ),

              // SECCIÓN: RESUMEN
              _buildSectionHeader(
                textTheme,
                colorScheme,
                "Resumen",
                PhosphorIconsRegular.textColumns,
              ),
              const SizedBox(height: 8),
              Text(
                norma.resumen,
                style: textTheme.bodySmall,
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 24),

              // SECCIÓN: PUNTOS CRÍTICOS
              _buildSectionHeader(
                textTheme,
                colorScheme,
                "Puntos Críticos",
                PhosphorIconsRegular.listChecks,
              ),
              const SizedBox(height: 12),
              ...norma.puntosClave
                  .split('\n')
                  .where((s) => s.trim().isNotEmpty)
                  .map((punto) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              PhosphorIconsFill.caretRight,
                              size: 14,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              punto.replaceFirst('• ', '').trim(),
                              style: textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

              const SizedBox(height: 24),

              // SECCIÓN: REFERENCIA (Estilo link de medicamentos)
              _buildSectionHeader(
                textTheme,
                colorScheme,
                "Referencia Oficial",
                PhosphorIconsRegular.link,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  final RegExp urlRegExp = RegExp(r'https?://[^\s]+');
                  final match = urlRegExp.firstMatch(norma.dofReferencia);
                  if (match != null) {
                    abrirUrl(context, match.group(0)!);
                  }
                },
                child: Text(
                  norma.dofReferencia,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    TextTheme textTheme,
    ColorScheme colorScheme,
    String titulo,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 25, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
