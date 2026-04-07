import 'package:flutter/material.dart';
import 'package:nursia_app/database/database_helper.dart';
import 'package:nursia_app/utils/icon_mapper.dart';
import 'package:nursia_app/utils/url_launcher_helper.dart';
import '../models/medicamento.dart';

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
    // CAMBIO AQUÍ: Ahora usamos el helper
    _medicamentoFuture = DatabaseHelper.instance.obtenerMedicamentoPorNombre(
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
            title: Text(widget.nombreMedicamento),
            backgroundColor: colorScheme.primaryContainer,
            leading: medicamento != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Icon(
                      IconMapper.fromString(medicamento.icono),
                      size: 28,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  )
                : null,
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
            _buildFormattedSection(
              textTheme,
              "Farmacodinamia",
              medicamento.farmacodinamia,
            ),
            const SizedBox(height: 16),
            _buildFormattedSection(
              textTheme,
              "Farmacocinética",
              medicamento.farmacocinetica,
            ),
            const SizedBox(height: 16),
            _buildFormattedSection(
              textTheme,
              "Indicaciones",
              medicamento.indicaciones,
            ),
            const SizedBox(height: 16),
            _buildSection(
              textTheme,
              "Vía de administración",
              medicamento.viaAdministracion,
            ),
            const SizedBox(height: 16),
            _buildContraindicaciones(textTheme, medicamento.contraindicaciones),
            const SizedBox(height: 16),
            _buildListSection(
              textTheme,
              "Efectos secundarios",
              medicamento.efectosSecundarios,
            ),
            const SizedBox(height: 16),
            _buildListSection(
              textTheme,
              "Efectos adversos",
              medicamento.efectosAdversos,
            ),
            const SizedBox(height: 16),
            _buildInteracciones(textTheme, medicamento.interacciones),
            const SizedBox(height: 16),
            _buildReferencias(textTheme, medicamento.referencias),
          ],
        ),
      ),
    );
  }

  // ================== SECCIONES CON FORMATO AUTOMÁTICO ==================

  Widget _buildSection(TextTheme textTheme, String titulo, String contenido) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          contenido.isEmpty ? "No especificado" : contenido,
          style: textTheme.bodySmall,
        ),
      ],
    );
  }

  /// Detecta palabras clave como "Absorción:", "Distribución:", etc.
  /// y las resalta en negrita y color primario.
  Widget _buildFormattedSection(
    TextTheme textTheme,
    String titulo,
    String contenido,
  ) {
    if (contenido.isEmpty) {
      return _buildSection(textTheme, titulo, contenido);
    }

    // Expresión regular para encontrar palabras que terminan en ":" al inicio de línea o después de salto
    final RegExp regex = RegExp(r'(^|\n)([A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+):\s*');
    final List<TextSpan> spans = [];
    int lastIndex = 0;

    for (final match in regex.allMatches(contenido)) {
      // Texto antes de la palabra clave
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: contenido.substring(lastIndex, match.start),
            style: textTheme.bodySmall,
          ),
        );
      }
      // Palabra clave resaltada
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

    // Texto después de la última palabra clave
    if (lastIndex < contenido.length) {
      spans.add(
        TextSpan(
          text: contenido.substring(lastIndex),
          style: textTheme.bodySmall,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: textTheme.titleMedium),
        const SizedBox(height: 6),
        RichText(text: TextSpan(children: spans)),
      ],
    );
  }

  Widget _buildListSection(
    TextTheme textTheme,
    String titulo,
    List<String> items,
  ) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: textTheme.titleMedium),
        const SizedBox(height: 6),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Contraindicaciones", style: textTheme.titleMedium),
        const SizedBox(height: 6),
        ...children,
      ],
    );
  }

  Widget _buildInteracciones(
    TextTheme textTheme,
    List<Interaccion> interacciones,
  ) {
    if (interacciones.isEmpty) return const SizedBox();
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Interacciones", style: textTheme.titleMedium),
        const SizedBox(height: 6),
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

  Widget _buildReferencias(TextTheme textTheme, List<Referencia> referencias) {
    if (referencias.isEmpty) return const SizedBox();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Material de apoyo", style: textTheme.titleMedium),
        const SizedBox(height: 6),
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
