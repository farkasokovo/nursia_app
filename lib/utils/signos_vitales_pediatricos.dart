// lib/utils/signos_vitales_pediatricos.dart
//
// Tablas de referencia e interpretación de signos vitales pediátricos.
//
// ESTO NO ES EL EVAT. Las tablas vienen del material del EVAT (Escala de
// Valoración de Alerta Temprana, St. Jude Children's Research Hospital), pero
// el EVAT suma categorías para dar un puntaje y aquí NO se suma nada: cada
// signo vital se interpreta por separado contra el renglón que le toca por
// edad. El EVAT como escala de puntaje es otra pantalla.
//
// Por qué son `const` y no una tabla de SQLite: no cambian, no se muestran
// como contenido y nadie las edita desde la app. Una tabla con su DAO, su
// repositorio y su migración sería infraestructura sin beneficio. Como datos
// const se prueban sin base de datos, que es justo lo que esta lógica
// necesita: está llena de fronteras.
//
// Este archivo NO importa Flutter a propósito: es lógica pura y así las
// pruebas no dependen del árbol de widgets. El color de cada resultado lo
// decide la pantalla a partir de [NivelSigno].
//
// ── DOS CORRECCIONES A LA HOJA ORIGINAL ─────────────────────────────────
// La hoja de la que se transcribieron estas tablas trae dos errores. Están
// corregidos aquí y se documentan para que nadie los "restaure" al cotejar
// contra la fotografía:
//
//   1. Frecuencia respiratoria, 15 a 18 años: la hoja pone la taquipnea
//      moderada como "37-32", un rango descendente que además se encima con
//      la grave (≥32). Por coherencia con el renglón de 12 a 14 años debe ser
//      27 a 31, que es lo que está escrito abajo.
//   2. Frecuencia respiratoria, menor de 3 meses: la hoja pone bradipnea ≤30
//      y normal 30-56, con el 30 en las dos categorías. Por coherencia con
//      los renglones siguientes lo normal empieza en 31.
//
// `test/signos_vitales_pediatricos_test.dart` recorre las tablas y falla si
// aparece un hueco o un traslape, que es la red contra un error de
// transcripción nuevo.

/// Unidad en la que se captura la edad.
enum UnidadEdad { anios, meses }

/// Peso clínico del resultado de un signo vital. La pantalla lo traduce a un
/// color; aquí solo se nombra la gravedad.
enum NivelSigno {
  /// Dentro de lo esperado para la edad.
  normal,

  /// Por debajo del rango normal. Cubre la bradicardia y la bradipnea, y
  /// también los valores que caen en una zona que la tabla no clasifica.
  bajo,

  leve,
  moderada,
  grave,

  /// No se puede interpretar: falta la edad, o la edad queda fuera de lo que
  /// cubren estas tablas.
  noValorable,
}

/// Lo que la pantalla pinta en la pastilla de un panel.
class ResultadoSigno {
  final String etiqueta;
  final NivelSigno nivel;

  const ResultadoSigno(this.etiqueta, this.nivel);
}

// ── Límites de captura ──────────────────────────────────────────────────
//
// El maxLength del campo no alcanza como validación: tres dígitos admiten una
// saturación de 999. Estos son los rangos que la pantalla acepta, y viven
// aquí para que la pantalla y las pruebas usen los mismos números.

const int edadMaximaMeses = 227;
const int edadMaximaAnios = 18;
const int frecuenciaCardiacaMin = 20;
const int frecuenciaCardiacaMax = 300;
const int frecuenciaRespiratoriaMin = 5;
const int frecuenciaRespiratoriaMax = 99;
const int sistolicaMin = 30;
const int sistolicaMax = 300;
const int diastolicaMin = 10;
const int diastolicaMax = 200;
const double temperaturaMin = 25.0;
const double temperaturaMax = 45.0;
const int saturacionMin = 0;
const int saturacionMax = 100;

/// Convierte la edad capturada a meses, que es la unidad en la que se busca en
/// todas las tablas.
int aMeses(int valor, UnidadEdad unidad) =>
    unidad == UnidadEdad.anios ? valor * 12 : valor;

// ── Frecuencia cardiaca y respiratoria ──────────────────────────────────

/// Un renglón de la tabla de frecuencia cardiaca o respiratoria.
///
/// Las categorías son contiguas por construcción: lo normal empieza en
/// [bajoMax] + 1, la leve en [normalMax] + 1, la moderada en [leveMax] + 1 y
/// la grave en [moderadaMax] + 1. Así no hay huecos ni traslapes.
class RangoFrecuencia {
  final int mesesMin;
  final int mesesMax;

  /// Igual o menor que esto es bradicardia o bradipnea.
  final int bajoMax;

  final int normalMax;
  final int leveMax;

  /// Por encima de esto es grave.
  final int moderadaMax;

  const RangoFrecuencia(
    this.mesesMin,
    this.mesesMax,
    this.bajoMax,
    this.normalMax,
    this.leveMax,
    this.moderadaMax,
  );

  bool cubre(int meses) => meses >= mesesMin && meses <= mesesMax;
}

/// Frecuencia cardiaca en latidos por minuto.
const List<RangoFrecuencia> tablaFrecuenciaCardiaca = [
  RangoFrecuencia(0, 2, 80, 164, 171, 186),
  RangoFrecuencia(3, 5, 80, 159, 167, 182),
  RangoFrecuencia(6, 8, 75, 156, 163, 178),
  RangoFrecuencia(9, 11, 75, 153, 160, 176),
  RangoFrecuencia(12, 17, 75, 149, 157, 173),
  RangoFrecuencia(18, 23, 75, 146, 154, 170),
  RangoFrecuencia(24, 35, 60, 142, 150, 167),
  RangoFrecuencia(36, 47, 60, 138, 146, 164),
  RangoFrecuencia(48, 71, 60, 134, 142, 161),
  RangoFrecuencia(72, 95, 60, 128, 137, 155),
  RangoFrecuencia(96, 143, 60, 120, 129, 147),
  RangoFrecuencia(144, 179, 50, 112, 121, 138),
  RangoFrecuencia(180, 227, 50, 107, 115, 132),
];

/// Frecuencia respiratoria en respiraciones por minuto.
const List<RangoFrecuencia> tablaFrecuenciaRespiratoria = [
  RangoFrecuencia(0, 2, 30, 56, 62, 76),
  RangoFrecuencia(3, 5, 26, 52, 58, 71),
  RangoFrecuencia(6, 8, 24, 49, 54, 67),
  RangoFrecuencia(9, 11, 22, 46, 51, 63),
  RangoFrecuencia(12, 17, 21, 43, 48, 60),
  RangoFrecuencia(18, 23, 20, 40, 45, 57),
  RangoFrecuencia(24, 35, 19, 37, 42, 54),
  RangoFrecuencia(36, 47, 18, 35, 40, 52),
  RangoFrecuencia(48, 71, 17, 33, 37, 50),
  RangoFrecuencia(72, 95, 15, 31, 35, 46),
  RangoFrecuencia(96, 143, 14, 28, 31, 41),
  RangoFrecuencia(144, 179, 12, 25, 28, 35),
  RangoFrecuencia(180, 227, 12, 23, 26, 31),
];

/// Texto que se muestra cuando la edad queda fuera de lo que cubren las
/// tablas. No se devuelve el renglón más cercano: un dato de otra edad es
/// peor que no dar dato.
const String _fueraDeRango =
    'Edad fuera del rango de esta escala. Se sugiere la escala de adultos';

/// Texto que se muestra cuando el signo depende de la edad y no se capturó.
const String _faltaEdad = 'Se requiere la edad para interpretar este signo';

RangoFrecuencia? _buscarFrecuencia(List<RangoFrecuencia> tabla, int meses) {
  for (final rango in tabla) {
    if (rango.cubre(meses)) return rango;
  }
  return null;
}

ResultadoSigno _interpretarFrecuencia(
  List<RangoFrecuencia> tabla,
  int valor,
  int? meses,
  String etiquetaBaja,
  String etiquetaAlta,
) {
  if (meses == null) {
    return const ResultadoSigno(_faltaEdad, NivelSigno.noValorable);
  }
  final rango = _buscarFrecuencia(tabla, meses);
  if (rango == null) {
    return const ResultadoSigno(_fueraDeRango, NivelSigno.noValorable);
  }
  if (valor <= rango.bajoMax) {
    return ResultadoSigno(etiquetaBaja, NivelSigno.bajo);
  }
  if (valor <= rango.normalMax) {
    return const ResultadoSigno('Normal', NivelSigno.normal);
  }
  if (valor <= rango.leveMax) {
    return ResultadoSigno('$etiquetaAlta leve', NivelSigno.leve);
  }
  if (valor <= rango.moderadaMax) {
    return ResultadoSigno('$etiquetaAlta moderada', NivelSigno.moderada);
  }
  return ResultadoSigno('$etiquetaAlta grave', NivelSigno.grave);
}

ResultadoSigno interpretarFrecuenciaCardiaca(int lpm, int? meses) =>
    _interpretarFrecuencia(
      tablaFrecuenciaCardiaca,
      lpm,
      meses,
      'Bradicardia',
      'Taquicardia',
    );

ResultadoSigno interpretarFrecuenciaRespiratoria(int rpm, int? meses) =>
    _interpretarFrecuencia(
      tablaFrecuenciaRespiratoria,
      rpm,
      meses,
      'Bradipnea',
      'Taquipnea',
    );

// ── Presión arterial ────────────────────────────────────────────────────

/// Un renglón de la tabla de presión arterial.
///
/// Los rangos de edad NO son los mismos que los de frecuencia cardiaca y
/// respiratoria: esta tabla tiene su propio corte y llega solo hasta los 17
/// años cumplidos (215 meses), mientras que las otras dos llegan a 18.
///
/// La tabla es asimétrica a propósito, así viene en la fuente:
///
///   - La hipotensión es SOLO sistólica. La diastólica no tiene criterio de
///     hipotensión, así que una diastólica baja se reporta como por debajo de
///     lo normal y no se le pone ese nombre.
///   - Entre la hipotensión sistólica y el inicio de lo normal hay un hueco en
///     todos los renglones (en el de menor de 1 mes, de 66 a 74). Un valor que
///     caiga ahí se reporta como por debajo de lo normal, sin redondear hacia
///     ninguno de los dos lados.
///   - La hipertensión viene como un par, por ejemplo 100/70. Se trata como
///     dos umbrales independientes para poder reportar cada componente por su
///     cuenta.
class RangoPresion {
  final int mesesMin;
  final int mesesMax;

  /// Igual o menor que esto es hipotensión sistólica.
  final int hipotensionSistolicaMax;

  final int sistolicaNormalMin;
  final int sistolicaNormalMax;
  final int diastolicaNormalMin;
  final int diastolicaNormalMax;

  /// Igual o mayor que esto es hipertensión en ese componente.
  final int hipertensionSistolica;
  final int hipertensionDiastolica;

  const RangoPresion(
    this.mesesMin,
    this.mesesMax,
    this.hipotensionSistolicaMax,
    this.sistolicaNormalMin,
    this.sistolicaNormalMax,
    this.diastolicaNormalMin,
    this.diastolicaNormalMax,
    this.hipertensionSistolica,
    this.hipertensionDiastolica,
  );

  bool cubre(int meses) => meses >= mesesMin && meses <= mesesMax;
}

const List<RangoPresion> tablaPresionArterial = [
  RangoPresion(0, 0, 65, 75, 99, 37, 69, 100, 70),
  RangoPresion(1, 6, 70, 78, 104, 38, 64, 105, 65),
  RangoPresion(7, 11, 70, 84, 109, 38, 69, 110, 70),
  RangoPresion(12, 23, 72, 86, 101, 40, 56, 102, 57),
  RangoPresion(24, 35, 74, 88, 105, 45, 60, 106, 61),
  RangoPresion(36, 47, 76, 89, 106, 49, 64, 107, 65),
  RangoPresion(48, 59, 78, 91, 108, 52, 67, 109, 68),
  RangoPresion(60, 71, 80, 93, 109, 54, 70, 110, 71),
  RangoPresion(72, 83, 82, 94, 111, 56, 73, 112, 74),
  RangoPresion(84, 95, 84, 96, 112, 57, 75, 113, 76),
  RangoPresion(96, 107, 86, 98, 113, 58, 76, 114, 77),
  RangoPresion(108, 119, 88, 100, 115, 59, 78, 116, 79),
  RangoPresion(120, 131, 90, 102, 116, 60, 79, 117, 80),
  RangoPresion(132, 143, 90, 103, 120, 61, 79, 121, 80),
  RangoPresion(144, 155, 90, 105, 122, 62, 80, 123, 81),
  RangoPresion(156, 167, 90, 107, 125, 63, 81, 126, 82),
  RangoPresion(168, 179, 90, 109, 127, 64, 81, 128, 82),
  RangoPresion(180, 191, 90, 110, 130, 65, 82, 131, 83),
  RangoPresion(192, 203, 90, 111, 133, 66, 84, 134, 85),
  RangoPresion(204, 215, 90, 111, 135, 66, 86, 136, 87),
];

RangoPresion? _buscarPresion(int meses) {
  for (final rango in tablaPresionArterial) {
    if (rango.cubre(meses)) return rango;
  }
  return null;
}

/// Resultado de UN componente de la presión arterial.
class _Componente {
  final String texto;
  final NivelSigno nivel;

  const _Componente(this.texto, this.nivel);
}

_Componente _sistolica(int valor, RangoPresion rango) {
  if (valor <= rango.hipotensionSistolicaMax) {
    return const _Componente('hipotensión sistólica', NivelSigno.grave);
  }
  if (valor < rango.sistolicaNormalMin) {
    // La zona muerta de la tabla: por debajo de lo normal, sin alcanzar el
    // criterio de hipotensión.
    return const _Componente(
      'sistólica por debajo de lo normal',
      NivelSigno.bajo,
    );
  }
  if (valor <= rango.sistolicaNormalMax) {
    return const _Componente('sistólica normal', NivelSigno.normal);
  }
  return const _Componente('hipertensión sistólica', NivelSigno.moderada);
}

_Componente _diastolica(int valor, RangoPresion rango) {
  if (valor < rango.diastolicaNormalMin) {
    // La tabla no define hipotensión diastólica, así que no se le pone ese
    // nombre a un valor bajo.
    return const _Componente(
      'diastólica por debajo de lo normal',
      NivelSigno.bajo,
    );
  }
  if (valor <= rango.diastolicaNormalMax) {
    return const _Componente('diastólica normal', NivelSigno.normal);
  }
  return const _Componente('hipertensión diastólica', NivelSigno.moderada);
}

/// Interpreta la presión arterial. Cualquiera de los dos componentes puede
/// venir en null: se interpreta el que haya.
ResultadoSigno interpretarPresionArterial({
  int? sistolica,
  int? diastolica,
  int? meses,
}) {
  if (meses == null) {
    return const ResultadoSigno(_faltaEdad, NivelSigno.noValorable);
  }
  final rango = _buscarPresion(meses);
  if (rango == null) {
    return const ResultadoSigno(_fueraDeRango, NivelSigno.noValorable);
  }

  final partes = <_Componente>[
    if (sistolica != null) _sistolica(sistolica, rango),
    if (diastolica != null) _diastolica(diastolica, rango),
  ];
  if (partes.isEmpty) {
    return const ResultadoSigno(_faltaEdad, NivelSigno.noValorable);
  }

  // Las dos se nombran cuando se capturaron las dos. Entre los dos niveles
  // manda el más grave: es el que decide el color de la pastilla.
  final texto = partes.map((p) => p.texto).join(', ');
  final nivel = partes
      .map((p) => p.nivel)
      .reduce((a, b) => a.index > b.index ? a : b);

  return ResultadoSigno(texto[0].toUpperCase() + texto.substring(1), nivel);
}

// ── Saturación de oxígeno ───────────────────────────────────────────────
//
// No depende de la edad.

ResultadoSigno interpretarSaturacion(int porcentaje) {
  if (porcentaje >= 95) {
    return const ResultadoSigno('Normal', NivelSigno.normal);
  }
  if (porcentaje >= 90) {
    return const ResultadoSigno('Desaturación leve', NivelSigno.leve);
  }
  if (porcentaje >= 85) {
    return const ResultadoSigno('Desaturación moderada', NivelSigno.moderada);
  }
  return const ResultadoSigno('Desaturación severa', NivelSigno.grave);
}

// ── Temperatura ─────────────────────────────────────────────────────────
//
// No viene en la hoja del EVAT. Los cortes son AXILARES, que es la vía de uso
// común en piso, y NO dependen de la edad:
//
//   - Fiebre, axilar por arriba de 37.5 °C: Guía de Práctica Clínica del IMSS
//     "Diagnóstico y tratamiento de la fiebre sin signos de focalización en
//     los niños de 3 meses hasta los 5 años de edad" (GER 350), apartado 3.3.
//     Es el único corte de la fuente que nombra la vía de forma explícita.
//   - Febrícula por debajo de 38 °C: clasificación por magnitud de "Fiebre en
//     pediatría" (Pediatría de México, 2010). Combinada con el corte anterior,
//     la febrícula ocupa de 37.6 a 37.9.
//
// NO se usa el criterio de fiebre en neutropenia, aunque la hoja venga de un
// servicio oncológico: ese es otro contexto y vive en la ficha "Hora Dorada"
// de Esenciales.
//
// El límite inferior de lo normal se toma del Cuadro 2 de esa misma GPC
// (36.0 °C). Por debajo de ahí el resultado se nombra "Por debajo del rango
// normal" y NO "hipotermia": no se encontró un corte de hipotermia axilar
// para población pediátrica general en una fuente citable, y ponerle nombre a
// un criterio que no se verificó sería inventarlo.

const double temperaturaNormalMin = 36.0;
const double temperaturaFiebreMin = 38.0;

/// Por arriba de esto ya no es normal. La febrícula ocupa el hueco entre este
/// valor y [temperaturaFiebreMin].
const double temperaturaNormalMax = 37.5;

ResultadoSigno interpretarTemperatura(double grados) {
  if (grados < temperaturaNormalMin) {
    return const ResultadoSigno('Por debajo del rango normal', NivelSigno.bajo);
  }
  if (grados <= temperaturaNormalMax) {
    return const ResultadoSigno('Normal', NivelSigno.normal);
  }
  if (grados < temperaturaFiebreMin) {
    return const ResultadoSigno('Febrícula', NivelSigno.leve);
  }
  return const ResultadoSigno('Fiebre', NivelSigno.moderada);
}
