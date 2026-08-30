// lib/widgets/seccion_ficha_view.dart
// Encabezado y acento de una sección de ficha, compartidos entre la ficha de
// medicamento y la pestaña "Ver más" de las escalas.
//
// Solo depende de `SeccionFicha`, del tema y de los hijos que le pasen, así que
// no arrastra nada de un módulo al otro. Lo que centraliza es la decisión
// visual: cómo se ve un encabezado con ícono y cómo se marca una sección con
// peso clínico. Si esa decisión cambia, cambia en un solo lugar y las dos
// pantallas la siguen.
import 'package:flutter/material.dart';
import '../utils/secciones_ficha.dart';

class SeccionFichaView extends StatelessWidget {
  /// De dónde salen el título, el ícono y el peso clínico.
  final SeccionFicha seccion;

  /// Contenido que va debajo del encabezado. Se reciben ya construidos (y no
  /// un solo `child`) porque todas las secciones son una columna de bloques:
  /// así se evita anidar una Column dentro de otra.
  final List<Widget> children;

  /// Separación entre el encabezado y el contenido. Es parámetro porque
  /// "Observaciones" usa un poco más de aire que el resto.
  final double espacioTitulo;

  const SeccionFichaView({
    super.key,
    required this.seccion,
    required this.children,
    this.espacioTitulo = 6,
  });

  @override
  Widget build(BuildContext context) {
    final contenido = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEncabezado(context),
        SizedBox(height: espacioTitulo),
        ...children,
      ],
    );

    // Las secciones informativas se devuelven tal cual, sin contenedor, para no
    // agregar cajas donde no aportan.
    final acento = seccion.nivel.colorAcento;
    if (acento == null) return contenido;

    // Sin borde lateral de color: el peso clínico lo cargan el tinte de fondo
    // (que sube con el nivel) y el ícono del encabezado, que va teñido con el
    // color de alerta. El borde se veía genérico y, al ser el elemento más
    // fuerte, se llevaba la atención antes que el contenido.
    //
    // Al no haber borde, la caja se cierra por los cuatro lados: el radio es
    // parejo y el padding simétrico. Con el radio solo del lado derecho, el
    // canto izquierdo recto quedaba como resto de un borde que ya no está.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: acento.withValues(alpha: seccion.nivel.opacidadFondo),
        borderRadius: BorderRadius.circular(10),
      ),
      child: contenido,
    );
  }

  /// Ícono + título. El ícono toma el color de acento del nivel de seguridad, o
  /// el color normal del texto si la sección es informativa: es la mitad de la
  /// señal clínica, junto con el tinte de fondo. El título nunca cambia de
  /// color, para que la ficha no se llene de rojo. Las secciones sin ícono se
  /// renderizan solo con el título.
  Widget _buildEncabezado(BuildContext context) {
    final theme = Theme.of(context);
    final acento = seccion.nivel.colorAcento ?? theme.colorScheme.onSecondary;

    final estiloBase = theme.textTheme.titleMedium;
    final estilo = estiloBase?.copyWith(
      fontSize: (estiloBase.fontSize ?? 25) - seccion.nivel.reduccionTitulo,
    );

    final icono = seccion.icono;
    if (icono == null) {
      return Text(seccion.titulo, style: estilo);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Icon(icono, size: seccion.nivel.tamanoIcono, color: acento),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(seccion.titulo, style: estilo)),
      ],
    );
  }
}
