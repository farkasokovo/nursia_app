// lib/screens/actualizaciones_screen.dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/nota_version.dart';
import '../theme/app_theme.dart';
import '../theme/alert_colors.dart';
import '../utils/changelog_local.dart';
import '../utils/url_launcher_helper.dart';
import '../utils/verificador_actualizacion.dart';
import '../widgets/lista_cambios.dart';
import '../widgets/tarjeta_desplegable.dart';

/// Pantalla de actualizaciones, desde el menú.
///
/// Dos bloques: el estado de actualización (con verificación manual) y las
/// novedades de la versión instalada, que salen del changelog local y no
/// necesitan internet.
class ActualizacionesScreen extends StatefulWidget {
  const ActualizacionesScreen({super.key});

  @override
  State<ActualizacionesScreen> createState() => _ActualizacionesScreenState();
}

/// Estado de la verificación manual.
enum _EstadoVerificacion { inicial, verificando, alDia, hayNueva, fallo }

class _ActualizacionesScreenState extends State<ActualizacionesScreen> {
  _EstadoVerificacion _estado = _EstadoVerificacion.inicial;

  /// Datos de la versión nueva, cuando la hay.
  InfoActualizacion? _info;
  String? _versionRemota;

  String? _versionInstalada;
  NotaVersion? _notasInstalada;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosLocales();
  }

  /// Versión instalada y notas del changelog. Todo local: sin red.
  Future<void> _cargarDatosLocales() async {
    String? version;
    try {
      version = (await PackageInfo.fromPlatform()).version;
    } catch (e) {
      debugPrint('Actualizaciones: no se pudo leer la versión instalada ($e).');
    }

    final notas = version == null
        ? null
        : await ChangelogLocal.notasDe(version);

    if (!mounted) return;
    setState(() {
      _versionInstalada = version;
      _notasInstalada = notas;
      _cargando = false;
    });
  }

  Future<void> _verificar() async {
    setState(() => _estado = _EstadoVerificacion.verificando);

    // A diferencia del banner del arranque, aquí la verificación la pidió el
    // usuario: el resultado detallado permite separar "al día" de "falló", que
    // buscarActualizacion() reporta igual (null en los dos casos).
    final resultado = await verificarActualizacion();
    if (!mounted) return;

    setState(() {
      switch (resultado) {
        case HayActualizacion(:final info, :final versionRemota):
          _info = info;
          _versionRemota = versionRemota;
          _estado = _EstadoVerificacion.hayNueva;
        case AlDia():
          _estado = _EstadoVerificacion.alDia;
        case FalloVerificacion():
          _estado = _EstadoVerificacion.fallo;
      }
    });
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
          'Actualizaciones',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: SafeArea(
        top: false,
        left: false,
        right: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEstado(colorScheme, textTheme),
              const SizedBox(height: 20),
              _buildNovedades(colorScheme, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bloque A: estado de actualización ────────────────────────────────
  Widget _buildEstado(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
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
                PhosphorIconsBold.arrowsClockwise,
                size: 28,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'Versión instalada',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _cargando ? '...' : (_versionInstalada ?? 'No disponible'),
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.primaryContainer,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _estado == _EstadoVerificacion.verificando
                  ? null
                  : _verificar,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                minimumSize: const Size(double.infinity, 52),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.defaultRadius,
                ),
              ),
              child: Text(
                'Buscar actualizaciones',
                style: textTheme.titleSmall?.copyWith(fontSize: 17),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildResultadoVerificacion(colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildResultadoVerificacion(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    switch (_estado) {
      case _EstadoVerificacion.inicial:
        return Text(
          'La verificación consulta el sitio de Nurska. El resto de la app '
          'funciona sin conexión.',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSecondaryContainer,
          ),
        );

      case _EstadoVerificacion.verificando:
        return Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colorScheme.primaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Verificando...',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.primaryContainer,
              ),
            ),
          ],
        );

      case _EstadoVerificacion.alDia:
        return _mensaje(
          icono: PhosphorIconsFill.checkCircle,
          color: AlertColors.onSurface(context, NivelAlerta.verde),
          texto: 'Nurska está al día.',
          colorScheme: colorScheme,
          textTheme: textTheme,
        );

      case _EstadoVerificacion.fallo:
        // Aquí SÍ se muestra el error: la verificación fue explícita, y callar
        // dejaría el botón sin respuesta aparente.
        return _mensaje(
          icono: PhosphorIconsFill.warningCircle,
          color: colorScheme.error,
          texto:
              'No se pudo verificar. Sin conexión a internet o el sitio no '
              'responde.',
          colorScheme: colorScheme,
          textTheme: textTheme,
        );

      case _EstadoVerificacion.hayNueva:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _mensaje(
              icono: PhosphorIconsFill.arrowCircleUp,
              color: AlertColors.onSurface(context, NivelAlerta.verde),
              texto: 'Versión ${_versionRemota ?? "nueva"} disponible.',
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            if ((_info?.notas ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _info!.notas,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => abrirUrl(context, _info!.urlDescarga),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AlertColors.fill(context, NivelAlerta.verde),
                  foregroundColor: colorScheme.onPrimaryContainer,
                  minimumSize: const Size(double.infinity, 52),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.defaultRadius,
                  ),
                ),
                child: Text(
                  'Ir a la descarga',
                  style: textTheme.titleSmall?.copyWith(fontSize: 17),
                ),
              ),
            ),
          ],
        );
    }
  }

  Widget _mensaje({
    required IconData icono,
    required Color color,
    required String texto,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            texto,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.primaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  // ── Bloque B: novedades de la versión instalada ──────────────────────
  Widget _buildNovedades(ColorScheme colorScheme, TextTheme textTheme) {
    final notas = _notasInstalada;

    return TarjetaDesplegable(
      icono: PhosphorIconsFill.cloudCheck,
      titulo: 'Novedades',
      // El fondo de la pantalla ya es secondaryContainer: la tarjeta necesita
      // un color sólido para no fundirse con él.
      colorFondo: colorScheme.secondary,
      expandidoInicial: true,
      contenido: Padding(
        padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
        child: notas == null
            ? Text(
                _cargando
                    ? 'Cargando...'
                    : 'Esta versión no trae notas registradas.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notas.fecha.isNotEmpty) ...[
                    Text(
                      notas.fechaLegible,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  ListaCambios(
                    cambios: notas.cambios,
                    colorTexto: colorScheme.primaryContainer,
                    colorVinieta: colorScheme.primary,
                  ),
                ],
              ),
      ),
    );
  }
}
