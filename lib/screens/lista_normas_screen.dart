import 'package:flutter/material.dart';
import 'package:nursia_app/models/norma.dart';
import 'package:nursia_app/repositories/norma_repository.dart';
import 'package:nursia_app/screens/ficha_normativa_screen.dart';
import 'package:nursia_app/theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class ListaNormasFiltradaScreen extends StatefulWidget {
  final String categoria;

  const ListaNormasFiltradaScreen({super.key, required this.categoria});

  @override
  State<ListaNormasFiltradaScreen> createState() =>
      _ListaNormasFiltradaScreenState();
}

class _ListaNormasFiltradaScreenState extends State<ListaNormasFiltradaScreen> {
  List<Norma> _normasFiltradas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarNormas();
  }

  // Se carga UNA sola vez y se guarda en el estado. Antes esto vivía en un
  // FutureBuilder dentro de build(), así que cada reconstrucción provocada por
  // la animación Hero re-lanzaba la consulta y mostraba el spinner un instante
  // → parpadeo. Igual que escalas_screen.dart, ahora el spinner solo aparece
  // en la primera carga.
  Future<void> _cargarNormas() async {
    final todas = await context.read<NormaRepository>().obtenerTodos();
    final categoria = widget.categoria.toLowerCase();
    final filtradas = todas
        .where(
          (n) =>
              n.areaSalud.toLowerCase().contains(categoria) ||
              n.titulo.toLowerCase().contains(categoria),
        )
        .toList();

    if (mounted) {
      setState(() {
        _normasFiltradas = filtradas;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_normasFiltradas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "No hay normas registradas para ${widget.categoria} aún.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _normasFiltradas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final norma = _normasFiltradas[index];

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
  }
}
