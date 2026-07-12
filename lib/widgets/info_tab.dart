// lib/widgets/info_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calculadora_info.dart';
import '../repositories/calculadora_repository.dart';
import '../utils/url_launcher_helper.dart';

class InfoTab extends StatefulWidget {
  final String calculadoraId;

  const InfoTab({super.key, required this.calculadoraId});

  @override
  State<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> with AutomaticKeepAliveClientMixin {
  late final Future<CalculadoraInfo> _infoFuture;

  @override
  void initState() {
    super.initState();
    _infoFuture = context.read<CalculadoraRepository>().obtenerPorId(
      widget.calculadoraId,
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return FutureBuilder<CalculadoraInfo>(
      future: _infoFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final info = snapshot.data!;

        return SingleChildScrollView(
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
                Text(info.descripcion, style: textTheme.bodySmall),
                const SizedBox(height: 16),
                Text("Fórmula", style: textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(info.formula, style: textTheme.bodySmall),
                const SizedBox(height: 16),
                Text("Notas clínicas", style: textTheme.titleMedium),
                const SizedBox(height: 8),
                ...info.notas.map(
                  (n) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text("• $n", style: textTheme.bodySmall),
                  ),
                ),
                const SizedBox(height: 16),
                Text("Material de apoyo", style: textTheme.titleMedium),
                const SizedBox(height: 8),
                ...info.referencias.map(
                  (ref) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: GestureDetector(
                      // FIX: Usa helper compartido — mismo comportamiento que estructura_ver_mas_screen
                      // FIX: Elimina canLaunchUrl() deprecado
                      onTap: () => abrirUrl(context, ref['url']!),
                      child: Text(
                        "• ${ref['text']}",
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
            ),
          ),
        );
      },
    );
  }
}
