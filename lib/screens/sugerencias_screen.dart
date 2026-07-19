import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../utils/url_launcher_helper.dart';

class SugerenciasScreen extends StatefulWidget {
  const SugerenciasScreen({super.key});

  @override
  State<SugerenciasScreen> createState() => _SugerenciasScreenState();
}

class _SugerenciasScreenState extends State<SugerenciasScreen> {
  late Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  Future<void> _abrirCorreo() async {
    final info = await _packageInfoFuture;
    final asunto = 'Sugerencia para Nurska v${info.version}';
    final uri =
        'mailto:nurska.app@gmail.com?subject=${Uri.encodeComponent(asunto)}';
    debugPrint('Abriendo correo de sugerencias: $uri');
    if (!mounted) return;
    await abrirUrl(context, uri);
  }

  Future<void> _abrirInstagram() async {
    const uri = 'https://instagram.com/diego_munozslv';
    debugPrint('Abriendo Instagram de sugerencias: $uri');
    await abrirUrl(context, uri);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.secondaryContainer,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            PhosphorIconsBold.caretLeft,
            color: colorScheme.onPrimaryContainer,
            size: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sugerencias',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primaryContainer,
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
              Row(
                children: [
                  Icon(
                    PhosphorIconsBold.chatCircleDots,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Me encantaría\nescucharte',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '¿Se te ocurre una función nueva, notaste algo que se puede mejorar, o encontraste un dato incorrecto? Me encantaría escucharte. Nurska crece con la experiencia de quienes la usan en el turno, así que cualquier idea o corrección es bienvenida.',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Si detectaste un error, no dudes en avisarme. Escríbeme con confianza, '
                'sin formalismos.',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              Text('Cómo contactarme', style: textTheme.titleMedium),
              const SizedBox(height: 12),
              _buildContactoTile(
                colorScheme: colorScheme,
                textTheme: textTheme,
                icon: PhosphorIconsBold.envelopeSimple,
                titulo: 'Correo electrónico',
                subtitulo: 'nurska.app@gmail.com',
                onTap: _abrirCorreo,
              ),
              const SizedBox(height: 24),
              Text(
                'Nurska es un proyecto independiente mantenido por un estudiante de enfermería. Cada sugerencia ayuda a que la app sea más útil y segura para todos.',
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactoTile({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 24, color: colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                PhosphorIconsBold.caretRight,
                size: 22,
                color: colorScheme.onSecondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
