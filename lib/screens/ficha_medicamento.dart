import 'package:flutter/material.dart';
import 'package:nursia_app/repositories/medicamento_repository.dart';
import 'package:nursia_app/utils/icon_mapper.dart';
import 'package:nursia_app/utils/secciones_ficha.dart';
import 'package:nursia_app/utils/url_launcher_helper.dart';
import 'package:nursia_app/widgets/alto_riesgo_badge.dart';
import 'package:nursia_app/widgets/seccion_ficha_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/medicamento.dart';
import 'package:provider/provider.dart';

class FichaMedicamento extends StatefulWidget {
  final String nombreMedicamento;

  const FichaMedicamento({super.key, required this.nombreMedicamento});

  @override
  State<FichaMedicamento> createState() => _FichaMedicamentoState();
}

class _FichaMedicamentoState extends State<FichaMedicamento> {
  late Future<Medicamento?> _medicamentoFuture;

  @override
  void initState() {
    super.initState();
    final medicamentoRepo = context.read<MedicamentoRepository>();
    _medicamentoFuture = medicamentoRepo.obtenerPorNombre(
      widget.nombreMedicamento,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<Medicamento?>(
      future: _medicamentoFuture,
      builder: (context, snapshot) {
        final medicamento = snapshot.data;

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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (medicamento != null) ...[
                  Icon(
                    IconMapper.fromString(medicamento.icono),
                    size: 26,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ],
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.nombreMedicamento,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: colorScheme.primaryContainer,
          ),
          body: _buildBody(snapshot, colorScheme),
        );
      },
    );
  }

  Widget _buildBody(
    AsyncSnapshot<Medicamento?> snapshot,
    ColorScheme colorScheme,
  ) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final medicamento = snapshot.data!;
    final textTheme = Theme.of(context).textTheme;

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
            if (medicamento.altoRiesgo) ...[
              const AltoRiesgoBadge(),
              const SizedBox(height: 16),
            ],
            _buildFormattedSection(
              textTheme,
              seccionPorClave(seccionesFichaMedicamento, 'farmacodinamia'),
              medicamento.farmacodinamia,
            ),
            const SizedBox(height: 16),
            _buildFormattedSection(
              textTheme,
              seccionPorClave(seccionesFichaMedicamento, 'farmacocinetica'),
              medicamento.farmacocinetica,
            ),
            const SizedBox(height: 16),
            _buildFormattedSection(
              textTheme,
              seccionPorClave(seccionesFichaMedicamento, 'indicaciones'),
              medicamento.indicaciones,
            ),
            const SizedBox(height: 16),
            _buildSection(
              textTheme,
              seccionPorClave(seccionesFichaMedicamento, 'via_administracion'),
              medicamento.viaAdministracion,
            ),
            const SizedBox(height: 16),
            _buildContraindicaciones(textTheme, medicamento.contraindicaciones),
            const SizedBox(height: 16),
            _buildListSection(
              textTheme,
              seccionPorClave(seccionesFichaMedicamento, 'efectos_secundarios'),
              medicamento.efectosSecundarios,
            ),
            const SizedBox(height: 16),
            _buildListSection(
              textTheme,
              seccionPorClave(seccionesFichaMedicamento, 'efectos_adversos'),
              medicamento.efectosAdversos,
            ),
            const SizedBox(height: 16),
            _buildInteracciones(textTheme, medicamento.interacciones),
            const SizedBox(height: 16),
            if (medicamento.observaciones != null)
              _buildObservaciones(textTheme, medicamento.observaciones!),
            if (medicamento.observaciones != null) const SizedBox(height: 16),
            _buildReferencias(textTheme, medicamento.referencias),
          ],
        ),
      ),
    );
  }

  // ================== SECCIONES CON FORMATO AUTOMÁTICO ==================

  Widget _buildSection(
    TextTheme textTheme,
    SeccionFicha seccion,
    String contenido,
  ) {
    return SeccionFichaView(
      seccion: seccion,
      children: [
        Text(
          contenido.isEmpty ? "No especificado" : contenido,
          style: textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildFormattedSection(
    TextTheme textTheme,
    SeccionFicha seccion,
    String contenido,
  ) {
    if (contenido.isEmpty) {
      return _buildSection(textTheme, seccion, contenido);
    }

    final RegExp regex = RegExp(r'(^|\n)([A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+):\s*');
    final List<TextSpan> spans = [];
    int lastIndex = 0;

    for (final match in regex.allMatches(contenido)) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: contenido.substring(lastIndex, match.start),
            style: textTheme.bodySmall,
          ),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(0)!,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < contenido.length) {
      spans.add(
        TextSpan(
          text: contenido.substring(lastIndex),
          style: textTheme.bodySmall,
        ),
      );
    }

    return SeccionFichaView(
      seccion: seccion,
      children: [RichText(text: TextSpan(children: spans))],
    );
  }

  Widget _buildListSection(
    TextTheme textTheme,
    SeccionFicha seccion,
    List<String> items,
  ) {
    if (items.isEmpty) return const SizedBox();

    return SeccionFichaView(
      seccion: seccion,
      children: [
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text("• $item", style: textTheme.bodySmall),
          ),
        ),
      ],
    );
  }

  Widget _buildContraindicaciones(
    TextTheme textTheme,
    Contraindicaciones contra,
  ) {
    final children = <Widget>[];

    if (contra.absolutas.isNotEmpty) {
      children.add(Text("Absolutas:", style: textTheme.bodyMedium));
      children.add(const SizedBox(height: 6));
      children.addAll(
        contra.absolutas.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text("• $item", style: textTheme.bodySmall),
          ),
        ),
      );
      children.add(const SizedBox(height: 12));
    }

    if (contra.relativas.isNotEmpty) {
      children.add(Text("Relativas:", style: textTheme.bodyMedium));
      children.add(const SizedBox(height: 6));
      children.addAll(
        contra.relativas.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text("• $item", style: textTheme.bodySmall),
          ),
        ),
      );
    }

    if (children.isEmpty) return const SizedBox();

    final seccion = seccionPorClave(
      seccionesFichaMedicamento,
      'contraindicaciones',
    );

    return SeccionFichaView(seccion: seccion, children: children);
  }

  Widget _buildInteracciones(
    TextTheme textTheme,
    List<Interaccion> interacciones,
  ) {
    if (interacciones.isEmpty) return const SizedBox();
    final colorScheme = Theme.of(context).colorScheme;
    final seccion = seccionPorClave(seccionesFichaMedicamento, 'interacciones');
    return SeccionFichaView(
      seccion: seccion,
      children: [
        ...interacciones.map(
          (inter) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "• ${inter.medicamento}",
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Efecto: ",
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      TextSpan(text: inter.efecto, style: textTheme.bodySmall),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Severidad: ",
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      TextSpan(
                        text: inter.severidad,
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildObservaciones(TextTheme textTheme, Observaciones obs) {
    final colorScheme = Theme.of(context).colorScheme;

    final items = <Map<String, String>>[
      if (obs.preparacion != null)
        {'label': 'Preparación', 'valor': obs.preparacion!},
      if (obs.administracion != null)
        {'label': 'Administración', 'valor': obs.administracion!},
      if (obs.precauciones != null)
        {'label': 'Precauciones', 'valor': obs.precauciones!},
    ];

    if (items.isEmpty) return const SizedBox();

    final seccion = seccionPorClave(seccionesFichaMedicamento, 'observaciones');

    return SeccionFichaView(
      seccion: seccion,
      espacioTitulo: 8,
      children: [
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${item['label']}: ',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  TextSpan(text: item['valor'], style: textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferencias(TextTheme textTheme, List<Referencia> referencias) {
    if (referencias.isEmpty) return const SizedBox();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final seccion = seccionPorClave(seccionesFichaMedicamento, 'referencias');

    return SeccionFichaView(
      seccion: seccion,
      children: [
        ...referencias.map(
          (ref) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: GestureDetector(
              onTap: () => abrirUrl(context, ref.url),
              child: Text(
                ref.text,
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
