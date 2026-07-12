import 'package:flutter/material.dart';
import 'package:nursia_app/models/norma.dart';
import 'package:nursia_app/repositories/norma_repository.dart';
import 'package:nursia_app/screens/ficha_normativa_screen.dart';
import 'package:nursia_app/theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class ListaNormasFiltradaScreen extends StatelessWidget {
  final String categoria;

  const ListaNormasFiltradaScreen({super.key, required this.categoria});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Quitamos 'colorScheme' porque solo se usaba en la AppBar que eliminamos

    // Devolvemos el FutureBuilder directo, sin Scaffold
    return FutureBuilder<List<Norma>>(
      future: context.read<NormaRepository>().obtenerTodos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final normasFiltradas =
            snapshot.data
                ?.where(
                  (n) =>
                      n.areaSalud.toLowerCase().contains(
                        categoria.toLowerCase(),
                      ) ||
                      n.titulo.toLowerCase().contains(categoria.toLowerCase()),
                )
                .toList() ??
            [];

        if (normasFiltradas.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "No hay normas registradas para $categoria aún.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: normasFiltradas.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final norma = normasFiltradas[index];

            return SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FichaNormativaScreen(norma: norma),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.defaultRadius,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(PhosphorIconsRegular.fileText, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(norma.codigo, style: theme.textTheme.titleSmall),
                          Text(
                            norma.tituloCorto,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      PhosphorIconsRegular.caretRight,
                      color: Colors.white54,
                      size: 30,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
