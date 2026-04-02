import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/ver_mas_screen.dart';
import '../theme/app_theme.dart';

class EstructuraVerMasScreen extends StatelessWidget {
  final VerMasScreen info;

  const EstructuraVerMasScreen({super.key, required this.info});

  Widget buildSection(String titulo, List<String> contenido) {
    if (contenido.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        Text(titulo, style: AppTextStyles.titleBrownTextv0),

        const SizedBox(height: 6),

        ...contenido.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text("• $item", style: AppTextStyles.verMasBodyText),
          ),
        ),
      ],
    );
  }

  Widget buildReferencias(
    BuildContext context,
    List<Map<String, dynamic>> refs,
  ) {
    if (refs.isEmpty) {
      return const SizedBox();
    }

    final messenger = ScaffoldMessenger.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        Text("Referencias", style: AppTextStyles.titleBrownTextv0),

        const SizedBox(height: 6),

        ...refs.map(
          (ref) => Padding(
            padding: const EdgeInsets.only(bottom: 6),

            child: GestureDetector(
              onTap: () async {
                final urlString = ref["url"].toString().trim();

                try {
                  final uri = Uri.parse(urlString);

                  final success = await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );

                  if (!success) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text("No se pudo abrir la referencia"),
                      ),
                    );
                  }
                } catch (e) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text("URL inválida en referencias"),
                    ),
                  );
                }
              },

              child: Text(
                ref["text"],

                style: AppTextStyles.bodyDarkBrownText.copyWith(
                  fontSize: 13,
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(info.description, style: AppTextStyles.verMasBodyText),

          const SizedBox(height: 16),

          buildSection("¿Cuándo usarla?", info.whenToUse),

          buildSection("Componentes", info.components),

          buildSection("Interpretación", info.interpretation),

          buildSection("Limitaciones", info.limitations),

          buildSection("Notas clínicas", info.clinicalNotes),

          buildReferencias(context, info.references),
        ],
      ),
    );
  }
}
