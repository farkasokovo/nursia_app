// lib/utils/signos_vitales_adulto.dart
//
// Interpretación de signos vitales del adulto. Mismo contrato que
// utils/signos_vitales_pediatricos.dart (se reusan NivelSigno y
// ResultadoSigno), pero SIN edad: en el adulto los cortes no cambian por
// grupo de edad.
//
// Lógica pura, sin Flutter, para probarla sin árbol de widgets. El color lo
// decide la pantalla a partir de [NivelSigno].
//
// ── FUENTES ─────────────────────────────────────────────────────────────
//
//   - Presión arterial: NOM-030-SSA2-2009, apartado 6.1 (clasificación y
//     criterios diagnósticos). Es la norma que rige en México; la AHA/ACC y la
//     ESC usan otros cortes y NO se mencionan en la pestaña de Información
//     (decisión de Diego).
//   - La NOM-030 NO define hipotensión. El corte de hipotensión (sistólica
//     ≤90) viene de NEWS2, que es la misma fuente del resto de los signos.
//   - Frecuencia cardiaca (salvo su rango normal, ver abajo), frecuencia
//     respiratoria, temperatura y saturación: NEWS2 (Royal College of Physicians, 2017). Cada signo se interpreta por
//     separado y NO se suma ningún puntaje: el puntaje de NEWS2 de cada
//     parámetro (0 a 3) se traduce a nivel de gravedad así:
//       0 → normal · 1 → leve · 2 → moderada · 3 → grave
//     Los NOMBRES de las categorías (bradicardia, fiebre elevada, etc.) son
//     nuestros; NEWS2 solo da los cortes y el puntaje.
//   - Saturación en EPOC: escala 2 de SpO2 de NEWS2, para pacientes con
//     insuficiencia respiratoria hipercápnica y meta de 88 a 92%.
//
// ── POR QUÉ LA PRESIÓN NO SIGUE EL PUNTAJE DE NEWS2 ──────────────────────
// NEWS2 puntúa una sistólica de 91 a 110 como anormal, mientras que para la
// NOM-030 eso es presión óptima. Mezclar ambos criterios daría resultados
// contradictorios, así que del lado bajo SOLO se toma el corte de hipotensión
// de NEWS2 y todo lo demás lo clasifica la NOM.
//
// `test/signos_vitales_adulto_test.dart` recorre las fronteras de cada corte.

import 'signos_vitales_pediatricos.dart' show NivelSigno, ResultadoSigno;

// Los límites de captura (frecuenciaCardiacaMin, sistolicaMax, etc.) son los
// mismos que en pediatría y viven en signos_vitales_pediatricos.dart. No se
// duplican aquí.

// ── Frecuencia cardiaca (NEWS2) ─────────────────────────────────────────
//
// Todos los cortes de este archivo son constantes para que las tablas de la
// pestaña "Información" lean los mismos números que las funciones. Cada uno
// es el límite SUPERIOR, inclusivo, de su categoría.

// El rango NORMAL no es el de NEWS2 (51 a 90): es 50 a 100, la definición
// de la guía ACC/AHA/HRS 2018 de bradicardia (bradicardia <50) y el límite
// de taquicardia (>100) de uso general. Decisión de Diego. Fuera de ese
// rango la gravedad sí sigue los cortes de NEWS2 (40, 110, 130).
const int fcBradicardiaGraveMaxAdulto = 40;
const int fcBradicardiaLeveMaxAdulto = 49;
const int fcNormalMaxAdulto = 100;
const int fcTaquicardiaLeveMaxAdulto = 110;
const int fcTaquicardiaModeradaMaxAdulto = 130;

ResultadoSigno interpretarFrecuenciaCardiacaAdulto(int lpm) {
  if (lpm <= fcBradicardiaGraveMaxAdulto) {
    return const ResultadoSigno('Bradicardia grave', NivelSigno.grave);
  }
  if (lpm <= fcBradicardiaLeveMaxAdulto) {
    return const ResultadoSigno('Bradicardia leve', NivelSigno.leve);
  }
  if (lpm <= fcNormalMaxAdulto) {
    return const ResultadoSigno('Normal', NivelSigno.normal);
  }
  if (lpm <= fcTaquicardiaLeveMaxAdulto) {
    return const ResultadoSigno('Taquicardia leve', NivelSigno.leve);
  }
  if (lpm <= fcTaquicardiaModeradaMaxAdulto) {
    return const ResultadoSigno('Taquicardia moderada', NivelSigno.moderada);
  }
  return const ResultadoSigno('Taquicardia grave', NivelSigno.grave);
}

// ── Frecuencia respiratoria (NEWS2) ─────────────────────────────────────
// NEWS2 no tiene categoría de puntaje 1 del lado alto: de lo normal (12 a 20)
// salta directo a 2 (21 a 24). Por eso no existe "taquipnea leve".

const int frBradipneaGraveMaxAdulto = 8;
const int frBradipneaLeveMaxAdulto = 11;
const int frNormalMaxAdulto = 20;
const int frTaquipneaModeradaMaxAdulto = 24;

ResultadoSigno interpretarFrecuenciaRespiratoriaAdulto(int rpm) {
  if (rpm <= frBradipneaGraveMaxAdulto) {
    return const ResultadoSigno('Bradipnea grave', NivelSigno.grave);
  }
  if (rpm <= frBradipneaLeveMaxAdulto) {
    return const ResultadoSigno('Bradipnea leve', NivelSigno.leve);
  }
  if (rpm <= frNormalMaxAdulto) {
    return const ResultadoSigno('Normal', NivelSigno.normal);
  }
  if (rpm <= frTaquipneaModeradaMaxAdulto) {
    return const ResultadoSigno('Taquipnea moderada', NivelSigno.moderada);
  }
  return const ResultadoSigno('Taquipnea grave', NivelSigno.grave);
}

// ── Temperatura (NEWS2) ─────────────────────────────────────────────────
// NEWS2 no fija la vía de medición. Los cortes se aplican tal cual al valor
// capturado; la pestaña de Información advierte que la axilar suele leer más
// bajo que la central.

const double temperaturaHipotermiaMaxAdulto = 35.0;
const double temperaturaNormalMinAdulto = 36.1;
const double temperaturaNormalMaxAdulto = 38.0;
const double temperaturaFiebreLeveMaxAdulto = 39.0;

ResultadoSigno interpretarTemperaturaAdulto(double grados) {
  if (grados <= temperaturaHipotermiaMaxAdulto) {
    return const ResultadoSigno('Hipotermia', NivelSigno.grave);
  }
  if (grados < temperaturaNormalMinAdulto) {
    return const ResultadoSigno('Por debajo del rango normal', NivelSigno.leve);
  }
  if (grados <= temperaturaNormalMaxAdulto) {
    return const ResultadoSigno('Normal', NivelSigno.normal);
  }
  if (grados <= temperaturaFiebreLeveMaxAdulto) {
    return const ResultadoSigno('Fiebre', NivelSigno.leve);
  }
  return const ResultadoSigno('Fiebre elevada', NivelSigno.moderada);
}

// ── Saturación de oxígeno (NEWS2, escalas 1 y 2) ────────────────────────

// Escala 1 (general): límites INFERIORES, inclusivos.
const int spo2NormalMinAdulto = 96;
const int spo2LeveMinAdulto = 94;
const int spo2ModeradaMinAdulto = 92;

// Escala 2 (EPOC): límites SUPERIORES, inclusivos.
const int spo2EpocGraveMax = 83;
const int spo2EpocModeradaMax = 85;
const int spo2EpocLeveMax = 87;
const int spo2EpocMetaMax = 92;

/// Con oxígeno, por arriba de la meta: hasta aquí es leve.
const int spo2EpocArribaLeveMax = 94;

/// Con oxígeno, por arriba de la meta: hasta aquí es moderada; más, grave.
const int spo2EpocArribaModeradaMax = 96;

/// Meta de saturación en EPOC, para los textos de la pantalla y del resultado.
const String metaEpocTexto = '${spo2EpocLeveMax + 1} a $spo2EpocMetaMax%';

/// [epoc] activa la escala 2 de NEWS2 (meta 88 a 92%). Solo en esa escala
/// importa [conOxigeno]: una saturación de 93% o más es normal al aire
/// ambiente, pero con oxígeno suplementario se considera por arriba de la
/// meta, por el riesgo de hipercapnia. Con [epoc] en false, [conOxigeno] se
/// ignora.
ResultadoSigno interpretarSaturacionAdulto(
  int porcentaje, {
  bool epoc = false,
  bool conOxigeno = false,
}) {
  if (!epoc) {
    if (porcentaje >= spo2NormalMinAdulto) {
      return const ResultadoSigno('Normal', NivelSigno.normal);
    }
    if (porcentaje >= spo2LeveMinAdulto) {
      return const ResultadoSigno('Desaturación leve', NivelSigno.leve);
    }
    if (porcentaje >= spo2ModeradaMinAdulto) {
      return const ResultadoSigno('Desaturación moderada', NivelSigno.moderada);
    }
    return const ResultadoSigno('Desaturación severa', NivelSigno.grave);
  }

  if (porcentaje <= spo2EpocGraveMax) {
    return const ResultadoSigno('Desaturación severa', NivelSigno.grave);
  }
  if (porcentaje <= spo2EpocModeradaMax) {
    return const ResultadoSigno('Desaturación moderada', NivelSigno.moderada);
  }
  if (porcentaje <= spo2EpocLeveMax) {
    return const ResultadoSigno('Desaturación leve', NivelSigno.leve);
  }
  if (porcentaje <= spo2EpocMetaMax) {
    return const ResultadoSigno('En meta ($metaEpocTexto)', NivelSigno.normal);
  }
  if (!conOxigeno) return const ResultadoSigno('Normal', NivelSigno.normal);
  if (porcentaje <= spo2EpocArribaLeveMax) {
    return const ResultadoSigno('Por arriba de la meta', NivelSigno.leve);
  }
  if (porcentaje <= spo2EpocArribaModeradaMax) {
    return const ResultadoSigno('Por arriba de la meta', NivelSigno.moderada);
  }
  return const ResultadoSigno('Por arriba de la meta', NivelSigno.grave);
}

// ── Presión arterial (NOM-030-SSA2-2009 + hipotensión de NEWS2) ─────────

/// Igual o menor que esto es hipotensión (NEWS2). La NOM-030 no la define.
const int hipotensionSistolicaMaxAdulto = 90;

/// Categorías de la NOM-030, en orden de gravedad. El orden importa: la NOM
/// manda clasificar con el componente más alto cuando sistólica y diastólica
/// caen en etapas distintas, y aquí "más alto" es el índice mayor.
enum CategoriaPresion {
  optima('Presión óptima', NivelSigno.normal),
  normal('Presión normal', NivelSigno.normal),
  fronteriza('Presión fronteriza', NivelSigno.leve),
  hipertension1('Hipertensión etapa 1', NivelSigno.moderada),
  hipertension2('Hipertensión etapa 2', NivelSigno.grave),
  hipertension3('Hipertensión etapa 3', NivelSigno.grave);

  final String etiqueta;
  final NivelSigno nivel;

  const CategoriaPresion(this.etiqueta, this.nivel);
}

/// Límite inferior de cada categoría, en el mismo orden que
/// [CategoriaPresion]. La óptima no tiene límite inferior (0).
///
/// La NOM escribe la etapa 3 como ">180 / >110", pero la etapa 2 termina en
/// 179/109, así que 180 y 110 tienen que ser etapa 3 o quedarían sin
/// categoría.
const List<int> limitesSistolica = [0, 120, 130, 140, 160, 180];
const List<int> limitesDiastolica = [0, 80, 85, 90, 100, 110];

CategoriaPresion _categoria(int valor, List<int> limites) {
  var i = 0;
  while (i + 1 < limites.length && valor >= limites[i + 1]) {
    i++;
  }
  return CategoriaPresion.values[i];
}

CategoriaPresion categoriaSistolica(int mmHg) =>
    _categoria(mmHg, limitesSistolica);

CategoriaPresion categoriaDiastolica(int mmHg) =>
    _categoria(mmHg, limitesDiastolica);

/// Interpreta la presión arterial. Cualquiera de los dos componentes puede
/// venir en null: se interpreta el que haya.
///
/// Devuelve null si no se capturó ninguno; la pantalla decide qué mostrar.
ResultadoSigno? interpretarPresionArterialAdulto({
  int? sistolica,
  int? diastolica,
}) {
  if (sistolica == null && diastolica == null) return null;

  // La hipotensión manda sobre todo lo demás: una sistólica de 85 con una
  // diastólica de 95 no es "hipertensión etapa 1".
  if (sistolica != null && sistolica <= hipotensionSistolicaMaxAdulto) {
    return const ResultadoSigno('Hipotensión', NivelSigno.grave);
  }

  final s = sistolica == null ? null : categoriaSistolica(sistolica);
  final d = diastolica == null ? null : categoriaDiastolica(diastolica);

  // Hipertensión sistólica aislada (NOM-030): sistólica ≥140 con diastólica
  // <90. Solo se puede afirmar si se capturaron las dos. La gravedad la
  // marca la etapa de la sistólica.
  if (s != null &&
      d != null &&
      s.index >= CategoriaPresion.hipertension1.index &&
      d.index < CategoriaPresion.hipertension1.index) {
    return ResultadoSigno('Hipertensión sistólica aislada', s.nivel);
  }

  final mayor = [
    s,
    d,
  ].whereType<CategoriaPresion>().reduce((a, b) => a.index >= b.index ? a : b);
  return ResultadoSigno(mayor.etiqueta, mayor.nivel);
}
