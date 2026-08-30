// lib/widgets/opcion_selector.dart
//
// Fila de botones para elegir una opción entre varias: un botón por opción, con
// el seleccionado resaltado.
//
// Antes existía dos veces (el selector de mcg/mg/g de la calculadora de dosis y
// el de tipo de equipo de la de goteo) con exactamente el mismo estilo. Al ser
// genérico sirve para cualquier enum, y cualquier ajuste visual (o el efecto de
// selección) se hace en un solo lugar.

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OpcionSelector<T> extends StatelessWidget {
  const OpcionSelector({
    super.key,
    required this.opciones,
    required this.seleccionada,
    required this.onChanged,
    required this.etiqueta,
  });

  /// Opciones a mostrar, en el orden en que aparecen (normalmente `X.values`).
  final List<T> opciones;

  /// Opción actualmente seleccionada.
  final T seleccionada;

  /// Se llama con la opción tocada. El estado lo mantiene la pantalla.
  final ValueChanged<T> onChanged;

  /// Texto de cada botón.
  final String Function(T opcion) etiqueta;

  /// Alto fijo del botón. No cambia al seleccionar: si el botón creciera, la
  /// columna entera daría un salto en pantalla.
  static const double _alto = 44;

  /// Separación entre botones.
  static const double _separacion = 8;

  /// Cuánto crece el texto de la opción seleccionada, en puntos. Es el mismo
  /// recurso visual que usan las pestañas del TabBar de las calculadoras: el
  /// texto activo se ve más grande. Sube solo el texto, no el botón.
  static const double _crecimientoSeleccion = 3;

  /// Duración del crecimiento del texto. Corta: acompaña el toque, no lo
  /// retrasa.
  static const Duration _duracionSeleccion = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final estiloBase = textTheme.labelLarge ?? const TextStyle();
    // Tamaño en reposo: el que ya tenía el selector antes de unificarse.
    final tamanoBase = estiloBase.fontSize ?? 14;

    return Row(
      children: [
        for (var i = 0; i < opciones.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: i == opciones.length - 1 ? 0 : _separacion,
              ),
              child: _boton(
                opcion: opciones[i],
                seleccionado: opciones[i] == seleccionada,
                colorScheme: colorScheme,
                estiloBase: estiloBase,
                tamanoBase: tamanoBase,
              ),
            ),
          ),
      ],
    );
  }

  Widget _boton({
    required T opcion,
    required bool seleccionado,
    required ColorScheme colorScheme,
    required TextStyle estiloBase,
    required double tamanoBase,
  }) {
    return OutlinedButton(
      onPressed: () => onChanged(opcion),
      style: OutlinedButton.styleFrom(
        backgroundColor: seleccionado
            ? colorScheme.primaryContainer
            : colorScheme.primary,
        foregroundColor: seleccionado
            ? colorScheme.onPrimaryContainer
            : colorScheme.primaryContainer,
        minimumSize: const Size(double.infinity, _alto),
        padding: EdgeInsets.zero,
        side: BorderSide(color: colorScheme.primaryContainer),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.defaultRadius,
        ),
      ),
      // FittedBox: red de seguridad para pantallas angostas. Con el texto ya
      // crecido, encoge en vez de desbordar el botón.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: AnimatedDefaultTextStyle(
          duration: _duracionSeleccion,
          curve: Curves.easeOut,
          style: estiloBase.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
            fontSize: seleccionado
                ? tamanoBase + _crecimientoSeleccion
                : tamanoBase,
          ),
          child: Text(etiqueta(opcion)),
        ),
      ),
    );
  }
}
