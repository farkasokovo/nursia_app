import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';

/// Peso clínico de una sección de la ficha de medicamento.
///
/// Reutiliza la misma escala de color que las escalas clínicas y las
/// calculadoras (`withoutAlert` leve, `redAlertv1` moderado, `redAlertv2`
/// grave), para que un acento rojizo signifique lo mismo en toda la app.
///
/// El acento es deliberadamente tenue: guía el ojo hacia lo que hay que
/// encontrar rápido, sin competir con `AltoRiesgoBadge`, que sí es un bloque
/// sólido y habla de otra cosa (el fármaco completo, no una sección).
enum NivelSeguridad {
  /// Sección informativa. Sin acento.
  ninguno,

  /// Molesto pero esperable.
  leve,

  /// Requiere vigilancia.
  medio,

  /// Puede contraindicar o dañar. Es lo que se busca primero en un turno.
  alto;

  /// Color del borde izquierdo y del ícono. Null en las secciones sin acento,
  /// que usan el color normal del texto.
  Color? get colorAcento => switch (this) {
    NivelSeguridad.ninguno => null,
    NivelSeguridad.leve => AppColors.withoutAlert,
    NivelSeguridad.medio => AppColors.redAlertv1,
    NivelSeguridad.alto => AppColors.redAlertv2,
  };

  /// Tinte de fondo sobre la tarjeta. Muy bajo a propósito: sobre el crema de
  /// la tarjeta apenas se percibe como una banda cálida, no como un bloque.
  double get opacidadFondo => switch (this) {
    NivelSeguridad.ninguno => 0,
    NivelSeguridad.leve => 0.04,
    NivelSeguridad.medio => 0.05,
    NivelSeguridad.alto => 0.06,
  };

  /// Grosor del borde izquierdo. Es el que carga la gradación, junto con el
  /// color; el fondo casi no cambia entre niveles.
  double get grosorBorde => switch (this) {
    NivelSeguridad.ninguno => 0,
    NivelSeguridad.leve => 3,
    NivelSeguridad.medio => 3,
    NivelSeguridad.alto => 4,
  };

  /// Cuánto se le resta al tamaño normal de `titleMedium` en el encabezado.
  ///
  /// Las secciones con acento llevan el título más chico: el borde de color y
  /// el ícono teñido ya las hacen visibles, así que un título del tamaño
  /// completo dentro de la caja se siente pesado. Es un delta, no un tamaño
  /// fijo, para que siga al tema si `titleBrownText` cambia.
  double get reduccionTitulo => this == NivelSeguridad.ninguno ? 0 : 4;

  /// Tamaño del ícono del encabezado. Baja junto con el título para que la
  /// relación entre ambos se mantenga.
  double get tamanoIcono => this == NivelSeguridad.ninguno ? 26 : 22;
}

/// Una sección de la ficha de medicamento.
///
/// Este archivo es la ÚNICA fuente de verdad de la presentación de las
/// secciones: título visible, ícono y peso clínico. `ficha_medicamento.dart`
/// lee de aquí y no vuelve a escribir un título ni elige un ícono por su
/// cuenta. Cambiar un ícono = cambiar un renglón, en un solo lugar.
///
/// Ojo: esto NO es lo mismo que `icon_mapper.dart`. Aquel mapea el campo
/// `icono` de CADA MEDICAMENTO (una lista abierta que crece con el contenido);
/// esto describe las secciones de la ficha, que son un conjunto fijo.
class SeccionFicha {
  /// Identificador interno. No se muestra.
  final String clave;

  /// Encabezado visible para el usuario.
  final String titulo;

  /// Null cuando la sección va sin ícono. "Material de apoyo" cierra la ficha
  /// y no es contenido clínico que haya que localizar de un vistazo, así que
  /// no compite por atención con las secciones de arriba.
  final IconData? icono;

  final NivelSeguridad nivel;

  const SeccionFicha({
    required this.clave,
    required this.titulo,
    this.icono,
    this.nivel = NivelSeguridad.ninguno,
  });
}

/// Las 10 secciones de la ficha, en el orden en que se muestran.
const List<SeccionFicha> seccionesFichaMedicamento = [
  SeccionFicha(
    clave: 'farmacodinamia',
    titulo: 'Farmacodinamia',
    icono: PhosphorIconsFill.target,
  ),
  SeccionFicha(
    clave: 'farmacocinetica',
    titulo: 'Farmacocinética',
    icono: PhosphorIconsFill.flowArrow,
  ),
  SeccionFicha(
    clave: 'indicaciones',
    titulo: 'Indicaciones',
    icono: PhosphorIconsFill.checkCircle,
  ),
  SeccionFicha(
    clave: 'via_administracion',
    titulo: 'Vía de administración',
    icono: PhosphorIconsFill.path,
  ),
  SeccionFicha(
    clave: 'contraindicaciones',
    titulo: 'Contraindicaciones',
    icono: PhosphorIconsFill.prohibit,
    nivel: NivelSeguridad.alto,
  ),
  SeccionFicha(
    clave: 'efectos_secundarios',
    titulo: 'Efectos secundarios',
    icono: PhosphorIconsFill.warningCircle,
    nivel: NivelSeguridad.leve,
  ),
  SeccionFicha(
    clave: 'efectos_adversos',
    titulo: 'Efectos adversos',
    icono: PhosphorIconsFill.warning,
    nivel: NivelSeguridad.alto,
  ),
  SeccionFicha(
    clave: 'interacciones',
    titulo: 'Interacciones',
    icono: PhosphorIconsFill.arrowsLeftRight,
    nivel: NivelSeguridad.medio,
  ),
  SeccionFicha(
    clave: 'observaciones',
    titulo: 'Observaciones',
    icono: PhosphorIconsFill.notepad,
  ),
  SeccionFicha(clave: 'referencias', titulo: 'Material de apoyo'),
];

/// Busca por clave. Lanza si la clave no existe: a diferencia del contenido
/// clínico (que viene de un JSON y puede traer erratas), estas claves están
/// escritas en el código, así que un fallo aquí es un error de programación
/// que conviene ver de inmediato y no un dato malo que haya que tolerar.
SeccionFicha seccionPorClave(String clave) {
  for (final seccion in seccionesFichaMedicamento) {
    if (seccion.clave == clave) return seccion;
  }
  throw ArgumentError('Sección desconocida en la ficha de medicamento: $clave');
}
