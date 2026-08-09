// lib/screens/esenciales/ficha_esencial_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../models/ficha_esencial.dart';
import '../../utils/esencial_icon_mapper.dart';
import '../../utils/url_launcher_helper.dart';

/// Pantalla de una ficha de Esenciales.
///
/// Recibe la [FichaEsencial] ya construida: la lista de EsencialesScreen la
/// tiene en memoria, así que no hace falta volver a consultar la BD.
///
/// A diferencia de `ficha_medicamento.dart` (que pinta secciones fijas), aquí
/// el contenido es un arreglo ordenado de bloques y la pantalla solo recorre
/// `ficha.contenido` despachando cada uno según su tipo.
class FichaEsencialScreen extends StatelessWidget {
  final FichaEsencial ficha;

  const FichaEsencialScreen({super.key, required this.ficha});

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
        title: Row(
          children: [
            Icon(
              EsencialIconMapper.fromString(ficha.icono),
              size: 26,
              color: colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                ficha.tituloCorto.isEmpty ? ficha.titulo : ficha.tituloCorto,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
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
              Text(ficha.titulo, style: textTheme.titleMedium),
              if (ficha.resumen.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  ficha.resumen,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              for (final bloque in ficha.contenido) ...[
                _buildBloque(context, bloque, colorScheme, textTheme),
                const SizedBox(height: 16),
              ],
              _buildFuente(colorScheme, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  /// Despacho de bloques.
  ///
  /// El switch es exhaustivo sobre la sealed class y NO tiene `default`: si
  /// mañana se agrega un séptimo tipo de bloque, esto deja de compilar y avisa
  /// que falta pintarlo, en vez de desaparecer en silencio.
  Widget _buildBloque(
    BuildContext context,
    BloqueContenido bloque,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final cuerpo = switch (bloque) {
      BloqueTexto(:final valor) => Text(valor, style: textTheme.bodySmall),
      BloqueNota(:final valor) => _buildNota(valor, colorScheme, textTheme),
      BloqueLista(:final estilo, :final items) => _buildLista(
        estilo,
        items,
        textTheme,
      ),
      BloqueTabla(:final encabezados, :final filas) => _buildTabla(
        encabezados,
        filas,
        colorScheme,
        textTheme,
      ),
      BloqueColores(:final items) => _buildColores(items, textTheme),
      BloqueReferencias(:final items) => _buildReferencias(
        context,
        items,
        colorScheme,
        textTheme,
      ),
    };

    // El bloque de referencias es el único con encabezado por defecto: una
    // lista de citas sin título se lee como texto suelto al final de la ficha.
    final titulo =
        bloque.titulo ??
        (bloque is BloqueReferencias ? 'Material de apoyo' : null);

    if (titulo == null) return cuerpo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: textTheme.titleMedium),
        const SizedBox(height: 6),
        cuerpo,
      ],
    );
  }

  // ── Bloques ───────────────────────────────────────────────────────────

  Widget _buildNota(
    String valor,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primaryContainer.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhosphorIcon(
            PhosphorIconsFill.warningCircle,
            size: 20,
            color: colorScheme.primaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              valor,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLista(
    EstiloLista estilo,
    List<String> items,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(switch (estilo) {
              EstiloLista.vinetas => '• ${items[i]}',
              EstiloLista.numerada => '${i + 1}. ${items[i]}',
            }, style: textTheme.bodySmall),
          ),
      ],
    );
  }

  /// Por diseño las tablas no pasan de 3 columnas, pero igual van dentro de un
  /// scroll horizontal: un texto largo en una celda nunca debe provocar
  /// overflow en un celular en vertical.
  Widget _buildTabla(
    List<String> encabezados,
    List<List<String>> filas,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder.symmetric(
            inside: BorderSide(
              color: colorScheme.onSecondaryContainer.withValues(alpha: 0.25),
            ),
          ),
          children: [
            TableRow(
              decoration: BoxDecoration(color: colorScheme.primaryContainer),
              children: [
                for (final encabezado in encabezados)
                  _buildCelda(
                    encabezado,
                    textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
              ],
            ),
            for (final fila in filas)
              TableRow(
                decoration: BoxDecoration(
                  color: colorScheme.onPrimaryContainer,
                ),
                children: [
                  for (final celda in fila)
                    _buildCelda(celda, textTheme.bodySmall),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCelda(String texto, TextStyle? estilo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(texto, style: estilo),
    );
  }

  /// La muestra de color es lo que se viene a consultar (triage, RPBI, tapas
  /// de tubos), así que va grande, no como un puntito al lado del texto.
  Widget _buildColores(List<ItemColor> items, TextTheme textTheme) {
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _hexAColor(item.color),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black26),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.etiqueta,
                        style: textTheme.bodyMedium?.copyWith(fontSize: 15),
                      ),
                      if (item.descripcion != null) ...[
                        const SizedBox(height: 2),
                        Text(item.descripcion!, style: textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// El hex ya viene validado como "#RRGGBB" desde el parseo del modelo, así
  /// que aquí solo se arma el Color opaco.
  Color _hexAColor(String hex) =>
      Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000);

  Widget _buildReferencias(
    BuildContext context,
    List<ItemReferencia> items,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: item.url == null
                // Sin liga (ej. un libro impreso): texto plano, sin subrayado
                // ni gesto, para no prometer un toque que no hace nada.
                ? Text(item.texto, style: textTheme.bodySmall)
                : GestureDetector(
                    onTap: () => abrirUrl(context, item.url!),
                    child: Text(
                      item.texto,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
          ),
      ],
    );
  }

  Widget _buildFuente(ColorScheme colorScheme, TextTheme textTheme) {
    if (ficha.fuente.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          color: colorScheme.onSecondaryContainer.withValues(alpha: 0.25),
        ),
        const SizedBox(height: 4),
        Text(
          'Fuente: ${ficha.fuente}',
          style: textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: colorScheme.onSecondaryContainer.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}
