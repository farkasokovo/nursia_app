import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../utils/url_launcher_helper.dart';

class AcercaDeScreen extends StatefulWidget {
  const AcercaDeScreen({super.key});

  @override
  State<AcercaDeScreen> createState() => _AcercaDeScreenState();
}

class _AcercaDeScreenState extends State<AcercaDeScreen> {
  late Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  Future<void> _abrirSitioWeb() async {
    const uri = 'https://farkasokovo.github.io/nurska-app/';
    debugPrint('Abriendo sitio web de Nurska: $uri');
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
          'Acerca de',
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
                    PhosphorIconsBold.heartbeat,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Nurska',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              FutureBuilder<PackageInfo>(
                future: _packageInfoFuture,
                builder: (context, snapshot) {
                  final version = snapshot.data?.version;
                  return Text(
                    version == null ? 'Versión: ...' : 'Versión: $version',
                    style: textTheme.bodySmall,
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildEnlaceTile(
                colorScheme: colorScheme,
                textTheme: textTheme,
                icon: PhosphorIconsBold.globe,
                titulo: 'Sitio web de Nurska',
                subtitulo: 'farkasokovo.github.io/nurska-app',
                onTap: _abrirSitioWeb,
              ),
              const SizedBox(height: 20),
              Text('Descripción', style: textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                'Nurska es una herramienta de referencia para '
                'profesionales y estudiantes de enfermería. Reúne '
                'calculadoras, escalas de valoración, fichas farmacológicas '
                'y normativa vigente en un solo lugar, y está pensada para '
                'consultarse rápido, incluso sin conexión a internet, '
                'durante el turno.',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              Text('Aviso legal', style: textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                'Nurska es una herramienta de apoyo a la consulta clínica y '
                'no sustituye el juicio profesional, la valoración '
                'individualizada del paciente, ni los protocolos y '
                'políticas institucionales vigentes. La información '
                'contenida se ofrece con fines de referencia y educativos. '
                'Verifica siempre los datos críticos (dosis, diluciones, '
                'contraindicaciones) contra fuentes oficiales y las '
                'indicaciones de tu institución antes de aplicarlos en la '
                'práctica clínica.',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    PhosphorIconsBold.wifiSlash,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nurska funciona 100% de forma local: ningún dato sale '
                      'de tu dispositivo ni requiere conexión a internet.',
                      style: textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () => showLicensePage(
                    context: context,
                    applicationName: 'Nurska',
                  ),
                  icon: const Icon(PhosphorIconsBold.scroll),
                  label: const Text('Licencias de terceros'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnlaceTile({
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
