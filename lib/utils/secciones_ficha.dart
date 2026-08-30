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

  /// Color del ícono del encabezado y del tinte de fondo. Null en las secciones
  /// sin acento, que usan el color normal del texto y no llevan fondo.
  Color? get colorAcento => switch (this) {
    NivelSeguridad.ninguno => null,
    NivelSeguridad.leve => AppColors.withoutAlert,
    NivelSeguridad.medio => AppColors.redAlertv1,
    NivelSeguridad.alto => AppColors.redAlertv2,
  };

  /// Tinte de fondo sobre la tarjeta.
  ///
  /// Antes había además un borde izquierdo de color, y era ese borde el que
  /// cargaba la gradación entre niveles; el fondo casi no cambiaba. Al quitarse
  /// el borde, la gradación pasó aquí: los tres valores se separaron para que
  /// un nivel se distinga del siguiente sin él.
  ///
  /// Siguen siendo tintes, no bloques. Sobre el crema de la tarjeta (#EFE9E4)
  /// quedan en #E8E0D9 (leve), #E6DAD6 (medio) y #E0D3CF (alto): un lavado
  /// cálido que se nota de reojo sin competir con `AltoRiesgoBadge`, que sí es
  /// un bloque sólido.
  double get opacidadFondo => switch (this) {
    NivelSeguridad.ninguno => 0,
    NivelSeguridad.leve => 0.08,
    NivelSeguridad.medio => 0.11,
    NivelSeguridad.alto => 0.15,
  };

  /// Cuánto se le resta al tamaño normal de `titleMedium` en el encabezado.
  ///
  /// Las secciones con acento llevan el título más chico: el fondo teñido y el
  /// ícono de color ya las hacen visibles, así que un título del tamaño
  /// completo dentro de la caja se siente pesado. Es un delta, no un tamaño
  /// fijo, para que siga al tema si `titleBrownText` cambia.
  double get reduccionTitulo => this == NivelSeguridad.ninguno ? 0 : 4;

  /// Tamaño del ícono del encabezado. Baja junto con el título para que la
  /// relación entre ambos se mantenga.
  double get tamanoIcono => this == NivelSeguridad.ninguno ? 26 : 22;
}

/// Una sección de una ficha de referencia.
///
/// Este archivo es la ÚNICA fuente de verdad de la presentación de las
/// secciones: título visible, ícono y peso clínico. Las pantallas leen de aquí
/// y no vuelven a escribir un título ni a elegir un ícono por su cuenta.
/// Cambiar un ícono = cambiar un renglón, en un solo lugar.
///
/// `NivelSeguridad` y `SeccionFicha` describen "peso clínico de una sección",
/// que no tiene nada de específico de medicamentos, así que abajo viven varias
/// listas: una por módulo que necesite esta jerarquía.
///
/// Ojo: esto NO es lo mismo que `icon_mapper.dart`. Aquel mapea el campo
/// `icono` de CADA MEDICAMENTO (una lista abierta que crece con el contenido);
/// esto describe las secciones de una ficha, que son un conjunto fijo.
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

// ── Secciones que se repiten idénticas en más de un módulo ────────────────
//
// Se definen una sola vez y las listas de abajo las referencian. Así "la misma
// sección se ve igual en toda la app" queda garantizado por el código, en vez
// de depender de acordarse de copiar el mismo ícono y el mismo título.
//
// Solo entran aquí las secciones que coinciden por completo: clave, título,
// ícono y nivel. "Observaciones" de medicamentos, por ejemplo, comparte el
// ícono con "Notas clínicas" porque nombra lo mismo, pero es otra sección con
// otro título, así que se queda definida aparte.

/// Notas de práctica. La comparten escalas y calculadoras.
const SeccionFicha _seccionNotasClinicas = SeccionFicha(
  clave: 'notas_clinicas',
  titulo: 'Notas clínicas',
  icono: PhosphorIconsFill.notepad,
);

/// Cierra las tres fichas. Va sin ícono: no es contenido clínico que haya que
/// localizar de un vistazo.
const SeccionFicha _seccionMaterialDeApoyo = SeccionFicha(
  clave: 'referencias',
  titulo: 'Material de apoyo',
);

/// Las 10 secciones de la ficha de medicamento, en el orden en que se muestran.
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
  _seccionMaterialDeApoyo,
];

/// Las 6 secciones de la pestaña "Ver más" de las escalas clínicas, en el orden
/// en que las pinta `EstructuraVerMasScreen`.
///
/// Los íconos que comparten significado con la ficha de medicamento comparten
/// también el ícono, a propósito: "¿Cuándo usarla?" es a una escala lo que
/// "Indicaciones" a un fármaco, y "Notas clínicas" lo que "Observaciones".
const List<SeccionFicha> seccionesFichaEscala = [
  SeccionFicha(
    clave: 'cuando_usarla',
    titulo: '¿Cuándo usarla?',
    icono: PhosphorIconsFill.checkCircle,
  ),
  SeccionFicha(
    clave: 'componentes',
    titulo: 'Componentes',
    icono: PhosphorIconsFill.slidersHorizontal,
  ),
  SeccionFicha(
    clave: 'interpretacion',
    titulo: 'Interpretación',
    icono: PhosphorIconsFill.gauge,
  ),
  // Es la sección que evita que una escala se malinterprete o se aplique donde
  // no corresponde: lo que hay que notar antes de confiar en un puntaje.
  //
  // Lleva `handPalm` y no un ícono de la familia de advertencia (`warning`,
  // `warningCircle`, `prohibit`) porque en la ficha de medicamento esos tres
  // marcan gravedad del daño, y una limitación no es un daño: es hasta dónde
  // llega la validez del instrumento.
  SeccionFicha(
    clave: 'limitaciones',
    titulo: 'Limitaciones',
    icono: PhosphorIconsFill.handPalm,
    nivel: NivelSeguridad.medio,
  ),
  _seccionNotasClinicas,
  _seccionMaterialDeApoyo,
];

/// Las 3 secciones de la pestaña "Información" de las calculadoras, en el orden
/// en que las pinta `InfoTab`.
///
/// Las tres van en `NivelSeguridad.ninguno` a propósito: ninguna habla de
/// riesgo. Una fórmula y sus notas de uso no son una contraindicación ni una
/// limitación, así que marcarlas con acento diluiría el significado que el
/// acento ya tiene en medicamentos y escalas, donde sí señala algo que hay que
/// notar antes de actuar. Aquí los íconos aportan navegabilidad y con eso basta.
const List<SeccionFicha> seccionesFichaCalculadora = [
  // `function` y no `mathOperations`: ese último ya identifica a la Calculadora
  // de dosis y al módulo completo, así que dentro de esa calculadora el
  // encabezado de pantalla y el de la sección se verían iguales.
  SeccionFicha(
    clave: 'formula',
    titulo: 'Fórmula',
    icono: PhosphorIconsFill.function,
  ),
  _seccionNotasClinicas,
  _seccionMaterialDeApoyo,
];

/// Busca una clave dentro de la lista de secciones que se le pase.
///
/// Recibe la lista para poder servir a todos los módulos: `seccionPorClave(
/// seccionesFichaEscala, 'limitaciones')`.
///
/// Lanza si la clave no existe: a diferencia del contenido clínico (que viene
/// de un JSON y puede traer erratas), estas claves están escritas en el código,
/// así que un fallo aquí es un error de programación que conviene ver de
/// inmediato y no un dato malo que haya que tolerar.
SeccionFicha seccionPorClave(List<SeccionFicha> secciones, String clave) {
  for (final seccion in secciones) {
    if (seccion.clave == clave) return seccion;
  }
  throw ArgumentError('Sección desconocida en la ficha: $clave');
}
