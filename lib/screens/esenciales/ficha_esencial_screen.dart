// lib/screens/esenciales/ficha_esencial_screen.dart
import 'dart:math'; // EXPERIMENTAL: solo lo usa _anchosProporcionales
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:provider/provider.dart';

import '../../models/ficha_esencial.dart';
import '../../models/termino_glosario.dart';
import '../../repositories/glosario_repository.dart';
import '../../utils/esencial_icon_mapper.dart';
import '../../utils/secciones_ficha.dart';
import '../../utils/url_launcher_helper.dart';

/// Pantalla de una ficha de Esenciales.
///
/// Recibe la [FichaEsencial] ya construida: la lista de EsencialesScreen la
/// tiene en memoria, así que no hace falta volver a consultar la BD.
///
/// A diferencia de `ficha_medicamento.dart` (que pinta secciones fijas), aquí
/// el contenido es un arreglo ordenado de bloques y la pantalla solo recorre
/// `ficha.contenido` despachando cada uno según su tipo.
class FichaEsencialScreen extends StatefulWidget {
  final FichaEsencial ficha;

  const FichaEsencialScreen({super.key, required this.ficha});

  @override
  State<FichaEsencialScreen> createState() => _FichaEsencialScreenState();
}

class _FichaEsencialScreenState extends State<FichaEsencialScreen> {
  /// Tamaño del subtítulo de un bloque. El título de bloque (titleMedium) mide
  /// 25; este es el único número que no sale del tema, porque no hay un estilo
  /// intermedio entre titleMedium y bodySmall al cual colgarse.
  static const double _tamanoSubtitulo = 17;

  /// Peso visual del contenedor del glosario. Es el mismo nivel con el que se
  /// pinta "Efectos secundarios" en la ficha de medicamento: el color de fondo
  /// y su opacidad se LEEN de aquí, nunca se copian, para que el glosario siga
  /// cualquier ajuste de ese tinte.
  static const NivelSeguridad _nivelGlosario = NivelSeguridad.leve;

  /// Cuánto se le resta a los tamaños del tema DENTRO del glosario: encabezado,
  /// término, desglose y definición.
  ///
  /// Es un delta y no un tamaño fijo, igual que `NivelSeguridad.reduccionTitulo`,
  /// para que siga al tema si los estilos base cambian. El glosario es contenido
  /// de apoyo y el contenedor teñido ya lo distingue, así que no necesita el
  /// tamaño pleno del cuerpo de la ficha.
  static const double _reduccionGlosario = 2;

  /// Aplica [_reduccionGlosario] sobre un estilo del tema. [tamanoPorDefecto]
  /// es el respaldo por si el estilo llegara sin fontSize.
  TextStyle? _reducido(TextStyle? base, double tamanoPorDefecto) =>
      base?.copyWith(
        fontSize: (base.fontSize ?? tamanoPorDefecto) - _reduccionGlosario,
      );

  /// Términos del glosario indexados por id, resueltos UNA sola vez al abrir
  /// la ficha: no por bloque ni por término. Una ficha sin bloques "glosario"
  /// ni siquiera consulta la base.
  late final Future<Map<String, TerminoGlosario>>? _glosario;

  @override
  void initState() {
    super.initState();
    _glosario = widget.ficha.contenido.whereType<BloqueGlosario>().isEmpty
        ? null
        : context.read<GlosarioRepository>().obtenerPorId();
  }

  @override
  Widget build(BuildContext context) {
    final ficha = widget.ficha;
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
      // Mientras el glosario no llegue, la ficha se pinta completa salvo sus
      // bloques "glosario": es una lectura local de una tabla chica, así que
      // dura un frame o dos y no hay pantalla en blanco ni spinner de por
      // medio. El null distingue "todavía no cargó" de "cargó y está vacío",
      // que es lo que decide si se avisa por debugPrint.
      body: FutureBuilder<Map<String, TerminoGlosario>>(
        future: _glosario,
        builder: (context, snapshot) =>
            _buildCuerpo(context, snapshot.data, colorScheme, textTheme),
      ),
    );
  }

  Widget _buildCuerpo(
    BuildContext context,
    Map<String, TerminoGlosario>? glosario,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final ficha = widget.ficha;

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
              _buildBloque(context, bloque, glosario, colorScheme, textTheme),
              const SizedBox(height: 16),
            ],
            _buildFuente(colorScheme, textTheme),
          ],
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
    Map<String, TerminoGlosario>? glosario,
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
      BloqueGlosario() => _buildGlosario(
        context,
        bloque,
        glosario,
        colorScheme,
        textTheme,
      ),
    };

    // El glosario trae su propio encabezado dentro del desplegable, así que no
    // pasa por el envoltorio de título y subtítulo de los demás bloques.
    if (bloque is BloqueGlosario) return cuerpo;

    // El bloque de referencias es el único con encabezado por defecto: una
    // lista de citas sin título se lee como texto suelto al final de la ficha.
    final titulo =
        bloque.titulo ??
        (bloque is BloqueReferencias ? 'Material de apoyo' : null);

    // El subtítulo se pinta con o sin título. Un bloque con subtítulo solo es
    // una entrada que cuelga del bloque anterior: así el glosario lleva un
    // único encabezado "Glosario" y cada término debajo con su propio
    // subtítulo, sin repetir el encabezado en cada entrada.
    final subtitulo = bloque.subtitulo;
    if (titulo == null && subtitulo == null) return cuerpo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titulo != null) Text(titulo, style: textTheme.titleMedium),
        if (subtitulo != null) ...[
          if (titulo != null) const SizedBox(height: 2),
          // La MISMA tipografía del título (familia y peso salen de
          // titleMedium), solo que más chica y en el café claro del tema. Así
          // se lee como dependiente del título y no como un encabezado propio.
          Text(
            subtitulo,
            style: textTheme.titleMedium?.copyWith(
              fontSize: _tamanoSubtitulo,
              color: colorScheme.primary,
            ),
          ),
        ],
        const SizedBox(height: 6),
        cuerpo,
      ],
    );
  }

  // ── Bloques ───────────────────────────────────────────────────────────

  /// Sección plegable, cerrada por defecto, con las definiciones que la ficha
  /// cita por id.
  ///
  /// Los términos se pintan en el orden del arreglo del bloque, no en orden
  /// alfabético: ese orden lo decide quien escribe la ficha y suele ser
  /// pedagógico.
  Widget _buildGlosario(
    BuildContext context,
    BloqueGlosario bloque,
    Map<String, TerminoGlosario>? glosario,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    // Todavía no llega de la base: se deja el hueco sin avisar, porque no es
    // un error de contenido sino un frame de más.
    if (glosario == null) return const SizedBox.shrink();

    final resueltos = <TerminoGlosario>[];
    final vistos = <String>{};
    for (final id in bloque.terminos) {
      // Un id repetido dentro del mismo bloque se pinta una sola vez.
      if (!vistos.add(id)) continue;
      final termino = glosario[id];
      if (termino == null) {
        debugPrint(
          'Esenciales: el glosario no tiene el término "$id" que cita la '
          'ficha, se omite.',
        );
        continue;
      }
      resueltos.add(termino);
    }

    // Si ningún id resolvió, no tiene caso dibujar un desplegable vacío.
    if (resueltos.isEmpty) {
      debugPrint(
        'Esenciales: ningún término del bloque "glosario" existe '
        '(${bloque.terminos.join(", ")}), se omite el bloque.',
      );
      return const SizedBox.shrink();
    }

    final estiloTermino = _reducido(textTheme.titleMedium, 25);

    final desplegable = Theme(
      // ExpansionTile dibuja una línea arriba y otra abajo al desplegarse.
      // Aquí estorban: el bloque ya vive dentro de su propio contenedor.
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        // Tocar el encabezado, y no solo el caret, alterna abierto y cerrado:
        // es el comportamiento que ExpansionTile trae de fábrica.
        title: Text(bloque.titulo ?? 'Glosario', style: estiloTermino),
        initiallyExpanded: false,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 4),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        iconColor: colorScheme.primaryContainer,
        collapsedIconColor: colorScheme.primaryContainer,
        children: [
          for (final termino in resueltos)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Misma jerarquía visual que el título y el subtítulo de
                  // cualquier otro bloque de la ficha, un punto más chica.
                  Text(termino.termino, style: estiloTermino),
                  if (termino.desglose != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      termino.desglose!,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: _tamanoSubtitulo - _reduccionGlosario,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  // Las referencias del término NO se pintan: el campo existe
                  // como registro de dónde salió cada definición, no como
                  // contenido de la app. Ver TerminoGlosario.referencias.
                  Text(
                    termino.definicion,
                    style: _reducido(textTheme.bodySmall, 15),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    // El glosario va COMPLETO dentro del contenedor, encabezado incluido, para
    // que se lea como una zona aparte del contenido de la ficha.
    final acento = _nivelGlosario.colorAcento(context);
    if (acento == null) return desplegable;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: acento.withValues(alpha: _nivelGlosario.opacidadFondo(context)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: desplegable,
    );
  }

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

  /// La tabla se ajusta al ancho disponible: no hay scroll horizontal, el
  /// texto de cada celda se acomoda en varias líneas dentro de su columna.
  /// El ancho de cada columna lo reparte [_anchosProporcionales].
  Widget _buildTabla(
    List<String> encabezados,
    List<List<String>> filas,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Table(
        columnWidths: _anchosProporcionales(encabezados, filas),
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
              decoration: BoxDecoration(color: colorScheme.onPrimaryContainer),
              children: [
                for (final celda in fila)
                  _buildCelda(celda, textTheme.bodySmall),
              ],
            ),
        ],
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
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.26)
                          : Colors.black26,
                    ),
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
    if (widget.ficha.fuente.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          color: colorScheme.onSecondaryContainer.withValues(alpha: 0.25),
        ),
        const SizedBox(height: 4),
        Text(
          'Fuente: ${widget.ficha.fuente}',
          style: textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: colorScheme.onSecondaryContainer.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

// ── EXPERIMENTAL: anchos de columna proporcionales ──────────────────────
// Todo lo que sigue existe solo para que las tablas quepan a lo ancho sin
// scroll horizontal. Para revertir: borrar esta función, quitar la línea
// `columnWidths:` de _buildTabla, volver a envolver la tabla en un
// SingleChildScrollView horizontal con `defaultColumnWidth:
// IntrinsicColumnWidth()`, y quitar el import de dart:math.

/// Reparte el ancho disponible entre las columnas según cuánto texto lleva
/// cada una, para que ninguna quede aplastada ni acapare el renglón.
///
/// El peso NO es el largo promedio crudo sino su raíz cuadrada. Con el largo
/// crudo, en la tabla de regiones del abdomen ("Región" contra "Estructuras")
/// la primera columna se quedaba con ~22% del ancho y partía "Hipocondrio" a
/// media palabra. La raíz suaviza la diferencia sin volver iguales a las
/// columnas. Para usar la proporción cruda, quitar el sqrt.
///
/// El piso y el techo se aplican sobre el peso relativo al promedio (donde
/// 1.0 = columna promedio): ninguna columna baja de la mitad ni sube del
/// doble de ese promedio.
Map<int, TableColumnWidth> _anchosProporcionales(
  List<String> encabezados,
  List<List<String>> filas,
) {
  const pesoMinimo = 0.5;
  const pesoMaximo = 2.0;

  final pesos = <double>[];
  for (var i = 0; i < encabezados.length; i++) {
    // El encabezado cuenta como una celda más: una columna titulada
    // "Estructuras" con celdas cortas no debería quedar más angosta que su
    // propio título.
    var caracteres = encabezados[i].length;
    var celdas = 1;
    for (final fila in filas) {
      if (i < fila.length) {
        caracteres += fila[i].length;
        celdas++;
      }
    }
    pesos.add(sqrt(caracteres / celdas));
  }

  final promedio = pesos.reduce((a, b) => a + b) / pesos.length;
  return {
    for (var i = 0; i < pesos.length; i++)
      i: FlexColumnWidth((pesos[i] / promedio).clamp(pesoMinimo, pesoMaximo)),
  };
}
