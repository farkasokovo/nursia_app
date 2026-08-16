// lib/widgets/tarjeta_desplegable.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Construye el widget de la esquina derecha de la cabecera.
///
/// Recibe el estado actual de la tarjeta ([expandido]) y la función que
/// alterna ese estado ([alternar]), para que quien la use pueda decidir el
/// ícono y la acción según esté abierta o cerrada.
typedef AccionTrailingBuilder =
    Widget Function(
      BuildContext context,
      bool expandido,
      VoidCallback alternar,
    );

/// Tarjeta con cabecera clickable (ícono + título + acción a la derecha) que
/// expande y colapsa su contenido con una animación de tamaño.
///
/// Es SOLO la cáscara visual y el comportamiento de expandir/colapsar: el
/// contenido y la acción de la derecha los pone quien la usa.
///
/// ```dart
/// TarjetaDesplegable(
///   icono: PhosphorIconsFill.info,
///   titulo: 'Acerca de Esenciales',
///   contenido: Text('...'),
/// )
/// ```
class TarjetaDesplegable extends StatefulWidget {
  /// Ícono de la cabecera, a la izquierda del título.
  final IconData icono;

  /// Texto de la cabecera.
  final String titulo;

  /// Lo que se muestra al expandir.
  final Widget contenido;

  /// Widget de la esquina derecha de la cabecera. Si es null, se usa un
  /// botón de caret que solo abre/cierra la tarjeta.
  final AccionTrailingBuilder? accionTrailing;

  /// Estado inicial de la tarjeta.
  final bool expandidoInicial;

  /// Color de fondo de la tarjeta.
  ///
  /// Si es null se usa el translúcido de siempre (`secondaryContainer` al
  /// 50 %), que da por hecho que detrás hay un fondo claro (`surface`). Una
  /// pantalla cuyo Scaffold ya sea `secondaryContainer` tiene que pasar un
  /// color sólido, porque ese translúcido sobre ese fondo devuelve
  /// exactamente el color del fondo y la tarjeta desaparece.
  final Color? colorFondo;

  const TarjetaDesplegable({
    super.key,
    required this.icono,
    required this.titulo,
    required this.contenido,
    this.accionTrailing,
    this.expandidoInicial = false,
    this.colorFondo,
  });

  @override
  State<TarjetaDesplegable> createState() => _TarjetaDesplegableState();
}

class _TarjetaDesplegableState extends State<TarjetaDesplegable> {
  late bool _isExpanded = widget.expandidoInicial;

  void _alternar() => setState(() => _isExpanded = !_isExpanded);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        width: double.infinity,
        // Reducimos el padding inferior cuando está colapsado
        padding: EdgeInsets.fromLTRB(12, 5, 12, _isExpanded ? 12 : 5),
        decoration: BoxDecoration(
          color:
              widget.colorFondo ??
              colorScheme.secondaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hacemos que toda la cabecera sea clickable para expandir/colapsar
            InkWell(
              onTap: _alternar,
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Icon(
                    widget.icono,
                    size: 28,
                    color: colorScheme.primaryContainer,
                  ),
                  const SizedBox(width: 8),
                  // Expanded en vez de Text + Spacer: el layout se ve igual
                  // (título a la izquierda, acción hasta la derecha), pero un
                  // título que no cabe se acomoda en dos renglones en vez de
                  // desbordar el Row. Con Spacer, "Acerca de Esenciales" a
                  // 18 px se pasaba 13 px en pantallas de 320 dp.
                  Expanded(
                    child: Text(
                      widget.titulo,
                      style: textTheme.bodyLarge?.copyWith(fontSize: 18),
                    ),
                  ),
                  widget.accionTrailing?.call(
                        context,
                        _isExpanded,
                        _alternar,
                      ) ??
                      IconButton(
                        onPressed: _alternar,
                        icon: Icon(
                          _isExpanded
                              ? PhosphorIconsRegular.caretUp
                              : PhosphorIconsRegular.caretDown,
                          size: 20,
                          color: colorScheme.primaryContainer,
                        ),
                      ),
                ],
              ),
            ),
            // Solo mostramos el contenido si está expandido
            if (_isExpanded) ...[const SizedBox(height: 8), widget.contenido],
          ],
        ),
      ),
    );
  }
}
