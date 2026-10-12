// lib/widgets/tabla_referencia.dart
import 'dart:math'; // EXPERIMENTAL: solo lo usa _anchosProporcionales
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/theme_colors.dart';

/// Tabla de referencia con el estilo de las fichas de Esenciales: encabezado
/// en la barra café y filas con `filaTabla`/`sobreFilaTabla`.
///
/// La comparten la ficha de Esenciales y la pestaña "Información" de signos
/// vitales, para que haya un solo estilo de tabla en la app.
class TablaReferencia extends StatelessWidget {
  final List<String> encabezados;
  final List<List<String>> filas;

  /// true: la tabla se ajusta al ancho y el texto de cada celda se acomoda en
  /// varias líneas (Esenciales, máximo 3 columnas). false: cada columna mide
  /// lo que su texto y la tabla scrollea a lo ancho, para tablas de muchas
  /// columnas que no caben en un celular.
  final bool ajustarAlAncho;

  /// Relleno de gravedad por columna del encabezado, en el orden de
  /// [encabezados]. Null en una posición deja el encabezado normal. Va como
  /// relleno con texto crema, igual que las pastillas de resultado: un color
  /// de texto de alerta no se leería sobre la barra café.
  ///
  /// Las celdas teñidas se estiran al alto del renglón, así que al menos un
  /// encabezado debe ir sin color para que el renglón tenga alto propio.
  final List<Color?>? coloresEncabezado;

  const TablaReferencia({
    super.key,
    required this.encabezados,
    required this.filas,
    this.ajustarAlAncho = true,
    this.coloresEncabezado,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final tabla = Table(
      columnWidths: ajustarAlAncho
          ? _anchosProporcionales(encabezados, filas)
          : null,
      defaultColumnWidth: ajustarAlAncho
          ? const FlexColumnWidth()
          : const IntrinsicColumnWidth(),
      border: TableBorder.symmetric(
        inside: BorderSide(
          color: colorScheme.onSecondaryContainer.withValues(alpha: 0.25),
        ),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(color: colorScheme.primaryContainer),
          children: [
            for (var i = 0; i < encabezados.length; i++)
              _buildEncabezado(context, i, colorScheme, textTheme),
          ],
        ),
        for (final fila in filas)
          TableRow(
            // El fondo de la fila es una SUPERFICIE, no un color "on...":
            // pedirlo a onPrimaryContainer pintaba las filas de casi blanco
            // en oscuro.
            decoration: BoxDecoration(color: ThemeColors.filaTabla(context)),
            children: [
              for (final celda in fila)
                _buildCelda(
                  celda,
                  textTheme.bodySmall?.copyWith(
                    color: ThemeColors.sobreFilaTabla(context),
                  ),
                ),
            ],
          ),
      ],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ajustarAlAncho
          ? tabla
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: tabla,
            ),
    );
  }

  Widget _buildEncabezado(
    BuildContext context,
    int i,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final relleno = coloresEncabezado?[i];
    final estilo = textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: relleno == null
          ? colorScheme.onPrimaryContainer
          // Crema en los dos temas, como el texto de las pastillas.
          : ThemeColors.segunTema(
              context,
              claro: colorScheme.onPrimary,
              oscuro: AppColorsDark.ink,
            ),
    );
    final celda = _buildCelda(encabezados[i], estilo);
    if (relleno == null) return celda;
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.fill,
      child: ColoredBox(color: relleno, child: celda),
    );
  }

  Widget _buildCelda(String texto, TextStyle? estilo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(texto, style: estilo),
    );
  }
}

// ── EXPERIMENTAL: anchos de columna proporcionales ──────────────────────
// Todo lo que sigue existe solo para que las tablas quepan a lo ancho sin
// scroll horizontal. Para revertir: borrar esta función, pasar
// `ajustarAlAncho: false` desde la ficha de Esenciales y quitar el import de
// dart:math.

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
